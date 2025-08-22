package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.google.gson.Gson;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action != null) {
            handleAjaxRequest(request, response, session, action);
        } else {
            handleAdminPage(request, response, session);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void handleAdminPage(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        ServletContext context = getServletContext();
        String dbUrl = String.valueOf(context.getAttribute("db_url"));
        String dbUsername = String.valueOf(context.getAttribute("db_username"));
        String dbPassword = String.valueOf(context.getAttribute("db_password"));

        int userId = (Integer) session.getAttribute("userId");
        int departmentId;
        String departmentName;

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword)) {

            // Get or set department info
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

            Map<String, Object> departmentInfo = new HashMap<>();
            departmentInfo.put("departmentId", departmentId);
            departmentInfo.put("departmentName", departmentName);
            request.setAttribute("departmentInfo", departmentInfo);

            List<Map<String, String>> members = getDepartmentMembers(conn, departmentId);
            request.setAttribute("members", members);

            List<Map<String, String>> registers = getDepartmentRegisters(conn, departmentId);
            request.setAttribute("registers", registers);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin.jsp").forward(request, response);
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
                    handleGetEntries(request, response, conn);
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
        List<Map<String, String>> columns = new ArrayList<>();

        String sql = "SELECT column_id, label, field_name, data_type FROM register_columns " +
                     "WHERE register_id = ? ORDER BY ordering";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, registerId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, String> column = new HashMap<>();
                column.put("column_id", rs.getString("column_id"));
                column.put("label", rs.getString("label"));
                column.put("field_name", rs.getString("field_name"));
                column.put("data_type", rs.getString("data_type"));
                columns.add(column);
            }
        }

        sendJsonResponse(response, "success", "Columns loaded", Map.of("columns", columns));
    }

    private void handleGetEntries(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws IOException, SQLException {
        String registerIdStr = request.getParameter("registerId");
        if (registerIdStr == null || registerIdStr.isEmpty()) {
            sendJsonResponse(response, "error", "Missing register ID", null);
            return;
        }

        int registerId = Integer.parseInt(registerIdStr);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> data = new HashMap<>(); // This will contain both columns and entries

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

        data.put("columns", columns); // Add columns to data object

        // Get entries
        List<Map<String, String>> entries = new ArrayList<>();
        String entriesSql = "SELECT e.entry_id, e.submitted_by, u.username as submitted_by_name, " +
                          "e.submitted_at FROM register_entries_dynamic e " +
                          "LEFT JOIN users u ON e.submitted_by = u.id " +
                          "WHERE e.register_id = ? ORDER BY e.submitted_at DESC";

        try (PreparedStatement stmt = conn.prepareStatement(entriesSql)) {
            stmt.setInt(1, registerId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, String> entry = new HashMap<>();
                // FIX APPLIED HERE: Ensure entry_id is converted to String
                entry.put("entry_id", String.valueOf(rs.getInt("entry_id")));

                // Handle submitted_by_name - ensure it's never null
                String submittedByName = rs.getString("submitted_by_name");
                entry.put("submitted_by_name", submittedByName != null ? submittedByName : "Unknown");

                // Handle submitted_at - ensure it's never null
                Timestamp submittedAt = rs.getTimestamp("submitted_at");
                entry.put("submitted_at", submittedAt != null ? submittedAt.toString() : "Not available");

                // Get values for this entry (dynamic fields)
                String valuesSql = "SELECT v.column_id, v.value, c.field_name " +
                                 "FROM register_entry_values v " +
                                 "JOIN register_columns c ON v.column_id = c.column_id " +
                                 "WHERE v.entry_id = ?";

                try (PreparedStatement valuesStmt = conn.prepareStatement(valuesSql)) {
                    valuesStmt.setInt(1, rs.getInt("entry_id"));
                    ResultSet valuesRs = valuesStmt.executeQuery();

                    while (valuesRs.next()) {
                        String fieldName = valuesRs.getString("field_name");
                        String value = valuesRs.getString("value");
                        entry.put(fieldName, value != null ? value : "-");
                    }
                }

                entries.add(entry);
            }
        }

        data.put("entries", entries); // Add entries to data object
        result.put("data", data); // Wrap everything in data object

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

    private List<Map<String, String>> getDepartmentMembers(Connection conn, int deptId) throws SQLException {
        List<Map<String, String>> members = new ArrayList<>();
        String sql = "SELECT u.id, u.name, u.username, u.email, d.name AS department_name " +
                     "FROM users u JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE u.department_id = ? AND u.role = 'member' AND u.status = 'active'";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, deptId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, String> member = new HashMap<>();
                member.put("id", String.valueOf(rs.getInt("id")));
                member.put("name", rs.getString("name"));
                member.put("username", rs.getString("username"));
                member.put("email", rs.getString("email"));
                member.put("department_name", rs.getString("department_name"));
                members.add(member);
            }
        }
        return members;
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
                register.put("created_by_name", rs.getString("created_by_name"));
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
            responseData.putAll(data);
        }

        String json = new Gson().toJson(responseData);
        response.getWriter().write(json);
    }
}