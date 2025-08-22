<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
// Get user role from session
String backUrl = "login.jsp"; // Default fallback
String userRole = (String) session.getAttribute("role");
if (userRole == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Set appropriate back URL based on role
if ("admin".equals(userRole)) {
    backUrl = "admin";
} else if ("superadmin".equals(userRole)) {
    backUrl = "superadmin";
}

String id = request.getParameter("id");
String name = "";
String username = "";
String email = "";
String departmentId = "";
String departmentName = "";
String success = request.getParameter("success");
String error = request.getParameter("error");

ServletContext context = request.getServletContext();
String dbUrl = (String) context.getAttribute("db_url");
String dbUsername = (String) context.getAttribute("db_username");
String dbPassword = (String) context.getAttribute("db_password");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    String sql = "SELECT u.*, d.name AS department_name FROM users u LEFT JOIN departments d ON u.department_id = d.department_id WHERE u.id = ?";
    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, id);
    ResultSet rs = stmt.executeQuery();
    
    if (rs.next()) {
        name = rs.getString("name");
        username = rs.getString("username");
        email = rs.getString("email");
        departmentId = rs.getString("department_id");
        departmentName = rs.getString("department_name");
    }
    
    rs.close();
    stmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Member - NWR Super Admin</title>
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
                <h1 class="hero-title">Edit Member Details</h1>
                <p class="hero-description">Update member information</p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="main-content">
            <h2 class="section-title">Member Management</h2>
            
            <!-- Management Section -->
            <div class="management-section active">
                <% if (error != null) { %>
                    <div class="alert alert-danger"><%= error %></div>
                <% } else if (success != null) { %>
                    <div class="alert alert-success"><%= success %></div>
                <% } %>
                
                <div class="section-header">
                    <h3 class="section-subtitle">Edit Member Information</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='<%= backUrl %>'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>
                
                <form id="editMemberForm" action="edit-member" method="post">
                    <input type="hidden" name="id" value="<%= id %>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" value="<%= name %>" class="form-control" placeholder="Enter full name" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" value="<%= username %>" class="form-control" placeholder="Enter username" readonly>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" value="<%= email %>" class="form-control" placeholder="Enter email" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Department</label>
                            <% if ("superadmin".equals(userRole)) { %>
                                <!-- Superadmin sees normal select -->
                                <select name="department_id" class="form-control" required>
                                    <option value="">Select Department</option>
                                    <% 
                                        try {
                                            Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
                                            Statement stmt = conn.createStatement();
                                            ResultSet rs = stmt.executeQuery("SELECT department_id, name FROM departments");
                                            while (rs.next()) {
                                                String deptId = rs.getString("department_id");
                                                String deptName = rs.getString("name");
                                                String selected = deptId.equals(departmentId) ? "selected" : "";
                                                out.println("<option value='" + deptId + "' " + selected + ">" + deptName + "</option>");
                                            }
                                            rs.close();
                                            stmt.close();
                                            conn.close();
                                        } catch (SQLException e) {
                                            e.printStackTrace();
                                        }
                                    %>
                                </select>
                            <% } else { %>
                                <!-- Admin sees disabled field showing their department -->
                                <input type="text" class="form-control" value="<%= departmentName != null ? departmentName : "No Department" %>" disabled>
                                <input type="hidden" name="department_id" value="<%= departmentId %>">
                            <% } %>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Update Member
                    </button>
                </form>
            </div>
        </div>
    </div>
  
    <%@ include file="WEB-INF/notif.jsp" %>
</body>
</html>