<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userrole = session.getAttribute("role").toString();
    String username = session.getAttribute("username").toString();

    String name = "";
    String email = "";

    ServletContext context = getServletContext();
    String dbUrl = (String) context.getAttribute("db_url");
    String dbUser = (String) context.getAttribute("db_username");
    String dbPass = (String) context.getAttribute("db_password");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "SELECT * FROM users WHERE username = ? AND role = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, username);
        stmt.setString(2, userrole);

        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            email = rs.getString("email");
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
</head>
<body>
    <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>

    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Edit Profile</h1>
                <p class="hero-description">Update your personal information and password</p>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="main-content">
            <div class="management-section active">
                <% if (error != null) { %>
                    <div class="alert alert-danger"><%= error %></div>
                <% } else if (success != null) { %>
                    <div class="alert alert-success"><%= success %></div>
                <% } %>

                <div class="section-header">
                    <h3 class="section-subtitle">Edit Your Profile</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='<%= userrole %>'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>

                <form id="editProfileForm" action="edit-profile" method="post">
                    <input type="hidden" name="role" value="<%= userrole %>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" value="<%= name %>" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" value="<%= username %>" class="form-control" readonly>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" value="<%= email %>" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Current Password</label>
                            <div class="password-wrapper">
                                <input type="password" name="currentPassword" class="form-control" placeholder="Enter current password">
                                <i class="fas fa-eye toggle-password"></i>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">New Password</label>
                            <div class="password-wrapper">
                                <input type="password" name="newPassword" class="form-control" placeholder="Enter new password">
                                <i class="fas fa-eye toggle-password"></i>
                            </div>
                        </div>
                    </div>

                    <div class="form-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Profile
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="WEB-INF/notif.jsp" %>

    <script>
        // Toggle password visibility
        document.querySelectorAll('.toggle-password').forEach(icon => {
            icon.addEventListener('click', function() {
                const input = this.previousElementSibling;
                const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                input.setAttribute('type', type);
                this.classList.toggle('fa-eye-slash');
                this.classList.toggle('fa-eye');
            });
        });
    </script>
</body>
</html>