# Use official Tomcat 9 base image
FROM tomcat:9.0

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file into Tomcat
COPY ./NWR.war /usr/local/tomcat/webapps/ROOT.war

# Expose default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

