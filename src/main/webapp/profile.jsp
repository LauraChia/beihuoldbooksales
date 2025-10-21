<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<%
    // 檢查登入狀態
    if (session.getAttribute("accessId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userAccessId = (String) session.getAttribute("accessId");
    String email = "";  // ✅ 確保先宣告變數

    // 資料庫連線設定（依你的資料庫修改）
    String url = "jdbc:mysql://localhost:3306/bookdb?useUnicode=true&characterEncoding=utf-8";
    String user = "root";
    String password = "你的資料庫密碼";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, password);

        // ⚠️ 請確認資料表名稱和欄位名是否正確
        String sql = "SELECT email FROM users WHERE account = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, userAccessId);
        rs = ps.executeQuery();

        if (rs.next()) {
            email = rs.getString("email");
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>個人資料 - 北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <%@ include file="menu.jsp" %>

    <div class="container mt-5 pt-5">
        <div class="card p-4 shadow-sm">
            <p><strong>帳號：</strong><%= userAccessId %></p>
            <p><strong>電子郵件：</strong><%= email %></p>
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
</html>