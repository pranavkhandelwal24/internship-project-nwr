package com.nwr;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import java.security.MessageDigest; // Import MessageDigest
import java.security.NoSuchAlgorithmException; // Import NoSuchAlgorithmException
import java.util.regex.Pattern; // Import Pattern

import javax.servlet.ServletContext;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/edit-profile")
public class EditProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    // It's better to get SALT from ServletContext like in AddUserServlet for consistency
    // However, as per your instruction not to change anything else, I'll keep it as a static final here.
    private static final String SALT = "nwr-railway-system"; 

    // --- New: Password Regex Pattern and Error Message ---
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~])[a-zA-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~]{8,}$");
    private static final String PASSWORD_ERROR_MSG = "Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.";
    // --- End New ---

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = session.getAttribute("role").toString();
        String currentUsername = session.getAttribute("username").toString();

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");

        // Basic validation for name and email - assuming they are always required
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Name and Email are required.", "UTF-8"));
            return;
        }

        ServletContext context = getServletContext();
        String dbUrl = (String) context.getAttribute("db_url");
        String dbUser = (String) context.getAttribute("db_username");
        String dbPass = (String) context.getAttribute("db_password");

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {

            // Check if the new email conflicts with other users
            String checkSql = "SELECT * FROM users WHERE email = ? AND username != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, email);
                checkStmt.setString(2, currentUsername);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Email already exists", "UTF-8"));
                    return;
                }
            }

            // If changing password, verify old password AND validate new password complexity
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                // --- New: Password Complexity Validation for newPassword ---
                if (!PASSWORD_PATTERN.matcher(newPassword).matches()) {
                    response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode(PASSWORD_ERROR_MSG, "UTF-8"));
                    return;
                }
                // --- End New ---

                String verifySql = "SELECT * FROM users WHERE username = ? AND password = ?";
                try (PreparedStatement verifyStmt = conn.prepareStatement(verifySql)) {
                    verifyStmt.setString(1, currentUsername);
                    // Use the same hashing method for comparison
                    verifyStmt.setString(2, hashPassword(currentPassword)); 
                    ResultSet rs = verifyStmt.executeQuery();
                    if (!rs.next()) {
                        response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Current password is incorrect", "UTF-8"));
                        return;
                    }
                }
            }

            // Update: do not change username!
            String updateSql = "UPDATE users SET name = ?, email = ?" +
                    (newPassword != null && !newPassword.trim().isEmpty() ? ", password = ?" : "") +
                    " WHERE username = ? AND role = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, name);
                updateStmt.setString(2, email);
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    updateStmt.setString(3, hashPassword(newPassword));
                    updateStmt.setString(4, currentUsername);
                    updateStmt.setString(5, role);
                } else {
                    updateStmt.setString(3, currentUsername);
                    updateStmt.setString(4, role);
                }

                int rows = updateStmt.executeUpdate();
                if (rows > 0) {
                    session.setAttribute("fullName", name);

                    // For superadmin, keep legacy session key too
                    if ("superadmin".equals(role)) {
                        session.setAttribute("superadminName", name);
                    }

                    response.sendRedirect(role + "?success=" + URLEncoder.encode("Profile updated successfully", "UTF-8"));
                } else {
                    response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Profile update failed", "UTF-8"));
                }

            }

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Password hashing error: " + e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-profile.jsp?error=" + URLEncoder.encode("Server error: " + e.getMessage(), "UTF-8"));
        }
    }

    // IMPORTANT: Ensure this hashPassword method is consistent with your user creation
    // It should throw NoSuchAlgorithmException if the algorithm is not found.
    private String hashPassword(String password) throws NoSuchAlgorithmException {
        String saltedPassword = SALT + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest(saltedPassword.getBytes());
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}