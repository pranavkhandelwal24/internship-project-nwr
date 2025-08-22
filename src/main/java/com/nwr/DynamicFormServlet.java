package com.nwr;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/dynamic-form")
public class DynamicFormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null || !"member".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // The JSP will handle fetching form metadata.
        // We primarily ensure 'registerId' is available for the JSP.
        String registerId = request.getParameter("registerId");
        if (registerId != null && !registerId.isEmpty()) {
            request.setAttribute("registerId", registerId);
        } else {
            // If registerId is missing, the JSP should display an appropriate message.
            request.setAttribute("errorMessage", "No register ID provided. Please select a register to load the form.");
        }

        // Forward to the JSP page
        request.getRequestDispatcher("/dynamic-form.jsp").forward(request, response);
    }

    // Keep doPost to handle potential direct POST requests, though AddDynamicFormServlet will forward
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}