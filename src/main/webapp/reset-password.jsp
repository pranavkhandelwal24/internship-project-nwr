<%@ page import="java.sql.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.InputStream" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reset Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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

        .reset-container {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--glass-border);
            width: 100%;
            max-width: 500px;
        }

        .logo-title-group {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .railway-logo {
            height: 50px;
            width: auto;
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-dark);
        }

        .form-title {
            font-size: 1.4rem;
            font-weight: 600;
            color: var(--primary-dark);
            margin-bottom: 20px;
            position: relative;
            padding-left: 15px;
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

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--primary-dark);
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .form-control {
            width: 100%;
            padding: 14px 18px;
            padding-right: 40px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 1rem;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
            font-family: 'Poppins', sans-serif;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.2);
            outline: none;
        }

        .toggle-password {
            position: absolute;
            right: 15px;
            cursor: pointer;
            color: var(--gray);
            font-size: 1.1rem;
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
            width: 100%;
            font-family: 'Poppins', sans-serif;
        }

        .btn-primary {
            background: linear-gradient(90deg, var(--primary), var(--primary-light));
            color: white;
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
            justify-content: center;
            text-align: center;
        }

        .notification-error {
            background: rgba(248, 215, 218, 0.9);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        @media (max-width: 768px) {
            .page-title {
                font-size: 1.5rem;
            }
            
            .railway-logo {
                height: 40px;
            }
            
            .form-title {
                font-size: 1.2rem;
            }
            
            .reset-container {
                padding: 25px;
            }
        }
    </style>
</head>
<body>
    <div class="reset-container">
        <div class="logo-title-group">
            <img src="${pageContext.request.contextPath}/assets/logo.png" 
                 alt="Indian Railways Logo" 
                 class="railway-logo">
            <h1 class="page-title">Password Reset</h1>
        </div>

        <%
            String token = request.getParameter("token");
            if (token == null) {
                out.println("<div class='notification notification-error'>Invalid or missing token.</div>");
                return;
            }

            String email = null;
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                Properties props = new Properties();
                InputStream input = application.getResourceAsStream("/WEB-INF/config.properties");
                if (input != null) {
                    props.load(input);
                    String dbUrl = props.getProperty("db_url");
                    String dbUser = props.getProperty("db_username");
                    String dbPass = props.getProperty("db_password");

                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                    ps = con.prepareStatement("SELECT email FROM password_reset_tokens WHERE token = ?");
                    ps.setString(1, token);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        email = rs.getString("email");
                    }
                } else {
                    out.println("<div class='notification notification-error'>Configuration file (config.properties) not found.</div>");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<div class='notification notification-error'>An error occurred while processing your request. Please try again later.</div>");
                return;
            } finally {
                try { if (rs != null) rs.close(); } catch (SQLException e) { }
                try { if (ps != null) ps.close(); } catch (SQLException e) { }
                try { if (con != null) con.close(); } catch (SQLException e) { }
            }

            if (email == null) {
                out.println("<div class='notification notification-error'>Invalid or expired token.</div>");
                return;
            }
        %>

        <h2 class="form-title">Reset Password for <%= email %></h2>
        
        <form action="ResetPasswordServlet" method="post">
            <input type="hidden" name="token" value="<%= token %>"/>
            
            <div class="form-group">
                <label class="form-label">New Password</label>
                <div class="input-wrapper">
                    <input type="password" name="password" id="password" class="form-control" placeholder="Enter new password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('password', this)"></i>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">Confirm Password</label>
                <div class="input-wrapper">
                    <input type="password" name="confirm" id="confirm" class="form-control" placeholder="Confirm your password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('confirm', this)"></i>
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-sync-alt"></i> Reset Password
            </button>
        </form>
    </div>
    
    <script>
        function togglePassword(fieldId, icon) {
            const input = document.getElementById(fieldId);
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }
    </script>

    <%@ include file="WEB-INF/notif.jsp" %>
</body>
</html>
