package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.google.gson.Gson;

@WebServlet("/superadmin")
public class SuperadminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"superadmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action != null) {
            handleAjaxRequest(request, response, session, action);
        } else {
            handleSuperadminPage(request, response, session);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void handleSuperadminPage(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws ServletException, IOException {
        
        ServletContext context = getServletContext();
        String dbUrl = context.getAttribute("db_url").toString();
        String dbUsername = context.getAttribute("db_username").toString();
        String dbPassword = context.getAttribute("db_password").toString();

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword)) {
            // Get superadmin name if not in session
            String superadminName = (String) session.getAttribute("superadminName");
            if (superadminName == null) {
                superadminName = getSuperadminName(conn, (String) session.getAttribute("username"));
                session.setAttribute("superadminName", superadminName);
            }

            // Get first name
            String firstName = superadminName != null && !superadminName.isEmpty() ? 
                superadminName.split(" ")[0] : "Admin";
            
            // Get all data
            Map<String, Object> data = getAllData(conn);
            
            // Set request attributes
            request.setAttribute("firstName", firstName);
            request.setAttribute("superadminName", superadminName);
            request.setAttribute("departments", data.get("departments"));
            request.setAttribute("departmentHeads", data.get("departmentHeads"));
            request.setAttribute("departmentIds", data.get("departmentIds"));
            request.setAttribute("activeAdmins", data.get("activeAdmins"));
            request.setAttribute("activeMembers", data.get("activeMembers"));
            request.setAttribute("departmentMemberCounts", data.get("departmentMemberCounts"));

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
        }

        // Forward to JSP
        request.getRequestDispatcher("/superadmin.jsp").forward(request, response);
    }

    private void handleAjaxRequest(HttpServletRequest request, HttpServletResponse response,
                                 HttpSession session, String action) throws IOException {
        
        ServletContext context = getServletContext();
        String dbUrl = context.getAttribute("db_url").toString();
        String dbUsername = context.getAttribute("db_username").toString();
        String dbPassword = context.getAttribute("db_password").toString();

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword)) {
            switch (action) {
                case "getRegisters":
                    handleGetRegisters(request, response, conn);
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

    private void handleGetRegisters(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws IOException, SQLException {
        String departmentName = request.getParameter("department");
        if (departmentName == null || departmentName.isEmpty()) {
            sendJsonResponse(response, "error", "Missing department name", null);
            return;
        }

        // Get department ID
        int departmentId = getDepartmentId(conn, departmentName);
        if (departmentId == -1) {
            sendJsonResponse(response, "error", "Department not found", null);
            return;
        }

        List<Map<String, String>> registers = new ArrayList<>();
        String sql = "SELECT register_id, name FROM registers WHERE department_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, departmentId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, String> register = new HashMap<>();
                register.put("register_id", rs.getString("register_id"));
                register.put("name", rs.getString("name"));
                registers.add(register);
            }
        }
        
        sendJsonResponse(response, "success", "Registers loaded", Map.of("registers", registers));
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
        Map<String, Object> data = new HashMap<>();

        // 1. Get register columns
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
        
        data.put("columns", columns);

        // 2. Get entries with their values
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
                entry.put("entry_id", String.valueOf(rs.getInt("entry_id")));
                
                // Handle submitted_by_name - ensure it's never null
                String submittedByName = rs.getString("submitted_by_name");
                entry.put("submitted_by_name", submittedByName != null ? submittedByName : "Unknown");
                
                // Handle submitted_at - ensure it's never null
                Timestamp submittedAt = rs.getTimestamp("submitted_at");
                entry.put("submitted_at", submittedAt != null ? submittedAt.toString() : "Not available");
                
                // Get values for this entry
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
        
        data.put("entries", entries);
        result.put("data", data);
        
        sendJsonResponse(response, "success", "Entries loaded", result);
    }

    private int getDepartmentId(Connection conn, String departmentName) throws SQLException {
        String sql = "SELECT department_id FROM departments WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, departmentName);
            ResultSet rs = stmt.executeQuery();
            return rs.next() ? rs.getInt("department_id") : -1;
        }
    }

    private String getSuperadminName(Connection conn, String username) throws SQLException {
        String sql = "SELECT name FROM users WHERE username = ? AND role = 'superadmin'";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            return rs.next() ? rs.getString("name") : "Super Admin";
        }
    }

    private Map<String, Object> getAllData(Connection conn) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        
        // 1) Get departments
        List<String> departments = new ArrayList<>();
        Map<String, String> departmentHeads = new HashMap<>();
        Map<String, Integer> departmentIds = new HashMap<>();
        
        String deptSql = "SELECT department_id, name, department_head FROM departments";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(deptSql)) {
            while (rs.next()) {
                String deptName = rs.getString("name");
                departments.add(deptName);
                departmentIds.put(deptName, rs.getInt("department_id"));
                departmentHeads.put(deptName, rs.getString("department_head"));
            }
        }
        data.put("departments", departments);
        data.put("departmentHeads", departmentHeads);
        data.put("departmentIds", departmentIds);
        
        // 2) Get active admins
        List<Map<String, String>> activeAdmins = getActiveUsers(conn, "admin");
        data.put("activeAdmins", activeAdmins);
        
        // 3) Get active members
        List<Map<String, String>> activeMembers = getActiveUsers(conn, "member");
        data.put("activeMembers", activeMembers);
        
        // 4) Get department member counts
        Map<String, Integer> departmentMemberCounts = getDepartmentMemberCounts(conn);
        data.put("departmentMemberCounts", departmentMemberCounts);
        
        return data;
    }

    private List<Map<String, String>> getActiveUsers(Connection conn, String role) throws SQLException {
        List<Map<String, String>> users = new ArrayList<>();
        String sql = "SELECT u.*, d.name AS department_name FROM users u " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE u.status = 'active' AND u.role = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            ResultSet rs = stmt.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();

            while (rs.next()) {
                Map<String, String> user = new HashMap<>();
                for (int i = 1; i <= colCount; i++) {
                    user.put(meta.getColumnLabel(i), rs.getString(i));
                }
                users.add(user);
            }
        }
        return users;
    }

    private Map<String, Integer> getDepartmentMemberCounts(Connection conn) throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT d.name AS department_name, COUNT(u.id) AS member_count " +
                     "FROM users u " +
                     "RIGHT JOIN departments d ON u.department_id = d.department_id AND u.role = 'member' AND u.status = 'active' " +
                     "GROUP BY d.name";
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                counts.put(rs.getString("department_name"), rs.getInt("member_count"));
            }
        }
        return counts;
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