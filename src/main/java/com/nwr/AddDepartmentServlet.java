package com.nwr;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/add-department")
public class AddDepartmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String departmentName = request.getParameter("departmentName");

        if (departmentName == null || departmentName.trim().isEmpty()) {
            response.sendRedirect("superadmin?error=Department+name+cannot+be+empty");
            return;
        }

        departmentName = departmentName.trim();

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;

        try {
            // Get DB config from AppConfigListener
            ServletContext context = request.getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUsername = (String) context.getAttribute("db_username");
            String dbPassword = (String) context.getAttribute("db_password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            // 1️⃣ Check if department already exists
            String checkSql = "SELECT department_id FROM departments WHERE name = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, departmentName);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                response.sendRedirect("superadmin?error=Department+already+exists");
                return;
            }

            // 2️⃣ Insert new department
            String insertSql = "INSERT INTO departments (name) VALUES (?)";
            insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            insertStmt.setString(1, departmentName);

            int affectedRows = insertStmt.executeUpdate();

            if (affectedRows > 0) {
                response.sendRedirect("superadmin?success=Department+added+successfully");
            } else {
                response.sendRedirect("superadmin?error=Failed+to+add+department");
            }

        } catch (ClassNotFoundException e) {
            response.sendRedirect("superadmin?error=Database+driver+not+found");
        } catch (SQLException e) {
            if (e.getSQLState().equals("23000")) { // Duplicate entry
                response.sendRedirect("superadmin?error=Department+already+exists");
            } else {
                response.sendRedirect("superadmin?error=Database+error");
            }
        } catch (Exception e) {
            response.sendRedirect("superadmin?error=Unexpected+error");
        } finally {
            // Close resources in reverse order
            try { if (insertStmt != null) insertStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (checkStmt != null) checkStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}