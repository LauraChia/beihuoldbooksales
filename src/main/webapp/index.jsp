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
        .book-images {
            position: relative;
            width: 100%;
            height: 260px;
            overflow: hidden;
        }
        .book-img {
            width: 100%;
            height: 260px;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            transition: opacity 0.3s ease;
        }
        .book-img.img-second {
            opacity: 0;
        }
        .book-card:hover .book-img.img-first {
            opacity: 0;
        }
        .book-card:hover .book-img.img-second {
            opacity: 1;
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
        .image-indicator {
            position: absolute;
            bottom: 8px;
            right: 8px;
            background-color: rgba(0,0,0,0.6);
            color: white;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            z-index: 10;
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
        String photoStr = rs.getString("photo");
        
        // 分割圖片路徑
        String[] photos = new String[2];
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String[] photoArray = photoStr.split(",");
            photos[0] = photoArray[0].trim();
            if (photoArray.length > 1) {
                photos[1] = photoArray[1].trim();
            } else {
                photos[1] = photos[0]; // 如果只有一張圖，第二張用同一張
            }
        } else {
            photos[0] = "assets/images/about.png";
            photos[1] = "assets/images/about.png";
        }
%>
    <a class="book-link" href="bookDetail.jsp?bookId=<%= bookId %>">
        <div class="book-card">
            <div class="book-images">
                <img src="<%= photos[0] %>" alt="書籍圖片1" class="book-img img-first">
                <img src="<%= photos[1] %>" alt="書籍圖片2" class="book-img img-second">
                <% if (!photos[0].equals(photos[1])) { %>
                    <span class="image-indicator">1/2</span>
                <% } %>
            </div>
            <div class="book-info">
                <div class="book-title"><%= title %></div>
                <div class="book-author">作者：<%= author %></div>
                <div class="book-price">NT$<%= (int) Float.parseFloat(price) %></div>
                <div class="book-date">出版日期：<%= date != null ? date.split(" ")[0] : "" %></div>
            </div>
        </div>
    </a>
<%
    }
    con.close();
%>
</div>

<!-- Footer Start -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：北護二手書拍賣系統</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書拍賣網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

</body>
</html>