package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/delete-admin")
public class DeleteAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String id = request.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Admin ID is required.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement getNameStmt = null;
        PreparedStatement deactivateStmt = null;
        PreparedStatement updateDeptStmt = null;
        ResultSet rs = null;

        try {
            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUser = (String) context.getAttribute("db_username");
            String dbPass = (String) context.getAttribute("db_password");

            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false); // Start transaction

            // ✅ 1️⃣ Get the admin’s name & role check
            String getNameSql = "SELECT name, role FROM users WHERE id = ?";
            getNameStmt = conn.prepareStatement(getNameSql);
            getNameStmt.setInt(1, Integer.parseInt(id));
            rs = getNameStmt.executeQuery();

            String adminName = null;
            String role = null;

            if (rs.next()) {
                adminName = rs.getString("name");
                role = rs.getString("role");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Admin not found.\"}");
                return;
            }

            if (!"admin".equals(role)) {
                out.print("{\"status\":\"error\",\"message\":\"User is not an admin.\"}");
                return;
            }

            // ✅ 2️⃣ Soft delete: set status inactive
            String deactivateSql = "UPDATE users SET status = 'inactive' WHERE id = ?";
            deactivateStmt = conn.prepareStatement(deactivateSql);
            deactivateStmt.setInt(1, Integer.parseInt(id));
            deactivateStmt.executeUpdate();

            // ✅ 3️⃣ Clear department head if this admin was head
            String updateDeptSql = "UPDATE departments SET department_head = NULL WHERE department_head = ?";
            updateDeptStmt = conn.prepareStatement(updateDeptSql);
            updateDeptStmt.setString(1, adminName);
            updateDeptStmt.executeUpdate();

            conn.commit(); // Transaction success

            out.print("{\"status\":\"success\",\"message\":\"Admin deleted successfully.\"}");

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid admin ID format.\"}");
        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (getNameStmt != null) getNameStmt.close(); } catch (Exception ignore) {}
            try { if (deactivateStmt != null) deactivateStmt.close(); } catch (Exception ignore) {}
            try { if (updateDeptStmt != null) updateDeptStmt.close(); } catch (Exception ignore) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignore) {}
            out.flush();
        }
    }
}
