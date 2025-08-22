package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/download-register")
public class DownloadRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String registerId = request.getParameter("register_id");
        String format = request.getParameter("format");
        
        if (registerId == null || registerId.trim().isEmpty()) {
            sendErrorResponse(response, "Register ID is required", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        if (!"csv".equalsIgnoreCase(format)) {
            sendErrorResponse(response, "Only CSV format is supported", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Connection conn = null;
        try {
            ServletContext context = getServletContext();
            conn = DriverManager.getConnection(
                (String) context.getAttribute("db_url"),
                (String) context.getAttribute("db_username"),
                (String) context.getAttribute("db_password")
            );

            String registerName = getRegisterName(conn, registerId);
            if (registerName == null) {
                sendErrorResponse(response, "Register not found", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            List<ColumnInfo> columns = getRegisterColumns(conn, registerId);
            if (columns.isEmpty()) {
                sendErrorResponse(response, "No columns found for this register", HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            generateCSV(response, conn, registerId, registerName, columns);

        } catch (SQLException e) {
            sendErrorResponse(response, "Database error: " + e.getMessage(), HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignore) {}
            }
        }
    }

    private String getRegisterName(Connection conn, String registerId) throws SQLException {
        String sql = "SELECT name FROM registers WHERE register_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Integer.parseInt(registerId));
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getString("name") : null;
            }
        }
    }

    private List<ColumnInfo> getRegisterColumns(Connection conn, String registerId) throws SQLException {
        List<ColumnInfo> columns = new ArrayList<>();
        String sql = "SELECT column_id, label, field_name FROM register_columns WHERE register_id = ? ORDER BY ordering";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Integer.parseInt(registerId));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    columns.add(new ColumnInfo(
                        rs.getInt("column_id"),
                        rs.getString("label"),
                        rs.getString("field_name")
                    ));
                }
            }
        }
        return columns;
    }

    private void generateCSV(HttpServletResponse response, Connection conn, String registerId,
                           String registerName, List<ColumnInfo> columns) throws SQLException, IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + sanitizeFileName(registerName) + "_export.csv\"");
        
        try (PrintWriter writer = response.getWriter()) {
            // Write CSV header
            writer.print("Entry ID,Submitted By,Submitted At");
            for (ColumnInfo column : columns) {
                writer.print("," + escapeCsv(column.getLabel()));
            }
            writer.println();

            // Get all entries and their values
            String getEntriesSql = "SELECT e.entry_id, e.submitted_by, u.username as submitted_by_name, " +
                                "e.submitted_at FROM register_entries_dynamic e " +
                                "LEFT JOIN users u ON e.submitted_by = u.id " +
                                "WHERE e.register_id = ? ORDER BY e.submitted_at DESC";
            try (PreparedStatement getEntriesStmt = conn.prepareStatement(getEntriesSql)) {
                getEntriesStmt.setInt(1, Integer.parseInt(registerId));
                try (ResultSet rs = getEntriesStmt.executeQuery()) {
                    while (rs.next()) {
                        // Write static fields
                        writer.print(escapeCsv(rs.getInt("entry_id") + ""));
                        writer.print("," + escapeCsv(rs.getString("submitted_by_name")));
                        writer.print("," + escapeCsv(rs.getTimestamp("submitted_at").toString()));

                        // Get values for this entry
                        String getValuesSql = "SELECT column_id, value FROM register_entry_values " +
                                            "WHERE entry_id = ?";
                        try (PreparedStatement getValuesStmt = conn.prepareStatement(getValuesSql)) {
                            getValuesStmt.setInt(1, rs.getInt("entry_id"));
                            try (ResultSet valuesRs = getValuesStmt.executeQuery()) {
                                Map<Integer, String> valuesMap = new HashMap<>();
                                while (valuesRs.next()) {
                                    valuesMap.put(valuesRs.getInt("column_id"), valuesRs.getString("value"));
                                }

                                // Write dynamic fields
                                for (ColumnInfo column : columns) {
                                    String value = valuesMap.getOrDefault(column.getColumnId(), "");
                                    writer.print("," + escapeCsv(value));
                                }
                            }
                        }
                        writer.println();
                    }
                }
            }
        }
    }

    private String escapeCsv(String input) {
        if (input == null) {
            return "";
        }
        if (input.contains("\"") || input.contains(",") || input.contains("\n")) {
            return "\"" + input.replace("\"", "\"\"") + "\"";
        }
        return input;
    }

    private String sanitizeFileName(String name) {
        return name.replaceAll("[^a-zA-Z0-9.-]", "_");
    }

    private void sendErrorResponse(HttpServletResponse response, String message, int status) throws IOException {
        response.setContentType("text/html");
        response.setStatus(status);
        try (PrintWriter out = response.getWriter()) {
            out.println("<html><body>");
            out.println("<h2>Error: " + message + "</h2>");
            out.println("</body></html>");
        }
    }

    private static class ColumnInfo {
        private final int columnId;
        private final String label;
        private final String fieldName;

        public ColumnInfo(int columnId, String label, String fieldName) {
            this.columnId = columnId;
            this.label = label;
            this.fieldName = fieldName;
        }

        public int getColumnId() { return columnId; }
        public String getLabel() { return label; }
        public String getFieldName() { return fieldName; }
    }
}