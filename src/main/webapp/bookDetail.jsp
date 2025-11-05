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
        .image-gallery {
            position: relative;
            width: 300px;
        }
        .image-container {
            position: relative;
            width: 300px;
            height: 400px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
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
        .image-dots {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 15px;
        }
        .dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: #ddd;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .dot.active {
            background-color: #d9534f;
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
        /* 審核狀態樣式 */
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
        // 分割圖片路徑
        String photoStr = rs.getString("photo");
        String[] photos = new String[2];
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String[] photoArray = photoStr.split(",");
            photos[0] = photoArray[0].trim();
            if (photoArray.length > 1) {
                photos[1] = photoArray[1].trim();
            } else {
                photos[1] = photos[0];
            }
        } else {
            photos[0] = "assets/images/about.png";
            photos[1] = "assets/images/about.png";
        }
        boolean hasTwoImages = !photos[0].equals(photos[1]);
        
        // 🔹 處理審核狀態
        String approvalStatus = rs.getString("isApproved");
        String statusText = "待審核";  // 預設值
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
            <img src="<%= photos[0] %>" alt="書籍圖片1" class="book-image active" id="img1">
            <img src="<%= photos[1] %>" alt="書籍圖片2" class="book-image" id="img2">
            
            <% if (hasTwoImages) { %>
                <button class="image-nav prev" onclick="changeImage(-1)">‹</button>
                <button class="image-nav next" onclick="changeImage(1)">›</button>
                <div class="image-counter">
                    <span id="current-image">1</span> / 2
                </div>
            <% } %>
        </div>
        
        <% if (hasTwoImages) { %>
        <div class="image-dots">
            <span class="dot active" onclick="showImage(0)"></span>
            <span class="dot" onclick="showImage(1)"></span>
        </div>
        <% } %>
    </div>
    
    <div class="detail-info">
        <h2><%= rs.getString("titleBook") %></h2>

        <div class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></div>
        <div class="info-item">作者：<%= rs.getString("author") %></div>
        <div class="info-item">出版日期：<%= rs.getString("date").split(" ")[0] %></div>
        <div class="info-item">ISBN：<%= rs.getString("ISBN") %></div>
        <div class="info-item">系所：<%= rs.getString("department") %></div>
        <div class="info-item">狀態：<%= rs.getString("condition") %></div>
        <div class="info-item">有無筆記：<%= rs.getString("remarks") %></div>
        <div class="info-item">賣家：<%= rs.getString("sellerName") %></div>
        <div class="info-item">聯絡方式：<%= rs.getString("contact") %></div>
        <div class="info-item">上架日期：<%= rs.getString("createdAt").split(" ")[0] %></div>
        <div class="info-item">審核狀態：<span class="<%= statusClass %>"><%= statusText %></span></div>

        <a class="btn btn-link" href="index.jsp">回首頁</a>
    </div>
</div>

<script>
    let currentImageIndex = 0;
    const images = document.querySelectorAll('.book-image');
    const dots = document.querySelectorAll('.dot');
    const totalImages = images.length;

    function showImage(index) {
        // 移除所有 active class
        images.forEach(img => img.classList.remove('active'));
        if (dots.length > 0) {
            dots.forEach(dot => dot.classList.remove('active'));
        }
        
        // 添加 active class 到當前圖片
        currentImageIndex = index;
        images[currentImageIndex].classList.add('active');
        if (dots.length > 0) {
            dots[currentImageIndex].classList.add('active');
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
        if (e.key === 'ArrowLeft') {
            changeImage(-1);
        } else if (e.key === 'ArrowRight') {
            changeImage(1);
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
        <p class="mb-0">&copy; 2025年 二手書拍賣網. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->
</body>
</html>