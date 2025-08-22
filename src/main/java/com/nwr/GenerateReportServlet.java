package com.nwr;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/generate-report")
public class GenerateReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?sessionExpired=true");
            return;
        }

        String username = (String) session.getAttribute("username");
        if (username == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp?unauthorized=true");
            return;
        }

        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        if (startDateStr == null || endDateStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "startDate and endDate required");
            return;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        java.util.Date utilStartDate, utilEndDate;
        try {
            utilStartDate = sdf.parse(startDateStr);
            utilEndDate = sdf.parse(endDateStr);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format");
            return;
        }

        // Format dates for display
        SimpleDateFormat displayFormat = new SimpleDateFormat("dd.MM.yyyy");
        String displayStartDate = displayFormat.format(utilStartDate);
        String displayEndDate = displayFormat.format(utilEndDate);
        String currentDate = displayFormat.format(new java.util.Date());

        Connection conn = null;
        try {
            ServletContext context = getServletContext();
            conn = DriverManager.getConnection(
                    String.valueOf(context.getAttribute("db_url")),
                    String.valueOf(context.getAttribute("db_username")),
                    String.valueOf(context.getAttribute("db_password"))
            );

            // Get all users
            List<String> users = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT u.username FROM users u " +
                    "JOIN register_entries_dynamic red ON u.id = red.submitted_by " +
                    "WHERE red.register_id = 1 ORDER BY u.username")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        users.add(rs.getString("username"));
                    }
                }
            }

            // Build stats for each user
            Map<String, Map<String, Integer>> userStats = new LinkedHashMap<>();
            Map<String, Integer> totals = new HashMap<>();

            // Initialize totals
            String[] metrics = {"opening_eoffice", "opening_irpsm", "received_eoffice", "received_irpsm", 
                              "vetted_eoffice", "vetted_irpsm", "returned_eoffice", "returned_irpsm",
                              "closing_eoffice", "closing_irpsm", "putup_eoffice", "putup_irpsm",
                              "pending_eoffice", "pending_irpsm"};
            
            for (String metric : metrics) {
                totals.put(metric, 0);
            }

            for (String user : users) {
                Map<String, Integer> stats = new LinkedHashMap<>();
                
                // Calculate opening balance (files received before start date but not dispatched)
                int openingEoffice = getOpeningBalance(conn, user, "E-Office", startDateStr);
                int openingIrpsm = getOpeningBalance(conn, user, "IRPSM", startDateStr);
                
                stats.put("opening_eoffice", openingEoffice);
                stats.put("opening_irpsm", openingIrpsm);
                
                // Calculate received files (between start and end dates)
                int receivedEoffice = getReceivedCount(conn, user, "E-Office", startDateStr, endDateStr);
                int receivedIrpsm = getReceivedCount(conn, user, "IRPSM", startDateStr, endDateStr);
                
                stats.put("received_eoffice", receivedEoffice);
                stats.put("received_irpsm", receivedIrpsm);
                
                // Calculate vetted files
                int vettedEoffice = getVettedCount(conn, user, "E-Office", startDateStr, endDateStr);
                int vettedIrpsm = getVettedCount(conn, user, "IRPSM", startDateStr, endDateStr);
                
                stats.put("vetted_eoffice", vettedEoffice);
                stats.put("vetted_irpsm", vettedIrpsm);
                
                // Calculate returned files
                int returnedEoffice = getReturnedCount(conn, user, "E-Office", startDateStr, endDateStr);
                int returnedIrpsm = getReturnedCount(conn, user, "IRPSM", startDateStr, endDateStr);
                
                stats.put("returned_eoffice", returnedEoffice);
                stats.put("returned_irpsm", returnedIrpsm);
                
             // Calculate closing balance (opening + received - vetted - returned)
                int closingEoffice = openingEoffice + receivedEoffice - vettedEoffice - returnedEoffice;
                int closingIrpsm = openingIrpsm + receivedIrpsm - vettedIrpsm - returnedIrpsm;

                stats.put("closing_eoffice", closingEoffice);
                stats.put("closing_irpsm", closingIrpsm);

                // Calculate put up files (using Version B logic)
                int putupEoffice = getPutupCount(conn, user, "E-Office", startDateStr, endDateStr);
                int putupIrpsm = getPutupCount(conn, user, "IRPSM", startDateStr, endDateStr);

                stats.put("putup_eoffice", putupEoffice);
                stats.put("putup_irpsm", putupIrpsm);

                // ✅ Files pending = Closing - Putup
                stats.put("pending_eoffice", closingEoffice - putupEoffice);
                stats.put("pending_irpsm", closingIrpsm - putupIrpsm);

                
                userStats.put(user, stats);
                
                // Update totals
                for (Map.Entry<String, Integer> entry : stats.entrySet()) {
                    totals.put(entry.getKey(), totals.get(entry.getKey()) + entry.getValue());
                }
            }

            request.setAttribute("userStats", userStats);
            request.setAttribute("users", users);
            request.setAttribute("startDate", displayStartDate);
            request.setAttribute("endDate", displayEndDate);
            request.setAttribute("currentDate", currentDate);
            request.setAttribute("totals", totals);

            request.getRequestDispatcher("/report.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    private int getOpeningBalance(Connection conn, String user, String system, String beforeDate) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT red.entry_id) AS count " +
                "FROM register_entries_dynamic red " +
                "JOIN register_entry_values rev1 ON red.entry_id = rev1.entry_id AND rev1.column_id = 1 " +
                "JOIN register_entry_values rev2 ON red.entry_id = rev2.entry_id AND rev2.column_id = 10 " + // received_date
                "LEFT JOIN register_entry_values rev3 ON red.entry_id = rev3.entry_id AND rev3.column_id = 12 " + // dispatch_date
                "JOIN users u ON red.submitted_by = u.id " +
                "WHERE red.register_id = 1 AND u.username = ? " +
                "AND rev1.value = ? AND (rev3.value IS NULL OR rev3.value = '') " +
                "AND rev2.value < ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, system);
            ps.setString(3, beforeDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count");
            }
        }
        return 0;
    }

    private int getReceivedCount(Connection conn, String user, String system, String startDate, String endDate) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT red.entry_id) AS count " +
                "FROM register_entries_dynamic red " +
                "JOIN register_entry_values rev1 ON red.entry_id = rev1.entry_id AND rev1.column_id = 1 " +
                "JOIN register_entry_values rev2 ON red.entry_id = rev2.entry_id AND rev2.column_id = 10 " + // received_date
                "JOIN users u ON red.submitted_by = u.id " +
                "WHERE red.register_id = 1 AND u.username = ? " +
                "AND rev1.value = ? AND rev2.value BETWEEN ? AND ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, system);
            ps.setString(3, startDate);
            ps.setString(4, endDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count");
            }
        }
        return 0;
    }

    private int getVettedCount(Connection conn, String user, String system, String startDate, String endDate) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT red.entry_id) AS count " +
                "FROM register_entries_dynamic red " +
                "JOIN register_entry_values rev1 ON red.entry_id = rev1.entry_id AND rev1.column_id = 1 " +
                "JOIN register_entry_values rev2 ON red.entry_id = rev2.entry_id AND rev2.column_id = 10 " + // received_date
                "JOIN register_entry_values rev3 ON red.entry_id = rev3.entry_id AND rev3.column_id = 13 " + // status
                "JOIN users u ON red.submitted_by = u.id " +
                "WHERE red.register_id = 1 AND u.username = ? " +
                "AND rev1.value = ? AND rev2.value BETWEEN ? AND ? " +
                "AND rev3.value = 'V'";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, system);
            ps.setString(3, startDate);
            ps.setString(4, endDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count");
            }
        }
        return 0;
    }

    private int getReturnedCount(Connection conn, String user, String system, String startDate, String endDate) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT red.entry_id) AS count " +
                "FROM register_entries_dynamic red " +
                "JOIN register_entry_values rev1 ON red.entry_id = rev1.entry_id AND rev1.column_id = 1 " +
                "JOIN register_entry_values rev2 ON red.entry_id = rev2.entry_id AND rev2.column_id = 10 " + // received_date
                "JOIN register_entry_values rev3 ON red.entry_id = rev3.entry_id AND rev3.column_id = 13 " + // status
                "JOIN users u ON red.submitted_by = u.id " +
                "WHERE red.register_id = 1 AND u.username = ? " +
                "AND rev1.value = ? AND rev2.value BETWEEN ? AND ? " +
                "AND rev3.value = 'R'";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, system);
            ps.setString(3, startDate);
            ps.setString(4, endDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count");
            }
        }
        return 0;
    }

    private int getPutupCount(Connection conn, String user, String system, String startDate, String endDate) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT red.entry_id) AS count " +
                "FROM register_entries_dynamic red " +
                "JOIN register_entry_values rev1 ON red.entry_id = rev1.entry_id AND rev1.column_id = 1 " + // system
                "JOIN register_entry_values rev2 ON red.entry_id = rev2.entry_id AND rev2.column_id = 11 " + // putup_date
                "JOIN users u ON red.submitted_by = u.id " +
                "WHERE red.register_id = 1 AND u.username = ? " +
                "AND rev1.value = ? " +
                "AND rev2.value BETWEEN ? AND ? " +
                "AND TRIM(rev2.value) <> '' " +
                "AND NOT EXISTS ( " +
                "   SELECT 1 FROM register_entry_values rev3 " +
                "   WHERE rev3.entry_id = red.entry_id " +
                "   AND rev3.column_id = 12 " + // dispatch_date
                "   AND TRIM(rev3.value) <> '' " +
                ")";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, system);
            ps.setString(3, startDate);
            ps.setString(4, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("count");
            }
        }
        return 0;
    }

}