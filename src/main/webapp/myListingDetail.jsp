<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // 檢查是否登入
    String currentUserId = (String) session.getAttribute("userId");
    if (currentUserId == null || currentUserId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=myListings.jsp");
        return;
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>書籍詳情 - 我的上架</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f9f9f9;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        .back-button {
            position: fixed;
            top: 80px;
            left: 20px;
            background-color: white;
            border: 2px solid #667eea;
            color: #667eea;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s;
            z-index: 1000;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        
        .back-button:hover {
            background-color: #667eea;
            color: white;
            transform: translateX(-5px);
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
            border-color: #667eea;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
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
        
        .status-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 8px 15px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            z-index: 10;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }
        
        .status-approved {
            background-color: #4caf50;
            color: white;
        }
        
        .status-pending {
            background-color: #ff9800;
            color: white;
        }
        
        .status-rejected {
            background-color: #f44336;
            color: white;
        }
        
        .status-delisted {
            background-color: #9e9e9e;
            color: white;
        }
        
        .detail-info {
            max-width: 550px;
        }
        
        .detail-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }
        
        h2 {
            font-weight: bold;
            margin: 0;
            flex: 1;
        }
        
        .status-indicator {
            padding: 8px 15px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            margin-left: 15px;
        }
        
        .price {
            font-size: 24px;
            color: #d9534f;
            font-weight: bold;
            margin: 15px 0;
        }
        
        .info-section {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        
        .info-section h3 {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .info-item {
            margin: 12px 0;
            color: #555;
            line-height: 1.6;
        }
        
        .info-item strong {
            color: #333;
            min-width: 120px;
            display: inline-block;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-edit {
            background-color: #2196f3;
            color: white;
        }
        
        .btn-edit:hover {
            background-color: #1976d2;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(33, 150, 243, 0.4);
        }
        
        .btn-delete {
            background-color: #f44336;
            color: white;
        }
        
        .btn-delete:hover {
            background-color: #d32f2f;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.4);
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            animation: slideIn 0.3s;
        }
        
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            border-color: #bee5eb;
            color: #0c5460;
        }
        
        .alert-success {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 20px;
        }
        
        .stat-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-box .label {
            font-size: 12px;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        
        .stat-box .value {
            font-size: 24px;
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
        
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        @media (max-width: 768px) {
            .book-detail {
                flex-direction: column;
                padding: 40px 20px;
            }
            
            .image-gallery {
                width: 100%;
            }
            
            .image-container {
                width: 100%;
            }
            
            .detail-info {
                width: 100%;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<button class="back-button" onclick="window.location.href='myListings.jsp'">
    ← 返回我的上架
</button>

<br><br><br><br>

<%
    String listingId = request.getParameter("listingId");
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    String sql = "SELECT " +
                 "bl.listingId, bl.bookId, bl.sellerId, bl.price, bl.quantity, " +
                 "bl.condition, bl.photo, bl.remarks, bl.Approved, bl.listedAt, bl.expiryDate, bl.isDelisted, " +
                 "b.title, b.author, b.ISBN, b.edition, b.createdAt AS publishDate, " +
                 "c.courseName, c.teacher, c.department " +
                 "FROM bookListings bl " +
                 "INNER JOIN books b ON bl.bookId = b.bookId " +
                 "LEFT JOIN book_course_relations bcr ON b.bookId = bcr.bookId " +
                 "LEFT JOIN courses c ON bcr.courseId = c.courseId " +
                 "WHERE bl.listingId = " + listingId + " AND bl.sellerId = '" + currentUserId + "'";
    
    Statement smt = con.createStatement();
    ResultSet rs = smt.executeQuery(sql);
    
    if (rs.next()) {
        String bookId = rs.getString("bookId");
        String sellerId = rs.getString("sellerId");
        
        // 驗證是否為本人的書籍
        if (!currentUserId.equals(sellerId)) {
            response.sendRedirect("myListings.jsp");
            return;
        }
        
        // 分割圖片路徑
        String photoStr = rs.getString("photo");
        List<String> photoList = new ArrayList<>();
        
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String[] photoArray = photoStr.split(",");
            for (String photo : photoArray) {
                String trimmedPhoto = photo.trim();
                if (!trimmedPhoto.startsWith("assets/")) {
                    trimmedPhoto = "assets/images/member/" + trimmedPhoto;
                }
                photoList.add(trimmedPhoto);
            }
        }
        
        if (photoList.isEmpty()) {
            photoList.add("assets/images/about.png");
        }
        
        int totalImages = photoList.size();
        
        // 處理審核狀態
        String approvalStatus = rs.getString("Approved");
        Boolean isDelisted = rs.getBoolean("isDelisted");
        String statusText = "待審核";
        String statusClass = "status-pending";
        
        if (isDelisted != null && isDelisted) {
            statusText = "已下架";
            statusClass = "status-delisted";
        } else if ("TRUE".equalsIgnoreCase(approvalStatus)) {
            statusText = "已審核";
            statusClass = "status-approved";
        } else if ("FALSE".equalsIgnoreCase(approvalStatus)) {
            statusText = "未通過";
            statusClass = "status-rejected";
        }
        
        // 解析備註資訊
        String remarks = rs.getString("remarks");
        String contactInfo = "";
        String hasNotes = "";
        String additionalRemarks = "";
        
        if (remarks != null && !remarks.trim().isEmpty()) {
            String[] remarksParts = remarks.split("\\|");
            for (String part : remarksParts) {
                part = part.trim();
                if (part.startsWith("聯絡方式:")) {
                    contactInfo = part.substring("聯絡方式:".length()).trim();
                } else if (part.startsWith("筆記:")) {
                    hasNotes = part.substring("筆記:".length()).trim();
                } else {
                    additionalRemarks = part;
                }
            }
        }
        
        // ===== 註解掉統計資訊查詢 =====
        /*
        // 獲取統計資訊（瀏覽數、收藏數、訊息數）
        String statsSql = "SELECT " +
                         "(SELECT COUNT(*) FROM favorites WHERE bookId = " + bookId + ") as favoriteCount, " +
                         "(SELECT COUNT(*) FROM messages WHERE listingId = " + listingId + ") as messageCount";
        
        ResultSet statsRs = smt.executeQuery(statsSql);
        int favoriteCount = 0;
        int messageCount = 0;
        
        if (statsRs.next()) {
            favoriteCount = statsRs.getInt("favoriteCount");
            messageCount = statsRs.getInt("messageCount");
        }
        statsRs.close();
        */
        
        // 設定預設值（不執行查詢）
        int favoriteCount = 0;
        int messageCount = 0;
%>

<% if (isDelisted != null && isDelisted) { %>
<div class="container">
    <div class="alert alert-warning">
        <strong>⚠️ 此書籍已下架</strong><br>
        此書籍已從平台下架，買家無法看到此商品。如需重新上架，請聯繫管理員。
    </div>
</div>
<% } else if ("FALSE".equalsIgnoreCase(approvalStatus)) { %>
<div class="container">
    <div class="alert alert-warning">
        <strong>⚠️ 審核未通過</strong><br>
        此書籍未通過審核，買家無法看到此商品。請檢查上架內容是否符合規範，或聯繫管理員了解詳情。
    </div>
</div>
<% } else if (!"TRUE".equalsIgnoreCase(approvalStatus)) { %>
<div class="container">
    <div class="alert alert-info">
        <strong>ℹ️ 等待審核中</strong><br>
        您的書籍正在等待管理員審核，審核通過後買家才能看到此商品。
    </div>
</div>
<% } %>

<div class="book-detail">
    <div class="image-gallery">
        <div class="image-container">
            <div class="status-badge <%= statusClass %>"><%= statusText %></div>
            
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
        <div class="detail-header">
            <h2><%= rs.getString("title") %></h2>
        </div>

        <div class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></div>
        
        <!-- ===== 註解掉統計資訊顯示 ===== -->
        <!--
        <div class="stats-grid">
            <div class="stat-box">
                <div class="label">收藏數</div>
                <div class="value">❤️ <%= favoriteCount %></div>
            </div>
            <div class="stat-box">
                <div class="label">訊息數</div>
                <div class="value">💬 <%= messageCount %></div>
            </div>
            <div class="stat-box">
                <div class="label">剩餘數量</div>
                <div class="value">📦 <%= rs.getString("quantity") %></div>
            </div>
        </div>
        -->
        
        <!-- 基本資訊 -->
        <div class="info-section">
            <h3>📚 基本資訊</h3>
            <div class="info-item"><strong>作者：</strong><%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></div>
            <div class="info-item"><strong>出版日期：</strong><%= rs.getString("publishDate") != null ? rs.getString("publishDate").split(" ")[0] : "未提供" %></div>
            <div class="info-item"><strong>書籍版本：</strong><%= rs.getString("edition") != null && !rs.getString("edition").trim().isEmpty() ? rs.getString("edition") : "未提供" %></div>
            <div class="info-item"><strong>ISBN：</strong><%= rs.getString("ISBN") != null && !rs.getString("ISBN").trim().isEmpty() ? rs.getString("ISBN") : "未提供" %></div>
            <div class="info-item"><strong>書籍狀況：</strong><%= rs.getString("condition") %></div>
            <div class="info-item"><strong>有無筆記：</strong><%= hasNotes.isEmpty() ? "未提供" : hasNotes %></div>
        </div>
        
        <!-- 課程資訊 -->
        <div class="info-section">
            <h3>🎓 課程資訊</h3>
            <div class="info-item"><strong>使用系所：</strong><%= rs.getString("department") != null ? rs.getString("department") : "未提供" %></div>
            <div class="info-item"><strong>使用課程：</strong><%= rs.getString("courseName") != null ? rs.getString("courseName") : "未提供" %></div>
            <div class="info-item"><strong>授課老師：</strong><%= rs.getString("teacher") != null ? rs.getString("teacher") : "未提供" %></div>
        </div>
        
        <!-- 上架資訊 -->
        <div class="info-section">
            <h3>📅 上架資訊</h3>
            <% if (!contactInfo.isEmpty()) { %>
            <div class="info-item"><strong>偏好聯絡方式：</strong><%= contactInfo %></div>
            <% } %>
            <% if (!additionalRemarks.isEmpty()) { %>
            <div class="info-item"><strong>備註說明：</strong><%= additionalRemarks %></div>
            <% } %>
            <div class="info-item"><strong>上架日期：</strong><%= rs.getString("listedAt").split(" ")[0] %></div>
            <%
                String expiryDateStr = rs.getString("expiryDate");
                String displayExpiryDate = expiryDateStr;
                
                if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
                    try {
                        SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                        java.util.Date date = dbFormat.parse(expiryDateStr);
                        displayExpiryDate = displayFormat.format(date);
                    } catch (Exception e) {
                        displayExpiryDate = expiryDateStr;
                    }
                }
            %>
            <div class="info-item"><strong>下架日期時間：</strong><%= displayExpiryDate %></div>
            <div class="info-item"><strong>審核狀態：</strong><span class="<%= statusClass.replace("status-", "") %>"><%= statusText %></span></div>
        </div>

        <!-- 操作按鈕 -->
        <div class="action-buttons">
            <button class="btn-action btn-edit" onclick="editListing()">
                ✏️ 編輯書籍
            </button>
            <% if (isDelisted == null || !isDelisted) { %>
            <button class="btn-action btn-delete" onclick="deleteListing()">
                🗑️ 下架書籍
            </button>
            <% } %>
            <button class="btn-action btn-secondary" onclick="viewMessages()">
                💬 查看訊息 <% if (messageCount > 0) { %>(<%= messageCount %>)<% } %>
            </button>
        </div>
    </div>
</div>

<script>
    const listingId = '<%= listingId %>';
    const bookTitle = '<%= rs.getString("title") %>';
    
    let currentImageIndex = 0;
    const images = document.querySelectorAll('.book-image');
    const thumbnails = document.querySelectorAll('.thumbnail');
    const totalImages = images.length;
    
    function showImage(index) {
        images.forEach(img => img.classList.remove('active'));
        thumbnails.forEach(thumb => thumb.classList.remove('active'));
        
        currentImageIndex = index;
        images[currentImageIndex].classList.add('active');
        if (thumbnails.length > 0) {
            thumbnails[currentImageIndex].classList.add('active');
        }
        
        const counter = document.getElementById('current-image');
        if (counter) {
            counter.textContent = currentImageIndex + 1;
        }
    }
    
    function changeImage(direction) {
        let newIndex = currentImageIndex + direction;
        
        if (newIndex >= totalImages) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = totalImages - 1;
        }
        
        showImage(newIndex);
    }
    
    document.addEventListener('keydown', function(e) {
        if (totalImages > 1) {
            if (e.key === 'ArrowLeft') {
                changeImage(-1);
            } else if (e.key === 'ArrowRight') {
                changeImage(1);
            }
        }
    });
    
    function editListing() {
        window.location.href = 'editListing.jsp?listingId=' + listingId;
    }
    
    function deleteListing() {
        if (confirm('確定要下架「' + bookTitle + '」嗎？\n\n下架後買家將無法看到此書籍。')) {
            fetch('delistBook.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'listingId=' + listingId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('✅ 書籍已成功下架');
                    window.location.reload();
                } else {
                    alert('❌ 下架失敗: ' + (data.message || '未知錯誤'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('❌ 系統錯誤');
            });
        }
    }
    
    function viewMessages() {
        window.location.href = 'myMessages.jsp?listingId=' + listingId;
    }
</script>

<%
    }
    con.close();
%>

<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：國北護二手書交易網</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="myListings.jsp">我的上架</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書交易網. @All Rights Reserved.</p>
    </div>
</div>

</body>
</html>