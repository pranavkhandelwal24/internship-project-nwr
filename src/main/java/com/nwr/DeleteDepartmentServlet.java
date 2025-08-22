package com.nwr;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/delete-department")
public class DeleteDepartmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String departmentName = request.getParameter("departmentName");

        if (departmentName == null || departmentName.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Department Name is required\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement checkActiveUsersStmt = null;
        PreparedStatement checkRegistersStmt = null;
        PreparedStatement checkEntriesStmt = null;
        PreparedStatement deleteDeptStmt = null;

        try {
            // Get DB config from AppConfigListener
            ServletContext context = request.getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUsername = (String) context.getAttribute("db_username");
            String dbPassword = (String) context.getAttribute("db_password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            conn.setAutoCommit(false);

            // 1️⃣ Check if any ACTIVE users are still assigned to this department
            String checkActiveUsersSQL = "SELECT COUNT(*) FROM users WHERE department_id = " +
                                      "(SELECT department_id FROM departments WHERE name = ?) " +
                                      "AND status = 'active'";
            checkActiveUsersStmt = conn.prepareStatement(checkActiveUsersSQL);
            checkActiveUsersStmt.setString(1, departmentName);
            
            var rs = checkActiveUsersStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("{\"status\":\"error\",\"message\":\"Cannot delete department - there are active users still assigned to it\"}");
                return;
            }

            // 2️⃣ Check if any registers exist in this department
            String checkRegistersSQL = "SELECT COUNT(*) FROM registers WHERE department_id = " +
                                    "(SELECT department_id FROM departments WHERE name = ?)";
            checkRegistersStmt = conn.prepareStatement(checkRegistersSQL);
            checkRegistersStmt.setString(1, departmentName);
            
            rs = checkRegistersStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("{\"status\":\"error\",\"message\":\"Cannot delete department - there are registers still assigned to it\"}");
                return;
            }

            // 3️⃣ Check if any entries are still assigned to this department
            String checkEntriesSQL = "SELECT COUNT(*) FROM register_entries_dynamic WHERE register_id IN " +
                                   "(SELECT register_id FROM registers WHERE department_id = " +
                                   "(SELECT department_id FROM departments WHERE name = ?))";
            checkEntriesStmt = conn.prepareStatement(checkEntriesSQL);
            checkEntriesStmt.setString(1, departmentName);
            
            rs = checkEntriesStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("{\"status\":\"error\",\"message\":\"Cannot delete department - there are register entries still assigned to it\"}");
                return;
            }

            // 4️⃣ Delete the department if all checks pass
            String deleteDeptSQL = "DELETE FROM departments WHERE name = ?";
            deleteDeptStmt = conn.prepareStatement(deleteDeptSQL);
            deleteDeptStmt.setString(1, departmentName);
            int rowsAffected = deleteDeptStmt.executeUpdate();

            if (rowsAffected > 0) {
                conn.commit();
                out.print("{\"status\":\"success\",\"message\":\"Department deleted successfully\"}");
            } else {
                conn.rollback();
                out.print("{\"status\":\"error\",\"message\":\"Department not found\"}");
            }

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
            out.print("{\"status\":\"error\",\"message\":\"Error deleting department: " +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try { if (checkActiveUsersStmt != null) checkActiveUsersStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (checkRegistersStmt != null) checkRegistersStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (checkEntriesStmt != null) checkEntriesStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (deleteDeptStmt != null) deleteDeptStmt.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}