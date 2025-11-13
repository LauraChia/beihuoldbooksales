<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>書籍詳情 - 北護二手書交易網</title>
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
        .image-gallery {
            position: relative;
            width: 350px;
        }
        .image-container {
            position: relative;
            width: 350px;
            height: 450px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
            background-color: #f0f0f0;
        }
        .book-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }
        .book-image.active {
            display: block;
        }
        .image-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background-color: rgba(0,0,0,0.5);
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.3s;
            z-index: 10;
        }
        .image-nav:hover {
            background-color: rgba(0,0,0,0.7);
        }
        .image-nav.prev {
            left: 10px;
        }
        .image-nav.next {
            right: 10px;
        }
        .thumbnail-container {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            overflow-x: auto;
            padding: 5px 0;
        }
        .thumbnail {
            width: 70px;
            height: 90px;
            border-radius: 5px;
            object-fit: cover;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.3s;
            flex-shrink: 0;
        }
        .thumbnail:hover {
            transform: scale(1.05);
        }
        .thumbnail.active {
            border-color: #d9534f;
            box-shadow: 0 2px 8px rgba(217, 83, 79, 0.4);
        }
        .image-counter {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background-color: rgba(0,0,0,0.6);
            color: white;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 14px;
            z-index: 10;
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
        .status-pending {
            color: #ff9800;
            font-weight: bold;
        }
        .status-approved {
            color: #4caf50;
            font-weight: bold;
        }
        .status-rejected {
            color: #f44336;
            font-weight: bold;
        }
        .no-image {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            font-size: 16px;
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
        // 分割圖片路徑 - 支援多張圖片
        String photoStr = rs.getString("photo");
        List<String> photoList = new ArrayList<>();
        
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String[] photoArray = photoStr.split(",");
            for (String photo : photoArray) {
                String trimmedPhoto = photo.trim();
                // 確保路徑正確
                if (!trimmedPhoto.startsWith("assets/")) {
                    trimmedPhoto = "assets/images/member/" + trimmedPhoto;
                }
                photoList.add(trimmedPhoto);
            }
        }
        
        // 如果沒有圖片,使用預設圖
        if (photoList.isEmpty()) {
            photoList.add("assets/images/about.png");
        }
        
        int totalImages = photoList.size();
        
        // 處理審核狀態
        String approvalStatus = rs.getString("isApproved");
        String statusText = "待審核";
        String statusClass = "status-pending";

        if (approvalStatus != null) {
            if (approvalStatus.equals("已審核") || approvalStatus.equals("approved")) {
                statusText = "已審核";
                statusClass = "status-approved";
            } else if (approvalStatus.equals("未通過") || approvalStatus.equals("rejected")) {
                statusText = "未通過";
                statusClass = "status-rejected";
            }
        }
%>

<div class="book-detail">
    <div class="image-gallery">
        <div class="image-container">
            <% if (photoList.isEmpty()) { %>
                <div class="no-image">無圖片</div>
            <% } else { %>
                <% for (int i = 0; i < photoList.size(); i++) { %>
                    <img src="<%= photoList.get(i) %>" 
                         alt="書籍圖片<%= (i+1) %>" 
                         class="book-image <%= (i == 0) ? "active" : "" %>"
                         onerror="this.src='assets/images/about.png'">
                <% } %>
                
                <% if (totalImages > 1) { %>
                    <button class="image-nav prev" onclick="changeImage(-1)">‹</button>
                    <button class="image-nav next" onclick="changeImage(1)">›</button>
                    <div class="image-counter">
                        <span id="current-image">1</span> / <%= totalImages %>
                    </div>
                <% } %>
            <% } %>
        </div>
        
        <% if (totalImages > 1) { %>
        <div class="thumbnail-container">
            <% for (int i = 0; i < photoList.size(); i++) { %>
                <img src="<%= photoList.get(i) %>" 
                     alt="縮圖<%= (i+1) %>" 
                     class="thumbnail <%= (i == 0) ? "active" : "" %>"
                     onclick="showImage(<%= i %>)"
                     onerror="this.src='assets/images/about.png'">
            <% } %>
        </div>
        <% } %>
    </div>
    
    <div class="detail-info">
        <h2><%= rs.getString("titleBook") %></h2>

<div class="price">NT$<%= (rs.getString("price") != null && !rs.getString("price").trim().isEmpty()) ? (int) Float.parseFloat(rs.getString("price")) : 0 %></div>
<div class="info-item">書名：<%= (rs.getString("titleBook") != null && !rs.getString("titleBook").trim().isEmpty()) ? rs.getString("titleBook") : "無" %></div>
<div class="info-item">作者：<%= (rs.getString("author") != null && !rs.getString("author").trim().isEmpty()) ? rs.getString("author") : "無" %></div>
<div class="info-item">出版日期：<%= (rs.getString("date") != null && !rs.getString("date").trim().isEmpty()) ? rs.getString("date").split(" ")[0] : "無" %></div>
<div class="info-item">書籍版本：<%= (rs.getString("edition") != null && !rs.getString("edition").trim().isEmpty()) ? rs.getString("edition") : "無" %></div>
<div class="info-item">使用書籍系所：<%= (rs.getString("department") != null && !rs.getString("department").trim().isEmpty()) ? rs.getString("department") : "" %></div>
<div class="info-item">使用課程：<%= (rs.getString("course") != null && !rs.getString("course").trim().isEmpty()) ? rs.getString("course") : "無" %></div>
<div class="info-item">書籍狀況：<%= (rs.getString("condition") != null && !rs.getString("condition").trim().isEmpty()) ? rs.getString("condition") : "無" %></div>
<div class="info-item">有無筆記：<%= (rs.getString("remarks") != null && !rs.getString("remarks").trim().isEmpty()) ? rs.getString("remarks") : "無" %></div>
<div class="info-item">授課老師：<%= (rs.getString("teacher") != null && !rs.getString("teacher").trim().isEmpty()) ? rs.getString("teacher") : "無" %></div>
<div class="info-item">ISBN：<%= (rs.getString("ISBN") != null && !rs.getString("ISBN").trim().isEmpty()) ? rs.getString("ISBN") : "無" %></div>
<div class="info-item">賣家：<%= (rs.getString("sellerName") != null && !rs.getString("sellerName").trim().isEmpty()) ? rs.getString("sellerName") : "無" %></div>
<div class="info-item">偏好聯絡方式(請私訊)：<%= (rs.getString("contact") != null && !rs.getString("contact").trim().isEmpty()) ? rs.getString("contact") : "無" %></div>
<div class="info-item">上架日期：<%= (rs.getString("createdAt") != null && !rs.getString("createdAt").trim().isEmpty()) ? rs.getString("createdAt").split(" ")[0] : "無" %></div>
<div class="info-item">上架本數：<%= (rs.getString("quantity") != null && !rs.getString("quantity").trim().isEmpty()) ? rs.getString("quantity") : 1 %></div>
<div class="info-item">審核狀態：<span class="<%= statusClass %>"><%= (statusText != null && !statusText.trim().isEmpty()) ? statusText : "無" %></span></div>

        <a class="btn btn-link" href="index.jsp">回首頁</a>
    </div>
</div>

<script>
    let currentImageIndex = 0;
    const images = document.querySelectorAll('.book-image');
    const thumbnails = document.querySelectorAll('.thumbnail');
    const totalImages = images.length;

    function showImage(index) {
        // 移除所有 active class
        images.forEach(img => img.classList.remove('active'));
        thumbnails.forEach(thumb => thumb.classList.remove('active'));
        
        // 添加 active class 到當前圖片
        currentImageIndex = index;
        images[currentImageIndex].classList.add('active');
        if (thumbnails.length > 0) {
            thumbnails[currentImageIndex].classList.add('active');
        }
        
        // 更新計數器
        const counter = document.getElementById('current-image');
        if (counter) {
            counter.textContent = currentImageIndex + 1;
        }
    }

    function changeImage(direction) {
        let newIndex = currentImageIndex + direction;
        
        // 循環切換
        if (newIndex >= totalImages) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = totalImages - 1;
        }
        
        showImage(newIndex);
    }

    // 鍵盤導航
    document.addEventListener('keydown', function(e) {
        if (totalImages > 1) {
            if (e.key === 'ArrowLeft') {
                changeImage(-1);
            } else if (e.key === 'ArrowRight') {
                changeImage(1);
            }
        }
    });
</script>

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
                <p class="mb-2">題目:北護二手書拍賣系統</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 二手書交易網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->
</body>
</html>