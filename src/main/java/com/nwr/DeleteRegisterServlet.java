package com.nwr;

import java.io.*;
import java.sql.*;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/delete-register")
public class DeleteRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String registerId = request.getParameter("register_id");
        if (registerId == null || registerId.trim().isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Register ID is required.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement deleteValuesStmt = null;
        PreparedStatement deleteEntriesStmt = null;
        PreparedStatement deleteColumnsStmt = null;
        PreparedStatement deleteRegisterStmt = null;

        try {
            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUser = (String) context.getAttribute("db_username");
            String dbPass = (String) context.getAttribute("db_password");

            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

            // 1. Delete all entry values for this register
            String deleteValuesSql = "DELETE v FROM register_entry_values v " +
                                   "JOIN register_entries_dynamic e ON v.entry_id = e.entry_id " +
                                   "WHERE e.register_id = ?";
            deleteValuesStmt = conn.prepareStatement(deleteValuesSql);
            deleteValuesStmt.setInt(1, Integer.parseInt(registerId));
            deleteValuesStmt.executeUpdate();

            // 2. Delete all entries for this register
            String deleteEntriesSql = "DELETE FROM register_entries_dynamic WHERE register_id = ?";
            deleteEntriesStmt = conn.prepareStatement(deleteEntriesSql);
            deleteEntriesStmt.setInt(1, Integer.parseInt(registerId));
            deleteEntriesStmt.executeUpdate();

            // 3. Delete all columns for this register
            String deleteColumnsSql = "DELETE FROM register_columns WHERE register_id = ?";
            deleteColumnsStmt = conn.prepareStatement(deleteColumnsSql);
            deleteColumnsStmt.setInt(1, Integer.parseInt(registerId));
            deleteColumnsStmt.executeUpdate();

            // 4. Finally delete the register itself
            String deleteRegisterSql = "DELETE FROM registers WHERE register_id = ?";
            deleteRegisterStmt = conn.prepareStatement(deleteRegisterSql);
            deleteRegisterStmt.setInt(1, Integer.parseInt(registerId));
            int affectedRows = deleteRegisterStmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Register not found with ID: " + registerId);
            }

            conn.commit();
            out.print("{\"status\":\"success\",\"message\":\"Register and all associated data deleted successfully.\"}");

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid register ID format.\"}");
        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try { if (deleteValuesStmt != null) deleteValuesStmt.close(); } catch (Exception ignore) {}
            try { if (deleteEntriesStmt != null) deleteEntriesStmt.close(); } catch (Exception ignore) {}
            try { if (deleteColumnsStmt != null) deleteColumnsStmt.close(); } catch (Exception ignore) {}
            try { if (deleteRegisterStmt != null) deleteRegisterStmt.close(); } catch (Exception ignore) {}
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