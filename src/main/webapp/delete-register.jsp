<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Register - NWR Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">

    <style>
        /* Additional styles for the delete register page */
        .warning-card {
            display: flex;
            background: rgba(255, 193, 7, 0.15);
            border-left: 5px solid #ffc107;
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 8px;
            gap: 15px;
        }
        
        .warning-icon {
            font-size: 2rem;
            color: #ffc107;
        }
        
        .warning-content h4 {
            color: #856404;
            margin-bottom: 10px;
            font-size: 1.2rem;
        }
        
        .warning-content p {
            margin-bottom: 10px;
            color: #856404;
        }
        
        .warning-content ul {
            margin-bottom: 10px;
            padding-left: 20px;
        }
        
        .warning-content li {
            margin-bottom: 5px;
            color: #856404;
        }
        
        .download-section {
            margin-bottom: 25px;
        }
        
        .download-title {
            color: var(--primary-dark);
            margin-bottom: 15px;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .download-options {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .download-option {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: white;
            border: 1px solid var(--border);
            padding: 20px;
            border-radius: 8px;
            text-decoration: none;
            color: var(--primary-dark);
            transition: var(--transition);
            width: 150px;
        }
        
        .download-option:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            border-color: var(--primary);
        }
        
        .download-option i {
            font-size: 2rem;
            margin-bottom: 10px;
            color: var(--primary);
        }
        
        .confirm-section {
            background: rgba(220, 53, 69, 0.05);
            border-left: 5px solid var(--secondary);
            padding: 20px;
            border-radius: 8px;
        }
        
        .confirm-title {
            color: var(--secondary);
            margin-bottom: 15px;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .confirm-checkbox {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            color: var(--dark);
        }
        
        .confirm-checkbox input {
            width: auto;
        }
        
        .btn-danger {
            background: linear-gradient(90deg, var(--secondary), #e63946);
            color: white;
        }
        
        .btn-danger:hover {
            background: linear-gradient(90deg, #bb2d3b, var(--secondary));
            transform: translateY(-2px);
        }
        
        /* Ensure notification container is visible */
        .notification-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            width: 350px;
        }
    </style>
</head>
<body>
    <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>

    <%@ include file="WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Delete Register</h1>
                <p class="hero-description">Permanently remove register and all its data</p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="main-content">
            <h2 class="section-title">Register Management</h2>

            <div class="management-section active">
                <div class="section-header">
                    <h3 class="section-subtitle">Delete: ${register.name}</h3>
                    <button class="btn btn-sm btn-primary" onclick="window.location.href='admin'">
                        <i class="fas fa-arrow-left"></i> Back to Admin
                    </button>
                </div>

                <div class="warning-card">
                    <div class="warning-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <div class="warning-content">
                        <h4>Warning</h4>
                        <p>You are about to delete the register <strong>${register.name}</strong>. This will:</p>
                        <ul>
                            <li>Delete ${columnCount} columns</li>
                            <li>Delete ${entryCount} entries</li>
                            <li>This action cannot be undone</li>
                        </ul>
                        <p><strong>Recommendation:</strong> Download a backup first.</p>
                    </div>
                </div>

                <div class="download-section">
                    <h3 class="download-title"><i class="fas fa-download"></i> Download Data</h3>
                    <div class="download-options">
                        <a href="${pageContext.request.contextPath}/download-register?register_id=${register.registerId}&format=csv" class="download-option">
                            <i class="fas fa-file-csv"></i>
                            <span>CSV Export</span>
                        </a>
                    </div>
                </div>

                <div class="confirm-section">
                    <h3 class="confirm-title"><i class="fas fa-trash"></i> Confirm Deletion</h3>
                    <form id="deleteForm" method="post">
                        <input type="hidden" name="register_id" value="${register.registerId}">

                        <div class="form-group">
                            <label class="confirm-checkbox">
                                <input type="checkbox" name="confirm" required>
                                <span>I understand this will permanently delete the register and all its data</span>
                            </label>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Type "DELETE" to confirm:</label>
                            <input type="text" name="confirmation" class="form-control" required pattern="DELETE">
                        </div>

                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash"></i> Permanently Delete Register
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="WEB-INF/footer.jsp" %>
    <%@ include file="WEB-INF/notif.jsp" %>

    <script>
    document.getElementById('deleteForm').addEventListener('submit', function(e) {
        e.preventDefault();

        const btn = this.querySelector('button');
        const originalText = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';

        const confirmationInput = this.querySelector('input[name="confirmation"]');
        if (!this.checkValidity() || confirmationInput.value !== "DELETE") {
            showNotification('error', 'Please type "DELETE" exactly to confirm deletion');
            btn.disabled = false;
            btn.innerHTML = originalText;
            return;
        }

        const formData = new URLSearchParams(new FormData(this));

        fetch('${pageContext.request.contextPath}/delete-register', {
            method: 'POST',
            body: formData,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Server responded with ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showNotification('success', data.message);
                setTimeout(() => {
                    window.location.href = 'admin';
                }, 2000);
            } else {
                showNotification('error', data.message || 'Unknown error.');
                btn.disabled = false;
                btn.innerHTML = originalText;
            }
        })
        .catch(error => {
            showNotification('error', 'Error: ' + error.message);
            btn.disabled = false;
            btn.innerHTML = originalText;
        });
    });
    </script>
</body>
</html>