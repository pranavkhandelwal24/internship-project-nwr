<%@ page import="java.sql.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%! // This defines a method that can be used throughout the JSP
    public String escapeHtml(String unsafe) {
        if (unsafe == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(unsafe.length());
        for (int i = 0; i < unsafe.length(); i++) {
            char c = unsafe.charAt(i);
            switch (c) {
                case '&': sb.append("&amp;"); break;
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#039;"); break; // For apostrophe
                default: sb.append(c);
            }
        }
        return sb.toString();
    }
%>

<%
    // Retrieve data from request attributes (set by AddDynamicFormServlet in case of ERROR)
    // Or from request parameters (for initial load)
    String id = (String) request.getAttribute("registerId"); 
    if (id == null) { 
        id = request.getParameter("registerId");
    }

    // Messages:
    // Success messages come from session (after redirect) and cause form reset.
    // Error messages come from request (after forward) and preserve form data.
    String successMessage = (String) session.getAttribute("formSuccessMessage");
    String errorMessage = (String) request.getAttribute("formErrorMessage"); // Get from request attribute on error

    // Clear session success message after retrieving it to prevent re-display
    if (successMessage != null) {
        session.removeAttribute("formSuccessMessage");
    }

    // Pre-filled form data (only present if there was an error and AddDynamicFormServlet forwarded)
    Map<String, String> formData = (Map<String, String>) request.getAttribute("formData");
    if (formData == null) {
        formData = new HashMap<>(); // Initialize if not present (fresh load or success redirect)
    }

    String registerName = ""; 
    String registerDescription = ""; 

    Connection conn = null;
    List<Map<String, Object>> orderedColumnsMeta = new ArrayList<>(); 

    try {
        String dbUrl = (String) getServletContext().getAttribute("db_url");
        String dbUser = (String) getServletContext().getAttribute("db_username");
        String dbPass = (String) getServletContext().getAttribute("db_password");

        if (dbUrl == null || dbUser == null || dbPass == null) {
            // If DB config is missing, set an error message and skip DB operations
            errorMessage = "Database configuration missing. Please ensure your application listener is correctly initializing database parameters.";
        } else {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            if (id != null && !id.isEmpty()) {
                String getRegisterInfoSql = "SELECT name, description FROM registers WHERE register_id = ?";
                try (PreparedStatement rsStmt = conn.prepareStatement(getRegisterInfoSql)) {
                    rsStmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = rsStmt.executeQuery();
                    if (rs.next()) {
                        registerName = rs.getString("name");
                        registerDescription = rs.getString("description");
                    }
                }
            }

            String getColumnsSql = "SELECT column_id, label, field_name, data_type, is_required, is_unique, options FROM register_columns WHERE register_id = ? ORDER BY ordering";
            try (PreparedStatement stmt = conn.prepareStatement(getColumnsSql)) {
                if (id != null && !id.isEmpty()) {
                    stmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = stmt.executeQuery();
                    while (rs.next()) {
                        Map<String, Object> colData = new HashMap<>();
                        colData.put("column_id", rs.getInt("column_id"));
                        colData.put("label", rs.getString("label"));
                        colData.put("field_name", rs.getString("field_name")); 
                        colData.put("data_type", rs.getString("data_type"));
                        colData.put("is_required", rs.getBoolean("is_required"));
                        colData.put("is_unique", rs.getBoolean("is_unique"));
                        colData.put("options", rs.getString("options"));
                        orderedColumnsMeta.add(colData); 
                    }
                }
            }
        }
    } catch (Exception e) { 
        e.printStackTrace();
        if (errorMessage == null || errorMessage.isEmpty()) { 
             errorMessage = "Error loading form data: " + e.getMessage();
        }
    } finally {
        if (conn != null) {
            try { 
                conn.close(); 
            } catch (SQLException e) { 
                System.err.println("Error closing database connection in dynamic-form.jsp: " + e.getMessage());
                e.printStackTrace(); 
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Entry - <%= registerName.isEmpty() ? "Dynamic Register" : escapeHtml(registerName) %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/superadmin.css">
    <style>
        .required-field::after {
            content: ' *';
            color: #f72585;
        }
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
        }
        .management-section {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
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
                <h1 class="hero-title">New Entry for <%= registerName.isEmpty() ? "Dynamic Register" : escapeHtml(registerName) %></h1>
                <p class="hero-description"><%= escapeHtml(registerDescription.isEmpty() ? "Please fill out the form below to submit your entry." : registerDescription) %></p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="main-content">
            <% if (id == null || id.isEmpty() || orderedColumnsMeta.isEmpty()) { %>
                <div class="management-section active" style="text-align: center; padding: 40px; color: #6c757d;">
                    <i class="fas fa-exclamation-circle" style="font-size: 3rem; opacity: 0.5; margin-bottom: 15px;"></i>
                    <p>No form found or invalid register ID provided. Please return to the dashboard and select a register.</p>
                    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                        <div class="alert alert-danger"><%= escapeHtml(errorMessage) %></div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="management-section active">
                    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                        <div class="alert alert-danger"><%= escapeHtml(errorMessage) %></div>
                    <% } %>
                    <% if (successMessage != null && !successMessage.isEmpty()) { %>
                        <div class="alert alert-success"><%= escapeHtml(successMessage) %></div>
                    <% } %>
                    
                    <form id="registerEntryForm" action="<%= request.getContextPath() %>/add-dynamic-form" method="post">
                        <input type="hidden" id="registerId" name="registerId" value="<%= escapeHtml(id) %>">
                        <input type="hidden" id="submittedBy" name="submittedBy" value="<%= session.getAttribute("userId") %>">
                        
                        <% if (orderedColumnsMeta.isEmpty()) { %>
                            <p class="no-fields">No fields defined for this register. Please contact your administrator.</p>
                        <% } else { %>
                            <div class="form-grid">
                                <% 
                                    for (Map<String, Object> colData : orderedColumnsMeta) {
                                        String fieldName = (String) colData.get("field_name"); 
                                        String label = (String) colData.get("label");
                                        String dataType = (String) colData.get("data_type");
                                        boolean isRequired = (Boolean) colData.get("is_required");
                                        String options = (String) colData.get("options");

                                        String requiredAttr = isRequired ? "required" : "";
                                        String requiredClass = isRequired ? "required-field" : "";
                                        String currentValue = formData.getOrDefault(fieldName, ""); 
                                %>
                                        <div class="form-group">
                                            <label for="<%= escapeHtml(fieldName) %>" class="form-label <%= requiredClass %>"><%= escapeHtml(label) %></label>
                                            <% if ("enum".equalsIgnoreCase(dataType) && options != null && !options.isEmpty()) { %>
                                                <select name="<%= escapeHtml(fieldName) %>" id="<%= escapeHtml(fieldName) %>" class="form-control" <%= requiredAttr %>>
                                                    <option value="">-- Select --</option>
                                                    <% for (String option : options.split(",")) {
                                                        String trimmedOption = option.trim();
                                                        if (!trimmedOption.isEmpty()) {
                                                            String selected = currentValue.equals(trimmedOption) ? "selected" : "";
                                                    %>
                                                            <option value="<%= escapeHtml(trimmedOption) %>" <%= selected %>><%= escapeHtml(trimmedOption) %></option>
                                                    <%  }
                                                    } %>
                                                </select>
                                            <% } else if ("date".equalsIgnoreCase(dataType)) { %>
                                                <input type="date" name="<%= escapeHtml(fieldName) %>" id="<%= escapeHtml(fieldName) %>" class="form-control" value="<%= escapeHtml(currentValue) %>" <%= requiredAttr %>>
                                            <% } else if ("number".equalsIgnoreCase(dataType) || "decimal".equalsIgnoreCase(dataType)) { %>
                                                <input type="<%="number".equalsIgnoreCase(dataType)?"number":"text"%>" step="any" name="<%= escapeHtml(fieldName) %>" id="<%= escapeHtml(fieldName) %>" class="form-control" value="<%= escapeHtml(currentValue) %>" <%= requiredAttr %>>
                                            <% } else { %> 
                                                <input type="text" name="<%= escapeHtml(fieldName) %>" id="<%= escapeHtml(fieldName) %>" class="form-control" value="<%= escapeHtml(currentValue) %>" <%= requiredAttr %>>
                                            <% } %>
                                        </div>
                                <%  } %>
                            </div>
                            <div class="form-actions">
                                <button type="button" class="btn btn-secondary" onclick="window.location.href='<%= request.getContextPath() %>/member'">
                                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                                </button>
                                <button type="submit" class="btn btn-primary" id="submitEntryBtn">
                                    <i class="fas fa-save"></i> Submit Entry
                                </button>
                            </div>
                        <% } %>
                    </form>
                </div>
            <% } %>
        </div>
    </div>

    <%@ include file="WEB-INF/notif.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Function to decode HTML entities in JavaScript
            function decodeHtmlEntities(text) {
                const textArea = document.createElement('textarea');
                textArea.innerHTML = text;
                return textArea.value;
            }

            // Retrieve messages from session (for success) or request (for error)
            const rawSuccessMsg = "<%= successMessage != null ? escapeHtml(successMessage) : "" %>"; 
            const rawErrorMsg = "<%= errorMessage != null ? escapeHtml(errorMessage) : "" %>";

            // Decode HTML entities before passing to showNotification
            const decodedSuccessMsg = decodeHtmlEntities(rawSuccessMsg);
            const decodedErrorMsg = decodeHtmlEntities(rawErrorMsg);

            if (decodedSuccessMsg.trim() !== "") {
                showNotification('success', decodedSuccessMsg);
            }
            if (decodedErrorMsg.trim() !== "") {
                showNotification('error', decodedErrorMsg);
            }

            const form = document.getElementById('registerEntryForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    const submitBtn = document.getElementById('submitEntryBtn');
                    if (submitBtn) {
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
                        submitBtn.disabled = true;
                    }
                });
            }
        });
    </script>
</body>
</html>