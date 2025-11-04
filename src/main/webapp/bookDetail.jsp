<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>書籍詳情 - 北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f9f9f9;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .book-detail {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            gap: 40px;
            padding: 80px;
        }
        .book-detail img {
            width: 300px;
            height: 400px;
            object-fit: cover;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
        }
        .detail-info {
            max-width: 500px;
        }
        h2 {
            font-weight: bold;
        }
        .price {
            font-size: 20px;
            color: #d9534f;
            font-weight: bold;
            margin-top: 10px;
        }
        .info-item {
            margin-top: 10px;
            color: #555;
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>
<br><br><br><br>

<%
    String bookId = request.getParameter("bookId");
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt = con.createStatement();
    String sql = "SELECT b.*, u.name AS sellerName " +
            "FROM book b JOIN users u ON b.userId = u.userId " +
            "WHERE b.bookId = " + bookId;
ResultSet rs = smt.executeQuery(sql);
    if (rs.next()) {
%>

<div class="book-detail">
    <img src="<%= rs.getString("photo") != null ? rs.getString("photo") : "assets/images/about.png" %>" alt="書籍圖片">
    <div class="detail-info">
        <h2><%= rs.getString("titleBook") %></h2>
        
        <div class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></div>
        <div class="info-item">作者：<%= rs.getString("author") %></div>
       <div class="info-item">出版日期：<%= rs.getString("date").split(" ")[0] %></div>
        <div class="info-item">聯絡方式：<%= rs.getString("contact") %></div>
        <div class="info-item">系所：<%= rs.getString("department") %></div>
       <div class="info-item">ISBN：<%= rs.getString("ISBN") %></div>
        <div class="info-item">狀態：<%= rs.getString("condition") %></div>
        <div class="info-item">有無筆記：<%= rs.getString("remarks") %></div>
        <div class="info-item">賣家：<%= rs.getString("sellerName") %></div>
        <div class="info-item">上架日期：<%= rs.getString("createdAt").split(" ")[0] %></div>
        

        
         <a class="btn btn-link" href="index.jsp">回首頁</a>
    </div>
</div>

<%
    }
    con.close();
%>
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
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025 二手書拍賣網. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->
</body>
</html>
