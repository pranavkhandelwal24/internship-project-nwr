package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebListener;
import java.io.InputStream;
import java.util.Properties;

@WebListener
public class AppConfigListener implements ServletContextListener {

    private static Properties properties = new Properties();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        try (InputStream input = context.getResourceAsStream("/WEB-INF/config.properties")) {
            if (input == null) {
                throw new RuntimeException("Could not find config.properties in WEB-INF");
            }
            properties.load(input);

            // Store config in ServletContext attributes for global access
            context.setAttribute("db_url", properties.getProperty("db_url"));
            context.setAttribute("db_username", properties.getProperty("db_username"));
            context.setAttribute("db_password", properties.getProperty("db_password"));
            context.setAttribute("salt", properties.getProperty("salt"));
            
            
            
            System.out.println("✅ AppConfigListener: Config loaded successfully.");
            

        } catch (Exception e) {
            throw new RuntimeException("❌ Failed to load config: " + e.getMessage(), e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Clean up if needed
    }
}
