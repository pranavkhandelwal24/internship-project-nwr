<%@ page import="java.sql.*" %>
<%@ page import="java.util.Properties" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String id = request.getParameter("id");
    String name = "";
    String username = "";
    String email = "";
    String department = "";

    Connection conn = null;

    try {
        // Load config.properties
        Properties props = new Properties();
        props.load(application.getResourceAsStream("/WEB-INF/config.properties"));
        String dbUrl = props.getProperty("db_url");
        String dbUser = props.getProperty("db_username");
        String dbPass = props.getProperty("db_password");

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "SELECT u.*,d.name as department_name FROM users as u left join departments as d on u.department_id=d.department_id WHERE u.id = ? and u.role='admin'";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            username = rs.getString("username");
            email = rs.getString("email");
            department = rs.getString("department_name");
        }

        rs.close();
        stmt.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Admin - NWR Super Admin</title>
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
                <h1 class="hero-title">Edit Admin Details</h1>
                <p class="hero-description">Update administrator information and department assignment</p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="main-content">
            <h2 class="section-title">Admin Management</h2>
            
            <!-- Management Section -->
            <div class="management-section active">
                <div class="section-header">
                    <h3 class="section-subtitle">Edit Admin Information</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='superadmin'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>
                
                <form id="editAdminForm" action="edit-admin" method="post">
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
                            <select name="department" class="form-control" required>
                                <option value="">Select Department</option>
                                <%
                                Connection connDept = null;
                                try {
                                    Properties props = new Properties();
                                    props.load(application.getResourceAsStream("/WEB-INF/config.properties"));
                                    String dbUrl = props.getProperty("db_url");
                                    String dbUser = props.getProperty("db_username");
                                    String dbPass = props.getProperty("db_password");

                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    connDept = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                                    String sql = "SELECT name, department_head FROM departments";
                                    Statement stmt = connDept.createStatement();
                                    ResultSet rs = stmt.executeQuery(sql);

                                    while (rs.next()) {
                                        String deptName = rs.getString("name").trim();
                                        String deptHead = rs.getString("department_head");
                                        String currentDept = department.trim();

                                        if (deptName.equals(currentDept)) {
                                            out.println("<option value='" + deptName + "' selected>" + deptName + " (Current)</option>");
                                        } else if (deptHead == null || deptHead.trim().isEmpty()) {
                                            out.println("<option value='" + deptName + "'>" + deptName + "</option>");
                                        } else {
                                            out.println("<option disabled>" + deptName + " (Head Assigned)</option>");
                                        }
                                    }

                                    rs.close();
                                    stmt.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if (connDept != null) try { connDept.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Update Admin
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <%@ include file="WEB-INF/footer.jsp" %>
    
    <!-- Notification container -->
    <%@ include file="WEB-INF/notif.jsp" %>
</body>
</html>