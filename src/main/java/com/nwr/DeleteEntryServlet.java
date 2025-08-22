package com.nwr;

import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.InputStream;
import java.util.Scanner;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@MultipartConfig
@WebServlet("/delete-entry")
public class DeleteEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set content type and encoding first
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JsonObject jsonResponse = new JsonObject();
        Connection conn = null;
        PrintWriter out = response.getWriter(); // Get writer once at start

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null || 
                (!"member".equals(session.getAttribute("role")) && 
                 !"admin".equals(session.getAttribute("role")) && 
                 !"superadmin".equals(session.getAttribute("role")))) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Unauthorized access. Please log in.");
                sendResponse(out, jsonResponse);
                return;
            }

            int userId = (int) session.getAttribute("userId");
            String role = (String) session.getAttribute("role");

            // Get entryId from request
            String entryIdParam = getPartAsString(request, "entryId");
            if (entryIdParam == null || entryIdParam.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Entry ID is missing.");
                sendResponse(out, jsonResponse);
                return;
            }

            int entryId;
            try {
                entryId = Integer.parseInt(entryIdParam.trim());
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Invalid Entry ID format.");
                sendResponse(out, jsonResponse);
                return;
            }

            // Get database connection
            ServletContext context = getServletContext();
            conn = DriverManager.getConnection(
                (String) context.getAttribute("db_url"),
                (String) context.getAttribute("db_username"),
                (String) context.getAttribute("db_password")
            );
            conn.setAutoCommit(false);

            // For members, verify ownership
            if ("member".equals(role)) {
                if (!isEntryOwner(conn, entryId, userId)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    jsonResponse.addProperty("status", "error");
                    jsonResponse.addProperty("message", "You can only delete your own entries.");
                    sendResponse(out, jsonResponse);
                    return;
                }
            }

            // Delete operation
            deleteEntry(conn, entryId, jsonResponse, response);

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.addProperty("status", "error");
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.addProperty("status", "error");
            jsonResponse.addProperty("message", "Server error: " + e.getMessage());
        } finally {
            try { 
                if (conn != null) { 
                    conn.setAutoCommit(true); 
                    conn.close(); 
                } 
            } catch (SQLException e) {}
            
            // Final response writing
            sendResponse(out, jsonResponse);
        }
    }

    private String getPartAsString(HttpServletRequest request, String partName) throws IOException, ServletException {
        Part part = request.getPart(partName);
        if (part == null) return null;
        try (InputStream is = part.getInputStream();
             Scanner s = new Scanner(is).useDelimiter("\\A")) {
            return s.hasNext() ? s.next().trim() : "";
        }
    }

    private boolean isEntryOwner(Connection conn, int entryId, int userId) throws SQLException {
        String sql = "SELECT submitted_by FROM register_entries_dynamic WHERE entry_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, entryId);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && userId == rs.getInt("submitted_by");
        }
    }

    private void deleteEntry(Connection conn, int entryId, JsonObject jsonResponse, HttpServletResponse response) 
            throws SQLException {
        // Delete associated values
        try (PreparedStatement stmt = conn.prepareStatement(
            "DELETE FROM register_entry_values WHERE entry_id = ?")) {
            stmt.setInt(1, entryId);
            stmt.executeUpdate();
        }

        // Delete main entry
        try (PreparedStatement stmt = conn.prepareStatement(
            "DELETE FROM register_entries_dynamic WHERE entry_id = ?")) {
            stmt.setInt(1, entryId);
            int rows = stmt.executeUpdate();
            
            if (rows > 0) {
                conn.commit();
                jsonResponse.addProperty("status", "success");
                jsonResponse.addProperty("message", "Entry deleted successfully.");
            } else {
                conn.rollback();
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Entry not found.");
            }
        }
    }

    private void sendResponse(PrintWriter out, JsonObject jsonResponse) {
        String jsonString = jsonResponse.toString();
        out.print(jsonString); // Use print (not println) to avoid extra newlines
        out.flush();
        out.close();
    }
}