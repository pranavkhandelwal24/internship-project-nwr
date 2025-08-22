package com.nwr;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/edit-entry")
public class EditEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        Integer departmentId = (Integer) session.getAttribute("department_id");

        if (username == null || role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ServletContext context = getServletContext();
        String dbUrl = (String) context.getAttribute("db_url");
        String dbUsername = (String) context.getAttribute("db_username");
        String dbPassword = (String) context.getAttribute("db_password");

        if (dbUrl == null || dbUsername == null || dbPassword == null) {
            request.setAttribute("error", "System configuration error. Please contact administrator.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        String entryIdStr = request.getParameter("entryId");
        String registerIdStr = request.getParameter("registerId");
        
        if (entryIdStr == null || entryIdStr.isEmpty() || registerIdStr == null || registerIdStr.isEmpty()) {
            request.setAttribute("error", "Missing required parameters. Please provide both entry ID and register ID.");
            request.getRequestDispatcher("/edit-entry.jsp").forward(request, response);
            return;
        }

        int entryId;
        int registerId;
        try {
            entryId = Integer.parseInt(entryIdStr);
            registerId = Integer.parseInt(registerIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid ID format. Please provide numeric values for entry and register IDs.");
            request.getRequestDispatcher("/edit-entry.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        try {
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            String authSql = "SELECT re.submitted_by, r.department_id, r.name AS register_name " +
                           "FROM register_entries_dynamic re " +
                           "JOIN registers r ON re.register_id = r.register_id " +
                           "WHERE re.entry_id = ? AND re.register_id = ?";
            
            int entrySubmittedBy = -1;
            int registerDepartmentId = -1;
            String registerName = "Entry";

            try (PreparedStatement authStmt = conn.prepareStatement(authSql)) {
                authStmt.setInt(1, entryId);
                authStmt.setInt(2, registerId);
                ResultSet authRs = authStmt.executeQuery();
                
                if (!authRs.next()) {
                    request.setAttribute("error", "The requested entry could not be found or you don't have permission to access it.");
                    request.getRequestDispatcher("/edit-entry.jsp").forward(request, response);
                    return;
                }
                
                entrySubmittedBy = authRs.getInt("submitted_by");
                registerDepartmentId = authRs.getInt("department_id");
                registerName = authRs.getString("register_name");
            }

            boolean isAuthorized = false;
            String authError = null;

            if ("superadmin".equals(role)) {
                isAuthorized = true;
            } 
            else if ("admin".equals(role)) {
                if (departmentId != null && departmentId == registerDepartmentId) {
                    isAuthorized = true;
                } else {
                    authError = "You can only edit entries in your department.";
                }
            }
            else if ("member".equals(role)) {
                if (userId != null && userId == entrySubmittedBy) {
                    isAuthorized = true;
                } else {
                    authError = "You can only edit your own entries.";
                }
            }

            if (!isAuthorized) {
                request.setAttribute("error", authError != null ? authError : "You are not authorized to edit this entry.");
                request.getRequestDispatcher("/edit-entry.jsp").forward(request, response);
                return;
            }

            List<Map<String, Object>> columns = new ArrayList<>();
            String columnsSql = "SELECT column_id, label, field_name, data_type, is_required, options " +
                              "FROM register_columns WHERE register_id = ? ORDER BY ordering";
            
            try (PreparedStatement stmt = conn.prepareStatement(columnsSql)) {
                stmt.setInt(1, registerId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> column = new HashMap<>();
                    column.put("column_id", rs.getInt("column_id"));
                    column.put("label", rs.getString("label"));
                    column.put("field_name", rs.getString("field_name"));
                    column.put("data_type", rs.getString("data_type"));
                    column.put("is_required", rs.getBoolean("is_required"));
                    column.put("options", rs.getString("options"));
                    columns.add(column);
                }
            }

            Map<Integer, String> entryValues = new HashMap<>();
            String valuesSql = "SELECT column_id, value FROM register_entry_values WHERE entry_id = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(valuesSql)) {
                stmt.setInt(1, entryId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    entryValues.put(rs.getInt("column_id"), rs.getString("value"));
                }
            }

            StringBuilder formHtml = new StringBuilder();
            formHtml.append("<form id=\"editEntryForm\" action=\"").append(request.getContextPath())
                   .append("/edit-entry\" method=\"post\" class=\"entry-form\">");
            formHtml.append("<input type=\"hidden\" name=\"entryId\" value=\"").append(entryId).append("\">");
            formHtml.append("<input type=\"hidden\" name=\"registerId\" value=\"").append(registerId).append("\">");
            formHtml.append("<input type=\"hidden\" name=\"userRole\" value=\"").append(role).append("\">");
            formHtml.append("<div class=\"form-container\">");

            if (columns.isEmpty()) {
                formHtml.append("<div class=\"alert alert-info\">No fields defined for this register.</div>");
            } else {
                for (Map<String, Object> column : columns) {
                    int columnId = (Integer) column.get("column_id");
                    String label = (String) column.get("label");
                    String fieldName = (String) column.get("field_name");
                    String dataType = (String) column.get("data_type");
                    boolean isRequired = (Boolean) column.get("is_required");
                    String options = (String) column.get("options");
                    String currentValue = entryValues.getOrDefault(columnId, "");

                    formHtml.append("<div class=\"form-group\">")
                           .append("<label for=\"").append(fieldName).append("\"")
                           .append(isRequired ? " class=\"required\"" : "").append(">")
                           .append(label).append("</label>");

                    if ("enum".equalsIgnoreCase(dataType) && options != null && !options.isEmpty()) {
                        formHtml.append("<select name=\"").append(fieldName).append("\" id=\"")
                               .append(fieldName).append("\" class=\"form-control\"")
                               .append(isRequired ? " required" : "").append(">")
                               .append("<option value=\"\">-- Select --</option>");
                        
                        for (String option : options.split(",")) {
                            String trimmedOption = option.trim();
                            if (!trimmedOption.isEmpty()) {
                                boolean isSelected = trimmedOption.equals(currentValue);
                                formHtml.append("<option value=\"").append(trimmedOption).append("\"")
                                       .append(isSelected ? " selected" : "").append(">")
                                       .append(trimmedOption).append("</option>");
                            }
                        }
                        formHtml.append("</select>");
                    } 
                    else if ("date".equalsIgnoreCase(dataType)) {
                        formHtml.append("<input type=\"date\" name=\"").append(fieldName)
                               .append("\" id=\"").append(fieldName)
                               .append("\" class=\"form-control\" value=\"")
                               .append(currentValue).append("\"")
                               .append(isRequired ? " required" : "").append(">");
                    } 
                    else if ("number".equalsIgnoreCase(dataType)) {
                        formHtml.append("<input type=\"number\" name=\"").append(fieldName)
                               .append("\" id=\"").append(fieldName)
                               .append("\" class=\"form-control\" value=\"")
                               .append(currentValue).append("\"")
                               .append(isRequired ? " required" : "").append(">");
                    } 
                    else if ("decimal".equalsIgnoreCase(dataType)) {
                        formHtml.append("<input type=\"text\" name=\"").append(fieldName)
                               .append("\" id=\"").append(fieldName)
                               .append("\" class=\"form-control decimal\" value=\"")
                               .append(currentValue).append("\"")
                               .append(isRequired ? " required" : "").append(">");
                    } 
                    else {
                        formHtml.append("<input type=\"text\" name=\"").append(fieldName)
                               .append("\" id=\"").append(fieldName)
                               .append("\" class=\"form-control\" value=\"")
                               .append(currentValue).append("\"")
                               .append(isRequired ? " required" : "").append(">");
                    }
                    formHtml.append("</div>");
                }

                formHtml.append("<div class=\"form-actions\">")
                       .append("<button type=\"submit\" class=\"btn btn-primary\">")
                       .append("<i class=\"fas fa-save\"></i> Update Entry")
                       .append("</button>")
                       .append("</div>");
            }

            formHtml.append("</div></form>");

            request.setAttribute("entryTitle", registerName + " (Entry #" + entryId + ")");
            request.setAttribute("dynamicFormHtml", formHtml.toString());
            request.setAttribute("entryId", entryIdStr);
            request.setAttribute("registerId", registerIdStr);

        } catch (SQLException e) {
            request.setAttribute("error", "Database error while loading entry: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
        
        request.getRequestDispatcher("/edit-entry.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ServletContext context = getServletContext();
        String dbUrl = (String) context.getAttribute("db_url");
        String dbUsername = (String) context.getAttribute("db_username");
        String dbPassword = (String) context.getAttribute("db_password");

        if (dbUrl == null || dbUsername == null || dbPassword == null) {
            response.sendRedirect("error.jsp?error=" + URLEncoder.encode("System configuration error", "UTF-8"));
            return;
        }

        String entryIdStr = request.getParameter("entryId");
        String registerIdStr = request.getParameter("registerId");
        String userRoleFromForm = request.getParameter("userRole");

        if (entryIdStr == null || entryIdStr.isEmpty() || registerIdStr == null || registerIdStr.isEmpty()) {
            response.sendRedirect("edit-entry.jsp?error=" + URLEncoder.encode("Missing required parameters", "UTF-8"));
            return;
        }

        int entryId;
        int registerId;
        try {
            entryId = Integer.parseInt(entryIdStr);
            registerId = Integer.parseInt(registerIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("edit-entry.jsp?error=" + URLEncoder.encode("Invalid ID format", "UTF-8"));
            return;
        }

        Connection conn = null;
        try {
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            conn.setAutoCommit(false);

            String userRole = (String) session.getAttribute("role");
            Integer currentUserId = (Integer) session.getAttribute("userId");
            Integer currentUserDepartmentId = (Integer) session.getAttribute("department_id");

            String authSql = "SELECT re.submitted_by, r.department_id " +
                           "FROM register_entries_dynamic re " +
                           "JOIN registers r ON re.register_id = r.register_id " +
                           "WHERE re.entry_id = ? AND re.register_id = ?";
            
            int entrySubmittedBy = -1;
            int registerDepartmentId = -1;

            try (PreparedStatement authStmt = conn.prepareStatement(authSql)) {
                authStmt.setInt(1, entryId);
                authStmt.setInt(2, registerId);
                ResultSet authRs = authStmt.executeQuery();
                
                if (!authRs.next()) {
                    conn.rollback();
                    response.sendRedirect("edit-entry.jsp?error=" + 
                        URLEncoder.encode("Entry not found or access denied", "UTF-8"));
                    return;
                }
                
                entrySubmittedBy = authRs.getInt("submitted_by");
                registerDepartmentId = authRs.getInt("department_id");
            }

            boolean isAuthorized = false;
            
            if ("superadmin".equals(userRole)) {
                isAuthorized = true;
            } 
            else if ("admin".equals(userRole) && currentUserDepartmentId != null && 
                     currentUserDepartmentId == registerDepartmentId) {
                isAuthorized = true;
            } 
            else if ("member".equals(userRole) && currentUserId != null && 
                     currentUserId == entrySubmittedBy) {
                isAuthorized = true;
            }

            if (!isAuthorized) {
                conn.rollback();
                response.sendRedirect("edit-entry.jsp?error=" + 
                    URLEncoder.encode("You are not authorized to edit this entry", "UTF-8"));
                return;
            }

            List<Map<String, Object>> columns = new ArrayList<>();
            String columnsSql = "SELECT column_id, field_name, label, data_type, is_required, is_unique, options " +
                              "FROM register_columns WHERE register_id = ? ORDER BY ordering";
            
            try (PreparedStatement stmt = conn.prepareStatement(columnsSql)) {
                stmt.setInt(1, registerId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> column = new HashMap<>();
                    column.put("column_id", rs.getInt("column_id"));
                    column.put("field_name", rs.getString("field_name"));
                    column.put("label", rs.getString("label"));
                    column.put("data_type", rs.getString("data_type"));
                    column.put("is_required", rs.getBoolean("is_required"));
                    column.put("is_unique", rs.getBoolean("is_unique"));
                    column.put("options", rs.getString("options"));
                    columns.add(column);
                }
            }

            StringBuilder validationErrors = new StringBuilder();
            for (Map<String, Object> column : columns) {
                String fieldName = (String) column.get("field_name");
                String label = (String) column.get("label");
                boolean isRequired = (Boolean) column.get("is_required");
                boolean isUnique = (Boolean) column.get("is_unique");
                String dataType = (String) column.get("data_type");
                String submittedValue = request.getParameter(fieldName);
                
                if (submittedValue == null) submittedValue = "";
                submittedValue = submittedValue.trim();

                if (isRequired && submittedValue.isEmpty()) {
                    validationErrors.append("<li>").append(label).append(" is required</li>");
                    continue;
                }

                if (!submittedValue.isEmpty()) {
                    if ("number".equalsIgnoreCase(dataType)) {
                        try {
                            Integer.parseInt(submittedValue);
                        } catch (NumberFormatException e) {
                            validationErrors.append("<li>").append(label).append(" must be a valid integer</li>");
                        }
                    } else if ("decimal".equalsIgnoreCase(dataType)) {
                        try {
                            Double.parseDouble(submittedValue);
                        } catch (NumberFormatException e) {
                            validationErrors.append("<li>").append(label).append(" must be a valid decimal number</li>");
                        }
                    }
                }

                if (isUnique && !submittedValue.isEmpty()) {
                    String uniqueCheckSql = "SELECT COUNT(*) FROM register_entry_values rev " +
                                          "JOIN register_entries_dynamic red ON rev.entry_id = red.entry_id " +
                                          "WHERE rev.column_id = ? AND rev.value = ? " +
                                          "AND rev.entry_id != ? AND red.register_id = ?";
                    
                    try (PreparedStatement uniqueStmt = conn.prepareStatement(uniqueCheckSql)) {
                        uniqueStmt.setInt(1, (Integer) column.get("column_id"));
                        uniqueStmt.setString(2, submittedValue);
                        uniqueStmt.setInt(3, entryId);
                        uniqueStmt.setInt(4, registerId);
                        ResultSet rs = uniqueStmt.executeQuery();
                        if (rs.next() && rs.getInt(1) > 0) {
                            validationErrors.append("<li>").append(label)
                                           .append(" must be unique (value '").append(submittedValue)
                                           .append("' already exists)</li>");
                        }
                    }
                }
            }

            if (validationErrors.length() > 0) {
                conn.rollback();
                response.sendRedirect("edit-entry?entryId=" + entryId + "&registerId=" + registerId + 
                    "&error=" + URLEncoder.encode("Validation errors:<ul>" + validationErrors.toString() + "</ul>", "UTF-8"));
                return;
            }

            String deleteSql = "DELETE FROM register_entry_values WHERE entry_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteSql)) {
                stmt.setInt(1, entryId);
                stmt.executeUpdate();
            }

            String insertSql = "INSERT INTO register_entry_values (entry_id, column_id, value) VALUES (?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                for (Map<String, Object> column : columns) {
                    String fieldName = (String) column.get("field_name");
                    String value = request.getParameter(fieldName);
                    if (value == null) value = "";
                    value = value.trim();

                    stmt.setInt(1, entryId);
                    stmt.setInt(2, (Integer) column.get("column_id"));
                    stmt.setString(3, value);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            conn.commit();

            String redirectUrl;
            String separator;
            if ("superadmin".equals(userRoleFromForm)) {
                redirectUrl = "superadmin";
                separator = "?";
            } else if ("admin".equals(userRoleFromForm)) {
                redirectUrl = "admin";
                separator = "?";
            } else {
                redirectUrl = "member";
                separator = "?";
            }

            response.sendRedirect(redirectUrl + separator + "success=" + 
                URLEncoder.encode("Entry updated successfully.", "UTF-8"));

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            response.sendRedirect("edit-entry?entryId=" + entryId + "&registerId=" + registerId + 
                "&error=" + URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
}