package com.nwr;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/superadmin-delete-entry")
public class SuperadminDeleteEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @SuppressWarnings("unused")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JsonObject jsonResponse = new JsonObject();
        Connection conn = null;
        PrintWriter out = response.getWriter();

        try {
            // Verify superadmin session
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null || 
                !"superadmin".equals(session.getAttribute("role"))) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Unauthorized access. Superadmin privileges required.");
                out.print(jsonResponse.toString());
                return;
            }

            // Parse JSON request using non-deprecated approach
            BufferedReader reader = request.getReader();
            JsonObject jsonRequest = JsonParser.parseReader(reader).getAsJsonObject();
            
            // Get entryId and registerId from JSON
            int entryId = jsonRequest.get("entryId").getAsInt();
            int registerId = jsonRequest.get("registerId").getAsInt();

            // Get database connection
            ServletContext context = getServletContext();
            conn = DriverManager.getConnection(
                (String) context.getAttribute("db_url"),
                (String) context.getAttribute("db_username"),
                (String) context.getAttribute("db_password")
            );
            conn.setAutoCommit(false);

            // Delete operation
            deleteEntry(conn, entryId, jsonResponse, response);

        } catch (com.google.gson.JsonSyntaxException | NullPointerException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            jsonResponse.addProperty("status", "error");
            jsonResponse.addProperty("message", "Invalid request format. Please provide valid entryId and registerId.");
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
            
            out.print(jsonResponse.toString());
            out.close();
        }
    }

    private void deleteEntry(Connection conn, int entryId, JsonObject jsonResponse, HttpServletResponse response) 
            throws SQLException {
        // Delete associated values first
        try (PreparedStatement stmt = conn.prepareStatement(
            "DELETE FROM register_entry_values WHERE entry_id = ?")) {
            stmt.setInt(1, entryId);
            stmt.executeUpdate();
        }

        // Then delete the main entry
        try (PreparedStatement stmt = conn.prepareStatement(
            "DELETE FROM register_entries_dynamic WHERE entry_id = ?")) {
            stmt.setInt(1, entryId);
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
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
}