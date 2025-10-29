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
    String sql = "SELECT * FROM book WHERE bookId = " + bookId;
    ResultSet rs = smt.executeQuery(sql);
    if (rs.next()) {
%>

<div class="book-detail">
    <img src="<%= rs.getString("photo") != null ? rs.getString("photo") : "assets/images/noimage.png" %>" alt="書籍圖片">
    <div class="detail-info">
        <h2><%= rs.getString("titleBook") %></h2>
        <div class="price">NT$ <%= rs.getString("price") %></div>
        <div class="info-item">作者：<%= rs.getString("author") %></div>
        <div class="info-item">出版日期：<%= rs.getString("date") %></div>
        <div class="info-item">聯絡方式：<%= rs.getString("contact") %></div>
        <div class="info-item">備註：<%= rs.getString("remarks") %></div>
    </div>
</div>

<%
    }
    con.close();
%>

</body>
</html>
