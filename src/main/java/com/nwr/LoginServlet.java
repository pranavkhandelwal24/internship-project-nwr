package com.nwr;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Validate inputs
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            sendError(response, "Username and password are required");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Get config from ServletContext
        ServletContext context = getServletContext();
        String dbUrl = (String) context.getAttribute("db_url");
        String dbUser = (String) context.getAttribute("db_username");
        String dbPass = (String) context.getAttribute("db_password");
        String salt = (String) context.getAttribute("salt");

        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            Object[] userData = authenticateUser(con, username);
            if (userData == null) {
                sendError(response, "Username not found", "username");
                return;
            }

            int userId = (int) userData[0];
            String role = (String) userData[1];
            String name = (String) userData[2];
            String storedPassword = (String) userData[3];
            String status = (String) userData[4];

            if (!storedPassword.equals(hashPassword(password, salt))) {
                sendError(response, "Incorrect password", "password");
                return;
            }

            if ("inactive".equalsIgnoreCase(status)) {
                sendError(response, "User is deleted/inactive", "username");
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("fullName", name);
            session.setAttribute("role", role);
            session.setAttribute("userId", userId);
            session.setMaxInactiveInterval(30 * 60);

            if ("on".equals(request.getParameter("remember"))) {
                Cookie rememberCookie = new Cookie("remembered_username", username);
                rememberCookie.setMaxAge(30 * 24 * 60 * 60);
                rememberCookie.setHttpOnly(true);
                rememberCookie.setSecure(true);
                response.addCookie(rememberCookie);
            }

            logLogin(con, userId, request.getRemoteAddr());

            sendSuccess(response, getRedirectUrl(role));

        } catch (Exception e) {
            sendError(response, "Error: " + e.getMessage());
        } finally {
            if (con != null) try { con.close(); } catch (SQLException ignored) {}
        }
    }

    private Object[] authenticateUser(Connection con, String username) throws SQLException {
        String sql = "SELECT id, role, name, password, status FROM users WHERE username = ?";
        try (PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, username);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return new Object[]{
                        rs.getInt("id"),
                        rs.getString("role"),
                        rs.getString("name"),
                        rs.getString("password"),
                        rs.getString("status")
                    };
                }
            }
        }
        return null;
    }

    private void logLogin(Connection con, int userId, String ipAddress) throws SQLException {
        String sql = "INSERT INTO login_logs (user_id, ip_address) VALUES (?, ?)";
        try (PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, userId);
            pst.setString(2, ipAddress);
            pst.executeUpdate();
        }
    }

    private String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        String saltedPassword = salt + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(saltedPassword.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) sb.append(String.format("%02x", b & 0xff));
        return sb.toString();
    }

    private String getRedirectUrl(String role) {
        switch (role) {
            case "superadmin": return "superadmin";
            case "admin": return "admin";
            case "member": return "member";
            default: return "login.jsp";
        }
    }

    private void sendSuccess(HttpServletResponse response, String redirectUrl) throws IOException {
        response.getWriter().print("{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}");
    }

 // ✅ 2-arg
    private void sendError(HttpServletResponse response, String message) throws IOException {
        sendError(response, message, null);
    }

    // ✅ 3-arg
    private void sendError(HttpServletResponse response, String message, String errorField) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"" +
                message.replace("\"", "'") + "\"" +
                (errorField != null ? ", \"errorField\": \"" + errorField + "\"" : "") +
                "}");
    }

}
