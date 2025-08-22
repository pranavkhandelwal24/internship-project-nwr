package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.google.gson.Gson;

@WebServlet("/member")
public class MemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"member".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action != null) {
            handleAjaxRequest(request, response, session, action);
        } else {
            handleMemberPage(request, response, session);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void handleMemberPage(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        ServletContext context = getServletContext();
        String dbUrl = String.valueOf(context.getAttribute("db_url"));
        String dbUsername = String.valueOf(context.getAttribute("db_username"));
        String dbPassword = String.valueOf(context.getAttribute("db_password"));

        int userId = (Integer) session.getAttribute("userId");
        int departmentId = 0;
        String departmentName = "";
        String firstName = "User";

        Connection conn = null;
        try {
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            if (session.getAttribute("department_id") != null && session.getAttribute("department_name") != null) {
                departmentId = (Integer) session.getAttribute("department_id");
                departmentName = (String) session.getAttribute("department_name");
            } else {
                Map<String, Object> departmentInfo = getDepartmentInfo(conn, userId);
                departmentId = (Integer) departmentInfo.get("departmentId");
                departmentName = (String) departmentInfo.get("departmentName");
                session.setAttribute("department_id", departmentId);
                session.setAttribute("department_name", departmentName);
            }

            String fullName = (String) session.getAttribute("fullName");
            if (fullName != null && !fullName.isEmpty()) {
                firstName = fullName.split(" ")[0];
            }
            session.setAttribute("firstName", firstName);

            Map<String, Object> departmentInfo = new HashMap<>();
            departmentInfo.put("departmentId", departmentId);
            departmentInfo.put("departmentName", departmentName);
            request.setAttribute("departmentInfo", departmentInfo);

            List<Map<String, String>> registers = getDepartmentRegisters(conn, departmentId);
            request.setAttribute("registers", registers);

            StringBuilder formHtmlBuilder = new StringBuilder();
            String errorMessage = null;

            int registerIdToLoad = -1;
            String reqRegisterId = request.getParameter("registerId");

            if (reqRegisterId != null && !reqRegisterId.isEmpty()) {
                try {
                    registerIdToLoad = Integer.parseInt(reqRegisterId);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid Register ID provided.";
                    System.err.println("Invalid Register ID provided: " + reqRegisterId);
                }
            }

            if (registerIdToLoad != -1) {
                request.setAttribute("currentLoadedRegisterId", registerIdToLoad);

                String sql = "SELECT label, field_name, data_type, is_required, options " +
                             "FROM register_columns WHERE register_id = ? ORDER BY ordering";

                formHtmlBuilder.append("<form id=\"registerEntryForm\" action=\"").append(request.getContextPath()).append("/submit-dynamic-form\" method=\"post\">");
                formHtmlBuilder.append("    <input type=\"hidden\" id=\"registerId\" name=\"registerId\" value=\"").append(registerIdToLoad).append("\">");
                formHtmlBuilder.append("    <input type=\"hidden\" id=\"submittedBy\" name=\"submittedBy\" value=\"").append(userId).append("\">");
                formHtmlBuilder.append("    <div id=\"formFieldsContainer\">");

                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, registerIdToLoad);
                    ResultSet rs = stmt.executeQuery();

                    boolean hasFields = false;
                    while (rs.next()) {
                        hasFields = true;
                        String label = rs.getString("label");
                        String fieldName = rs.getString("field_name");
                        String dataType = rs.getString("data_type");
                        boolean isRequired = rs.getBoolean("is_required");
                        String options = rs.getString("options");

                        String requiredAttr = isRequired ? "required" : "";
                        String requiredClass = isRequired ? "required-field" : "";

                        formHtmlBuilder.append("        <div class=\"form-group dynamic-field\">");
                        formHtmlBuilder.append("            <label for=\"").append(fieldName).append("\" class=\"").append(requiredClass).append("\">").append(label != null && !label.isEmpty() ? label : fieldName).append("</label>");

                        if ("enum".equalsIgnoreCase(dataType) && options != null && !options.isEmpty()) {
                            formHtmlBuilder.append("            <select name=\"").append(fieldName).append("\" id=\"").append(fieldName).append("\" class=\"form-control\" ").append(requiredAttr).append(">");
                            formHtmlBuilder.append("                <option value=\"\">-- Select --</option>");
                            for (String option : options.split(",")) {
                                String trimmedOption = option.trim();
                                if (!trimmedOption.isEmpty()) {
                                    formHtmlBuilder.append("                <option value=\"").append(trimmedOption).append("\">").append(trimmedOption).append("</option>");
                                }
                            }
                            formHtmlBuilder.append("            </select>");
                        } else if ("date".equalsIgnoreCase(dataType)) {
                            formHtmlBuilder.append("            <input type=\"date\" name=\"").append(fieldName).append("\" id=\"").append(fieldName).append("\" class=\"form-control\" ").append(requiredAttr).append(">");
                        } else if ("number".equalsIgnoreCase(dataType)) {
                            formHtmlBuilder.append("            <input type=\"number\" name=\"").append(fieldName).append("\" id=\"").append(fieldName).append("\" class=\"form-control\" ").append(requiredAttr).append(">");
                        } else {
                            formHtmlBuilder.append("            <input type=\"text\" name=\"").append(fieldName).append("\" id=\"").append(fieldName).append("\" class=\"form-control\" ").append(requiredAttr).append(">");
                        }
                        formHtmlBuilder.append("        </div>");
                    }

                    if (!hasFields) {
                        formHtmlBuilder.append("        <p class=\"no-fields\">No fields defined for register ID ").append(registerIdToLoad).append(".</p>");
                    } else {
                        formHtmlBuilder.append("        <button type=\"submit\" class=\"btn btn-primary\" id=\"submitEntryBtn\">");
                        formHtmlBuilder.append("            <i class=\"fas fa-save\"></i> Submit Entry");
                        formHtmlBuilder.append("        </button>");
                    }

                } catch (SQLException e) {
                    errorMessage = "Database query error for form: " + e.getMessage();
                    System.err.println(errorMessage);
                    e.printStackTrace();
                    formHtmlBuilder.append("        <div class=\"form-error-message\">").append(errorMessage).append("</div>");
                }
                formHtmlBuilder.append("    </div>");
                formHtmlBuilder.append("</form>");
            } else if (errorMessage == null) {
                
            }

            request.setAttribute("dynamicFormHtml", formHtmlBuilder.toString());
            if (errorMessage != null) {
                request.setAttribute("formErrorMessage", errorMessage);
            }

        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database connection error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading member data: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing database connection: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
        request.getRequestDispatcher("/member.jsp").forward(request, response);
    }

    private void handleAjaxRequest(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, String action) throws IOException {

        ServletContext context = getServletContext();
        String dbUrl = String.valueOf(context.getAttribute("db_url"));
        String dbUsername = String.valueOf(context.getAttribute("db_username"));
        String dbPassword = String.valueOf(context.getAttribute("db_password"));

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword)) {
            switch (action) {
                case "getColumns":
                    handleGetColumns(request, response, conn);
                    break;
                case "getEntries":
                    handleGetEntries(request, response, conn, session);
                    break;
                default:
                    sendJsonResponse(response, "error", "Invalid action: " + action, null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, "error", "Failed to process request: " + e.getMessage(), null);
        }
    }

    private void handleGetColumns(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws IOException, SQLException {
        String registerIdStr = request.getParameter("registerId");
        if (registerIdStr == null || registerIdStr.isEmpty()) {
            sendJsonResponse(response, "error", "Missing register ID", null);
            return;
        }

        int registerId = Integer.parseInt(registerIdStr);
        List<Map<String, Object>> columns = new ArrayList<>();

        System.out.println("Processing getColumns for registerId: " + registerId);

        String sql = "SELECT column_id, label, field_name, data_type, is_required, is_unique, options " +
                     "FROM register_columns WHERE register_id = ? ORDER BY ordering";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, registerId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> column = new HashMap<>();
                column.put("column_id", rs.getInt("column_id"));

                String label = rs.getString("label");
                String fieldName = rs.getString("field_name");
                String dataType = rs.getString("data_type");
                String options = rs.getString("options");

                System.out.println("  Retrieved Column: ");
                System.out.println("    label: " + label + " (is null? " + (label == null) + ")");
                System.out.println("    field_name: " + fieldName + " (is null? " + (fieldName == null) + ")");
                System.out.println("    data_type: " + dataType);
                System.out.println("    options: " + options + " (is null? " + (options == null) + ")");

                column.put("label", label);
                column.put("field_name", fieldName);
                column.put("data_type", dataType);
                column.put("is_required", rs.getBoolean("is_required"));
                column.put("is_unique", rs.getBoolean("is_unique"));
                column.put("options", options);
                columns.add(column);
            }

            if (columns.isEmpty()) {
                System.out.println("No columns found for registerId: " + registerId);
            } else {
                System.out.println("Found " + columns.size() + " columns for registerId: " + registerId);
            }

        } catch (SQLException e) {
            System.err.println("SQL Error fetching columns for registerId " + registerId + ": " + e.getMessage());
            throw e;
        }

        sendJsonResponse(response, "success", "Columns loaded", Map.of("columns", columns));
    }

    private void handleGetEntries(HttpServletRequest request, HttpServletResponse response,
                                  Connection conn, HttpSession session) throws IOException, SQLException {
        String registerIdStr = request.getParameter("registerId");

        if (registerIdStr == null || registerIdStr.isEmpty()) {
            sendJsonResponse(response, "error", "Missing register ID", null);
            return;
        }

        int registerId = Integer.parseInt(registerIdStr);
        int departmentId = (Integer) session.getAttribute("department_id"); // Get department ID from session

        Map<String, Object> result = new HashMap<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        // Get columns
        List<Map<String, String>> columns = new ArrayList<>();
        String columnsSql = "SELECT column_id, label, field_name FROM register_columns " +
                            "WHERE register_id = ? ORDER BY ordering";

        try (PreparedStatement stmt = conn.prepareStatement(columnsSql)) {
            stmt.setInt(1, registerId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, String> column = new HashMap<>();
                column.put("column_id", rs.getString("column_id"));
                column.put("label", rs.getString("label"));
                column.put("field_name", rs.getString("field_name"));
                columns.add(column);
            }
        }

        // Get entries for the selected register within the user's department
        List<Map<String, String>> entries = new ArrayList<>();
        String entriesSql = "SELECT e.entry_id, e.submitted_by, u.username as submitted_by_name, e.submitted_at " +
                            "FROM register_entries_dynamic e " +
                            "JOIN registers r ON e.register_id = r.register_id " + // Join with registers table
                            "LEFT JOIN users u ON e.submitted_by = u.id " +
                            "WHERE e.register_id = ? AND r.department_id = ? " + // Filter by registerId AND departmentId
                            "ORDER BY e.submitted_at DESC";

        try (PreparedStatement stmt = conn.prepareStatement(entriesSql)) {
            stmt.setInt(1, registerId);
            stmt.setInt(2, departmentId); // Bind departmentId from session
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, String> entry = new HashMap<>();

                String entryIdStr = rs.getString("entry_id");
                if (entryIdStr == null) {
                    entryIdStr = "";
                    System.err.println("Warning: Found a NULL entry_id in register_entries_dynamic for registerId: " + registerId + ", departmentId: " + departmentId);
                }
                entry.put("entry_id", entryIdStr);

                String submittedByName = rs.getString("submitted_by_name");
                if (submittedByName == null || submittedByName.trim().isEmpty()) {
                    submittedByName = "Unknown User"; // Changed to "Unknown User" as it might not be 'You' if submitted by someone else
                }
                entry.put("submitted_by_name", submittedByName);

                Timestamp submittedAt = rs.getTimestamp("submitted_at");
                String submittedAtStr = (submittedAt != null) ?
                        dateFormat.format(submittedAt) : "Not available";
                entry.put("submitted_at", submittedAtStr);

                // Get values for this entry (dynamic fields)
                String valuesSql = "SELECT v.column_id, v.value, c.field_name " +
                                   "FROM register_entry_values v " +
                                   "JOIN register_columns c ON v.column_id = c.column_id " +
                                   "WHERE v.entry_id = ?";

                try (PreparedStatement valuesStmt = conn.prepareStatement(valuesSql)) {
                    int currentEntryIdInt;
                    try {
                        currentEntryIdInt = Integer.parseInt(entryIdStr);
                        valuesStmt.setInt(1, currentEntryIdInt);
                        ResultSet valuesRs = valuesStmt.executeQuery();

                        while (valuesRs.next()) {
                            String fieldName = valuesRs.getString("field_name");
                            String fieldValue = valuesRs.getString("value");
                            entry.put(fieldName, fieldValue != null ? fieldValue : "");
                        }
                    } catch (NumberFormatException e) {
                        System.err.println("Skipping dynamic values for invalid entry_id: " + entryIdStr);
                    }
                }
                entries.add(entry);
            }
        }

        result.put("columns", columns);
        result.put("entries", entries);
        sendJsonResponse(response, "success", "Entries loaded", result);
    }

    private Map<String, Object> getDepartmentInfo(Connection conn, int userId) throws SQLException {
        String sql = "SELECT d.department_id, d.name " +
                     "FROM users u JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE u.id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Map<String, Object> result = new HashMap<>();
                result.put("departmentId", rs.getInt("department_id"));
                result.put("departmentName", rs.getString("name"));
                return result;
            } else {
                throw new SQLException("No department found for user ID: " + userId);
            }
        }
    }

    private List<Map<String, String>> getDepartmentRegisters(Connection conn, int deptId) throws SQLException {
        List<Map<String, String>> registers = new ArrayList<>();
        String sql = "SELECT r.register_id, r.name, r.description, r.created_at, " +
                     "u.name AS created_by_name " +
                     "FROM registers r " +
                     "JOIN users u ON r.created_by = u.id " +
                     "WHERE r.department_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, deptId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, String> register = new HashMap<>();
                register.put("register_id", String.valueOf(rs.getInt("register_id")));
                register.put("name", rs.getString("name"));
                register.put("description", rs.getString("description"));
                register.put("created_at", rs.getString("created_at"));
                String createdByName = rs.getString("created_by_name");
                register.put("created_by_name", createdByName != null ? createdByName : "Unknown");
                registers.add(register);
            }
        }
        return registers;
    }

    private void sendJsonResponse(HttpServletResponse response, String status, String message, Map<String, ?> data)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("status", status);
        responseData.put("message", message);

        if (data != null) {
            responseData.put("data", data);
        }

        String json = new Gson().toJson(responseData);
        response.getWriter().write(json);
    }
}