<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">
    <title>NWR Member Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/superadmin.css">
    <style>
        /* Responsive fixes for member page only */
        .management-section {
            display: none;
        }
        
        .management-section.active {
            display: block;
        }
        
        /* Fix for register selector row */
        .register-selector-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            margin-bottom: 20px;
        }
        
        .register-selector-row .form-group {
            flex: 1;
            margin-bottom: 0;
        }
        
        .register-selector-row button {
            height: 42px;
            padding: 0 20px;
            white-space: nowrap;
            margin-bottom: 0;
        }
        
        /* Mobile adjustments */
        @media (max-width: 767px) {
            .register-selector-row {
                flex-direction: column;
                align-items: stretch;
            }
            
            .register-selector-row button {
                width: 100%;
            }
            
            .register-selector-row button .btn-text {
                display: none;
            }
            
            .register-selector-row button i {
                margin-right: 0;
            }
        }
        
        /* Table container fixes */
        .table-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        }
        
        /* Feature card hover effect */
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(58, 127, 197, 0.3);
        }
        
        /* Form control styling */
        .form-control {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid #dee2e6;
        }
        /* Table container fixes */
    .table-container {
        background: rgba(255, 255, 255, 0.95);
        border-radius: 12px;
        overflow-x: auto;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        max-height: 500px; /* Set a fixed height */
        display: block; /* Change to block for proper scrolling */
    }

    /* Ensure table takes full width */
    .data-table {
        width: 100%;
        min-width: 600px; /* Minimum width before scrolling kicks in */
    }

    /* Add scrollbar styling */
    .table-container::-webkit-scrollbar {
        height: 8px;
        width: 8px;
    }

    .table-container::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 10px;
    }

    .table-container::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 10px;
    }

    .table-container::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
    </style>
</head>
<body>
    <div class="floating-element circle-1"></div>
    <div class="floating-element circle-2"></div>
    <div class="floating-element circle-3"></div>

    <%@include file="WEB-INF/confirm-dialog.jsp" %>

    <%@ include file="WEB-INF/navbar.jsp" %>

    <div class="hero-section">
        <div class="hero-bg"></div>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <div class="hero-card">
                <h1 class="hero-title">Member Dashboard</h1>
                <p class="hero-description">
                    Welcome back, ${sessionScope.firstName}! Manage your entries in
                    ${not empty departmentInfo.departmentName ? departmentInfo.departmentName : 'your department'}.
                    <c:if test="${not empty errorMessage}">
                        <div class="error-message">${errorMessage}</div>
                    </c:if>
                </p>
            </div>
        </div>
    </div>

    <div class="main-content">
        <h2 class="section-title">Management Dashboard</h2>

        <div class="features">
            <div class="feature-card" id="registerEntriesCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h3 class="feature-title">Register Entries</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        Add new entries to department registers.
                    </p>
                </div>
            </div>

            <div class="feature-card" id="viewEntriesCard">
                <div class="feature-header">
                    <div class="feature-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3 class="feature-title">View Entries</h3>
                </div>
                <div class="feature-body">
                    <p class="feature-description">
                        View your submitted entries.
                    </p>
                </div>
            </div>
        </div>

        <div class="management-section" id="registerEntriesSection">
            <div class="section-header">
                <h3 class="section-subtitle">Register Entries</h3>
                <button class="close-section" onclick="closeSection('registerEntriesSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <div class="register-selector">
                <div class="register-selector-row">
                    <div class="form-group">
                        <label class="form-label">Select Register</label>
                        <select id="registerSelect" class="form-control">
                            <option value="">-- Select Register --</option>
                            <c:forEach items="${registers}" var="register">
                                <option value="${register.register_id}"
                                    <c:if test="${not empty currentLoadedRegisterId and register.register_id eq currentLoadedRegisterId}">selected</c:if>>
                                    ${register.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <button type="button" class="btn btn-primary" onclick="navigateToRegisterForm()" disabled id="loadFormBtn">
                        <i class="fas fa-arrow-alt-circle-up"></i> <span class="btn-text">Load Form</span>
                    </button>
                </div>
            </div>

            <div id="dynamicFormContainer" class="dynamic-form-container">
                <c:if test="${not empty formErrorMessage}">
                    <div class="form-error-message">${formErrorMessage}</div>
                </c:if>
                <div style="text-align: center; padding: 40px; color: #6c757d;">
                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                    <h4 style="color: #4361ee;">Select a Register</h4>
                    <p style="color: #6c757d;">Choose a register from the dropdown to load its entry form.</p>
                </div>
                ${dynamicFormHtml}
            </div>
        </div>

        <div class="management-section" id="viewEntriesSection">
            <div class="section-header">
                <h3 class="section-subtitle">View Entries</h3>
                <button class="close-section" onclick="closeSection('viewEntriesSection')">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <div class="register-selector">
                <div class="register-selector-row">
                    <div class="form-group">
                        <label class="form-label">Select Register</label>
                        <select id="entriesRegisterSelect" class="form-control">
                            <option value="">-- Select Register --</option>
                            <c:forEach items="${registers}" var="register">
                                <option value="${register.register_id}">${register.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <button type="button" class="btn btn-primary" onclick="loadRegisterEntries()" disabled id="loadEntriesBtn">
                        <i class="fas fa-search"></i> <span class="btn-text">Load Entries</span>
                    </button>
                </div>
            </div>

            <div class="table-container" id="entriesTableContainer" style="display: none; overflow-y: auto;">
			    <table class="data-table" id="entriesTable">
			        <thead id="entriesTableHeader">
			            <tr>
			                <th>Sr No.</th>
			                <th>Submitted By</th>
			                <th>Submitted At</th>
			            </tr>
			        </thead>
			        <tbody id="entriesTableBody">
			            <tr>
			                <td colspan="3" style="text-align: center; padding: 40px;">
			                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
			                    <h4 style="color: #4361ee;">No Entries Loaded</h4>
			                    <p style="color: #6c757d;">Select a register to view entries</p>
			                </td>
			            </tr>
			        </tbody>
			    </table>
			</div>
        </div>
    </div>
    
    <%@include file="WEB-INF/importantlinks.jsp" %>
    <%@include file="WEB-INF/footer.jsp" %>

    <%-- IMPORTANT: This includes your custom notification system --%>
    <%@include file="WEB-INF/notif.jsp" %>

    <script>
    // --- ABSOLUTE FIRST LINE OF JS EXECUTION ---
    console.log("Script block started execution!");

    const contextPath = '${pageContext.request.contextPath}';

    // Global variables for deletion
    let currentDeleteId = null;
    let currentDeleteRow = null;
    let currentDeleteButton = null;
    let currentRegisterId = null;

    document.addEventListener('DOMContentLoaded', function() {
        console.log("DOM Content Loaded event fired!");

        // Initialize feature cards
        const registerEntriesCard = document.getElementById('registerEntriesCard');
        const viewEntriesCard = document.getElementById('viewEntriesCard');
        const registerEntriesSection = document.getElementById('registerEntriesSection');
        const viewEntriesSection = document.getElementById('viewEntriesSection');
        const registerSelect = document.getElementById('registerSelect');
        const loadFormBtn = document.getElementById('loadFormBtn');

        // Animate feature cards on load
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            setTimeout(() => {
                card.classList.add('active');
            }, index * 150);
        });

        // Event listeners for feature cards
        if (registerEntriesCard) {
            registerEntriesCard.addEventListener('click', function() {
                viewEntriesSection.classList.remove('active');
                viewEntriesCard.classList.remove('active');
                registerEntriesSection.classList.add('active');
                registerEntriesCard.classList.add('active');
                registerEntriesSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        }

        if (viewEntriesCard) {
            viewEntriesCard.addEventListener('click', function() {
                registerEntriesSection.classList.remove('active');
                registerEntriesCard.classList.remove('active');
                viewEntriesSection.classList.add('active');
                viewEntriesCard.classList.add('active');
                viewEntriesSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        }

        // Enable/Disable load button when register is selected
        if (registerSelect) {
            registerSelect.addEventListener('change', function() {
                loadFormBtn.disabled = !this.value;
            });
        }

        const entriesRegisterSelect = document.getElementById('entriesRegisterSelect');
        const loadEntriesBtn = document.getElementById('loadEntriesBtn');
        if (entriesRegisterSelect) {
            entriesRegisterSelect.addEventListener('change', function() {
                loadEntriesBtn.disabled = !this.value;
            });
        }

        // Event delegation for delete buttons
        document.addEventListener('click', function(e) {
            const deleteBtn = e.target.closest('.btn-delete');
            if (deleteBtn) {
                e.preventDefault();
                e.stopPropagation();

                const entryIdToDelete = deleteBtn.getAttribute('data-id');
                const rowToDelete = deleteBtn.closest('tr');

                if (!entryIdToDelete) {
                    showNotification('error', 'Error: Entry ID missing for deletion.');
                    return;
                }

                // Store references
                currentDeleteId = entryIdToDelete;
                currentDeleteRow = rowToDelete;
                currentDeleteButton = deleteBtn;

                // Show confirmation dialog
                showDeleteConfirmation(entryIdToDelete);
            }
        });
    });

    function showDeleteConfirmation(entryId) {
        const dialog = document.getElementById('confirmationDialog');
        const message = document.getElementById('confirmationMessage');
        const confirmBtn = document.getElementById('confirmDelete');
        const cancelBtn = document.getElementById('cancelDelete');

        if (!dialog || !message || !confirmBtn || !cancelBtn) {
            console.error('Confirmation dialog elements not found!');
            showNotification('error', 'System error: Could not show confirmation dialog');
            return;
        }

        // Fix is here: Ensure the backticks (`) are used and ${entryId} is correctly inside
        message.textContent = `Are you sure you want to delete entry ${entryId}? This action cannot be undone.`;

        // Show the dialog
        dialog.classList.add('active');

        // Confirm button handler
        confirmBtn.onclick = function() {
            dialog.classList.remove('active');
            // currentDeleteId should already be set from the click handler
            performEntryDeletion(currentDeleteId, currentDeleteRow, currentDeleteButton);
        };

        // Cancel button handler
        cancelBtn.onclick = function() {
            dialog.classList.remove('active');
        };
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

            const data = await response.json(); // Always attempt to parse JSON

            if (!response.ok) { // Check if HTTP status code indicates an error
                // Server sent a non-2xx status, but still returned JSON
                showNotification('error', data.message || `Server responded with status: ${response.status}`);
                console.error('Server error:', response.status, data.message);
                return; // Exit here, no further processing needed
            }

            // HTTP status is OK (2xx), now check the 'status' property in the JSON
            if (data.status === 'success') {
                showNotification('success', data.message);
                if (rowElement) {
                    rowElement.remove();
                    checkIfTableEmpty();
                }
            } else {
                // Server returned 200 OK, but with an internal 'error' status
                showNotification('error', data.message || 'Delete failed: Server reported an issue.');
            }
        } catch (error) {
            console.error('Delete error (network/parsing):', error);
            showNotification('error', 'Delete failed: ' + error.message);
        } finally {
            if (deleteButton) {
                deleteButton.disabled = false;
                deleteButton.innerHTML = originalBtnHtml;
            }
        }
    }

    function checkIfTableEmpty() {
        const tableBody = document.getElementById('entriesTableBody');
        const tableHeaderRow = document.getElementById('entriesTableHeader').querySelector('tr');
        const totalColspan = tableHeaderRow ? tableHeaderRow.childElementCount : 10; // Default if header not found

        if (tableBody && tableBody.querySelectorAll('tr').length === 0) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="${totalColspan}" style="text-align: center; padding: 40px;">
                        <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                        <h4 style="color: #4361ee;">No Entries Found</h4>
                        <p style="color: #6c757d;">This register has no entries yet</p>
                    </td>
                </tr>
            `;
        }
    }

    function navigateToRegisterForm() {
        const registerSelect = document.getElementById('registerSelect');
        const selectedRegisterId = registerSelect.value;

        if (!selectedRegisterId) {
            showNotification('error', 'Please select a register first');
            return;
        }

        const url = contextPath + '/dynamic-form.jsp?registerId=' + selectedRegisterId;
        window.location.href = url;
    }

    function loadRegisterEntries() {
        const registerSelect = document.getElementById('entriesRegisterSelect');
        const registerId = registerSelect.value;

        if (!registerId) {
            showNotification('error', 'Please select a register first');
            return;
        }

        currentRegisterId = registerId;

        const entriesTableBody = document.getElementById('entriesTableBody');
        entriesTableBody.innerHTML = `<tr><td colspan="10" style="text-align: center; padding: 40px;"><div class="spinner"></div><p>Loading entries...</p></td></tr>`;

        fetch(contextPath + '/member?action=getEntries&registerId=' + registerId)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log("Received data in loadRegisterEntries:", data);
                const tableContainer = document.getElementById('entriesTableContainer');
                const tableHeader = document.getElementById('entriesTableHeader');
                const tableBody = document.getElementById('entriesTableBody');

                if (data.status === 'success') {
                    tableBody.innerHTML = '';

                    tableHeader.innerHTML = `
                        <tr>
                            <th>Sr No.</th>
                            <th>Submitted By</th>
                            <th>Submitted At</th>
                        </tr>
                    `;

                    if (data.data && data.data.columns) {
                        data.data.columns.forEach(column => {
                            const th = document.createElement('th');
                            th.textContent = column.label;
                            tableHeader.querySelector('tr').appendChild(th);
                        });
                    }

                    const actionsTh = document.createElement('th');
                    actionsTh.textContent = 'Actions';
                    tableHeader.querySelector('tr').appendChild(actionsTh);

                    if (data.data && data.data.entries && data.data.entries.length > 0) {
                        data.data.entries.forEach((entry, index) => {
                            console.log(`Processing entry #${index + 1}:`, entry);
                            console.log(`Value of entry.entry_id for this entry:`, entry.entry_id);

                            const row = document.createElement('tr');

                            const srNoCell = document.createElement('td');
                            srNoCell.textContent = index + 1;
                            row.appendChild(srNoCell);

                            const submittedByCell = document.createElement('td');
                            submittedByCell.textContent = entry.submitted_by_name || 'You';
                            row.appendChild(submittedByCell);

                            const submittedAtCell = document.createElement('td');
                            submittedAtCell.textContent = entry.submitted_at || 'Not available';
                            row.appendChild(submittedAtCell);

                            if (data.data.columns) {
                                data.data.columns.forEach(column => {
                                    const td = document.createElement('td');
                                    const value = entry[column.field_name] || '-';
                                    td.textContent = value;
                                    row.appendChild(td);
                                });
                            }

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
                            deleteButton.setAttribute('data-type', 'entry'); // Important for delegation
                            deleteButton.innerHTML = '<i class="fas fa-trash"></i> ';

                            actionsTd.appendChild(editButton);
                            actionsTd.appendChild(deleteButton);

                            row.appendChild(actionsTd);
                            tableBody.appendChild(row);
                        });
                    } else {
                        tableBody.innerHTML = `
                            <tr>
                                <td colspan="${tableHeader.querySelector('tr').childElementCount}" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-file-alt" style="font-size: 3rem; opacity: 0.3; margin-bottom: 15px;"></i>
                                    <h4 style="color: #4361ee;">No Entries Found</h4>
                                    <p style="color: #6c757d;">This register has no entries yet</p>
                                </td>
                            </tr>
                        `;
                    }

                    tableContainer.style.display = 'block';
                } else {
                    showNotification('error', data.message || 'Failed to load entries');
                }
            })
            .catch(error => {
                console.error('Error loading entries:', error);
                showNotification('error', 'Failed to load entries: ' + error.message);
                const tableHeaderRow = document.getElementById('entriesTableHeader').querySelector('tr');
                const currentColspan = tableHeaderRow ? tableHeaderRow.childElementCount : 10;
                tableBody.innerHTML = `<tr><td colspan="${currentColspan}" style="text-align: center; padding: 40px;"><p class="error-message">Network Error: ${error.message}</p></td></tr>`;
            });
    }

    function closeSection(sectionId) {
        document.getElementById(sectionId).classList.remove('active');
        if (sectionId === 'registerEntriesSection') {
            document.getElementById('registerEntriesCard').classList.remove('active');
            // Hide dynamic form container when closing the section
            document.getElementById('dynamicFormContainer').style.display = 'none';
        } else if (sectionId === 'viewEntriesSection') {
            document.getElementById('viewEntriesCard').classList.remove('active');
        }
    }

    function editEntry(entryId) {
        const registerSelect = document.getElementById('entriesRegisterSelect');
        const registerId = registerSelect.value; // Get the currently selected register ID

        if (!registerId) {
            showNotification('error', 'Please select a register first before editing an entry.');
            return;
        }
        // Redirect to the new edit-entry servlet with both entryId and registerId
        window.location.href = contextPath + '/edit-entry?entryId=' + entryId + '&registerId=' + registerId;
    }
</script>
</body>
</html>