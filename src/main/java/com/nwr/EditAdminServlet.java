package com.nwr;

import java.io.*;
import java.sql.*;
import java.util.Properties;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/edit-admin")
public class EditAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String dbUrl;
    private String dbUsername;
    private String dbPassword;

    @Override
    public void init() throws ServletException {
        try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {
            Properties props = new Properties();
            props.load(input);
            dbUrl = props.getProperty("db_url");
            dbUsername = props.getProperty("db_username");
            dbPassword = props.getProperty("db_password");
        } catch (IOException e) {
            throw new ServletException("Cannot load database configuration", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String newDepartmentName = request.getParameter("department");

        Connection conn = null;

        try {
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            conn.setAutoCommit(false);

            // Get current user info
            String oldName = "";
            int oldDeptId = -1;

            String oldSql = "SELECT u.name, u.department_id, d.name AS department_name FROM users u LEFT JOIN departments d ON u.department_id = d.department_id WHERE u.id = ? AND u.role = 'admin'";
            try (PreparedStatement oldStmt = conn.prepareStatement(oldSql)) {
                oldStmt.setInt(1, Integer.parseInt(id));
                ResultSet rs = oldStmt.executeQuery();
                if (rs.next()) {
                    oldName = rs.getString("name");
                    oldDeptId = rs.getInt("department_id");
                } else {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Admin not found");
                    return;
                }
            }

            // Get new department_id by name
            int newDeptId = -1;
            String deptSql = "SELECT department_id FROM departments WHERE name = ?";
            try (PreparedStatement deptStmt = conn.prepareStatement(deptSql)) {
                deptStmt.setString(1, newDepartmentName);
                ResultSet rs = deptStmt.executeQuery();
                if (rs.next()) {
                    newDeptId = rs.getInt("department_id");
                } else {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Department not found");
                    return;
                }
            }

            // Check for duplicate email
            String checkSql = "SELECT id FROM users WHERE email = ? AND id != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, email);
                checkStmt.setInt(2, Integer.parseInt(id));
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=Email already exists");
                    return;
                }
            }

            // Update user (username stays same!)
            String updateSql = "UPDATE users SET name = ?, email = ?, department_id = ? WHERE id = ? AND role = 'admin'";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, name);
                updateStmt.setString(2, email);
                updateStmt.setInt(3, newDeptId);
                updateStmt.setInt(4, Integer.parseInt(id));
                int rows = updateStmt.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    response.sendRedirect("edit-admin.jsp?id=" + id + "&error=No admin found to update");
                    return;
                }
            }

            // Update department head logic
            if (oldDeptId != newDeptId) {
                // Remove head from old department
                String clearHeadSql = "UPDATE departments SET department_head = NULL WHERE department_id = ? AND department_head = ?";
                try (PreparedStatement clearStmt = conn.prepareStatement(clearHeadSql)) {
                    clearStmt.setInt(1, oldDeptId);
                    clearStmt.setString(2, oldName);
                    clearStmt.executeUpdate();
                }

                // Set head for new department
                String setHeadSql = "UPDATE departments SET department_head = ? WHERE department_id = ?";
                try (PreparedStatement setStmt = conn.prepareStatement(setHeadSql)) {
                    setStmt.setString(1, name);
                    setStmt.setInt(2, newDeptId);
                    setStmt.executeUpdate();
                }

            } else if (!oldName.equals(name)) {
                // If name changed, update head in same department
                String updateHeadSql = "UPDATE departments SET department_head = ? WHERE department_id = ? AND department_head = ?";
                try (PreparedStatement updateHeadStmt = conn.prepareStatement(updateHeadSql)) {
                    updateHeadStmt.setString(1, name);
                    updateHeadStmt.setInt(2, oldDeptId);
                    updateHeadStmt.setString(3, oldName);
                    updateHeadStmt.executeUpdate();
                }
            }

            conn.commit();
            response.sendRedirect("superadmin?success=Admin updated successfully");

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("edit-admin.jsp?id=" + id + "&error=" + e.getMessage());
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
