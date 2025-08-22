<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- Modern Notification Styles -->
<style>
    /* Notification Container */
    .notification-container {
        position: fixed;
        top: 25px;
        right: 25px;
        max-width: 380px;
        z-index: 10000;
        display: flex;
        flex-direction: column;
        gap: 15px;
        
    }
    
    /* Base Notification - Modern Card Design */
    .notification {
        position: relative;
        padding: 18px 20px;
        border-radius: 10px;
        box-shadow: 0 3px 15px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: flex-start;
        animation: notificationSlideIn 0.35s cubic-bezier(0.21, 0.61, 0.35, 1) forwards;
        opacity: 0;
        transform: translateX(120%);
        max-width: 100%;
        background: white;
        border-left: 4px solid;
        transition: all 0.3s ease;
        overflow: hidden;
    }

    /* Notification States */
    .notification.show {
        opacity: 1;
        transform: translateX(0);
    }
    
    .notification.hide {
        animation: notificationSlideOut 0.35s forwards;
    }
    
    /* Notification Types */
    .notification-success {
        border-left-color: #4CAF50;
        background: #F1F8E9;
    }
    
    .notification-error {
        border-left-color: #F44336;
        background: #FFEBEE;
    }
    
    .notification-notice {
        border-left-color: #2196F3;
        background: #E3F2FD;
    }
    
    /* Notification Icon */
    .notification-icon {
        font-size: 1.5rem;
        margin-right: 15px;
        flex-shrink: 0;
        margin-top: 2px;
    }
    
    .notification-success .notification-icon {
        color: #4CAF50;
    }
    
    .notification-error .notification-icon {
        color: #F44336;
    }
    
    .notification-notice .notification-icon {
        color: #2196F3;
    }
    
    /* Notification Content */
    .notification-content {
        flex-grow: 1;
        padding-right: 25px;
    }
    
    .notification-title {
        font-weight: 600;
        margin-bottom: 5px;
        font-size: 1.1rem;
        color: #263238;
    }
    
    .notification-message {
        font-size: 0.95rem;
        line-height: 1.4;
        color: #455A64;
    }
    
    /* Close Button - Modern Circle */
    .notification-close-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        background: none;
        border: none;
        color: #78909C;
        font-size: 1rem;
        cursor: pointer;
        padding: 5px;
        width: 26px;
        height: 26px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: all 0.2s ease;
    }
    
    .notification-close-btn:hover {
        background: rgba(0, 0, 0, 0.05);
        color: #37474F;
    }
    
    /* Progress Bar */
    .notification-progress {
        position: absolute;
        bottom: 0;
        left: 0;
        height: 3px;
        background: rgba(0, 0, 0, 0.1);
        width: 100%;
    }
    
    .notification-progress-bar {
        height: 100%;
        transition: width linear;
    }
    
    .notification-success .notification-progress-bar {
        background: #4CAF50;
    }
    
    .notification-error .notification-progress-bar {
        background: #F44336;
    }
    
    .notification-notice .notification-progress-bar {
        background: #2196F3;
    }
    
    /* Animations */
    @keyframes notificationSlideIn {
        from {
            opacity: 0;
            transform: translateX(120%);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes notificationSlideOut {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(120%);
        }
    }
    
    /* Responsive */
    @media (max-width: 768px) {
        .notification-container {
            right: 15px;
            left: 15px;
            max-width: calc(100% - 30px);
        }
        
        .notification {
            padding: 16px;
        }
    }
</style>

<div id="notificationContainer" class="notification-container"></div>

<!-- Notification Script -->
<script>
function showNotification(type, message) {
    const container = document.getElementById('notificationContainer');
    const notification = document.createElement('div');
    
    // Determine icon and title based on type
    let iconClass, title;
    if (type === 'success') {
        iconClass = 'fa-check-circle';
        title = 'Success!';
        notification.className = 'notification notification-success';
    } else if (type === 'error') {
        iconClass = 'fa-exclamation-circle';
        title = 'Error!';
        notification.className = 'notification notification-error';
    } else {
        iconClass = 'fa-info-circle';
        title = 'Notice!';
        notification.className = 'notification notification-notice';
    }
    
    // Create notification elements
    const notificationIcon = document.createElement('div');
    notificationIcon.className = 'notification-icon';
    notificationIcon.innerHTML = `<i class="fas ${iconClass}"></i>`;
    
    const notificationContent = document.createElement('div');
    notificationContent.className = 'notification-content';
    
    const notificationTitle = document.createElement('div');
    notificationTitle.className = 'notification-title';
    notificationTitle.textContent = title;
    
    const notificationMessage = document.createElement('div');
    notificationMessage.className = 'notification-message';
    notificationMessage.textContent = message;
    
    notificationContent.appendChild(notificationTitle);
    notificationContent.appendChild(notificationMessage);
    
    const closeButton = document.createElement('button');
    closeButton.className = 'notification-close-btn';
    closeButton.innerHTML = '<i class="fas fa-times"></i>';
    
    // Build notification structure
    notification.appendChild(notificationIcon);
    notification.appendChild(notificationContent);
    notification.appendChild(closeButton);
    
    // Prepend to show newest on top
    container.insertBefore(notification, container.firstChild);
    
    // Trigger show animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Auto-remove after 8 seconds (longer for success messages)
    const removeTimeout = setTimeout(() => {
        notification.classList.remove('show');
        notification.classList.add('hide');
        setTimeout(() => notification.remove(), 500);
    }, type === 'success' ? 8000 : 5000);
    
    // Manual close
    closeButton.addEventListener('click', () => {
        clearTimeout(removeTimeout);
        notification.classList.remove('show');
        notification.classList.add('hide');
        setTimeout(() => notification.remove(), 500);
    });
    
    // Clicking on notification content refreshes page for success messages
    if (type === 'success') {
        notificationContent.style.cursor = 'pointer';
        notificationContent.addEventListener('click', () => {
            location.reload();
        });
    }
}

// Helper function to escape HTML special characters
function escapeHtml(unsafe) {
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
}

//Check for success message in URL and session
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const successMsg = urlParams.get('success');
    const errorMsg = urlParams.get('error');
    
    // Check if we've already shown this success message
    if (successMsg) {
showNotification('success', successMsg);

urlParams.delete('success');
const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
history.replaceState(null, '', newUrl);
}

    
    if (errorMsg) {
        showNotification('error', errorMsg);
    }
});
</script>