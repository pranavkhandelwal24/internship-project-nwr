<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>

<%-- ✅ Defensive check --%>
<%
    if (session == null || session.getAttribute("username") == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String roleSession = (String) session.getAttribute("role");
    String usernameSession = (String) session.getAttribute("username");
    String dep = null;

    if ("admin".equals(roleSession) || "member".equals(roleSession)) {
        Connection jodi = null;
        try {
            Properties props = new Properties();
            props.load(application.getResourceAsStream("/WEB-INF/config.properties"));
            String db_Url = props.getProperty("db_url");
            String db_User = props.getProperty("db_username");
            String db_Pass = props.getProperty("db_password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            jodi = DriverManager.getConnection(db_Url, db_User, db_Pass);

            // Updated query with JOIN to departments table
            String sql = "SELECT d.name AS department_name " +
                         "FROM users u " +
                         "LEFT JOIN departments d ON u.department_id = d.department_id " +
                         "WHERE u.username = ?";
            try (PreparedStatement pst = jodi.prepareStatement(sql)) {
                pst.setString(1, usernameSession);
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        dep = rs.getString("department_name");
                        if (dep != null) {
                            dep = dep.trim();
                        }
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            out.println("<!-- Error retrieving department: " + ex.getMessage() + " -->");
        } finally {
            try { if (jodi != null) jodi.close(); } catch (Exception ignored) {}
        }
    }
    
    
    
    // Get user's full name for display
    String fullName = (String) session.getAttribute("fullName");
    if ("superadmin".equals(roleSession) && session.getAttribute("superadminName") != null) {
        fullName = (String) session.getAttribute("superadminName");
    }
    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "User";
    }
    String[] nameParts = fullName.trim().split("\\s+");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Navigation Bar</title>
    <link rel="stylesheet" href="css/navbar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
    <div class="top-nav">
        <div class="nav-left">
            <div class="logo">
			    <a href="dev.jsp"> <!-- Change "home.jsp" to your desired destination page -->
			        <img src="assets/logo.png" alt="Indian Railways">
			    </a>
			    <div class="nav-title">North Western Railway</div>
			</div>
        </div>
        <div class="nav-right">
            <div class="user-menu" id="userMenu">
                <div class="user-info">
                    <div class="user-avatar">
                        <%
                            String initials = nameParts[0].substring(0, 1);
                            if (nameParts.length > 1) {
                                initials += nameParts[nameParts.length - 1].substring(0, 1);
                            }
                            out.print(initials.toUpperCase());
                        %>
                    </div>
                    <div class="user-details">
                        <h4><%= nameParts[0] %></h4>
                        <p>
                            <% 
                                if ("superadmin".equals(roleSession)) out.print("Super Admin");
                                else if ("admin".equals(roleSession)) out.print("Admin");
                                else if ("member".equals(roleSession)) out.print("Member");
                                else out.print("User");
                            %>
                        </p>
                    </div>
                    <i class="fas fa-chevron-down"></i>
                </div>
                <div class="dropdown-menu" id="dropdownMenu">
                    <a href="edit-profile.jsp" class="dropdown-item">
                        <i class="fas fa-user-cog"></i> Edit Profile
                    </a>
                    <% if ("superadmin".equals(roleSession)) { %>
                        <a href="panel.jsp" class="dropdown-item">
                            <i class="fas fa-tachometer-alt"></i> SuperAdmin Panel
                        </a>
                    <% } else if ("admin".equals(roleSession)) { %>
                        <a href="admin" class="dropdown-item">
                            <i class="fas fa-tools"></i> Admin Dashboard
                        </a>
                    <% } else if ("member".equals(roleSession)) { %>
                        <a href="member" class="dropdown-item">
                            <i class="fas fa-user"></i> Member Dashboard
                        </a>
                    <% } %>

                    <%-- ✅ Show Reports link only for Accounts department --%>
                    <% 
                    if (("admin".equals(roleSession) || "member".equals(roleSession))) { 
                        if (dep != null && dep.equalsIgnoreCase("Accounts")) { 
                    %>
                        <a href="report.jsp" class="dropdown-item">
                            <i class="fas fa-file-alt"></i> Generate Report
                        </a>
                    <% 
                        } 
                    } 
                    %>

                    <a href="logout.jsp" class="dropdown-item">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const userMenu = document.getElementById('userMenu');
        const dropdownMenu = document.getElementById('dropdownMenu');

        if (userMenu && dropdownMenu) {
            userMenu.addEventListener('click', function(e) {
                e.stopPropagation();
                dropdownMenu.classList.toggle('show');
            });

            document.addEventListener('click', function() {
                dropdownMenu.classList.remove('show');
            });
        }
    });
    </script>
</body>
</html>