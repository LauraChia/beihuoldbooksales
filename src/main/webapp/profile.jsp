<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<%
    if (session.getAttribute("accessId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>個人資料-北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <%@ include file="menu.jsp" %>

    <div class="container mt-5 pt-5">
        <div class="card p-4 shadow-sm">
            <p><strong>帳號：</strong><%= session.getAttribute("accessId") %></p>
            <p><strong>電子郵件：</strong> example@email.com</p>
            <p><strong>註冊日期：</strong> 2024-09-01</p>
            <a href="editProfile.jsp" class="btn btn-primary mt-3">編輯資料</a>
        </div>
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