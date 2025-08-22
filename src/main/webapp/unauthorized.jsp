<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        :root {
            --shadow-dark: radial-gradient(ellipse at center, rgba(0,0,0,0.35) 0%, rgba(0,0,0,0) 70%);
        }
        
        body {
            font-family: 'Segoe UI', Roboto, -apple-system, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
            color: #212529;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            line-height: 1.6;
        }

        .access-container {
            text-align: center;
            padding: 2rem;
            max-width: 480px;
            width: 90%;
        }

        h1 {
            font-size: 1.8rem;
            margin: 0 0 1.5rem;
            font-weight: 500;
            color: #343a40;
        }

        .character-wrapper {
            position: relative;
            height: 180px;
            margin: 2rem 0;
        }

        .character {
            width: 140px;
            height: 140px;
            object-fit: contain;
            position: absolute;
            left: 50%;
            top: 0;
            transform: translateX(-50%);
            z-index: 2;
            animation: float 5s ease-in-out infinite;
        }

        .shadow {
            position: absolute;
            width: 100px;
            height: 15px;
            left: 50%;
            bottom: 0;
            transform: translateX(-50%) scale(1);
            border-radius: 50%;
            z-index: 1;
            background: var(--shadow-dark);
            animation: shadow-fade 5s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% {
                transform: translate(-50%, 0);
            }
            50% {
                transform: translate(-50%, -20px);
            }
        }

        @keyframes shadow-fade {
            0%, 100% {
                opacity: 0.8;
                transform: translateX(-50%) scale(1);
            }
            50% {
                opacity: 0.4;
                transform: translateX(-50%) scale(0.7);
            }
        }

        .message {
            color: #495057;
            margin-bottom: 2rem;
            font-size: 1.05rem;
        }

        .actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            text-decoration: none;
            border-radius: 6px;
            font-size: 0.95rem;
            font-weight: 500;
            transition: all 0.2s;
        }

        .btn-secondary {
            background: white;
            border: 1px solid #dee2e6;
            color: #495057;
        }

        .btn-primary {
            background: #dc3545;
            color: white;
            border: 1px solid #dc3545;
        }
    </style>
</head>
<body>
    <div class="access-container">
        <h1>Access Restricted</h1>
        
        <div class="character-wrapper">
            <img src="assets/d.png" alt="Access Denied" class="character">
            <div class="shadow"></div>
        </div>
        
        <p class="message">
 You are not authorized to access this resource, Kindly ensure that you are logged in with the correct account credentials.     </p>
        
        <div class="actions">
            <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
            <a href="logout.jsp" class="btn btn-primary">Login</a>
        </div>
    </div>
</body>
</html>
