<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
// Database connection and data retrieval
Connection conn = null;
Statement stmt = null;
ResultSet set = null;
try {
    // Load database configuration
    Properties props = new Properties();
    props.load(application.getResourceAsStream("/WEB-INF/config.properties"));
    String db_Url = props.getProperty("db_url");
    String db_User = props.getProperty("db_username");
    String db_Pass = props.getProperty("db_password");

    // Connect to database
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(db_Url, db_User, db_Pass);
    
    // Get inactive users
    String inactiveUsersQuery = "SELECT u.*, d.name as department_name FROM users u " +
                               "LEFT JOIN departments d ON u.department_id = d.department_id " +
                               "WHERE u.status = 'inactive'";
    stmt = conn.createStatement();
    set = stmt.executeQuery(inactiveUsersQuery);
    
    List<Map<String, String>> inactiveUsers = new ArrayList<>();
    while (set.next()) {
        Map<String, String> user = new HashMap<>();
        user.put("id", set.getString("id"));
        user.put("name", set.getString("name"));
        user.put("username", set.getString("username"));
        user.put("email", set.getString("email"));
        user.put("department_name", set.getString("department_name"));
        user.put("role", set.getString("role"));
        inactiveUsers.add(user);
    }
    
    // Get all superadmins
    String superadminsQuery = "SELECT u.*, d.name as department_name FROM users u " +
                             "LEFT JOIN departments d ON u.department_id = d.department_id " +
                             "WHERE u.role = 'superadmin'";
    set = stmt.executeQuery(superadminsQuery);
    
    List<Map<String, String>> superadmins = new ArrayList<>();
    while (set.next()) {
        Map<String, String> user = new HashMap<>();
        user.put("id", set.getString("id"));
        user.put("name", set.getString("name"));
        user.put("username", set.getString("username"));
        user.put("email", set.getString("email"));
        user.put("department_name", set.getString("department_name"));
        user.put("role", set.getString("role"));
        superadmins.add(user);
    }
    
    // Get login logs with user details
    String loginLogsQuery = "SELECT ll.*, u.name as user_name, u.username, u.role, " +
                           "d.name as department_name FROM login_logs ll " +
                           "LEFT JOIN users u ON ll.user_id = u.id " +
                           "LEFT JOIN departments d ON u.department_id = d.department_id " +
                           "ORDER BY ll.login_time DESC LIMIT 100";
    set = stmt.executeQuery(loginLogsQuery);
    
    List<Map<String, String>> loginLogs = new ArrayList<>();
    while (set.next()) {
        Map<String, String> log = new HashMap<>();
        log.put("id", set.getString("ll.id"));
        log.put("user_id", set.getString("ll.user_id"));
        log.put("user_name", set.getString("user_name"));
        log.put("username", set.getString("username"));
        log.put("role", set.getString("u.role"));
        log.put("department_name", set.getString("department_name"));
        log.put("ip_address", set.getString("ll.ip_address"));
        log.put("login_time", set.getString("ll.login_time"));
        loginLogs.add(log);
    }
    
    // Store in request attributes
    request.setAttribute("inactiveUsers", inactiveUsers);
    request.setAttribute("superadmins", superadmins);
    request.setAttribute("loginLogs", loginLogs);
    
} catch (Exception e) {
    e.printStackTrace();
    request.setAttribute("errorMessage", "Error loading user data: " + e.getMessage());
} finally {
    // Close resources
    if (set != null) try { set.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
}
%>

<!DOCTYPE html>
<html lang="en">
<head> 
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>NWR User Panel</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
        .badge-log {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        .badge-log-admin {
            background-color: #ffc107;
            color: #000;
        }
        .badge-log-superadmin {
            background-color: #dc3545;
            color: #fff;
        }
        .badge-log-member {
            background-color: #17a2b8;
            color: #fff;
        }
        .ip-address {
            font-family: monospace;
            background-color: #f8f9fa;
            padding: 2px 5px;
            border-radius: 3px;
            font-size: 13px;
        }
    </style>
</head>
<body>
   
   <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>
    
    <!-- Top Navigation -->
    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Superadmin Panel</h1>
                <p class="hero-description">
                    View inactive users, superadmin details, and login logs.
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" style="margin-top: 15px;">
                            ${errorMessage}
                        </div>
                    </c:if>
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">User Information</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card" id="inactiveUsersCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-user-slash"></i>
                    </div>
                    <h3 class="feature-title">Inactive Users</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View all inactive users across all roles and departments.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="superadminsCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <h3 class="feature-title">Super Admins</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View all super admin users with their details.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="loginLogsCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-sign-in-alt"></i>
                    </div>
                    <h3 class="feature-title">Login Logs</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View recent login activity across the system.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- Inactive Users Section -->
        <div class="management-section" id="inactiveUsersSection">
            <div class="section-header">
                <h3 class="section-subtitle">Inactive Users</h3>
                <button class="close-section" onclick="closeSection('inactiveUsersSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Role</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty inactiveUsers}">
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-user-slash" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Inactive Users Found</h4>
                                        <p style="color: var(--gray);">All users are currently active</p>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${inactiveUsers}" var="user">
                                    <tr>
                                        <td>${user.id}</td>
                                        <td>${user.name}</td>
                                        <td>${user.username}</td>
                                        <td>${user.email}</td>
                                        <td>${user.department_name}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${user.role == 'superadmin'}">
                                                    <span class="badge badge-superadmin">Super Admin</span>
                                                </c:when>
                                                <c:when test="${user.role == 'admin'}">
                                                    <span class="badge badge-admin">Admin</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-member">Member</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Super Admins Section -->
        <div class="management-section" id="superadminsSection">
            <div class="section-header">
                <h3 class="section-subtitle">Super Admins</h3>
                <button class="close-section" onclick="closeSection('superadminsSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Department</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty superadmins}">
                                <tr>
                                    <td colspan="5" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-user-shield" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Super Admins Found</h4>
                                        <p style="color: var(--gray);">No super admin users exist in the system</p>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${superadmins}" var="user">
                                    <tr>
                                        <td>${user.id}</td>
                                        <td>${user.name}</td>
                                        <td>${user.username}</td>
                                        <td>${user.email}</td>
                                        <td>${user.department_name}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Login Logs Section -->
        <div class="management-section" id="loginLogsSection">
            <div class="section-header">
                <h3 class="section-subtitle">Recent Login Activity</h3>
                <button class="close-section" onclick="closeSection('loginLogsSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>User</th>
                            <th>Username</th>
                            <th>Role</th>
                            <th>Department</th>
                            <th>IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty loginLogs}">
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px;">
                                        <i class="fas fa-sign-in-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                        <h4 style="color: var(--primary);">No Login Logs Found</h4>
                                        <p style="color: var(--gray);">No login activity has been recorded yet</p>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${loginLogs}" var="log">
                                    <tr>
                                        <td>${log.login_time}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty log.user_name}">
                                                    ${log.user_name}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #999;">User Deleted</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty log.username}">
                                                    ${log.username}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #999;">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.role == 'superadmin'}">
                                                    <span class="badge-log badge-log-superadmin">Super Admin</span>
                                                </c:when>
                                                <c:when test="${log.role == 'admin'}">
                                                    <span class="badge-log badge-log-admin">Admin</span>
                                                </c:when>
                                                <c:when test="${log.role == 'member'}">
                                                    <span class="badge-log badge-log-member">Member</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #999;">Unknown</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty log.department_name}">
                                                    ${log.department_name}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #999;">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="ip-address">${log.ip_address}</span></td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        
        <%@ include file="WEB-INF/importantlinks.jsp" %>
    </div>
    
    <!-- Footer -->
    <%@include file="WEB-INF/footer.jsp" %>
    
    <!-- Notification container -->
    <%@include file="WEB-INF/notif.jsp" %>
    
    <script>
    // Feature cards
    const inactiveUsersCard = document.getElementById('inactiveUsersCard');
    const superadminsCard = document.getElementById('superadminsCard');
    const loginLogsCard = document.getElementById('loginLogsCard');
    const inactiveUsersSection = document.getElementById('inactiveUsersSection');
    const superadminsSection = document.getElementById('superadminsSection');
    const loginLogsSection = document.getElementById('loginLogsSection');

    inactiveUsersCard.addEventListener('click', function() {
        superadminsSection.classList.remove('active');
        superadminsCard.classList.remove('active');
        loginLogsSection.classList.remove('active');
        loginLogsCard.classList.remove('active');

        inactiveUsersSection.classList.add('active');
        inactiveUsersCard.classList.add('active');
        inactiveUsersSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    superadminsCard.addEventListener('click', function() {
        inactiveUsersSection.classList.remove('active');
        inactiveUsersCard.classList.remove('active');
        loginLogsSection.classList.remove('active');
        loginLogsCard.classList.remove('active');

        superadminsSection.classList.add('active');
        superadminsCard.classList.add('active');
        superadminsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    loginLogsCard.addEventListener('click', function() {
        inactiveUsersSection.classList.remove('active');
        inactiveUsersCard.classList.remove('active');
        superadminsSection.classList.remove('active');
        superadminsCard.classList.remove('active');

        loginLogsSection.classList.add('active');
        loginLogsCard.classList.add('active');
        loginLogsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');

        if (sectionId === 'inactiveUsersSection') {
            inactiveUsersCard.classList.remove('active');
        } else if (sectionId === 'superadminsSection') {
            superadminsCard.classList.remove('active');
        } else if (sectionId === 'loginLogsSection') {
            loginLogsCard.classList.remove('active');
        }
    }

    // Animate on load
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.style.animation = 'fadeInUp 0.6s ease-out forwards';
            }, index * 150);
        });
    });
    </script>
</body>
</html>