<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
            padding: 40px;
            max-width: 1200px;
            margin: 60px auto;
        }
        .book-card {
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 10px;
            overflow: hidden;
            transition: 0.2s ease-in-out;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        .book-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .book-link {
            text-decoration: none;
            color: inherit;
        }
        .book-img {
            width: 100%;
            height: 260px;
            object-fit: cover;
        }
        .book-info {
            padding: 12px 14px;
        }
        .book-title {
            font-size: 16px;
            font-weight: bold;
            color: #333;
            margin-bottom: 6px;
            height: 40px;
            overflow: hidden;
            line-height: 20px;
        }
        .book-author {
            color: #666;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .book-price {
            color: #d9534f;
            font-weight: bold;
            font-size: 15px;
        }
        .book-date {
            font-size: 13px;
            color: #888;
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>
<br><br><br><br>

<%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt = con.createStatement();
    String sql = "SELECT * FROM book ORDER BY createdAt DESC";
    ResultSet rs = smt.executeQuery(sql);
%>

<div class="book-grid">
<%
    while(rs.next()) {
        String bookId = rs.getString("bookId");
        String title = rs.getString("titleBook");
        String author = rs.getString("author");
        String price = rs.getString("price");
        String date = rs.getString("date");
        String photo = rs.getString("photo");
        if (photo == null || photo.trim().isEmpty()) {
            photo = "assets/images/noimage.png"; // 預設圖片
        }
%>
    <a class="book-link" href="bookDetail.jsp?bookId=<%= bookId %>">
        <div class="book-card">
            <img src="<%= photo %>" alt="書籍圖片" class="book-img">
            <div class="book-info">
                <div class="book-title"><%= title %></div>
                <div class="book-author">作者：<%= author %></div>
                <div class="book-price">NT$ <%= price %></div>
                <div class="book-date">出版日期：<%= date != null ? date.split(" ")[0] : "" %></div>
            </div>
        </div>
    </a>
<%
    }
    con.close();
%>
</div>

<!-- Footer -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5 text-center">
        <p class="mb-0">&copy; 2025 北護二手書拍賣系統. All Rights Reserved.</p>
    </div>
</div>

</body>
</html>