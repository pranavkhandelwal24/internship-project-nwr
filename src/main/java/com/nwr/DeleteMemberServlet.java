package com.nwr;

import java.io.*;
import java.sql.*;
import javax.servlet.ServletContext;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/delete-member")
public class DeleteMemberServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (id == null || id.trim().isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Member ID is required\"}");
            return;
        }

        Connection conn = null;
        try {
            // ✅ Get DB config from context
            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUsername = (String) context.getAttribute("db_username");
            String dbPassword = (String) context.getAttribute("db_password");

            if (dbUrl == null || dbUsername == null || dbPassword == null) {
                out.print("{\"status\":\"error\",\"message\":\"Database configuration not found\"}");
                return;
            }

            // ✅ Connect using config
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            // ✅ Update `users` table now
            String sql = "UPDATE users SET status = 'inactive' WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, Integer.parseInt(id));
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    out.print("{\"status\":\"success\",\"message\":\"Member deleted successfully\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Member not found\"}");
                }
            }
        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid member ID format\"}");
        } catch (SQLException e) {
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doPost(request, response);
    }
}
