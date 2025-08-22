<%@ page import="javax.servlet.http.HttpSession" %>
<%
    if (session != null) {
        session.invalidate();
    }

    // Clear remember me cookie if exists
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("remembered_username")) {
                cookie.setMaxAge(0);
                response.addCookie(cookie);
                break;
            }
        }
    }

    response.sendRedirect("login.jsp");
%>
