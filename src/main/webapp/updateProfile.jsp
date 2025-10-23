<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    if (session.getAttribute("accessId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    request.setCharacterEncoding("utf-8");

    String userAccessId = (String) session.getAttribute("accessId");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    String message = "";
    boolean success = false;

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "UPDATE users SET name=?, email=?, password=? WHERE userId=?";
        ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, userAccessId);

        int result = ps.executeUpdate();

        if (result > 0) {
            message = "✅ 資料已成功更新！3 秒後將自動返回個人資料頁面。";
            success = true;
        } else {
            message = "⚠️ 更新失敗，請稍後再試。";
        }

    } catch (Exception e) {
        e.printStackTrace();
        message = "❌ 發生錯誤：" + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>更新個人資料 - 北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <%-- ✅ 成功後自動跳轉 --%>
    <% if (success) { %>
        <meta http-equiv="refresh" content="3;URL=profile.jsp">
    <% } %>
</head>

<body>
    <%@ include file="menu.jsp" %>

    <div class="container mt-5 pt-5">
        <div class="alert alert-info"><%= message %></div>
        <a href="profile.jsp" class="btn btn-primary">立即返回個人資料</a>
    </div>

    <!-- Footer Start -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：北護二手書拍賣系統</p>
                <p class="mb-2">系所：健康事業管理系</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="#">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025 二手書拍賣網. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>