package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/edit-member")
public class EditMemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get user role from session
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("role");
        
        // Determine redirect URL based on role
        String redirectUrl = "superadmin"; 
        if ("admin".equals(userRole)) {
            redirectUrl = "admin";
        }

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String departmentId = request.getParameter("department_id");

        // Get database credentials from ServletContext
        ServletContext context = getServletContext();
        String dbUrl = (String) context.getAttribute("db_url");
        String dbUsername = (String) context.getAttribute("db_username");
        String dbPassword = (String) context.getAttribute("db_password");

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword)) {
            // Check for duplicate username/email
            String checkSql = "SELECT id FROM users WHERE (username = ? OR email = ?) AND id != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                checkStmt.setInt(3, Integer.parseInt(id));
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    response.sendRedirect("edit-member.jsp?id=" + id + "&error=Username or email already exists");
                    return;
                }
            }
            
            // For admin users, verify they're not trying to change department
            if ("admin".equals(userRole)) {
                String currentDeptSql = "SELECT department_id FROM users WHERE id = ?";
                try (PreparedStatement deptStmt = conn.prepareStatement(currentDeptSql)) {
                    deptStmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = deptStmt.executeQuery();
                    if (rs.next()) {
                        String currentDeptId = rs.getString("department_id");
                        if (!currentDeptId.equals(departmentId)) {
                            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Unauthorized department change");
                            return;
                        }
                    }
                }
            }
            
            // Update user
            String updateSql = "UPDATE users SET name = ?, email = ?, department_id = ? WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, name);
                updateStmt.setString(2, email);
                updateStmt.setObject(3, departmentId != null && !departmentId.isEmpty() ? Integer.parseInt(departmentId) : null);
                updateStmt.setInt(4, Integer.parseInt(id));
                int rowsUpdated = updateStmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    response.sendRedirect(redirectUrl + "?success=Member updated successfully");
                } else {
                    response.sendRedirect("edit-member.jsp?id=" + id + "&error=No member found with ID: " + id);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            response.sendRedirect("edit-member.jsp?id=" + id + "&error=Invalid member ID format");
        }
    }
}