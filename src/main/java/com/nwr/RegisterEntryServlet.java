package com.nwr;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.math.BigDecimal;
import javax.servlet.ServletContext;

@WebServlet("/register-entry")
public class RegisterEntryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Get session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            out.print("{\"status\":\"error\",\"message\":\"Session expired. Please login again.\"}");
            return;
        }

        String username = (String) session.getAttribute("username");
        Integer departmentId = (Integer) session.getAttribute("department_id");

        // Get parameters
        String system = request.getParameter("system");
        String ifileNoStr = request.getParameter("ifile_no");
        String efileNoStr = request.getParameter("efile_no");
        String details = request.getParameter("details");
        String sanctionYear = request.getParameter("sanction_year");
        String subject = request.getParameter("subject");
        String proposedCostStr = request.getParameter("proposed_cost");
        String vettedCostStr = request.getParameter("vetted_cost");
        String receivedDate = request.getParameter("received_date");
        String putupDate = request.getParameter("putup_date");
        String dispatchDate = request.getParameter("dispatch_date");
        String status = request.getParameter("status");

        // Validate required fields
        if (ifileNoStr == null || ifileNoStr.isEmpty() ||
            efileNoStr == null || efileNoStr.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"Internal and External File Numbers are required.\"}");
            return;
        }

        Connection conn = null;

        try {
            int ifileNo = Integer.parseInt(ifileNoStr);
            int efileNo = Integer.parseInt(efileNoStr);

            ServletContext context = getServletContext();
            String dbUrl = (String) context.getAttribute("db_url");
            String dbUsername = (String) context.getAttribute("db_username");
            String dbPassword = (String) context.getAttribute("db_password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

            // Check duplicate
            String checkSql = "SELECT COUNT(*) FROM register_entries WHERE ifile_no = ? OR efile_no = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, ifileNo);
                ps.setInt(2, efileNo);
                ResultSet rs = ps.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("{\"status\":\"error\",\"message\":\"File number already exists.\"}");
                    return;
                }
            }

            // Validate proposed > vetted
            BigDecimal proposedCost = null;
            BigDecimal vettedCost = null;
            BigDecimal savings = null;

            if (proposedCostStr != null && !proposedCostStr.trim().isEmpty()) {
                proposedCost = new BigDecimal(proposedCostStr.trim());
            }

            if (vettedCostStr != null && !vettedCostStr.trim().isEmpty()) {
                vettedCost = new BigDecimal(vettedCostStr.trim());
            }

            if (proposedCost != null && vettedCost != null) {
                if (proposedCost.compareTo(vettedCost) <= 0) {
                    out.print("{\"status\":\"error\",\"message\":\"Proposed cost must be greater than vetted cost.\"}");
                    return;
                }
                savings = proposedCost.subtract(vettedCost);
            }

            String insertSql = "INSERT INTO register_entries " +
                    "(username, department_id, `system`, ifile_no, efile_no, details, sanction_year, " +
                    "subject, proposed_cost, vetted_cost, savings, received_date, putup_date, dispatch_date, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, username);
                ps.setInt(2, departmentId);
                ps.setString(3, system);
                ps.setInt(4, ifileNo);
                ps.setInt(5, efileNo);
                ps.setString(6, details);
                ps.setString(7, sanctionYear);
                ps.setString(8, subject);

                if (proposedCost != null) {
                    ps.setBigDecimal(9, proposedCost);
                } else {
                    ps.setNull(9, Types.DECIMAL);
                }

                if (vettedCost != null) {
                    ps.setBigDecimal(10, vettedCost);
                } else {
                    ps.setNull(10, Types.DECIMAL);
                }

                if (savings != null) {
                    ps.setBigDecimal(11, savings);
                } else {
                    ps.setNull(11, Types.DECIMAL);
                }

                ps.setString(12, receivedDate);
                ps.setString(13, (putupDate == null || putupDate.isEmpty()) ? null : putupDate);
                ps.setString(14, (dispatchDate == null || dispatchDate.isEmpty()) ? null : dispatchDate);
                ps.setString(15, (status == null || status.isEmpty()) ? null : status);

                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("{\"status\":\"success\",\"message\":\"File added successfully.\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Failed to add file.\"}");
                }
            }

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"File numbers must be numeric.\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage().replace("\"", "'") + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":\"Unexpected error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            out.flush();
        }
    }
}
