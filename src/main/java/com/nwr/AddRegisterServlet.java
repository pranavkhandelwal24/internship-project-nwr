package com.nwr;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

@WebServlet("/add-register")
public class AddRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Unauthorized\"}");
            return;
        }

        Gson gson = new Gson();
        Connection conn = null; // Declare connection outside try-with-resources

        try {
            // Read JSON request body
            StringBuilder sb = new StringBuilder();
            String line;
            BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            JsonObject jsonObject = gson.fromJson(sb.toString(), JsonObject.class);

            int departmentId = jsonObject.get("department_id").getAsInt();
            String name = jsonObject.get("name").getAsString().trim();
            String description = jsonObject.get("description").getAsString();
            int createdBy = jsonObject.get("created_by").getAsInt();

            JsonArray columnsArray = jsonObject.getAsJsonArray("columns");

            if (columnsArray == null || columnsArray.size() == 0) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"No columns provided.\"}");
                return;
            }

            ServletContext context = getServletContext();
            String dbUrl = context.getAttribute("db_url").toString();
            String dbUsername = context.getAttribute("db_username").toString();
            String dbPassword = context.getAttribute("db_password").toString();

            // Initialize connection manually to control transaction
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            
            // First check if register name already exists
            String checkSql = "SELECT COUNT(*) FROM registers WHERE department_id = ? AND LOWER(name) = LOWER(?)";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, departmentId);
                checkStmt.setString(2, name);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Register name already exists in this department.\"}");
                    return;
                }
            }

            conn.setAutoCommit(false);

            int registerId;

            String registerSql = "INSERT INTO registers (department_id, name, description, created_by) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(registerSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, departmentId);
                stmt.setString(2, name);
                stmt.setString(3, description);
                stmt.setInt(4, createdBy);

                int rows = stmt.executeUpdate();
                if (rows == 0) {
                    throw new SQLException("Creating register failed, no rows affected.");
                }

                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        registerId = rs.getInt(1);
                    } else {
                        throw new SQLException("Creating register failed, no ID obtained.");
                    }
                }
            }

            String columnSql = "INSERT INTO register_columns (register_id, label, field_name, data_type, options, is_required, is_unique, ordering) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(columnSql)) {
                for (JsonElement element : columnsArray) {
                    JsonObject col = element.getAsJsonObject();

                    stmt.setInt(1, registerId);
                    stmt.setString(2, col.get("label").getAsString());
                    stmt.setString(3, col.get("field_name").getAsString());
                    stmt.setString(4, col.get("data_type").getAsString());

                    if (col.has("options") && !col.get("options").isJsonNull() && !col.get("options").getAsString().isEmpty()) {
                        stmt.setString(5, col.get("options").getAsString());
                    } else {
                        stmt.setNull(5, Types.VARCHAR);
                    }

                    stmt.setInt(6, col.get("is_required").getAsInt());
                    stmt.setInt(7, col.get("is_unique").getAsInt());
                    stmt.setInt(8, col.get("ordering").getAsInt());

                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            conn.commit();

            JsonObject success = new JsonObject();
            success.addProperty("status", "success");
            success.addProperty("message", "Register created successfully. Please refresh to see updated changes.");
            success.addProperty("registerId", registerId);
            response.getWriter().write(gson.toJson(success));

        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("status", "error");
            error.addProperty("message", "Database error: " + e.getMessage());
            response.getWriter().write(gson.toJson(error));
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("status", "error");
            error.addProperty("message", "Error: " + e.getMessage());
            response.getWriter().write(gson.toJson(error));
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}