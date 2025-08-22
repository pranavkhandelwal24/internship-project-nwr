package com.nwr;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/delete-register-view")
public class DeleteRegisterViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String registerId = request.getParameter("register_id");
        if (registerId == null || registerId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Register ID is required");
            return;
        }

        Connection conn = null;
        try {
            // Get database connection using context attributes
            ServletContext context = getServletContext();
            conn = DriverManager.getConnection(
                (String) context.getAttribute("db_url"),
                (String) context.getAttribute("db_username"),
                (String) context.getAttribute("db_password")
            );

            // Get register info
            RegisterInfo register = getRegisterInfo(conn, registerId);
            if (register == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Register not found");
                return;
            }

            // Get counts
            int entryCount = getCount(conn, 
                "SELECT COUNT(*) FROM register_entries_dynamic WHERE register_id = ?", 
                registerId);
            int columnCount = getCount(conn, 
                "SELECT COUNT(*) FROM register_columns WHERE register_id = ?", 
                registerId);

            // Set attributes
            request.setAttribute("register", register);
            request.setAttribute("entryCount", entryCount);
            request.setAttribute("columnCount", columnCount);

            // Forward to JSP
            request.getRequestDispatcher("/delete-register.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        }
    }

    // RegisterInfo class with proper getters
    public static class RegisterInfo {
        private final String registerId;
        private final String name;

        public RegisterInfo(String registerId, String name) {
            this.registerId = registerId;
            this.name = name;
        }

        // Proper getter methods
        public String getRegisterId() {
            return registerId;
        }

        public String getName() {
            return name;
        }
    }

    // Helper methods
    private RegisterInfo getRegisterInfo(Connection conn, String registerId) throws SQLException {
        String sql = "SELECT register_id, name FROM registers WHERE register_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, registerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? 
                    new RegisterInfo(rs.getString("register_id"), rs.getString("name")) : 
                    null;
            }
        }
    }

    private int getCount(Connection conn, String sql, String registerId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, registerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}