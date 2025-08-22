package com.nwr;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebFilter("/*")
public class RestrictionFilter implements Filter {

    // ✅ Public paths: accessible by anyone
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
        "/login.jsp", "/login", "/auth", "/logout.jsp",
        "/forgot-password.jsp",
        "/send-reset-link",
        "/reset-password.jsp",
        "/ResetPasswordServlet",
        "/unauthorized.jsp",
        "/edit-profile.jsp",
        "/edit-profile",
        "/edit-entry.jsp",
        "/edit-entry",
        "/delete-entry",
        "/dev.jsp",
        "/css/", "/js/", "/assets/", "/favicon.ico"
    ));

    // ✅ SuperAdmin-only paths
    private static final Set<String> SUPERADMIN_PATHS = new HashSet<>(Arrays.asList(
        "/superadmin",
        "/edit-admin.jsp",
        "/edit-department.jsp",
        "/edit-member.jsp",
        "/panel.jsp",
        "/add-department",
        "/add-user",
        "/delete-admin",
        "/delete-department",
        "/delete-member",
        "/edit-admin",
        "/edit-department",
        "/edit-member",
        "/superadmin-delete-entry"
        // Add more superadmin-only paths here
    ));

    // ✅ Admin-only paths
    private static final Set<String> ADMIN_PATHS = new HashSet<>(Arrays.asList(
        "/admin",
        "/delete-register.jsp",
        "/edit-member.jsp",
        "/report.jsp",
        "/viewcolumns.jsp",
        "/add-register",
        "/add-user",
        "/delete-member",
        "/delete-register",
        "/delete-register-view",
        "/download-register",
        "/generate-report",
        "/register-entry",
        "/register-entry",
        "/view-register-columns"
        
        // Add more admin-only paths here
    ));

    // ✅ Member-only paths
    private static final Set<String> MEMBER_PATHS = new HashSet<>(Arrays.asList(
        "/member",
        "/dynamic-form.jsp",
        "/add-dynamic-form",
        "/report.jsp",
        "/dynamic-form",
        "/generate-report",
        "/register-entry"
        // Add more member-only paths here
    ));

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = req.getServletPath();

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!isRoleAllowed(role, path)) {
            res.sendRedirect(req.getContextPath() + "/unauthorized.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        for (String publicPath : PUBLIC_PATHS) {
            if (publicPath.endsWith("/")) {
                if (path.startsWith(publicPath)) return true;
            } else {
                if (path.equals(publicPath)) return true;
            }
        }
        return false;
    }

    private boolean isRoleAllowed(String role, String path) {
        switch (role.toLowerCase()) {
            case "superadmin":
                return SUPERADMIN_PATHS.contains(path);
            case "admin":
                return ADMIN_PATHS.contains(path);
            case "member":
                return MEMBER_PATHS.contains(path);
            default:
                return false;
        }
    }

    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void destroy() { }
}
