<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String loggedInUserId = (String) session.getAttribute("userId");
    if (loggedInUserId == null || loggedInUserId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=" + request.getRequestURI());
        return;
    }

    String bookId = request.getParameter("bookId");
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String reason = request.getParameter("reason");
        if (reason != null && !reason.trim().isEmpty() && bookId != null && !bookId.trim().isEmpty()) {
            try {
                Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
                Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
                String sql = "INSERT INTO reports (userId, bookId, reason) VALUES (?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, loggedInUserId);
                ps.setString(2, bookId);
                ps.setString(3, reason);
                ps.executeUpdate();
                ps.close();
                con.close();

                response.sendRedirect("report.jsp?bookId=" + bookId + "&success=1");
                return;
            } catch(Exception e) {
                message = "舉報失敗: " + e.getMessage();
            }
        } else {
            message = "請填寫舉報原因。";
        }
    }

    if ("1".equals(request.getParameter("success"))) {
        message = "舉報成功，管理員將會處理此書籍。";
    }
%>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>舉報不佳的書籍</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #d4f5d4; /* 淺綠色背景 */
            color: #2c3e50;           /* 文字顏色略深 */
        }
        .container {
            background-color: #ffffff; /* 表單白色底 */
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.2);
        }
        h3 {
            color: #2c3e50;
        }
        .alert-info {
            background-color: #a8e6a1; /* 淺綠提示訊息 */
            border-color: #8ed18c;
            color: #2c3e50;
        }
        textarea.form-control {
            background-color: #f0fff0; /* 淺綠輸入框 */
        }
    </style>
</head>
<body class="p-4">
    <div class="container">
        <h3>舉報不佳的書籍</h3>
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-info mt-3"><%= message %></div>
        <% } %>

        <form method="post" action="report.jsp?bookId=<%= bookId %>">
            <div class="mb-3 mt-3">
                <label for="reason" class="form-label">舉報原因</label>
                <textarea id="reason" name="reason" class="form-control" rows="4" required></textarea>
            </div>
            <button type="submit" class="btn btn-danger">送出舉報</button>
            <a href="index.jsp" class="btn btn-secondary">返回首頁</a>
        </form>
    </div>
</body>
</html>
