package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/view-register-columns")
public class ViewRegisterColumnsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String registerId = request.getParameter("register_id");
        if (registerId == null || registerId.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Register ID is required");
            request.getRequestDispatcher("admin.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement getRegisterStmt = null;
        PreparedStatement getColumnsStmt = null;
        ResultSet rs = null;

        try {
            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUser = (String) context.getAttribute("db_username");
            String dbPass = (String) context.getAttribute("db_password");

            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Get register info
            String getRegisterSql = "SELECT r.*, u.name as created_by_name FROM registers r " +
                                   "LEFT JOIN users u ON r.created_by = u.id " +
                                   "WHERE r.register_id = ?";
            getRegisterStmt = conn.prepareStatement(getRegisterSql);
            getRegisterStmt.setInt(1, Integer.parseInt(registerId));
            rs = getRegisterStmt.executeQuery();

            if (!rs.next()) {
                request.setAttribute("errorMessage", "Register not found");
                request.getRequestDispatcher("admin.jsp").forward(request, response);
                return;
            }

            Map<String, Object> register = new HashMap<>();
            register.put("register_id", rs.getInt("register_id"));
            register.put("department_id", rs.getInt("department_id"));
            register.put("name", rs.getString("name"));
            register.put("description", rs.getString("description"));
            register.put("created_by", rs.getInt("created_by"));
            register.put("created_by_name", rs.getString("created_by_name"));
            register.put("created_at", rs.getTimestamp("created_at").toString());
            rs.close();

            // Get columns for this register
            String getColumnsSql = "SELECT * FROM register_columns WHERE register_id = ? ORDER BY ordering";
            getColumnsStmt = conn.prepareStatement(getColumnsSql);
            getColumnsStmt.setInt(1, Integer.parseInt(registerId));
            rs = getColumnsStmt.executeQuery();

            List<Map<String, Object>> columns = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> column = new HashMap<>();
                column.put("column_id", rs.getInt("column_id"));
                column.put("register_id", rs.getInt("register_id"));
                column.put("label", rs.getString("label"));
                column.put("field_name", rs.getString("field_name"));
                column.put("data_type", rs.getString("data_type"));
                column.put("options", rs.getString("options"));
                column.put("is_required", rs.getInt("is_required"));
                column.put("is_unique", rs.getInt("is_unique"));
                column.put("ordering", rs.getInt("ordering"));
                columns.add(column);
            }

            request.setAttribute("register", register);
            request.setAttribute("columns", columns);
            request.getRequestDispatcher("viewcolumns.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("admin.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (getRegisterStmt != null) getRegisterStmt.close(); } catch (Exception ignore) {}
            try { if (getColumnsStmt != null) getColumnsStmt.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }
}