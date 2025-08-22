package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;

@WebServlet("/send-reset-link")
public class SendResetLinkServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email = req.getParameter("email");
        String token = UUID.randomUUID().toString();
        System.out.println("👉 Email entered: " + email);

        Properties config = new Properties();
        try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {
            if (input == null) {
                System.out.println("❌ Config file not found");
                throw new ServletException("Could not find WEB-INF/config.properties");
            }
            config.load(input);
            System.out.println("✅ Loaded config.properties");
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect("forgot-password.jsp?error=config");
            return;
        }

        String dbUrl = config.getProperty("db_url");
        String dbUser = config.getProperty("db_username");
        String dbPass = config.getProperty("db_password");
        String fromEmail = config.getProperty("smtp_email");
        String appPassword = config.getProperty("smtp_password");

        System.out.println("👉 db_url: " + dbUrl);
        System.out.println("👉 From Email: " + fromEmail);

        boolean emailExists = false;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            System.out.println("✅ Connected to DB");

            String[] tables = {"users"};

            for (String table : tables) {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM " + table + " WHERE email = ?");
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    emailExists = true;
                    System.out.println("✅ Found email in table: " + table);
                    break;
                }
            }

            if (emailExists) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO password_reset_tokens (email, token) VALUES (?, ?)"
                );
                ps.setString(1, email);
                ps.setString(2, token);
                ps.executeUpdate();
                System.out.println("✅ Token inserted");

                // Dynamically build the link
                String scheme = req.getScheme();
                String serverName = req.getServerName();
                int serverPort = req.getServerPort();
                String contextPath = req.getContextPath();

                StringBuilder url = new StringBuilder();
                url.append(scheme).append("://").append(serverName);
                if ((scheme.equals("http") && serverPort != 80) || (scheme.equals("https") && serverPort != 443)) {
                    url.append(":").append(serverPort);
                }
                url.append(contextPath).append("/reset-password.jsp?token=").append(token);

                String resetLink = url.toString();
                System.out.println("✅ Reset link: " + resetLink);

                Properties props = new Properties();
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.debug", "true");  // Enable debug

                Session session = Session.getInstance(props, new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(fromEmail, appPassword);
                    }
                });


                Message msg = new MimeMessage(session);
                msg.setFrom(new InternetAddress(fromEmail));
                msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
                msg.setSubject("Reset Your Password");
                msg.setText("Click the link below to reset your password:\n\n" + resetLink);

                Transport.send(msg);
                System.out.println("✅ Email sent!");

                res.sendRedirect("forgot-password.jsp?success=true");
            } else {
                System.out.println("❌ Email not found");
                res.sendRedirect("forgot-password.jsp?error=No account linked with this email");
            }

            con.close();

        } catch (Exception e) {
            System.out.println("❌ Exception in main try block:");
            e.printStackTrace();
            res.sendRedirect("forgot-password.jsp?error=server");
        }
    }
}