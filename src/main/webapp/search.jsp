<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">

<head>
    <meta charset="utf-8">
    <title>二手書拍賣網 - 搜尋結果</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet">

    <!-- Stylesheets -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">

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
            margin: 100px auto 60px;
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
        .no-results {
            text-align: center;
            padding: 80px 20px;
            margin: 150px auto 100px;
            max-width: 600px;
        }
        .no-results i {
            font-size: 80px;
            color: #ccc;
            margin-bottom: 20px;
        }
        .no-results h4 {
            color: #666;
            margin-bottom: 15px;
        }
        .no-results p {
            color: #999;
            font-size: 14px;
        }
        .search-info {
            background-color: white;
            padding: 15px 25px;
            border-radius: 8px;
            margin: 120px auto 20px;
            max-width: 1200px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .search-info strong {
            color: #d9534f;
        }
    </style>
</head>

<body>
    <%@ include file="menu.jsp" %>

<%
    // 取得搜尋參數
    String type = request.getParameter("type");
    String query = request.getParameter("query");

    // 搜尋類型的中文顯示
    String typeDisplay = "";
    if("titleBook".equals(type)) typeDisplay = "書名";
    else if("author".equals(type)) typeDisplay = "作者";
    else if("ISBN".equals(type)) typeDisplay = "ISBN";
    else if("department".equals(type)) typeDisplay = "系所";

    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt = con.createStatement();

    String sql = "SELECT * FROM book";
    if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) {
        sql += " WHERE " + type + " LIKE '%" + query + "%'";
    }
    sql += " ORDER BY createdAt DESC";

    ResultSet rs = smt.executeQuery(sql);

    // 計算結果數量
    int resultCount = 0;
    if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) {
        String sqlCount = "SELECT COUNT(*) AS cnt FROM book WHERE " + type + " LIKE ?";
        PreparedStatement psCount = con.prepareStatement(sqlCount);
        psCount.setString(1, "%" + query + "%");
        ResultSet rsCount = psCount.executeQuery();
        if(rsCount.next()) {
            resultCount = rsCount.getInt("cnt");
        }
        rsCount.close();
        psCount.close();
    } else {
        String sqlCount = "SELECT COUNT(*) AS cnt FROM book";
        PreparedStatement psCount = con.prepareStatement(sqlCount);
        ResultSet rsCount = psCount.executeQuery();
        if(rsCount.next()) {
            resultCount = rsCount.getInt("cnt");
        }
        rsCount.close();
        psCount.close();
    }
%>

<!-- 搜尋資訊顯示 -->
<% if(query != null && !query.trim().isEmpty()) { %>
<div class="search-info">
    搜尋「<strong><%= typeDisplay %></strong>」包含「<strong><%= query %></strong>」
    - 找到 <strong><%= resultCount %></strong> 筆結果
</div>
<% } %>

<% if(resultCount == 0) { %>
    <!-- 無結果顯示 -->
    <div class="no-results">
        <i class="fas fa-search"></i>
        <h4>找不到相符的書籍</h4>
        <p>請嘗試使用其他關鍵字或搜尋條件</p>
        <a href="index.jsp" class="btn btn-primary mt-3">
            <i class="fas fa-home me-2"></i>返回首頁
        </a>
    </div>
<% } else { %>
    <!-- 有結果時顯示書籍列表 -->
    <div class="book-grid">
    <%
        while(rs.next()) {
            String bookId = rs.getString("bookId");
            String title = rs.getString("titleBook");
            String author = rs.getString("author");
            String price = rs.getString("price");
            String date = rs.getString("date");
            String photo = rs.getString("photo");

            // 多張圖片的情況：用逗號分隔
            String displayPhoto = "assets/images/about.png"; // 預設圖片
            if(photo != null && !photo.trim().isEmpty()) {
                String[] photos = photo.split(",");
                displayPhoto = photos[0].trim(); // 取第一張
            }

            // 修正相對路徑
            if(!displayPhoto.startsWith("http") && !displayPhoto.startsWith("assets/") && !displayPhoto.startsWith("upload/")) {
                displayPhoto = "upload/" + displayPhoto;
            }
    %>
        <a class="book-link" href="bookDetail.jsp?bookId=<%= bookId %>">
            <div class="book-card">
                <img src="<%= displayPhoto %>" alt="書籍圖片" class="book-img" onerror="this.src='assets/images/about.png'">
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
    %>
    </div>
<% } %>

<%
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

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
