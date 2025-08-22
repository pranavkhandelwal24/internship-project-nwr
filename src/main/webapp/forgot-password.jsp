<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0056b3;
            --primary-light: #3a7fc5;
            --primary-dark: #003d7a;
            --primary-darker: #002a5a;
            --secondary: #e63946;
            --success: #28a745;
            --warning: #ff9800;
            --light: #f8f9fa;
            --dark: #212529;
            --gray: #6c757d;
            --gray-light: #e9ecef;
            --border: #dee2e6;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            --glass-bg: rgba(255, 255, 255, 0.9);
            --glass-border: rgba(255, 255, 255, 0.3);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--primary-darker), var(--primary-dark));
            color: var(--dark);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .main-content {
            width: 100%;
            max-width: 600px;
        }

        .form-header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }

        .logo-title-group {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .railway-logo {
            height: 50px;
            width: auto;
        }

        .form-main-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 0;
        }

        .form-title {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--primary-dark);
            position: relative;
            padding-left: 15px;
            margin-bottom: 20px;
        }

        .form-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 5px;
            height: 80%;
            width: 5px;
            background: var(--primary);
            border-radius: 3px;
        }

        .edit-form-container {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--glass-border);
        }

        .back-button {
            background: rgba(0, 86, 179, 0.1);
            border: none;
            border-radius: 8px;
            padding: 8px 15px;
            cursor: pointer;
            font-weight: 600;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .back-button:hover {
            background: rgba(0, 86, 179, 0.2);
        }

        .form-group {
            margin-bottom: 20px;
            position: relative;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--primary-dark);
            font-size: 1rem;
        }

        .form-control {
            width: 100%;
            padding: 14px 18px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 1rem;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.2);
            outline: none;
        }

        .btn {
            padding: 14px 28px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
        }

        .btn-primary {
            background: linear-gradient(90deg, var(--primary), var(--primary-light));
            color: white;
            width: 100%;
            margin-top: 10px;
        }

        .btn-primary:hover {
            background: linear-gradient(90deg, var(--primary-dark), var(--primary));
        }

        .notification {
            margin-top: 20px;
            padding: 15px;
            border-radius: 10px;
            display: flex;
            align-items: center;
        }

        .notification i {
            margin-right: 12px;
            font-size: 1.2rem;
        }

        .notification-success {
            background: rgba(212, 237, 218, 0.9);
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .notification-error {
            background: rgba(248, 215, 218, 0.9);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        @media (max-width: 768px) {
            .form-main-title {
                font-size: 1.5rem;
            }
            
            .railway-logo {
                height: 40px;
            }
            
            .form-title {
                font-size: 1.4rem;
            }
            
            .edit-form-container {
                padding: 25px;
            }
            
            .logo-title-group {
                gap: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="main-content">
        <div class="edit-form-container">
            <div class="form-header-container">
                <div class="logo-title-group">
                    <img src="${pageContext.request.contextPath}/assets/logo.png" 
                         alt="Indian Railways Logo" 
                         class="railway-logo">
                    <h1 class="form-main-title">Account Recovery</h1>
                </div>
                <button class="back-button" onclick="window.location.href='login.jsp'">
                    <i class="fas fa-arrow-left"></i> Back to Login
                </button>
            </div>
            
            <h2 class="form-title">Reset Your Password</h2>
            
            <form action="send-reset-link" method="post">
                <div class="form-group">
                    <label class="form-label">Registered Email</label>
                    <input type="email" name="email" class="form-control" placeholder="Enter your registered email" required>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-paper-plane"></i> Send Reset Link
                </button>
            </form>
            
            <% if ("true".equals(request.getParameter("success"))) { %>
                <div class="notification notification-success">
                    <i class="fas fa-check-circle"></i>
                    Reset link sent successfully! Check your email.
                </div>
            <% } else if ("false".equals(request.getParameter("error"))) { %>
                <div class="notification notification-error">
                    <i class="fas fa-exclamation-circle"></i>
                    Failed to send email. Please try again.
                </div>
            <% } %>
        </div>
    </div>
        
    <%@ include file="WEB-INF/notif.jsp" %>
    
</body>
</html>