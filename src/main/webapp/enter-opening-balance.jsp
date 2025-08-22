<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<String> users = (List<String>) request.getAttribute("users");
    String[] systems = (String[]) request.getAttribute("systems");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String days = (String) request.getAttribute("days");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Enter Opening Balance</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }
        table {
            border-collapse: collapse;
            width: 60%;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #333;
            padding: 8px 12px;
            text-align: left;
        }
        th {
            background: #eee;
        }
        input[type="number"] {
            width: 80px;
        }
        .submit-btn {
            margin-top: 20px;
            padding: 10px 20px;
            background: #4285f4;
            color: white;
            border: none;
            cursor: pointer;
        }
        .submit-btn:hover {
            background: #3367d6;
        }
    </style>
</head>
<body>

<h2>Manual Opening Balance Entry</h2>

<p>No opening balance was found for the given period.<br>
Please enter the opening balance for each user and system before <strong><%= startDate %></strong>.</p>

<form action="generate-report" method="get">
    <input type="hidden" name="refDate" value="<%= endDate %>">
    <input type="hidden" name="days" value="<%= days %>">
    <input type="hidden" name="manualOpeningsDone" value="true">

    <table>
        <thead>
        <tr>
            <th>User</th>
            <% for (String sys : systems) { %>
                <th><%= sys %></th>
            <% } %>
        </tr>
        </thead>
        <tbody>
        <% for (String user : users) { %>
            <tr>
                <td><%= user %></td>
                <% for (String sys : systems) { %>
                    <td>
                        <input type="number" name="<%= user %>_<%= sys %>" min="0" required>
                    </td>
                <% } %>
            </tr>
        <% } %>
        </tbody>
    </table>

    <button class="submit-btn" type="submit">Submit Opening Balances</button>
</form>

</body>
</html>
