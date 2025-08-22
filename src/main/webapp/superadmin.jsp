<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head> 
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>NWR Super Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
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
        
        /* Error field styling */
        .error-field {
            border-color: #dc3545 !important;
            background-color: rgba(220, 53, 69, 0.1) !important;
        }
        
        @media (max-width: 768px) {
            .register-selector-row {
                flex-direction: column;
                align-items: stretch;
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
    <%@ include file="/WEB-INF/navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Super Admin Dashboard</h1>
                <p class="hero-description">
                    Manage railway operations efficiently with our comprehensive admin tools. 
                    Monitor departments, users, and registers.
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
        <h2 class="section-title">Management Dashboard</h2>
        
        <!-- Feature Cards -->
        <div class="features">
            <div class="feature-card" id="userManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">User Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Manage all users including administrators and members. Add new users, 
                        edit existing profiles, and assign departments.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="departmentManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-building"></i>
                    </div>
                    <h3 class="feature-title">Department Management</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Create, modify, and manage departments. Assign users to departments 
                        and monitor department-specific activities.
                    </p>
                </div>
            </div>
            
            <div class="feature-card" id="entriesManagementCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h3 class="feature-title">Manage Register Entries</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View and manage all register entries across departments. 
                        Select a department and register to view its entries.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- User Management Section -->
        <div class="management-section" id="userManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">User Management</h3>
                <button class="close-section" onclick="closeSection('userManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="user-type-tabs">
                <div class="user-type-tab" data-target="manageMembers">Manage Members</div>
                <div class="user-type-tab" data-target="manageAdmins">Manage Admins</div>
                <div class="user-type-tab" data-target="addUser">Add User</div>
            </div>
            
            <!-- Manage Members -->
            <div class="user-form-section" id="manageMembers">
                <h4>Active Members</h4>
                <div class="table-container">
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
                        <tbody>
                            <c:choose>
                                <c:when test="${empty activeMembers}">
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 40px;">
                                            <i class="fas fa-user-slash" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                            <h4 style="color: var(--primary);">No Active Members Found</h4>
                                            <p style="color: var(--gray);">All members are inactive or not created yet</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${activeMembers}" var="member">
                                        <tr>
                                            <td>${member.id}</td>
                                            <td>${member.name}</td>
                                            <td>${member.username}</td>
                                            <td>${member.email}</td>
                                            <td>${member.department_name}</td>
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
            
            <!-- Manage Admins -->
            <div class="user-form-section" id="manageAdmins">
                <h4>Active Administrators</h4>
                <div class="table-container">
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
                        <tbody>
                            <c:choose>
                                <c:when test="${empty activeAdmins}">
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 40px;">
                                            <i class="fas fa-user-shield" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                            <h4 style="color: var(--primary);">No Active Administrators Found</h4>
                                            <p style="color: var(--gray);">All administrators are inactive or not created yet</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${activeAdmins}" var="admin">
                                        <tr>
                                            <td>${admin.id}</td>
                                            <td>${admin.name}</td>
                                            <td>${admin.username}</td>
                                            <td>${admin.email}</td>
                                            <td>${admin.department_name}</td>
                                            <td class="actions">
                                                <a href="edit-admin.jsp?id=${admin.id}&type=admin" 
                                                   class="btn-edit" 
                                                   data-id="${admin.id}"
                                                   data-type="admin"
                                                   style="text-decoration: none;">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>
                                                <button type="button"
                                                   class="btn-delete"
                                                   data-id="${admin.id}"
                                                   data-type="admin">
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
            
            <!-- Add User -->
            <div class="user-form-section" id="addUser">
                <h4>Add New User</h4>
                <form id="addUserForm">
                    <div class="form-group">
                        <label class="form-label">User Type</label>
                        <select id="userType" class="form-control" name="role" required>
                            <option value="">Select User Type</option>
                            <option value="superadmin">Super Admin</option>
                            <option value="admin">Admin</option>
                            <option value="member">Member</option>
                        </select>
                    </div>
                    
                    <div id="userFormFields">
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
                            
                            <div class="form-group" id="departmentField">
                                <label class="form-label">Department</label>
                                <select id="department" name="department_id" class="form-control" required>
                                    <option value="">Select Department</option>
                                    <c:forEach items="${departments}" var="dept">
                                        <c:set var="hasHead" value="${departmentHeads[dept] != null}" />
                                        <option value="${dept}" 
                                            ${'admin' eq param.role && hasHead ? 'disabled' : ''}>
                                            ${dept}
                                            <c:if test="${hasHead}">
                                                (Head assigned)
                                            </c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-plus"></i> Add User
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Department Management Section -->
        <div class="management-section" id="departmentManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Department Management</h3>
                <button class="close-section" onclick="closeSection('departmentManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="department-tabs">
                <div class="department-tab" data-target="manageDepartments">Manage Departments</div>
                <div class="department-tab" data-target="addDepartment">Add Department</div>
            </div>
            
            <!-- Manage Departments -->
            <div class="department-section" id="manageDepartments">
                <h4>All Departments</h4>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Department Name</th>
                                <th>Department Head</th>
                                <th>Active Members</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty departments}">
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 40px;">
                                            <i class="fas fa-building" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                            <h4 style="color: var(--primary);">No Departments Found</h4>
                                            <p style="color: var(--gray);">Add departments to organize your users</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${departments}" var="dept">
                                        <c:set var="memberCount" value="${departmentMemberCounts[dept] != null ? departmentMemberCounts[dept] : 0}" />
                                        <tr>
                                            <td><strong>${dept}</strong></td>
                                            <td>${departmentHeads[dept] != null ? departmentHeads[dept] : "Not assigned"}</td>
                                            <td><span class="badge">${memberCount} members</span></td>
                                            <td class="actions">
                                                <a href="edit-department.jsp?id=${departmentIds[dept]}" 
                                                   class="btn-edit"
                                                   style="text-decoration: none;">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>
                                                <button type="button"
                                                        class="btn-delete"
                                                        data-id="${dept}"
                                                        data-type="department">
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
            
            <!-- Add Department -->
            <div class="department-section" id="addDepartment">
                <h4>Create New Department</h4>
                <form id="addDepartmentForm" action="add-department" method="post">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Department Name</label>
                            <input type="text" name="departmentName" class="form-control" placeholder="Enter department name" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add Department
                    </button>
                </form>
            </div>
        </div>
    
        <!-- Entries Management Section -->
        <div class="management-section" id="entriesManagementSection">
            <div class="section-header">
                <h3 class="section-subtitle">Register Entries</h3>
                <button class="close-section" onclick="closeSection('entriesManagementSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <!-- Register Selector -->
            <div class="register-selector">
                <div class="register-selector-row">
                    <div class="form-group">
                        <label class="form-label">Select Department</label>
                        <select id="departmentSelect" class="form-control" onchange="loadRegisters(this.value)">
                            <option value="">-- Select Department --</option>
                            <c:forEach items="${departments}" var="dept">
                                <option value="${dept}">${dept}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Select Register</label>
                        <select id="registerSelect" class="form-control" disabled>
                            <option value="">-- Select Register --</option>
                        </select>
                    </div>
                    
                    <button type="button" class="btn btn-primary" onclick="loadRegisterEntries()" disabled id="loadEntriesBtn">
                        <i class="fas fa-search"></i> Load Entries
                    </button>
                </div>
            </div>
            
            <!-- Loading Spinner -->
            <div class="loading-spinner" id="entriesLoadingSpinner">
                <div class="spinner"></div>
                <p>Loading entries...</p>
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
                                <p style="color: var(--gray);">Select a department and register to view entries</p>
                            </td>
                        </tr>
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
    const contextPath = '${pageContext.request.contextPath}';

    // Global variables for deletion
    let currentDeleteId = null;
    let currentDeleteType = null;
    let currentDeleteRow = null;
    let currentRegisterId = null;

 // Update the delete button handler in superadmin.jsp
    document.addEventListener('click', function(e) {
        const deleteBtn = e.target.closest('.btn-delete');
        if (deleteBtn) {
            e.preventDefault();
            const entryId = deleteBtn.getAttribute('data-id');
            const type = deleteBtn.getAttribute('data-type');
            const row = deleteBtn.closest('tr');

            if (type === 'entry') {
                // Store references for entry deletion
                currentDeleteId = entryId;
                currentDeleteType = type;
                currentDeleteRow = row;
                currentDeleteButton = deleteBtn;
                currentRegisterId = document.getElementById('registerSelect').value;

                // Validate register selection
                if (!currentRegisterId) {
                    showNotification('error', 'Please select a register first');
                    return;
                }

                // Update confirmation message
                const message = `Are you sure you want to delete this entry?`;
                document.getElementById('confirmationMessage').textContent = message;

                // Show dialog
                document.getElementById('confirmationDialog').classList.add('active');
            } else {
                // Handle other delete types (member, admin, department)
                currentDeleteId = deleteBtn.getAttribute('data-id');
                currentDeleteType = deleteBtn.getAttribute('data-type');
                currentDeleteRow = deleteBtn.closest('tr');

                // Update confirmation message
                const message = `Are you sure you want to delete this ${currentDeleteType}?`;
                document.getElementById('confirmationMessage').textContent = message;

                // Show dialog
                document.getElementById('confirmationDialog').classList.add('active');
            }
        }
    });

    // Update the confirm delete handler for superadmin
    document.getElementById('confirmDelete').addEventListener('click', async function() {
        const confirmBtn = this;
        confirmBtn.disabled = true;
        confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';

        try {
            if (currentDeleteType === 'entry') {
                // For entry deletion, use the superadmin-specific endpoint
                const payload = {
                    entryId: currentDeleteId,
                    registerId: currentRegisterId
                };

                const response = await fetch(contextPath + '/superadmin-delete-entry', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest' // Indicate AJAX request
                    },
                    body: JSON.stringify(payload)
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.message || `Server responded with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.status === 'success') {
                    showNotification('success', data.message);
                    currentDeleteRow.remove();
                    
                    // Check if table is now empty
                    const tableBody = document.getElementById('entriesTableBody');
                    if (tableBody && tableBody.querySelectorAll('tr').length === 0) {
                        const tableHeaderRow = document.getElementById('entriesTableHeader').querySelector('tr');
                        const totalColspan = tableHeaderRow ? tableHeaderRow.childElementCount : 10;
                        
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
                } else {
                    throw new Error(data.message || 'Delete failed');
                }
            } else {
                // Existing delete logic for other types
                const formData = new URLSearchParams();
                if (currentDeleteType === 'member' || currentDeleteType === 'admin') {
                    formData.append('id', currentDeleteId);
                } else if (currentDeleteType === 'department') {
                    formData.append('departmentName', currentDeleteId);
                } else {
                    formData.append('ifile_no', currentDeleteId);
                }

                const response = await fetch(contextPath + '/delete-' + currentDeleteType, {
                    method: 'POST',
                    headers: { 
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: formData
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.message || `Server responded with status: ${response.status}`);
                }

                const data = await response.json();
                
                if (data.status === 'success') {
                    showNotification('success', data.message);
                    currentDeleteRow.remove();
                    
                    // Check if table is now empty
                    let tableBodyId = '';
                    let colspan = 0;
                    let icon = '';
                    let title = '';
                    let message = '';

                    switch (currentDeleteType) {
                        case 'member':
                            tableBodyId = 'membersTableBody';
                            colspan = 6;
                            icon = 'user-slash';
                            title = 'Members';
                            message = 'All members are inactive or not created yet';
                            break;
                        case 'admin':
                            tableBodyId = 'adminsTableBody';
                            colspan = 6;
                            icon = 'user-shield';
                            title = 'Admins';
                            message = 'No admin users exist';
                            break;
                        case 'department':
                            tableBodyId = 'departmentsTableBody';
                            colspan = 3;
                            icon = 'building';
                            title = 'Departments';
                            message = 'No departments exist yet';
                            break;
                    }

                    const tableBody = document.getElementById(tableBodyId);
                    if (tableBody && tableBody.querySelectorAll('tr').length === 0) {
                        tableBody.innerHTML = 
                            `<tr>
                                <td colspan="${colspan}" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-${icon}" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                    <h4 style="color: var(--primary);">No ${title} Found</h4>
                                    <p style="color: var(--gray);">${message}</p>
                                </td>
                            </tr>`;
                    }
                } else {
                    throw new Error(data.message || 'Delete failed');
                }
            }
        } catch (err) {
            console.error('Delete error:', err);
            showNotification('error', 'Delete failed: ' + (err.message || 'Unknown error occurred'));
        } finally {
            document.getElementById('confirmationDialog').classList.remove('active');
            confirmBtn.disabled = false;
            confirmBtn.innerHTML = 'Confirm';
            currentDeleteId = null;
            currentDeleteType = null;
            currentDeleteRow = null;
            currentDeleteButton = null;
            currentRegisterId = null;
        }
    });

    // Cancel delete
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('confirmationDialog').classList.remove('active');
        currentDeleteId = null;
        currentDeleteType = null;
        currentDeleteRow = null;
    });

    // Feature cards
    const userManagementCard = document.getElementById('userManagementCard');
    const departmentManagementCard = document.getElementById('departmentManagementCard');
    const entriesManagementCard = document.getElementById('entriesManagementCard');
    const userManagementSection = document.getElementById('userManagementSection');
    const departmentManagementSection = document.getElementById('departmentManagementSection');
    const entriesManagementSection = document.getElementById('entriesManagementSection');

    userManagementCard.addEventListener('click', function() {
        departmentManagementSection.classList.remove('active');
        departmentManagementCard.classList.remove('active');
        entriesManagementSection.classList.remove('active');
        entriesManagementCard.classList.remove('active');

        userManagementSection.classList.add('active');
        userManagementCard.classList.add('active');
        userManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    departmentManagementCard.addEventListener('click', function() {
        userManagementSection.classList.remove('active');
        userManagementCard.classList.remove('active');
        entriesManagementSection.classList.remove('active');
        entriesManagementCard.classList.remove('active');

        departmentManagementSection.classList.add('active');
        departmentManagementCard.classList.add('active');
        departmentManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    entriesManagementCard.addEventListener('click', function() {
        userManagementSection.classList.remove('active');
        userManagementCard.classList.remove('active');
        departmentManagementSection.classList.remove('active');
        departmentManagementCard.classList.remove('active');

        entriesManagementSection.classList.add('active');
        entriesManagementCard.classList.add('active');
        entriesManagementSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    function closeSection(sectionId) {
        const section = document.getElementById(sectionId);
        section.classList.remove('active');

        if (sectionId === 'userManagementSection') {
            userManagementCard.classList.remove('active');
        } else if (sectionId === 'departmentManagementSection') {
            departmentManagementCard.classList.remove('active');
        } else if (sectionId === 'entriesManagementSection') {
            entriesManagementCard.classList.remove('active');
        }
    }

    // Tabs
    document.querySelectorAll('.user-type-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            document.querySelectorAll('.user-type-tab').forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            document.querySelectorAll('.user-form-section').forEach(s => s.classList.remove('active'));
            const target = this.getAttribute('data-target');
            document.getElementById(target).classList.add('active');
        });
    });

    document.querySelectorAll('.department-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            document.querySelectorAll('.department-tab').forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            document.querySelectorAll('.department-section').forEach(s => s.classList.remove('active'));
            const target = this.getAttribute('data-target');
            document.getElementById(target).classList.add('active');
        });
    });

    // Department select toggle
    const userTypeSelect = document.getElementById('userType');
    const departmentField = document.getElementById('departmentField');
    const userFormFields = document.getElementById('userFormFields');
    const departmentSelect = document.getElementById('department');

    userTypeSelect.addEventListener('change', function() {
        if (this.value) {
            userFormFields.style.display = 'block';
            if (this.value === 'superadmin') {
                departmentField.style.display = 'none';
                departmentSelect.removeAttribute('required');
            } else {
                departmentField.style.display = 'block';
                departmentSelect.setAttribute('required', 'required');
                if (this.value === 'admin') {
                    Array.from(departmentSelect.options).forEach(option => {
                        if (option.text.includes('(Head assigned)')) {
                            option.disabled = true;
                        } else {
                            option.disabled = false;
                        }
                    });
                } else {
                    Array.from(departmentSelect.options).forEach(option => option.disabled = false);
                }
            }
        } else {
            userFormFields.style.display = 'none';
        }
    });

    // Password toggle
    const passwordField = document.getElementById('passwordField');
    const togglePassword = document.getElementById('togglePassword');

    togglePassword.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);
        this.innerHTML = type === 'password'
            ? '<i class="fas fa-eye"></i>'
            : '<i class="fas fa-eye-slash"></i>';
    });

    // Add user form submission
    document.getElementById('addUserForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        document.getElementById("username").classList.remove("error-field");
        document.getElementById("email").classList.remove("error-field");
        document.getElementById("department").classList.remove("error-field");

        const submitBtn = document.querySelector('#addUserForm button[type="submit"]');
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
        submitBtn.disabled = true;

        const formData = new FormData(this);
        if (formData.get('role') === 'superadmin') {
            formData.delete('department_id');
        }

        try {
            const response = await fetch(contextPath + '/add-user', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams(formData).toString()
            });
            const data = await response.json();

            if (data.status === 'success') {
                showNotification('success', data.message);
                this.reset();
                userFormFields.style.display = 'none';
                departmentField.style.display = 'none';
                userTypeSelect.value = '';
            } else {
                showNotification('error', data.message);
                if (data.message.includes("Username")) {
                    document.getElementById('username').classList.add('error-field');
                } else if (data.message.includes("Email")) {
                    document.getElementById('email').classList.add('error-field');
                } else if (data.message.includes("Department")) {
                    document.getElementById('department').classList.add('error-field');
                }
            }
        } catch (err) {
            showNotification('error', 'An error occurred: ' + err.message);
        } finally {
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
        }
    });

   
    

    // Animate on load
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('userFormFields').style.display = 'none';
        document.getElementById('departmentField').style.display = 'none';

        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.style.animation = 'fadeInUp 0.6s ease-out forwards';
            }, index * 150);
        });
    });

    // Load registers for selected department
    function loadRegisters(departmentName) {
        const registerSelect = document.getElementById('registerSelect');
        const loadEntriesBtn = document.getElementById('loadEntriesBtn');
        
        if (!departmentName) {
            registerSelect.innerHTML = '<option value="">-- Select Register --</option>';
            registerSelect.disabled = true;
            loadEntriesBtn.disabled = true;
            return;
        }
        
        fetch(contextPath + '/superadmin?action=getRegisters&department=' + encodeURIComponent(departmentName))
            .then(response => response.json())
            .then(data => {
                registerSelect.innerHTML = '<option value="">-- Select Register --</option>';
                if (data.status === 'success' && data.registers.length > 0) {
                    data.registers.forEach(register => {
                        const option = document.createElement('option');
                        option.value = register.register_id;
                        option.textContent = register.name;
                        registerSelect.appendChild(option);
                    });
                    registerSelect.disabled = false;
                } else {
                    registerSelect.innerHTML = '<option value="">No registers found</option>';
                    registerSelect.disabled = true;
                    loadEntriesBtn.disabled = true;
                    if (data.status === 'error') {
                        showNotification('error', data.message);
                    }
                }
            })
            .catch(error => {
                console.error('Error loading registers:', error);
                showNotification('error', 'Failed to load registers');
            });
    }

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
        const entriesLoadingSpinner = document.getElementById('entriesLoadingSpinner');
        const entriesTableContainer = document.getElementById('entriesTableContainer');
        
        entriesTableContainer.style.display = 'none';
        entriesLoadingSpinner.classList.add('active');
        entriesTableBody.innerHTML = '';
        
        fetch(contextPath + '/superadmin?action=getEntries&registerId=' + registerId)
            .then(response => response.json())
            .then(data => {
                entriesLoadingSpinner.classList.remove('active');
                entriesTableContainer.style.display = 'block';
                
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
                            
                            // Add static columns
                            const srNoCell = document.createElement('td');
                            srNoCell.textContent = index + 1;
                            row.appendChild(srNoCell);

                            const submittedByCell = document.createElement('td');
                            submittedByCell.textContent = entry.submitted_by_name || 'Unknown';
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
                            
                            // Create Edit Button (updated to match member.jsp)
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
                entriesLoadingSpinner.classList.remove('active');
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

    // Enable load button when register is selected
    document.getElementById('registerSelect').addEventListener('change', function() {
        document.getElementById('loadEntriesBtn').disabled = !this.value;
    });

    function editEntry(entryId) {
        const registerSelect = document.getElementById('registerSelect');
        const registerId = registerSelect.value;

        if (!registerId) {
            showNotification('error', 'Please select a register first before editing an entry.');
            return;
        }
        window.location.href = contextPath + '/edit-entry?entryId=' + entryId + '&registerId=' + registerId;
    }
    </script>
</body>
</html>