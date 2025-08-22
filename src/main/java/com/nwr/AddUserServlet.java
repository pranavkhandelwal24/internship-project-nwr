package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.regex.Pattern; // Import Pattern

@WebServlet("/add-user")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DEFAULT_SALT = "nwr-railway-system";

    // --- New: Regex Patterns and Error Messages for Validation ---
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9._-]{5,20}$");
    private static final String USERNAME_ERROR_MSG = "Username must be 5-20 characters long and can only contain letters, numbers, dots, underscores, or hyphens.";

    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~])[a-zA-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~]{8,}$");
    private static final String PASSWORD_ERROR_MSG = "Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.";
    // --- End New ---

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;

        try {
            request.setCharacterEncoding("UTF-8");
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
                out.print("{\"status\":\"error\",\"message\":\"Session expired. Please login again.\"}");
                return;
            }

            String currentUserRole = (String) session.getAttribute("role");
            Integer currentUserDepartmentId = (Integer) session.getAttribute("department_id");

            // Read form params
            String name = request.getParameter("name");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String departmentIdStr = request.getParameter("department_id");

            // Basic null/empty check (already present)
            if (name == null || username == null || password == null || email == null ||
                name.trim().isEmpty() || username.trim().isEmpty() || password.isEmpty() || email.trim().isEmpty()) {
                out.print("{\"status\":\"error\",\"message\":\"All fields are required.\"}");
                return;
            }

            // --- New: Username and Password Validation ---
            if (!USERNAME_PATTERN.matcher(username).matches()) {
                out.print("{\"status\":\"error\",\"message\":\"" + USERNAME_ERROR_MSG + "\"}");
                return;
            }

            if (!PASSWORD_PATTERN.matcher(password).matches()) {
                out.print("{\"status\":\"error\",\"message\":\"" + PASSWORD_ERROR_MSG + "\"}");
                return;
            }
            // --- End New ---
            
            // Get DB config from context
            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUser = (String) context.getAttribute("db_username");
            String dbPass = (String) context.getAttribute("db_password");
            String salt = (String) context.getAttribute("salt");
            if (salt == null) salt = DEFAULT_SALT;

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Department ID handling section
            int departmentId = 0;
            if ("superadmin".equals(currentUserRole)) {
                if (role == null || role.trim().isEmpty()) {
                    out.print("{\"status\":\"error\",\"message\":\"Role is required.\"}");
                    return;
                }
                if (!"superadmin".equals(role)) {
                    if (departmentIdStr == null || departmentIdStr.trim().isEmpty()) {
                        out.print("{\"status\":\"error\",\"message\":\"Department is required for this role.\"}");
                        return;
                    }
                    // Get department ID from name
                    departmentId = getDepartmentIdByName(conn, departmentIdStr);
                    if (departmentId == 0) {
                        out.print("{\"status\":\"error\",\"message\":\"Invalid department selected.\"}");
                        return;
                    }
                }
            } else if ("admin".equals(currentUserRole)) {
                role = "member"; // Force role to member
                departmentId = currentUserDepartmentId;
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Unauthorized access.\"}");
                return;
            }

            // Check for conflicts one by one
            if (isValueExists(conn, "username", username)) {
                out.print("{\"status\":\"error\",\"message\":\"Username already exists.\"}");
                return;
            }
            if (isValueExists(conn, "email", email)) {
                out.print("{\"status\":\"error\",\"message\":\"Email already exists.\"}");
                return;
            }

            String hashedPassword = hashPassword(password, salt);

            String sql = "INSERT INTO users (name, username, email, password, department_id, status, role) " +
                         "VALUES (?, ?, ?, ?, ?, 'active', ?)";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, name);
                stmt.setString(2, username);
                stmt.setString(3, email);
                stmt.setString(4, hashedPassword);
                if (departmentId > 0) {
                    stmt.setInt(5, departmentId);
                } else {
                    stmt.setNull(5, Types.INTEGER);
                }
                stmt.setString(6, role);

                int rowsInserted = stmt.executeUpdate();
                if (rowsInserted > 0) {
                    if ("admin".equals(role)) {
                        updateDepartmentHead(conn, departmentId, name);
                    }
                    out.print("{\"status\":\"success\",\"message\":\"User added successfully. Refresh to view updated data.\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Failed to add user.\"}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Server error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
            out.flush();
        }
    }
    
    // Add this helper method to the servlet
    private int getDepartmentIdByName(Connection conn, String departmentName) throws SQLException {
        String query = "SELECT department_id FROM departments WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, departmentName);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("department_id");
            }
        }
        return 0;
    }

    private boolean isValueExists(Connection conn, String column, String value) throws SQLException {
        String query = "SELECT COUNT(*) AS count FROM users WHERE " + column + " = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, value);
            ResultSet rs = stmt.executeQuery();
            if (rs.next() && rs.getInt("count") > 0) {
                return true;
            }
        }
        return false;
    }

    private void updateDepartmentHead(Connection conn, int departmentId, String adminName) throws SQLException {
        String updateSql = "UPDATE departments SET department_head = ? WHERE department_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
            stmt.setString(1, adminName);
            stmt.setInt(2, departmentId);
            stmt.executeUpdate();
        }
        
        // Also update any previous department where this admin was head
        String clearPreviousSql = "UPDATE departments SET department_head = NULL WHERE department_head = ? AND department_id != ?";
        try (PreparedStatement stmt = conn.prepareStatement(clearPreviousSql)) {
            stmt.setString(1, adminName);
            stmt.setInt(2, departmentId);
            stmt.executeUpdate();
        }
    }

    private String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        String saltedPassword = salt + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = md.digest(saltedPassword.getBytes());
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}