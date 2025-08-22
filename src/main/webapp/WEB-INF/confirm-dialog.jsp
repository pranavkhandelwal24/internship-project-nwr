<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
/* Custom confirmation dialog */
.confirmation-dialog {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 10000;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
}

.confirmation-dialog.active {
    opacity: 1;
    visibility: visible;
}

.confirmation-box {
    background: white;
    border-radius: 20px;
    padding: 30px;
    max-width: 500px;
    width: 90%;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
    transform: translateY(-30px);
    transition: all 0.4s ease;
}

.confirmation-dialog.active .confirmation-box {
    transform: translateY(0);
}

.confirmation-title {
    font-size: 1.8rem;
    color: var(--primary-dark);
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 15px;
}

.confirmation-title i {
    color: var(--secondary);
    font-size: 2.2rem;
}

.confirmation-message {
    font-size: 1.2rem;
    color: var(--dark);
    margin-bottom: 30px;
    line-height: 1.6;
}

.confirmation-actions {
    display: flex;
    gap: 15px;
    justify-content: flex-end;
}

.btn-cancel {
    background: var(--gray-light);
    color: var(--dark);
    border: none;
    padding: 12px 25px;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 600;
    transition: var(--transition);
}

.btn-confirm {
    background: var(--secondary);
    color: white;
    border: none;
    padding: 12px 25px;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 600;
    transition: var(--transition);
}

.btn-cancel:hover {
    background: #d1d1d1;
    transform: translateY(-3px);
}

.btn-confirm:hover {
    background: #c1121f;
    transform: translateY(-3px);
}
</style>

<!-- Custom confirmation dialog -->
<div class="confirmation-dialog" id="confirmationDialog">
    <div class="confirmation-box">
        <h3 class="confirmation-title">
            <i class="fas fa-exclamation-triangle"></i>
            Confirm Deletion
        </h3>
        <p class="confirmation-message" id="confirmationMessage">
            Are you sure you want to delete this user?
        </p>
        <div class="confirmation-actions">
            <button class="btn-cancel" id="cancelDelete">Cancel</button>
            <button class="btn-confirm" id="confirmDelete">Delete</button>
        </div>
    </div>
</div>