<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.ServletContext" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String departmentIdParam = request.getParameter("id");
    String currentDepartmentName = "";
    int departmentId = 0;

    if (departmentIdParam == null || departmentIdParam.trim().isEmpty()) {
        response.sendRedirect("superadmin?error=No+department+selected");
        return;
    }

    try {
        departmentId = Integer.parseInt(departmentIdParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("superadmin?error=Invalid+department+ID");
        return;
    }

    ServletContext context = request.getServletContext();
    String dbUrl = (String) context.getAttribute("db_url");
    String dbUsername = (String) context.getAttribute("db_username");
    String dbPassword = (String) context.getAttribute("db_password");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        String sql = "SELECT name FROM departments WHERE department_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, departmentId);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            currentDepartmentName = rs.getString("name");
        } else {
            response.sendRedirect("superadmin?error=Department+not+found");
            return;
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        response.sendRedirect("superadmin?error=Database+error");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Department - NWR Super Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
</head>
<body>
    <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>
    
    <!-- Top Navigation -->
    <%@ include file="WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Edit Department Details</h1>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">Department Management</h2>
        
        <!-- Edit Form Container -->
        <div class="management-section active">
            <div class="section-header">
                    <h3 class="section-subtitle">Edit Member Information</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='superadmin'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>
            
            <form id="editDepartmentForm" action="edit-department" method="post">
                <input type="hidden" name="department_id" value="<%= departmentId %>">
                <input type="hidden" name="old_name" value="<%= currentDepartmentName %>">

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Department ID</label>
                        <input type="text" value="<%= departmentId %>" class="form-control" readonly>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Department Name</label>
                        <input type="text" name="new_name"
                               value="<%= currentDepartmentName %>"
                               class="form-control"
                               placeholder="Enter department name"
                               required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update Department
                </button>
            </form>
        </div>
    </div>
    <!-- Notification container -->
    <%@include file="WEB-INF/notif.jsp" %>
    
    
</body>
</html>