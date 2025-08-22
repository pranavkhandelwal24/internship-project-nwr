<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="department" value="${requestScope.departmentInfo}" />
<c:set var="members" value="${requestScope.members}" />
<c:set var="registers" value="${requestScope.registers}" />
<c:set var="errorMessage" value="${requestScope.errorMessage}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>NWR Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
        /* Register Management Styles */
        .register-tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 20px;
        }
        
        .register-tab {
            padding: 10px 20px;
            cursor: pointer;
            border: 1px solid transparent;
            border-bottom: none;
            border-radius: 5px 5px 0 0;
            margin-right: 5px;
            background: #f5f5f5;
        }
        
        .register-tab.active {
            background: white;
            border-color: #ddd;
            border-bottom-color: white;
            font-weight: 500;
            color: var(--primary);
        }
        
        .register-content {
            display: none;
        }
        
        .register-content.active {
            display: block;
        }
        
        .column-badge {
            display: inline-block;
            padding: 3px 8px;
            background: #f0f0f0;
            border-radius: 4px;
            margin-right: 5px;
            margin-bottom: 5px;
            font-size: 0.8rem;
        }
        
        .data-type-badge {
            display: inline-block;
            padding: 2px 6px;
            background: #e0e0e0;
            border-radius: 3px;
            font-size: 0.7rem;
            margin-left: 5px;
        }
        
        /* Form styles for new register */
        .form-grid-columns {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .column-definition {
            border: 1px solid #eee;
            padding: 15px;
            border-radius: 8px;
            background: #f9f9f9;
        }
        
        .column-actions {
            display: flex;
            justify-content: flex-end;
            margin-top: 10px;
        }
        
        /* Register selector styles */
        .register-selector {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }
        
        .register-selector-row {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .register-selector select {
            flex: 1;
            min-width: 200px;
        }
        
        .register-selector button {
            width: auto;
        }
        
        @media (max-width: 768px) {
            .register-selector-row {
                flex-direction: column;
                align-items: stretch;
            }
        }
        
        /* Loading spinner */
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 20px;
        }
        
        .loading-spinner.active {
            display: block;
        }
        
        .spinner {
            border: 4px solid rgba(0, 0, 0, 0.1);
            border-radius: 50%;
            border-top: 4px solid var(--primary);
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Empty table message */
        .empty-table-message {
            text-align: center;
            padding: 40px;
        }
        .empty-table-message i {
            font-size: 3rem;
            opacity: 0.3;
            margin-bottom: 15px;
        }
        .empty-table-message h4 {
            color: var(--primary);
        }
        .empty-table-message p {
            color: var(--gray);
        }
        
        /* Error field styling */
        .error-field {
            border-color: #dc3545 !important;
            background-color: rgba(220, 53, 69, 0.1) !important;
        }
        
        /* Create Register Form Styles */
.columns-container {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin-bottom: 20px;
}

.column-definition {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 10px;
    padding: 15px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    border: 1px solid rgba(0, 0, 0, 0.08);
}

.column-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
    margin-bottom: 15px;
}

.column-options {
    margin-top: 15px;
}

.options-box {
    display: none;
}

.options-box.active {
    display: block;
}

.column-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
}

.column-actions label {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    margin-right: 15px;
    cursor: pointer;
    font-size: 0.9rem;
    color: var(--primary-darker);
}

.column-actions input[type="checkbox"] {
    width: 16px;
    height: 16px;
    cursor: pointer;
}

.form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    margin-top: 25px;
}

.action-buttons {
    display: flex;
    gap: 10px;
}

.btn-outline-primary {
    background: transparent;
    border: 1px solid var(--primary);
    color: var(--primary);
}

.btn-outline-primary:hover {
    background: var(--primary);
    color: white;
}

.btn-success {
    background: linear-gradient(90deg, var(--success), #34ce57);
}

.btn-success:hover {
    background: linear-gradient(90deg, #218838, #28a745);
}

@media (max-width: 576px) {
    .column-row {
        grid-template-columns: 1fr;
    }
    
    .form-actions {
        flex-direction: column;
        align-items: stretch;
    }
    
    .action-buttons {
        width: 100%;
    }
    
    .action-buttons .btn {
        flex: 1;
    }
}
        
    </style>
</head>
<body>
   
   <!-- Floating elements -->
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>
    
    <!-- Custom confirmation dialog -->
    <%@ include file="WEB-INF/confirm-dialog.jsp" %>
    
    <!-- Top Navigation -->
    <%@ include file="WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Admin Dashboard</h1>
                <p class="hero-description">
                    Manage ${not empty department.departmentName ? department.departmentName : 'your department'} operations efficiently.
                    <c:if test="${not empty errorMessage}">
                        <div class="error-message">${errorMessage}</div>
                    </c:if>
                </p>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <h2 class="section-title">Management Dashboard</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card" id="memberManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">Member Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Manage all members in your department. Add new members, 
                        edit existing profiles.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="registerManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3 class="feature-title">Register Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Create and manage registers for your department. View entries 
                        and define custom fields for each register.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- Member Management Section -->
        <div class="management-section" id="memberManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Member Management</h3>
                <button class="close-section" onclick="closeSection('memberManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="user-type-tabs">
                <div class="user-type-tab active" data-target="manageMembers">Manage Members</div>
                <div class="user-type-tab" data-target="addMember">Add Member</div>
            </div>
            
            <!-- Manage Members -->
            <div class="user-form-section active" id="manageMembers">
                <h4>Active Members in ${not empty department.departmentName ? department.departmentName : 'your department'}</h4>
                <div class="loading-spinner" id="membersLoadingSpinner">
                    <div class="spinner"></div>
                    <p>Loading members...</p>
                </div>
                <div class="table-container" id="membersTableContainer">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Department</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="membersTableBody">
                            <c:choose>
                                <c:when test="${empty members}">
                                    <tr>
                                        <td colspan="6" class="empty-table-message">
                                            <i class="fas fa-user-slash"></i>
                                            <h4>No Active Members Found</h4>
                                            <p>All members are inactive or not created yet</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${members}" var="member">
                                        <tr data-id="${member.id}">
                                            <td>${member.id}</td>
                                            <td>${member.name}</td>
                                            <td>${member.username}</td>
                                            <td>${member.email}</td>
                                            <td>${department.departmentName}</td>
                                            <td class="actions">
                                                <a href="edit-member.jsp?id=${member.id}&type=member" 
                                                   class="btn-edit" 
                                                   data-id="${member.id}"
                                                   data-type="member"
                                                   style="text-decoration: none;">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>
                                                <button type="button"
                                                       class="btn-delete"
                                                       data-id="${member.id}"
                                                       data-type="member">
                                                       <i class="fas fa-trash"></i> 
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Add Member -->
            <div class="user-form-section" id="addMember">
                <h4>Add New Member to ${not empty department.departmentName ? department.departmentName : 'your department'}</h4>
                <form id="addMemberForm">
                    <input type="hidden" name="department_id" value="${department.departmentId}">
                    <input type="hidden" name="role" value="member">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" id="name" name="name" class="form-control" placeholder="Enter full name" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" id="username" name="username" class="form-control" placeholder="Enter username" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" id="email" name="email" class="form-control" placeholder="Enter email" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Password</label>
                            <div class="password-wrapper">
                                <input type="password" id="passwordField" name="password" class="form-control" placeholder="Create password" required>
                                <span class="toggle-password" id="togglePassword">
                                    <i class="fas fa-eye"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        <i class="fas fa-plus"></i> Add Member
                    </button>
                </form>
            </div>
        </div>
    
        <!-- Register Management Section -->
        <div class="management-section" id="registerManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Register Management</h3>
                <button class="close-section" onclick="closeSection('registerManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="register-tabs">
                <div class="register-tab active" data-target="manageRegisters">Manage Registers</div>
                <div class="register-tab" data-target="viewRegisterEntries">View Entries</div>
                <div class="register-tab" data-target="createRegister">Create Register</div>
            </div>
            
            <!-- Manage Registers -->
            <div class="register-content active" id="manageRegisters">
                <h4>Department Registers</h4>
                <div class="loading-spinner" id="registersLoadingSpinner">
                    <div class="spinner"></div>
                    <p>Loading registers...</p>
                </div>
                <div class="table-container" id="registersTableContainer">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Description</th>
                                <th>Created By</th>
                                <th>Created At</th>
                                <th>Columns</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="registersTableBody">
                            <c:choose>
                                <c:when test="${empty registers}">
                                    <tr>
                                        <td colspan="7" class="empty-table-message">
                                            <i class="fas fa-book"></i>
                                            <h4>No Registers Found</h4>
                                            <p>Create your first register to get started</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${registers}" var="register">
                                        <tr data-id="${register.register_id}">
                                            <td>${register.register_id}</td>
                                            <td>${register.name}</td>
                                            <td>${not empty register.description ? register.description : '-'}</td>
                                            <td>${register.created_by_name}</td>
                                            <td>${register.created_at}</td>
                                            <td>
    <a href="view-register-columns?register_id=${register.register_id}" 
       class="btn btn-primary btn-sm" style="text-decoration:none">
       <i class="fas fa-eye"></i> View Columns
    </a>
</td>
                                            <td class="actions">
    <button type="button"
           class="btn-delete"
           data-id="${register.register_id}"
           data-type="register">
           <i class="fas fa-trash"></i> 
    </button>
</td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- View Register Entries -->
            <div class="register-content" id="viewRegisterEntries">
                <h4>View Register Entries</h4>
                
                <!-- Register Selector -->
                <div class="register-selector">
                    <div class="register-selector-row">
                        <div class="form-group">
                            <label class="form-label">Select Register</label>
                            <select id="registerSelect" class="form-control">
                                <option value="">-- Select Register --</option>
                                <c:forEach items="${registers}" var="register">
                                    <option value="${register.register_id}">${register.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <button type="button" class="btn btn-primary" onclick="loadRegisterEntries()" disabled id="loadEntriesBtn">
                            <i class="fas fa-search"></i> Load Entries
                        </button>
                    </div>
                </div>
                
                <!-- Entries Table -->
                <div class="table-container" id="entriesTableContainer" style="display: none;">
                    <table class="data-table" id="entriesTable">
                        <thead id="entriesTableHeader">
                            <tr>
                                <th>Sr No.</th>
                                <th>Submitted By</th>
                                <th>Submitted At</th>
                                <!-- Dynamic columns will be added here -->
                            </tr>
                        </thead>
                        <tbody id="entriesTableBody">
                            <tr>
                                <td colspan="3" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                    <h4 style="color: var(--primary);">No Entries Loaded</h4>
                                    <p style="color: var(--gray);">Select a register to view entries</p>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
<!-- Create Register -->
<div class="register-content " id="createRegister">
    <div class="section-header">
        <h3 class="section-subtitle">Create New Register</h3>
    </div>
    
    <form id="createRegisterForm">
        <input type="hidden" name="department_id" value="${department.departmentId}">
        <input type="hidden" name="created_by" value="${sessionScope.userId}">
        
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label">Register Name *</label>
                <input type="text" name="name" class="form-control" placeholder="e.g. Employee Records" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="1" placeholder="Brief description about this register"></textarea>
            </div>
        </div>
        
        <h4 class="section-subtitle" style="margin: 25px 0 15px; font-size: 1.2rem;">Register Columns *</h4>
        
        <div id="columnsContainer" class="form-grid" style="grid-template-columns: 1fr; gap: 20px;">
            <!-- Columns will be added here dynamically -->
        </div>
        
        <div style="display: flex; justify-content: space-between; margin-top: 25px;">
            <button type="button" class="btn btn-outline-primary" onclick="addColumn()" style="border: 1px solid var(--primary); color: var(--primary); background: transparent;">
                <i class="fas fa-plus"></i> Add Column
            </button>
            
            <div style="display: flex; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="resetRegisterForm()">
                    <i class="fas fa-undo"></i> Reset
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Create Register
                </button>
            </div>
        </div>
    </form>
</div>


        </div>
    
        <%@ include file="WEB-INF/importantlinks.jsp" %>
    </div>
    
    <!-- Footer -->
    <%@include file="WEB-INF/footer.jsp" %>
    
    <!-- Notification container -->
    <%@include file="WEB-INF/notif.jsp" %>
    
    <script>
    const contextPath = '${pageContext.request.contextPath}';
    const adminDepartment = '${department.departmentName}';
    // Global variables for deletion
    let currentDeleteId = null;
    let currentDeleteType = null;
    let currentDeleteRow = null;
    let currentRegisterId = null;
    let currentDeleteButton = null;

    // Initialize when DOM is loaded
    document.addEventListener('DOMContentLoaded', function() {
        // Animate elements on load
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.style.animation = 'fadeInUp 0.6s ease-out forwards';
            }, index * 150);
        });

        // Add first column when creating new register
        if (document.getElementById('createRegister') && document.getElementById('createRegister').classList.contains('active')) {
            addColumn();
        }

        // Feature cards navigation
        const memberManagementCard = document.getElementById('memberManagementCard');
        const registerManagementCard = document.getElementById('registerManagementCard');
        const memberManagementSection = document.getElementById('memberManagementSection');
        const registerManagementSection = document.getElementById('registerManagementSection');

        if (memberManagementCard) {
            memberManagementCard.addEventListener('click', function() {
                registerManagementSection.classList.remove('active');
                registerManagementCard.classList.remove('active');

                memberManagementSection.classList.add('active');
                memberManagementCard.classList.add('active');
                memberManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        }

        if (registerManagementCard) {
            registerManagementCard.addEventListener('click', function() {
                memberManagementSection.classList.remove('active');
                memberManagementCard.classList.remove('active');

                registerManagementSection.classList.add('active');
                registerManagementCard.classList.add('active');
                registerManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        }

        // Tabs navigation
        document.querySelectorAll('.user-type-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.user-type-tab').forEach(t => t.classList.remove('active'));
                this.classList.add('active');
                document.querySelectorAll('.user-form-section').forEach(s => s.classList.remove('active'));
                const target = this.getAttribute('data-target');
                document.getElementById(target).classList.add('active');
            });
        });
        
        document.querySelectorAll('.register-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.register-tab').forEach(t => t.classList.remove('active'));
                this.classList.add('active');
                document.querySelectorAll('.register-content').forEach(s => s.classList.remove('active'));
                const target = this.getAttribute('data-target');
                document.getElementById(target).classList.add('active');
            });
        });
        
        // Password toggle
        const passwordField = document.getElementById('passwordField');
        const togglePassword = document.getElementById('togglePassword');
        if (togglePassword && passwordField) {
            togglePassword.addEventListener('click', function() {
                const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordField.setAttribute('type', type);
                this.innerHTML = type === 'password'
                    ? '<i class="fas fa-eye"></i>'
                    : '<i class="fas fa-eye-slash"></i>';
            });
        }

        // Add member form submission
        if (document.getElementById('addMemberForm')) {
            document.getElementById('addMemberForm').addEventListener('submit', async function(e) {
                e.preventDefault();

                document.getElementById("username").classList.remove("error-field");
                document.getElementById("email").classList.remove("error-field");

                const submitBtn = document.querySelector('#addMemberForm button[type="submit"]');
                const originalBtnText = submitBtn.innerHTML;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
                submitBtn.disabled = true;

                try {
                    const formData = new FormData(this);
                    const response = await fetch(contextPath + '/add-user', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: new URLSearchParams(formData)
                    });
                    const data = await response.json();

                    if (data.status === 'success') {
                        showNotification('success', data.message);
                        this.reset();
                    } else {
                        showNotification('error', data.message);
                        if (data.message.includes("Username")) {
                            document.getElementById('username').classList.add('error-field');
                        } else if (data.message.includes("Email")) {
                            document.getElementById('email').classList.add('error-field');
                        }
                    }
                } catch (err) {
                    showNotification('error', 'An error occurred: ' + err.message);
                } finally {
                    submitBtn.innerHTML = originalBtnText;
                    submitBtn.disabled = false;
                }
            });
        }

        // Enable load button when register is selected
        if (document.getElementById('registerSelect')) {
            document.getElementById('registerSelect').addEventListener('change', function() {
                document.getElementById('loadEntriesBtn').disabled = !this.value;
                currentRegisterId = this.value; // Update current register ID when selection changes
            });
        }

        // Cancel button handler for confirmation dialog
        document.getElementById('cancelDelete').addEventListener('click', function() {
            document.getElementById('confirmationDialog').classList.remove('active');
            currentDeleteId = null;
            currentDeleteType = null;
            currentDeleteRow = null;
            currentDeleteButton = null;
        });

        // Confirm delete handler (now only handles entries and members)
        document.getElementById('confirmDelete').addEventListener('click', async function() {
            const confirmBtn = this;
            confirmBtn.disabled = true;
            confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';

            try {
                if (currentDeleteType === 'entry') {
                    await performEntryDeletion(currentDeleteId, currentDeleteRow, confirmBtn);
                } else if (currentDeleteType === 'member') {
                    const response = await fetch(contextPath + '/delete-' + currentDeleteType, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'id=' + encodeURIComponent(currentDeleteId)
                    });
                    const data = await response.json();

                    if (data.status === 'success') {
                        showNotification('success', data.message);
                        currentDeleteRow.remove();

                        // Check if members table is now empty
                        const tableBody = document.getElementById('membersTableBody');
                        if (tableBody && tableBody.querySelectorAll('tr').length === 0) {
                            tableBody.innerHTML = `
                                <tr>
                                    <td colspan="6" class="empty-table-message">
                                        <i class="fas fa-user-slash"></i>
                                        <h4>No Members Found</h4>
                                        <p>All members are inactive or not created yet</p>
                                    </td>
                                </tr>
                            `;
                        }
                    } else {
                        showNotification('error', data.message);
                    }
                }
            } catch (err) {
                showNotification('error', 'Failed to delete: ' + err.message);
            } finally {
                document.getElementById('confirmationDialog').classList.remove('active');
                confirmBtn.disabled = false;
                confirmBtn.innerHTML = 'Confirm';
                currentDeleteId = null;
                currentDeleteType = null;
                currentDeleteRow = null;
                currentDeleteButton = null;
            }
        });

        // Event delegation for edit and delete buttons
        document.addEventListener('click', function(e) {
            // Handle entry deletion
            const entryDeleteBtn = e.target.closest('.btn-delete[data-type="entry"]');
            if (entryDeleteBtn) {
                e.preventDefault();
                e.stopPropagation();

                const entryIdToDelete = entryDeleteBtn.getAttribute('data-id');
                const rowToDelete = entryDeleteBtn.closest('tr');

                // Store references
                currentDeleteId = entryIdToDelete;
                currentDeleteRow = rowToDelete;
                currentDeleteButton = entryDeleteBtn;
                currentDeleteType = 'entry';

                // Update confirmation message
                const message = `Are you sure you want to delete this entry?`;
                document.getElementById('confirmationMessage').textContent = message;

                // Show dialog
                document.getElementById('confirmationDialog').classList.add('active');
                return;
            }

            // Handle register deletion - redirect to delete-register.jsp
            const registerDeleteBtn = e.target.closest('.btn-delete[data-type="register"]');
            if (registerDeleteBtn) {
                e.preventDefault();
                const registerId = registerDeleteBtn.getAttribute('data-id');
                window.location.href = contextPath + '/delete-register-view?register_id=' + registerId;
                return;
            }

            // Handle member deletion
            const memberDeleteBtn = e.target.closest('.btn-delete[data-type="member"]');
            if (memberDeleteBtn) {
                e.preventDefault();
                currentDeleteId = memberDeleteBtn.getAttribute('data-id');
                currentDeleteType = memberDeleteBtn.getAttribute('data-type');
                currentDeleteRow = memberDeleteBtn.closest('tr');

                // Update confirmation message
                const message = `Are you sure you want to delete this member?`;
                document.getElementById('confirmationMessage').textContent = message;

                // Show dialog
                document.getElementById('confirmationDialog').classList.add('active');
                return;
            }

            // Handle edit button clicks for entries
            const editBtn = e.target.closest('.btn-edit[data-type="edit-entry"]');
            if (editBtn) {
                e.preventDefault();
                const entryId = editBtn.getAttribute('data-id');
                editEntry(entryId);
                return;
            }

            // Edit button handling for other types
            const otherEditBtn = e.target.closest('.btn-edit:not([data-type="edit-entry"])');
            if (otherEditBtn) {
                const id = otherEditBtn.getAttribute('data-id');
                const type = otherEditBtn.getAttribute('data-type');
                if (type === 'register') {
                    window.location.href = 'edit-register.jsp?register_id=' + id;
                } else if (type === 'member') {
                    window.location.href = 'edit-member.jsp?id=' + id;
                }
            }
        });
    });

    // Section closing
    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');

        if (sectionId === 'memberManagementSection') {
            document.getElementById('memberManagementCard').classList.remove('active');
        } else if (sectionId === 'registerManagementSection') {
            document.getElementById('registerManagementCard').classList.remove('active');
        }
    }

    async function performEntryDeletion(entryId, rowElement, deleteButton) {
        const originalBtnHtml = deleteButton.innerHTML;
        deleteButton.disabled = true;
        deleteButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';

        try {
            const formData = new FormData();
            formData.append('entryId', entryId);

            const response = await fetch(contextPath + '/delete-entry', {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (!response.ok) {
                showNotification('error', data.message || `Server responded with status: ${response.status}`);
                console.error('Server error:', response.status, data.message);
                return;
            }
            
            if (data.status === 'success') {
                showNotification('success', data.message);
                if (rowElement) {
                    rowElement.remove();
                    checkIfTableEmpty();
                }
            } else {
                throw new Error(data.message || 'Delete failed: Server reported an issue.');
            }
        } catch (error) {
            console.error('Delete error:', error);
            showNotification('error', 'Delete failed: ' + error.message);
        } finally {
            deleteButton.innerHTML = originalBtnHtml;
            deleteButton.disabled = false;
        }
    }

    function checkIfTableEmpty() {
        const tableBody = document.getElementById('entriesTableBody');
        const tableHeaderRow = document.getElementById('entriesTableHeader').querySelector('tr');
        const totalColspan = tableHeaderRow ? tableHeaderRow.childElementCount : 10;
        if (tableBody && tableBody.querySelectorAll('tr').length === 0) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="${totalColspan}" style="text-align: center; padding: 40px;">
                        <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                        <h4 style="color: var(--primary);">No Entries Found</h4>
                        <p style="color: var(--gray);">This register has no entries yet</p>
                    </td>
                </tr>
            `;
        }
    }

    function editEntry(entryId) {
        const registerSelect = document.getElementById('registerSelect');
        const registerId = registerSelect.value;

        if (!registerId) {
            showNotification('error', 'Please select a register first before editing an entry.');
            return;
        }
        window.location.href = contextPath + '/edit-entry?entryId=' + entryId + '&registerId=' + registerId;
    }

    // Load register columns
    function loadRegisterColumns(registerId) {
        const spinner = document.getElementById(`columnsSpinner-${registerId}`);
        const container = document.getElementById(`columnsContainer-${registerId}`);

        spinner.style.display = 'block';
        container.innerHTML = '';
        fetch(contextPath + '/admin?action=getColumns&registerId=' + registerId)
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    if (data.columns && data.columns.length > 0) {
                        let html = '';
                        data.columns.forEach(column => {
                            html += `<span class="column-badge">${column.label}
                                    <span class="data-type-badge">${column.data_type}</span>
                                    </span>`;
                        });
                        container.innerHTML = html;
                    } else {
                        container.innerHTML = '<span class="text-muted">No columns defined</span>';
                    }
                } else {
                    container.innerHTML = '<button class="btn btn-primary btn-sm" onclick="loadRegisterColumns(' + registerId + ')">Retry</button>';
                    showNotification('error', data.message);
                }
            })
            .catch(error => {
                container.innerHTML = '<button class="btn btn-primary btn-sm" onclick="loadRegisterColumns(' + registerId + ')">Retry</button>';
                showNotification('error', 'Failed to load columns: ' + error.message);
            })
            .finally(() => {
                spinner.style.display = 'none';
            });
    }

    // Load register entries
    function loadRegisterEntries() {
        const registerSelect = document.getElementById('registerSelect');
        const registerId = registerSelect.value;

        if (!registerId) {
            showNotification('error', 'Please select a register first');
            return;
        }

        currentRegisterId = registerId;
        // Show loading state
        const entriesTableBody = document.getElementById('entriesTableBody');
        entriesTableBody.innerHTML = `<tr><td colspan="10" style="text-align: center; padding: 40px;"><div class="spinner"></div><p>Loading entries...</p></td></tr>`;
        
        fetch(contextPath + '/admin?action=getEntries&registerId=' + registerId)
            .then(response => response.json())
            .then(data => {
                const tableContainer = document.getElementById('entriesTableContainer');
                const tableHeader = document.getElementById('entriesTableHeader');
                const tableBody = document.getElementById('entriesTableBody');

                if (data.status === 'success') {
                    // Clear previous data
                    tableBody.innerHTML = '';

                    // Rebuild header
                    tableHeader.innerHTML = `
                        <tr>
                            <th>Sr No.</th>
                            <th>Submitted By</th>
                            <th>Submitted At</th>
                    `;

                    // Add dynamic columns to header
                    if (data.data && data.data.columns) {
                        data.data.columns.forEach(column => {
                            const th = document.createElement('th');
                            th.textContent = column.label;
                            tableHeader.querySelector('tr').appendChild(th);
                        });
                    }

                    // Add actions column
                    const actionsTh = document.createElement('th');
                    actionsTh.textContent = 'Actions';
                    tableHeader.querySelector('tr').appendChild(actionsTh);

                    // Add rows
                    if (data.data && data.data.entries && data.data.entries.length > 0) {
                        data.data.entries.forEach((entry, index) => {
                            const row = document.createElement('tr');
                            row.dataset.entryId = entry.entry_id;

                            // Add static columns
                            const srNoCell = document.createElement('td');
                            srNoCell.textContent = index + 1;
                            row.appendChild(srNoCell);

                            const submittedByCell = document.createElement('td');
                            submittedByCell.textContent = entry.submitted_by_name || 'You';
                            row.appendChild(submittedByCell);

                            const submittedAtCell = document.createElement('td');
                            submittedAtCell.textContent = entry.submitted_at || 'Not available';
                            row.appendChild(submittedAtCell);
                            
                            // Add dynamic columns
                            if (data.data.columns) {
                                data.data.columns.forEach(column => {
                                    const td = document.createElement('td');
                                    const value = entry[column.field_name] || '-';
                                    td.textContent = value;
                                    row.appendChild(td);
                                });
                            }

                            // Add actions
                            const actionsTd = document.createElement('td');
                            actionsTd.className = 'actions';
                            
                            // Create Edit Button
                            const editButton = document.createElement('button');
                            editButton.className = 'btn-edit';
                            editButton.setAttribute('data-id', entry.entry_id);
                            editButton.setAttribute('data-type', 'edit-entry');
                            editButton.innerHTML = '<i class="fas fa-edit"></i> Edit';
                            editButton.addEventListener('click', () => editEntry(entry.entry_id));
                            
                            // Create Delete Button
                            const deleteButton = document.createElement('button');
                            deleteButton.type = 'button';
                            deleteButton.className = 'btn-delete';
                            deleteButton.setAttribute('data-id', entry.entry_id);
                            deleteButton.setAttribute('data-type', 'entry');
                            deleteButton.innerHTML = '<i class="fas fa-trash"></i>';
                            
                            actionsTd.appendChild(editButton);
                            actionsTd.appendChild(deleteButton);
                            row.appendChild(actionsTd);

                            tableBody.appendChild(row);
                        });
                    } else {
                        // Calculate colspan dynamically
                        const dynamicColumnCount = (data.data && data.data.columns ? data.data.columns.length : 0);
                        const totalColspan = 3 + dynamicColumnCount + 1; // 3 static + dynamic + actions

                        tableBody.innerHTML = `
                            <tr>
                                <td colspan="${totalColspan}" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                    <h4 style="color: var(--primary);">No Entries Found</h4>
                                    <p style="color: var(--gray);">This register has no entries yet</p>
                                </td>
                            </tr>
                        `;
                    }

                    tableContainer.style.display = 'block';
                } else {
                    showNotification('error', data.message || 'Failed to load entries');
                    // Fallback colspan for error message
                    const dynamicColumnCount = (data.data && data.data.columns ? data.data.columns.length : 0);
                    const totalColspan = 3 + dynamicColumnCount + 1;

                    tableBody.innerHTML = `
                        <tr>
                            <td colspan="${totalColspan}" style="text-align: center; padding: 40px;">
                                <p class="error-message">Error: ${data.message || 'Failed to load entries'}</p>
                            </td>
                        </tr>
                    `;
                }
            })
            .catch(error => {
                console.error('Error loading entries:', error);
                showNotification('error', 'Failed to load entries');

                // Fallback colspan for network error
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="10" style="text-align: center; padding: 40px;">
                            <p class="error-message">Network Error: ${error.message}</p>
                        </td>
                    </tr>
                `;
            });
    }

    // Column management functions
    function addColumn() {
        const container = document.getElementById('columnsContainer');
        const columnId = Date.now();

        const div = document.createElement('div');
        div.className = 'column-definition';
        div.dataset.id = columnId;
        div.style.background = 'rgba(255, 255, 255, 0.95)';
        div.style.borderRadius = '10px';
        div.style.padding = '15px';
        div.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.05)';
        div.style.border = '1px solid rgba(0, 0, 0, 0.08)';

        div.innerHTML = `
            <div class="form-grid" style="margin-bottom: 15px;">
                <div class="form-group">
                    <label class="form-label">Label *</label>
                    <input type="text" class="form-control column-label" placeholder="e.g. Employee Name" required>
                    <small class="error-message" style="color: var(--secondary); display: none;">Label must be unique</small>
                </div>
                <div class="form-group">
                    <label class="form-label">Field Name *</label>
                    <input type="text" class="form-control column-field" placeholder="e.g. employee_name (no spaces)" required>
                    <small class="error-message" style="color: var(--secondary); display: none;">Field name must be unique and valid</small>
                </div>
            </div>

            <div class="form-grid" style="margin-bottom: 15px;">
                <div class="form-group">
                    <label class="form-label">Data Type *</label>
                    <select class="form-control column-type">
                        <option value="text">Text</option>
                        <option value="number">Number</option>
                        <option value="decimal">Decimal</option>
                        <option value="date">Date</option>
                        <option value="enum">Dropdown</option>
                    </select>
                </div>
                <div class="form-group column-options-box" style="display: none;">
                    <label class="form-label">Options *</label>
                    <input type="text" class="form-control column-options" placeholder="Comma separated values (e.g. Yes,No,Maybe)">
                    <small class="error-message" style="color: var(--secondary); display: none;">Please provide options</small>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <label style="display: inline-flex; align-items: center; gap: 5px; margin-right: 15px; cursor: pointer;">
                        <input type="checkbox" class="column-required" style="width: 16px; height: 16px; cursor: pointer;"> Required
                    </label>
                    <label style="display: inline-flex; align-items: center; gap: 5px; cursor: pointer;" class="unique-checkbox">
                        <input type="checkbox" class="column-unique" style="width: 16px; height: 16px; cursor: pointer;"> Unique
                    </label>
                </div>
                <button type="button" class="btn-delete" onclick="removeColumn(this)" style="padding: 8px 12px; font-size: 0.85rem;">
                    <i class="fas fa-trash"></i> Remove
                </button>
            </div>
        `;

        container.appendChild(div);

        // Add event listeners
        const select = div.querySelector('.column-type');
        const optionsBox = div.querySelector('.column-options-box');
        const uniqueCheckbox = div.querySelector('.unique-checkbox');

        select.addEventListener('change', function() {
            if (this.value === 'enum') {
                optionsBox.style.display = 'block';
                // Hide unique checkbox for enum type
                uniqueCheckbox.style.display = 'none';
                div.querySelector('.column-unique').checked = false;
            } else {
                optionsBox.style.display = 'none';
                uniqueCheckbox.style.display = 'inline-flex';
            }
        });

        // Initialize based on default selection
        if (select.value === 'enum') {
            optionsBox.style.display = 'block';
            uniqueCheckbox.style.display = 'none';
        }

        // Add validation for duplicate columns
        const labelInput = div.querySelector('.column-label');
        const fieldInput = div.querySelector('.column-field');

        labelInput.addEventListener('blur', validateColumnLabels);
        fieldInput.addEventListener('blur', validateFieldNames);
    }

    function validateColumnLabels() {
        const labels = Array.from(document.querySelectorAll('.column-label'));
        const currentLabel = this.value.trim().toLowerCase();
        const errorElement = this.nextElementSibling;

        if (!currentLabel) {
            errorElement.style.display = 'none';
            return;
        }

        const duplicates = labels.filter(input =>
            input !== this && input.value.trim().toLowerCase() === currentLabel
        );
        if (duplicates.length > 0) {
            errorElement.textContent = 'Label must be unique';
            errorElement.style.display = 'block';
            this.classList.add('error-field');
        } else {
            errorElement.style.display = 'none';
            this.classList.remove('error-field');
        }
    }

    function validateFieldNames() {
        const fields = Array.from(document.querySelectorAll('.column-field'));
        const currentField = this.value.trim().toLowerCase();
        const errorElement = this.nextElementSibling;

        if (!currentField) {
            errorElement.style.display = 'none';
            return;
        }

        // Check for duplicates
        const duplicates = fields.filter(input =>
            input !== this && input.value.trim().toLowerCase() === currentField
        );
        // Check for valid field name (letters, numbers, underscores)
        const isValid = /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(currentField);
        if (duplicates.length > 0) {
            errorElement.textContent = 'Field name must be unique';
            errorElement.style.display = 'block';
            this.classList.add('error-field');
        } else if (!isValid) {
            errorElement.textContent = 'Only letters, numbers and underscores allowed (no spaces)';
            errorElement.style.display = 'block';
            this.classList.add('error-field');
        } else {
            errorElement.style.display = 'none';
            this.classList.remove('error-field');
        }
    }

    function removeColumn(btn) {
        if (confirm('Are you sure you want to remove this column?')) {
            btn.closest('.column-definition').remove();
        }
    }

    function resetRegisterForm() {
        if (confirm('Are you sure you want to reset the form? All entered data will be lost.')) {
            document.getElementById('createRegisterForm').reset();
            document.getElementById('columnsContainer').innerHTML = '';
            addColumn(); // Add one default column
        }
    }

    // Register form submission
    if (document.getElementById('createRegisterForm')) {
        document.getElementById('createRegisterForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const form = this;
            const submitBtn = form.querySelector('button[type="submit"]');

            const originalBtnText = submitBtn.innerHTML;

            // Disable button and show loading state
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating...';

            try {
                // Validate main form
                const name = form.name.value.trim();
                if (!name) {
                    throw new Error('Register name is required');
                }

                // Validate at least one column exists
                const columns = document.querySelectorAll('#columnsContainer .column-definition');
                if (columns.length === 0) {
                    throw new Error('Please add at least one column');
                }

                // Prepare columns data
                const columnsData = [];
                let hasErrors = false;
                const fieldNames = new Set();

                columns.forEach((column, index) => {
                    const label = column.querySelector('.column-label').value.trim();
                    const fieldName = column.querySelector('.column-field').value.trim();
                    const type = column.querySelector('.column-type').value;
                    const isRequired = column.querySelector('.column-required').checked ? 1 : 0;
                    const isUnique = column.querySelector('.column-unique').checked ? 1 : 0;

                    // Reset error states
                    column.querySelector('.column-label').classList.remove('error-field');
                    column.querySelector('.column-field').classList.remove('error-field');
                    if (column.querySelector('.column-options')) {
                        column.querySelector('.column-options').classList.remove('error-field');
                    }

                    // Validate column
                    if (!label) {
                        column.querySelector('.column-label').classList.add('error-field');
                        hasErrors = true;
                    }

                    if (!fieldName || !/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(fieldName)) {
                        column.querySelector('.column-field').classList.add('error-field');
                        hasErrors = true;
                    }

                    // Check for duplicate field names
                    if (fieldNames.has(fieldName.toLowerCase())) {
                        column.querySelector('.column-field').nextElementSibling.textContent = 'Field name must be unique';
                        column.querySelector('.column-field').nextElementSibling.style.display = 'block';
                        column.querySelector('.column-field').classList.add('error-field');
                        hasErrors = true;
                    } else {
                        fieldNames.add(fieldName.toLowerCase());
                    }

                    let options = null;
                    if (type === 'enum') {
                        options = column.querySelector('.column-options').value.trim();
                        if (!options) {
                            column.querySelector('.column-options').classList.add('error-field');
                            column.querySelector('.column-options').nextElementSibling.style.display = 'block';
                            hasErrors = true;
                        }
                    }

                    columnsData.push({
                        label: label,
                        field_name: fieldName,
                        data_type: type,
                        options: options,
                        is_required: isRequired,
                        is_unique: isUnique,
                        ordering: index + 1
                    });
                });

                if (hasErrors) {
                    throw new Error('Please fix all validation errors');
                }

                // Prepare payload
                const payload = {
                    department_id: form.department_id.value,
                    name: name,
                    description: form.description.value.trim(),
                    created_by: form.created_by.value,
                    columns: columnsData
                };
                // Send request
                const response = await fetch('${pageContext.request.contextPath}/add-register', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(payload)
                });
                const data = await response.json();

                if (data.status === 'success') {
                    showNotification('success', data.message);
                    form.reset();
                    document.getElementById('columnsContainer').innerHTML = '';
                    addColumn(); // Add one empty column

                    // Refresh the registers list
                    if (typeof loadRegisters === 'function') {
                        loadRegisters();
                    }
                } else {
                    throw new Error(data.message || 'Failed to create register');
                }
            } catch (error) {
                console.error('Error:', error);
                showNotification('error', error.message);

                // Scroll to the first error if there are validation errors
                const firstError = document.querySelector('.error-field');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            } finally {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalBtnText;
            }
        });
    }
</script>
</body>
</html>