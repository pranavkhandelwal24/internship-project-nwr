<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get user role from session for navigation and authorization display
    String backUrl = "login.jsp"; // Default fallback
    String userRole = (String) session.getAttribute("role");
    Integer userId = (Integer) session.getAttribute("userId"); // Get current user ID
    Integer userDepartmentId = (Integer) session.getAttribute("department_id"); // Get current user's department ID

    if (userRole == null || userId == null ) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Set appropriate back URL based on role
    if ("admin".equals(userRole)) {
        backUrl = "admin";
    } else if ("superadmin".equals(userRole)) {
        backUrl = "superadmin";
    } else if ("member".equals(userRole)) {
        backUrl = "member";
    }

    // Retrieve data passed from the servlet
    String entryId = (String) request.getAttribute("entryId");
    String registerId = (String) request.getAttribute("registerId");
    String dynamicFormHtml = (String) request.getAttribute("dynamicFormHtml");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String entryTitle = (String) request.getAttribute("entryTitle"); // Title for the hero section

    if (entryId == null || registerId == null || dynamicFormHtml == null) {
        // This indicates a direct access or an error in servlet forwarding
        error = "Invalid entry or register ID provided, or data could not be loaded.";
        dynamicFormHtml = "<div style=\"text-align: center; padding: 40px; color: #dc3545;\">" +
                          "<i class=\"fas fa-exclamation-triangle\" style=\"font-size: 3rem; opacity: 0.7; margin-bottom: 15px;\"></i>" +
                          "<h4 style=\"color: #dc3545;\">Error Loading Entry</h4>" +
                          "<p style=\"color: #6c757d;\">Please go back to the dashboard and try again.</p>" +
                          "</div>";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>Edit Entry - NWR Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css"> <%-- Reusing superadmin.css for consistent styling --%>
    <style>
        /* LABEL FIX - CORE SOLUTION */
        label {
            display: block !important;
            margin-bottom: 8px !important;
            font-family: 'Poppins', sans-serif !important;
            font-size: 14px !important;
            font-weight: 500 !important;
            color: #333 !important;
        }

        /* Form Styles */
        .dynamic-form-container {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .form-group.dynamic-field {
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
        }

        .required-field::after {
            content: " *";
            color: #f72585;
        }

        /* Alert Styles (copied from superadmin.css or similar) */
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 5px;
            font-family: 'Poppins', sans-serif;
            font-size: 1rem;
        }

        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }

        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
    </style>
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
                <h1 class="hero-title">Edit Entry: <%= entryTitle != null ? entryTitle : "Loading..." %></h1>
                <p class="hero-description">Update the details for this register entry.</p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="main-content">
            <h2 class="section-title">Entry Management</h2>

            <!-- Management Section -->
            <div class="management-section active">
                <% if (error != null) { %>
                    <div class="alert alert-danger"><%= error %></div>
                <% } else if (success != null) { %>
                    <div class="alert alert-success"><%= success %></div>
                <% } %>

                <div class="section-header">
                    <h3 class="section-subtitle">Edit Entry Information</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='<%= backUrl %>'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>

                <div id="dynamicFormContainer" class="dynamic-form-container">
                    <%= dynamicFormHtml != null ? dynamicFormHtml : "" %>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="WEB-INF/notif.jsp" %>
</body>
</html>