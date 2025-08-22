<%@ page import="javax.servlet.http.HttpSession" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
    <title>NWR Employee Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/login.css">
</head>
<body>
    <div class="preloader">
        <div class="preloader-content">
            <div class="train-animation">
                <div class="train-track"></div>
                <i class="fas fa-train train-icon"></i>
            </div>
            <h2 class="loading-text">NORTH WESTERN RAILWAYS</h2>
            <p class="loading-subtext">Initializing secure portal...</p>
            <div class="progress-container">
                <div class="progress-bar"></div>
            </div>
        </div>
    </div>

    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    

    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <div class="logo">
                    <img src="assets/logo.png" 
                         alt="Indian Railways Logo" class="railway-logo">
                    <span class="logo-text">NWR Portal</span>
                </div>
                <h2 class="login-title">Employee Login</h2>
                <p class="login-subtitle">Enter your credentials to access the portal</p>
            </div>
            
            <form id="loginForm" action="login" method="post">
                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" class="input-field" 
                               placeholder="Enter Username" required>
                        <i class="fas fa-user input-icon"></i>
                    </div>
                    <span class="error-text">Please enter your Username</span>
                </div>
                
                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" class="input-field" 
                               placeholder="Enter Password" required>
                        <i class="fas fa-lock input-icon"></i>
                        <i class="fas fa-eye password-toggle" id="passwordToggle"></i>
                    </div>
                    <span class="error-text">Please enter your password</span>
                </div>
                
                <div class="remember-forgot">
                    <div class="remember-me">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">Remember me</label>
                    </div>
                    <a href="forgot-password.jsp" class="forgot-password">Forgot password?</a>
                </div>
                
                <button type="submit" class="login-button">Sign In</button>
                <div class="error-message" id="errorMessage"></div>
            </form>
        </div>
    </div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Get form elements
        const loginForm = document.getElementById('loginForm');
        const errorMessage = document.getElementById('errorMessage');
        const usernameInput = document.getElementById('username');
        const passwordInput = document.getElementById('password');
        const rememberCheckbox = document.getElementById('remember');
        const passwordToggle = document.getElementById('passwordToggle');
        const loginButton = document.querySelector('.login-button');
        
        // Password visibility toggle
        passwordToggle.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
            
            // Add animation effect
            passwordInput.style.transform = 'scale(1.02)';
            setTimeout(() => {
                passwordInput.style.transform = 'scale(1)';
            }, 200);
        });
        
        // Input focus effects
        const inputs = document.querySelectorAll('.input-field');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                this.style.boxShadow = '0 0 0 3px rgba(0, 86, 179, 0.2)';
                this.parentElement.querySelector('.input-icon').style.color = 'var(--primary)';
            });
            
            input.addEventListener('blur', function() {
                this.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)';
                this.parentElement.querySelector('.input-icon').style.color = 'var(--gray)';
            });
        });
        
        // Form validation and submission
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Reset error states
            errorMessage.classList.remove('show');
            usernameInput.classList.remove('invalid');
            passwordInput.classList.remove('invalid');
            
            // Simple validation
            let isValid = true;
            if (!usernameInput.value.trim()) {
                usernameInput.classList.add('invalid');
                isValid = false;
            }
            if (!passwordInput.value) {
                passwordInput.classList.add('invalid');
                isValid = false;
            }
            
            if (!isValid) {
                errorMessage.textContent = "Please fill in all required fields";
                errorMessage.classList.add('show');
                return;
            }
            
            // Show loading state on button
            loginButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing in...';
            loginButton.disabled = true;
            
            // Create FormData object from the form
            const formData = new FormData(loginForm);
            
            // Send data to login servlet using fetch API
            fetch('login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams(formData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    // Successful login - redirect
                    loginButton.innerHTML = '<i class="fas fa-check"></i> Login Successful!';
                    loginButton.style.backgroundColor = 'var(--success)';
                    
                    setTimeout(() => {
                        window.location.href = data.redirectUrl;
                    }, 1000);
                } else {
                    // Show specific error message from server
                    errorMessage.textContent = data.message;
                    errorMessage.classList.add('show');
                    
                    // Shake animation for error
                    loginForm.classList.add('shake');
                    
                    setTimeout(() => {
                        loginForm.classList.remove('shake');
                        
                        // Clear password field
                        passwordInput.value = '';
                        
                        // Focus on the problematic field
                        if (data.errorField === 'username') {
                            usernameInput.focus();
                        } else if (data.errorField === 'password') {
                            passwordInput.focus();
                        }
                    }, 500);
                    
                    // Reset button
                    loginButton.innerHTML = 'Sign In';
                    loginButton.disabled = false;
                }
            })
            .catch(error => {
                errorMessage.textContent = "Error communicating with server. Please try again.";
                errorMessage.classList.add('show');
                console.error('Error:', error);
                
                // Reset button
                loginButton.innerHTML = 'Sign In';
                loginButton.disabled = false;
            });
        });
        
        // Preloader animation
        const preloader = document.querySelector('.preloader');
        const progressBar = document.querySelector('.progress-bar');
        const statusText = document.querySelector('.loading-subtext');
        
        const statusMessages = [
            "Authenticating security protocols...",
            "Connecting to railway database...",
            "Loading employee records...",
            "Finalizing system checks...",
            "Ready to proceed..."
        ];
        
        let progress = 0;
        let currentStatus = 0;
        
        const loadInterval = setInterval(() => {
            progress += Math.random() * 10;
            progress = Math.min(progress, 100);
            progressBar.style.width = progress + '%';
            
            if (progress % 25 < 5) {
                statusText.style.opacity = 0;
                setTimeout(() => {
                    statusText.textContent = statusMessages[currentStatus];
                    statusText.style.opacity = 1;
                    currentStatus = (currentStatus + 1) % statusMessages.length;
                }, 300);
            }
            
            if (progress >= 100) {
                clearInterval(loadInterval);
                setTimeout(() => {
                    preloader.style.opacity = '0';
                    preloader.style.visibility = 'hidden';
                }, 500);
            }
        }, 100);
    });
</script>
</body>
</html>