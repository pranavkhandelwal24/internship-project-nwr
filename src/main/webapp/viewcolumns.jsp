<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="register" value="${requestScope.register}" />
<c:set var="columns" value="${requestScope.columns}" />
<c:set var="errorMessage" value="${requestScope.errorMessage}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>View Register Columns - NWR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
        .register-columns-container {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--glass-border);
            animation: fadeIn 0.6s ease;
        }
        
        .register-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .register-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 5px;
        }
        
        .register-description {
            color: var(--gray);
            font-size: 0.95rem;
        }
        
        .register-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .meta-item {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .meta-label {
            font-weight: 500;
            color: var(--primary);
        }
        
        .meta-value {
            color: var(--gray-dark);
        }
        
        .columns-table-container {
            overflow-x: auto;
            margin-top: 25px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            background: rgba(255, 255, 255, 0.95);
            -webkit-overflow-scrolling: touch;
        }
        
        .columns-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            min-width: 800px;
        }
        
        .columns-table th {
            background: linear-gradient(to bottom, var(--primary), var(--primary-dark));
            color: white;
            padding: 14px 16px;
            text-align: left;
            font-weight: 600;
            font-size: 0.95rem;
            border-bottom: 2px solid var(--primary-darker);
            position: sticky;
            top: 0;
        }
        
        .columns-table td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            vertical-align: middle;
            font-size: 0.9rem;
            color: var(--primary-darker);
        }
        
        .columns-table tr:nth-child(even) {
            background: rgba(0, 86, 179, 0.03);
        }
        
        .columns-table tr:last-child td {
            border-bottom: none;
        }
        
        .columns-table tr:hover td {
            background: rgba(0, 86, 179, 0.08);
        }
        
        /* Compact view styles */
        .columns-table.compact-view td {
            padding: 6px 10px;
            font-size: 0.85rem;
        }
        
        .columns-table.compact-view th {
            padding: 8px 10px;
            font-size: 0.85rem;
        }
        
        .columns-table.compact-view .badge {
            padding: 3px 6px;
            font-size: 0.75rem;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            margin-top: 25px;
        }
        
        .empty-state i {
            font-size: 3rem;
            color: var(--primary-light);
            margin-bottom: 15px;
        }
        
        .empty-state h4 {
            color: var(--primary-darker);
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: var(--gray);
        }
        
        .view-toggle {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .view-toggle-btn {
            background: rgba(0, 86, 179, 0.1);
            border: none;
            padding: 8px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 6px;
            color: var(--primary);
            font-size: 0.85rem;
        }
        
        .view-toggle-btn.active {
            background: var(--primary);
            color: white;
        }
        
        .view-toggle-btn:hover {
            background: rgba(0, 86, 179, 0.2);
        }
        
        @media (max-width: 768px) {
            .register-meta {
                flex-direction: column;
                gap: 10px;
            }
            
            .view-toggle {
                justify-content: center;
            }
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
                <h1 class="hero-title">Register Columns</h1>
                <p class="hero-description">
                    View column definitions for register: ${register.name}
                    <c:if test="${not empty errorMessage}">
                        <div class="error-message">${errorMessage}</div>
                    </c:if>
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <a href="admin" class="btn btn-primary" style="margin-bottom: 20px; display: inline-flex; align-items: center; gap: 8px; text-decoration: none">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
        
        <div class="register-columns-container">
            <div class="register-header">
                <div>
                    <h2 class="register-title">${register.name}</h2>
                    <p class="register-description">${not empty register.description ? register.description : 'No description available'}</p>
                </div>
            </div>
            
            <div class="register-meta">
                <div class="meta-item">
                    <span class="meta-label">Created By:</span>
                    <span class="meta-value">${register.created_by_name}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Created On:</span>
                    <span class="meta-value">${register.created_at}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Total Columns:</span>
                    <span class="meta-value">${columns.size()}</span>
                </div>
            </div>
            
            <h3 class="section-subtitle" style="margin-top: 30px;">Column Definitions</h3>
            
            
            
            <c:choose>
                <c:when test="${empty columns}">
                    <div class="empty-state">
                        <i class="fas fa-columns"></i>
                        <h4>No Columns Defined</h4>
                        <p>This register doesn't have any columns yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="columns-table-container">
                        <table class="columns-table" id="columnsTable">
                            <thead>
                                <tr>
                                    <th>Label</th>
                                    <th>Field Name</th>
                                    <th>Data Type</th>
                                    <th>Required</th>
                                    <th>Unique</th>
                                    <th>Options</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${columns}" var="column">
                                    <tr>
                                        <td>${column.label}</td>
                                        <td>${column.field_name}</td>
                                        <td><span class="badge badge-superadmin">${column.data_type}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${column.is_required == 1}">
                                                    <span class="badge badge-success">Yes</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-warning">No</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${column.is_unique == 1}">
                                                    <span class="badge badge-success">Yes</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-warning">No</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${not empty column.options && column.data_type == 'enum'}">
                                                <span class="badge badge-info">${column.options}</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <!-- Footer -->
    <%@include file="WEB-INF/footer.jsp" %>
    
    <!-- Notification container -->
    <%@include file="WEB-INF/notif.jsp" %>
    
    
</body>
</html>