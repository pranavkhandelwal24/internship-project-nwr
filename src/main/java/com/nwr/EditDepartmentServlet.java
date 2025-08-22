package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/edit-department")
public class EditDepartmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String oldName = request.getParameter("old_name");
        String newName = request.getParameter("new_name");
        String deptIdParam = request.getParameter("department_id");

        if (oldName == null || newName == null || deptIdParam == null ||
                oldName.trim().isEmpty() || newName.trim().isEmpty() || deptIdParam.trim().isEmpty()) {
            response.sendRedirect("superadmin?error=Missing+fields!");
            return;
        }

        oldName = oldName.trim();
        newName = newName.trim();
        int departmentId = Integer.parseInt(deptIdParam.trim());

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement updateDeptStmt = null;

        try {
            // Use AppConfigListener DB config
            ServletContext context = request.getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUsername = (String) context.getAttribute("db_username");
            String dbPassword = (String) context.getAttribute("db_password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            // 1️⃣ Check if new name already exists for other departments
            String checkSql = "SELECT department_id FROM departments WHERE TRIM(name) = ? AND department_id != ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, newName);
            checkStmt.setInt(2, departmentId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                rs.close();
                response.sendRedirect("edit-department.jsp?error=Department+name+already+exists!&id=" + departmentId);
                return;
            }
            rs.close();

            // 2️⃣ Update only the department name (no need to update foreign keys)
            String updateDeptSql = "UPDATE departments SET name = ? WHERE department_id = ?";
            updateDeptStmt = conn.prepareStatement(updateDeptSql);
            updateDeptStmt.setString(1, newName);
            updateDeptStmt.setInt(2, departmentId);

            int updated = updateDeptStmt.executeUpdate();
            if (updated == 0) {
                response.sendRedirect("edit-department.jsp?error=Department+not+found!&id=" + departmentId);
                return;
            }

            // ✅ Success! No need to update other tables since they reference department_id
            response.sendRedirect("superadmin?success=Department+updated+successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-department.jsp?error=Database+error:" +
                    URLEncoder.encode(e.getMessage(), "UTF-8") + "&id=" + departmentId);
        } finally {
            try { if (checkStmt != null) checkStmt.close(); } catch (Exception ignored) {}
            try { if (updateDeptStmt != null) updateDeptStmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}