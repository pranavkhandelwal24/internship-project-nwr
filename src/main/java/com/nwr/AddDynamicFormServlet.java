package com.nwr;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/add-dynamic-form")
public class AddDynamicFormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"member".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        ServletContext context = getServletContext();
        String dbUrl = String.valueOf(context.getAttribute("db_url"));
        String dbUsername = String.valueOf(context.getAttribute("db_username"));
        String dbPassword = String.valueOf(context.getAttribute("db_password"));

        int registerId = -1;
        int submittedByUserId = -1;
        String redirectUrl = request.getContextPath() + "/dynamic-form"; // Default redirect URL
        String message = "";
        boolean submissionSuccessful = false;

        Connection conn = null;
        // Store submitted form data for re-population on error
        Map<String, String> formData = new HashMap<>();

        try {
            String registerIdParam = request.getParameter("registerId");
            String submittedByParam = request.getParameter("submittedBy");

            if (registerIdParam == null || registerIdParam.isEmpty() ||
                submittedByParam == null || submittedByParam.isEmpty()) {
                throw new IllegalArgumentException("Missing register ID or submitted by user ID.");
            }

            registerId = Integer.parseInt(registerIdParam);
            submittedByUserId = Integer.parseInt(submittedByParam);

            redirectUrl += "?registerId=" + registerId;

            // Populate formData map with all submitted parameters for re-population on error
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String name = paramNames.nextElement();
                // Exclude system parameters from formData if needed, or include them and let JSP filter
                formData.put(name, request.getParameter(name));
            }
            request.setAttribute("formData", formData); // Set immediately for error path

            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            conn.setAutoCommit(false); // Start transaction

            // --- Fetch Column Metadata for Validation (Type, Required, Unique) ---
            Map<String, Map<String, Object>> columnMetadata = new HashMap<>(); // field_name -> {column_id, data_type, is_required, is_unique}
            
            String getColumnsMetaSql = "SELECT column_id, field_name, data_type, is_required, is_unique FROM register_columns WHERE register_id = ?";
            try (PreparedStatement metaStmt = conn.prepareStatement(getColumnsMetaSql)) {
                metaStmt.setInt(1, registerId);
                ResultSet metaRs = metaStmt.executeQuery();
                while (metaRs.next()) {
                    Map<String, Object> meta = new HashMap<>();
                    meta.put("column_id", metaRs.getInt("column_id"));
                    meta.put("data_type", metaRs.getString("data_type"));
                    meta.put("is_required", metaRs.getBoolean("is_required"));
                    meta.put("is_unique", metaRs.getBoolean("is_unique"));
                    columnMetadata.put(metaRs.getString("field_name"), meta);
                }
            }

            List<String> validationErrors = new ArrayList<>();
            List<String> uniqueViolations = new ArrayList<>();

            // --- Server-Side Validation Loop (Required, Data Type, Unique) ---
            for (Map.Entry<String, Map<String, Object>> entry : columnMetadata.entrySet()) {
                String fieldName = entry.getKey();
                Map<String, Object> meta = entry.getValue();

                int columnId = (int) meta.get("column_id");
                String dataType = (String) meta.get("data_type");
                boolean isRequired = (boolean) meta.get("is_required");
                boolean isUnique = (boolean) meta.get("is_unique");
                
                String submittedValue = request.getParameter(fieldName);
                if (submittedValue == null) {
                    submittedValue = ""; // Treat null parameters as empty string for consistent handling
                } else {
                    submittedValue = submittedValue.trim();
                }

                // 1. Required Field Validation
                if (isRequired && submittedValue.isEmpty()) {
                    validationErrors.add("Field '" + fieldName + "' is required.");
                }

                // 2. Data Type Validation (if not empty)
                if (!submittedValue.isEmpty()) {
                    switch (dataType.toLowerCase()) {
                        case "number": // Integer
                            try {
                                Integer.parseInt(submittedValue);
                            } catch (NumberFormatException e) {
                                validationErrors.add("Field '" + fieldName + "' must be a whole number.");
                            }
                            break;
                        case "decimal": // Double/Float
                            try {
                                Double.parseDouble(submittedValue);
                            } catch (NumberFormatException e) {
                                validationErrors.add("Field '" + fieldName + "' must be a decimal number.");
                            }
                            break;
                        case "date":
                            // Simple regex for YYYY-MM-DD. More robust validation might use SimpleDateFormat.
                            if (!submittedValue.matches("\\d{4}-\\d{2}-\\d{2}")) {
                                validationErrors.add("Field '" + fieldName + "' must be a valid date (YYYY-MM-DD).");
                            }
                            break;
                        // Add more data types if needed (e.g., email, URL with regex)
                        default:
                            // For 'text', 'enum', etc., no specific format validation beyond being a string
                            break;
                    }
                }
                
                // 3. Unique Constraint Validation
                if (isUnique && !submittedValue.isEmpty()) {
                    String checkUniqueSql = "SELECT COUNT(rev.value) " +
                                            "FROM register_entry_values rev " +
                                            "JOIN register_entries_dynamic red ON rev.entry_id = red.entry_id " +
                                            "WHERE rev.column_id = ? AND rev.value = ? AND red.register_id = ?";

                    try (PreparedStatement checkStmt = conn.prepareStatement(checkUniqueSql)) {
                        checkStmt.setInt(1, columnId);
                        checkStmt.setString(2, submittedValue);
                        checkStmt.setInt(3, registerId);
                        ResultSet uniqueRs = checkStmt.executeQuery();
                        if (uniqueRs.next() && uniqueRs.getInt(1) > 0) {
                            uniqueViolations.add("The value '" + submittedValue + "' for '" + fieldName + "' already exists in this register.");
                        }
                    }
                }
            } // End of server-side validation loop

            // If any validation or unique violations found, handle as an error (forward with data)
            if (!validationErrors.isEmpty() || !uniqueViolations.isEmpty()) {
                message = "Submission failed:";
                if (!validationErrors.isEmpty()) {
                    message += " Validation errors: " + String.join(" ", validationErrors) + ".";
                }
                if (!uniqueViolations.isEmpty()) {
                    message += " Unique constraint violations: " + String.join(" ", uniqueViolations) + ".";
                }
                conn.rollback(); // Rollback the transaction
                request.setAttribute("formErrorMessage", message);
                request.setAttribute("registerId", String.valueOf(registerId)); // Pass registerId back
                // formData is already set above
                request.getRequestDispatcher("/dynamic-form.jsp").forward(request, response);
                return; // Stop further processing
            }

            // --- If validation passes, proceed with database insertion ---

            // 1. Insert into register_entries_dynamic table
            String insertEntrySql = "INSERT INTO register_entries_dynamic (register_id, submitted_by, submitted_at) VALUES (?, ?, NOW())";
            long newEntryId = -1;

            try (PreparedStatement stmt = conn.prepareStatement(insertEntrySql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, registerId);
                stmt.setInt(2, submittedByUserId);
                int affectedRows = stmt.executeUpdate();

                if (affectedRows == 0) {
                    throw new SQLException("Creating entry failed, no rows affected.");
                }

                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        newEntryId = generatedKeys.getLong(1);
                    } else {
                        throw new SQLException("Creating entry failed, no ID obtained.");
                    }
                }
            }

            // 2. Insert dynamic field values into register_entry_values
            String insertValueSql = "INSERT INTO register_entry_values (entry_id, column_id, value) VALUES (?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertValueSql)) {
                // Iterate through the collected columnMetadata to ensure all defined columns are handled
                for (Map.Entry<String, Map<String, Object>> entry : columnMetadata.entrySet()) {
                    String fieldName = entry.getKey();
                    int columnId = (int) entry.getValue().get("column_id");
                    
                    String paramValue = request.getParameter(fieldName);
                    if (paramValue == null) {
                        paramValue = ""; // Ensure empty string for null parameters
                    } else {
                        paramValue = paramValue.trim();
                    }

                    stmt.setLong(1, newEntryId);
                    stmt.setInt(2, columnId);
                    stmt.setString(3, paramValue); // Always set as String in PreparedStatement
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            conn.commit(); // Commit transaction
            submissionSuccessful = true;
            message = "Entry submitted successfully!";

        } catch (IllegalArgumentException e) {
            message = "Input error: " + e.getMessage();
            System.err.println("AddDynamicFormServlet: " + message);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rbEx) { System.err.println("Rollback failed: " + rbEx.getMessage()); }
            }
        } catch (SQLException e) {
            message = "Database error: " + e.getMessage();
            System.err.println("AddDynamicFormServlet: " + message);
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rbEx) { System.err.println("Rollback failed: " + rbEx.getMessage()); }
            }
        } catch (Exception e) {
            message = "An unexpected error occurred: " + e.getMessage();
            System.err.println("AddDynamicFormServlet: " + message);
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rbEx) { System.err.println("Rollback failed: " + rbEx.getMessage()); }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing database connection in AddDynamicFormServlet: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }

        // Final redirection/forwarding logic
        if (submissionSuccessful) {
            session.setAttribute("formSuccessMessage", message); 
            response.sendRedirect(redirectUrl);
        } else {
            // Error handling is already done within the try block for validation/unique issues
            // This block handles other exceptions (DB, config etc.)
            request.setAttribute("formErrorMessage", message);
            request.setAttribute("registerId", String.valueOf(registerId)); 
            // formData is already set at the beginning of the try block
            request.getRequestDispatcher("/dynamic-form.jsp").forward(request, response);
        }
    }
}