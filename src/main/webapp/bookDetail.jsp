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
        
        /* 購買按鈕相關樣式 */
        .action-buttons {
            margin-top: 30px;
            display: flex;
            gap: 15px;
        }
        .btn-contact {
            background-color: #d9534f;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
        }
        .btn-contact:hover {
            background-color: #c9302c;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .btn-contact:disabled {
            background-color: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        .btn-favorite {
            background-color: #fff;
            color: #ff6b6b;
            padding: 12px 30px;
            border: 2px solid #ff6b6b;
            border-radius: 25px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }
        .btn-favorite:hover {
            background-color: #ff6b6b;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
        }
        .btn-favorite.favorited {
            background-color: #ff6b6b;
            color: white;
            border-color: #ff6b6b;
        }
        .btn-favorite:disabled {
            background-color: #e0e0e0;
            border-color: #e0e0e0;
            color: #999;
            cursor: not-allowed;
            transform: none;
        }
        .favorite-icon {
            font-size: 18px;
            transition: transform 0.3s;
        }
        .btn-favorite:hover .favorite-icon {
            transform: scale(1.2);
        }
        .favorite-count {
            font-size: 13px;
            color: #666;
            margin-top: 5px;
        }
        
        /* Tooltip 樣式 */
        .tooltip-wrapper {
            position: relative;
            display: inline-block;
        }
        .custom-tooltip {
            visibility: hidden;
            width: 280px;
            background-color: #333;
            color: #fff;
            text-align: center;
            border-radius: 6px;
            padding: 10px;
            position: absolute;
            z-index: 1000;
            bottom: 125%;
            left: 50%;
            margin-left: -140px;
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 14px;
            line-height: 1.5;
        }
        .custom-tooltip::after {
            content: "";
            position: absolute;
            top: 100%;
            left: 50%;
            margin-left: -5px;
            border-width: 5px;
            border-style: solid;
            border-color: #333 transparent transparent transparent;
        }
        .tooltip-wrapper:hover .custom-tooltip {
            visibility: visible;
            opacity: 1;
        }
        
        /* Modal 樣式 */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s;
        }
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
            animation: slideIn 0.3s;
        }
        @keyframes fadeIn {
            from {opacity: 0;}
            to {opacity: 1;}
        }
        @keyframes slideIn {
            from {transform: translateY(-50px); opacity: 0;}
            to {transform: translateY(0); opacity: 1;}
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .modal-header h3 {
            margin: 0;
            color: #333;
        }
        .close {
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            border: none;
            background: none;
        }
        .close:hover {
            color: #000;
        }
        .modal-body {
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-group input.form-control, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: "Microsoft JhengHei", sans-serif;
            resize: vertical;
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        .btn-modal {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
        }
        .btn-send {
            background-color: #d9534f;
            color: white;
        }
        .btn-send:hover {
            background-color: #c9302c;
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #5a6268;
        }
        
        /* 警告訊息 */
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
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
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>
<br><br><br><br>

<%
    String listingId = request.getParameter("listingId");
    
    // 檢查使用者是否登入
    String currentUserId = (String) session.getAttribute("userId");
    boolean isLoggedIn = (loggedInUserId != null && !loggedInUserId.trim().isEmpty());
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 修改後的 SQL - 使用 JOIN 連接正規化的資料表
    String sql = "SELECT " +
                 "bl.listingId, bl.bookId, bl.sellerId, bl.price, bl.quantity, " +
                 "bl.condition, bl.photo, bl.remarks, bl.Approved, bl.listedAt, bl.expiryDate, " +
                 "b.title, b.author, b.ISBN, b.edition, b.createdAt AS publishDate, " +
                 "u.name AS sellerName, u.username AS sellerEmail, " +
                 "c.courseName, c.teacher, c.department " +
                 "FROM bookListings bl " +
                 "INNER JOIN books b ON bl.bookId = b.bookId " +
                 "INNER JOIN users u ON bl.sellerId = u.userId " +
                 "LEFT JOIN book_course_relations bcr ON b.bookId = bcr.bookId " +
                 "LEFT JOIN courses c ON bcr.courseId = c.courseId " +
                 "WHERE bl.listingId = " + listingId;
    
    Statement smt = con.createStatement();
    ResultSet rs = smt.executeQuery(sql);
    
    if (rs.next()) {
        String bookId = rs.getString("bookId");
        String sellerId = rs.getString("sellerId");
        String sellerEmail = rs.getString("sellerEmail");
        boolean isOwnBook = isLoggedIn && loggedInUserId.equals(sellerId);
        
        // 分割圖片路徑 - 支援多張圖片
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
        String statusText = "待審核";
        String statusClass = "status-pending";

        if ("TRUE".equalsIgnoreCase(approvalStatus) || "已審核".equals(approvalStatus)) {
            statusText = "已審核";
            statusClass = "status-approved";
        } else if ("FALSE".equalsIgnoreCase(approvalStatus) || "未通過".equals(approvalStatus)) {
            statusText = "未通過";
            statusClass = "status-rejected";
        }
        
        // 檢查是否已收藏
        boolean isFavorited = false;
        int favoriteCount = 0;
        
        if (isLoggedIn) {
            String checkFavSql = "SELECT COUNT(*) as cnt FROM favorites " +
                                "WHERE userId = '" + loggedInUserId + "' AND bookId = " + bookId;
            ResultSet favRs = smt.executeQuery(checkFavSql);
            if (favRs.next()) {
                isFavorited = (favRs.getInt("cnt") > 0);
            }
            favRs.close();
        }
        
        // 取得總收藏數
        String countFavSql = "SELECT COUNT(*) as total FROM favorites WHERE bookId = " + bookId;
        ResultSet countRs = smt.executeQuery(countFavSql);
        if (countRs.next()) {
            favoriteCount = countRs.getInt("total");
        }
        countRs.close();
        
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
        <h2><%= rs.getString("title") %></h2>

        <div class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></div>
        
        <div class="info-item"><strong>作者：</strong><%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></div>
        <div class="info-item"><strong>出版日期：</strong><%= rs.getString("publishDate") != null ? rs.getString("publishDate").split(" ")[0] : "未提供" %></div>
        <div class="info-item"><strong>書籍版本：</strong><%= rs.getString("edition") != null && !rs.getString("edition").trim().isEmpty() ? rs.getString("edition") : "未提供" %></div>
        <div class="info-item"><strong>ISBN：</strong><%= rs.getString("ISBN") != null && !rs.getString("ISBN").trim().isEmpty() ? rs.getString("ISBN") : "未提供" %></div>
        <div class="info-item"><strong>書籍狀況：</strong><%= rs.getString("condition") %></div>
        <div class="info-item"><strong>有無筆記：</strong><%= hasNotes.isEmpty() ? "未提供" : hasNotes %></div>
        <div class="info-item"><strong>使用系所：</strong><%= rs.getString("department") != null ? rs.getString("department") : "未提供" %></div>
        <div class="info-item"><strong>使用課程：</strong><%= rs.getString("courseName") != null ? rs.getString("courseName") : "未提供" %></div>
        <div class="info-item"><strong>授課老師：</strong><%= rs.getString("teacher") != null ? rs.getString("teacher") : "未提供" %></div>
        <% if (!contactInfo.isEmpty()) { %>
        <div class="info-item"><strong>偏好聯絡方式：</strong><%= contactInfo %></div>
        <% } %>
        <% if (!additionalRemarks.isEmpty()) { %>
        <div class="info-item"><strong>備註說明：</strong><%= additionalRemarks %></div>
        <% } %>
        <div class="info-item"><strong>賣家：</strong><%= rs.getString("sellerName") %></div>
        <div class="info-item"><strong>上架日期：</strong><%= rs.getString("listedAt").split(" ")[0] %></div>
        <div class="info-item"><strong>下架日期：</strong><%= rs.getString("expiryDate").split(" ")[0] %></div>
        <div class="info-item"><strong>上架本數：</strong><%= rs.getString("quantity") %></div>
        <div class="info-item"><strong>審核狀態：</strong><span class="<%= statusClass %>"><%= statusText %></span></div>

        <!-- 購買按鈕區域 -->
        <div class="action-buttons">
            <% if (!isOwnBook) { %>
                <div class="tooltip-wrapper">
                    <button class="btn-contact" onclick="handleContactSeller()" id="contactBtn">
                        📧 我要購買
                    </button>
                    <span class="custom-tooltip">
                        點擊後將開啟訊息視窗，<br>
                        您可以向賣家表達購買意願<br>
                        <small>(需要先登入)</small>
                    </span>
                </div>
            <% } else { %>
                <button class="btn-contact" disabled>
                    這是您的書籍
                </button>
            <% } %>
            
            <div style="text-align: center;">
                <button class="btn-favorite <%= isFavorited ? "favorited" : "" %>" 
                        onclick="toggleFavorite()"
                        id="favoriteBtn"
                        data-book-id="<%= bookId %>"
                        data-favorited="<%= isFavorited %>">
                    <span class="favorite-icon"><%= isFavorited ? "❤️" : "🤍" %></span>
                    <span id="favoriteBtnText"><%= isFavorited ? "已收藏" : "加入收藏" %></span>
                </button>
                <div class="favorite-count">
                    <span id="favoriteCount"><%= favoriteCount %></span> 人收藏
                </div>
            </div>
            
            <a class="btn btn-link" href="index.jsp">回首頁</a>
        </div>
    </div>
</div>

<!-- 聯絡賣家的 Modal -->
<div id="contactModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>📧 聯絡賣家</h3>
            <button class="close" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="alert alert-warning">
                <strong>提醒：</strong>您的訊息將會透過系統通知賣家，請禮貌表達購買意願。
            </div>
            <form id="contactForm">
                <input type="hidden" name="bookId" value="<%= bookId %>">
                <input type="hidden" name="listingId" value="<%= listingId %>">
                <input type="hidden" name="sellerId" value="<%= sellerId %>">
                <input type="hidden" name="sellerEmail" value="<%= sellerEmail %>">
                
                <div class="form-group">
                    <label>書籍名稱：</label>
                    <input type="text" class="form-control" value="<%= rs.getString("title") %>" readonly style="background-color: #f0f0f0;">
                </div>
                
                <div class="form-group">
                    <label>給賣家的訊息：<span style="color: red;">*</span></label>
                    <textarea name="message" id="messageText" rows="5" placeholder="例如：您好，我對這本書很感興趣，想了解更多細節...

建議內容：
• 表達購買意願
• 詢問書籍狀況
• 詢問面交時間地點
• 其他問題" required></textarea>
                    <small style="color: #666;">至少需要10個字元</small>
                </div>
                
                <div class="form-group">
                    <label>您的聯絡方式 (選填)：</label>
                    <input type="text" 
                           name="contactInfo" 
                           id="contactInfo" 
                           class="form-control" 
                           placeholder="例如：手機 0912-345-678 或 Line ID: yourlineid"
                           maxlength="100">
                    <small style="color: #28a745;">
                        建議提供手機或 Line ID，方便賣家與您聯繫！
                    </small>
                </div>
                
                <div class="alert alert-info" style="margin-top: 15px;">
                    <strong>隱私提醒：</strong>您的聯絡方式只會顯示給此書籍的賣家，請放心填寫。
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn-modal btn-cancel" onclick="closeModal()">取消</button>
            <button class="btn-modal btn-send" onclick="sendMessage()">發送訊息</button>
        </div>
    </div>
</div>

<script>
    const isLoggedIn = <%= isLoggedIn %>;
    const isOwnBook = <%= isOwnBook %>;
    
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
    
    function handleContactSeller() {
        if (!isLoggedIn) {
            if (confirm('您需要先登入才能聯絡賣家\n\n是否前往登入頁面？')) {
                window.location.href = 'login.jsp?redirect=' + encodeURIComponent(window.location.href);
            }
            return;
        }
        
        if (isOwnBook) {
            alert('這是您自己的書籍，無法聯絡自己');
            return;
        }
        
        openModal();
    }
    
    function openModal() {
        document.getElementById('contactModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
    
    function closeModal() {
        document.getElementById('contactModal').style.display = 'none';
        document.body.style.overflow = 'auto';
        document.getElementById('messageText').value = '';
        document.getElementById('contactInfo').value = '';
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('contactModal');
        if (event.target == modal) {
            closeModal();
        }
    }

    function sendMessage() {
        const messageText = document.getElementById('messageText').value.trim();
        const contactInfo = document.getElementById('contactInfo').value.trim();
        
        if (!messageText) {
            alert('請輸入訊息內容');
            return;
        }
        
        if (messageText.length < 10) {
            alert('訊息內容至少需要10個字元');
            return;
        }
        
        const bookId = document.querySelector('input[name="bookId"]').value;
        const listingId = document.querySelector('input[name="listingId"]').value;
        const sellerId = document.querySelector('input[name="sellerId"]').value;
        const sellerEmail = document.querySelector('input[name="sellerEmail"]').value;
        
        if (!bookId || !listingId || !sellerId) {
            alert('❌ 系統錯誤：缺少必要資料');
            return;
        }
        
        const formData = new URLSearchParams();
        formData.append('bookId', bookId);
        formData.append('listingId', listingId);
        formData.append('sellerId', sellerId);
        formData.append('sellerEmail', sellerEmail || '');
        formData.append('message', messageText);
        formData.append('contactInfo', contactInfo);
        
        const sendBtn = document.querySelector('.btn-send');
        const originalText = sendBtn.textContent;
        sendBtn.textContent = '發送中...';
        sendBtn.disabled = true;
        
        fetch('sendContactMessage.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    alert('✅ 訊息已成功發送!\n\n賣家將會收到您的購買意願通知。');
                    closeModal();
                } else {
                    alert('❌ 發送失敗: ' + (data.message || '未知錯誤'));
                }
            } catch (e) {
                alert('❌ 伺服器回傳格式錯誤');
            }
        })
        .catch(error => {
            alert('❌ 系統錯誤: ' + error.message);
        })
        .finally(() => {
            sendBtn.textContent = originalText;
            sendBtn.disabled = false;
        });
    }
    
    function toggleFavorite() {
        if (!isLoggedIn) {
            if (confirm('您需要先登入才能收藏書籍\n\n是否前往登入頁面？')) {
                window.location.href = 'login.jsp?redirect=' + encodeURIComponent(window.location.href);
            }
            return;
        }
        
        const btn = document.getElementById('favoriteBtn');
        const bookId = btn.getAttribute('data-book-id');
        const isFavorited = btn.getAttribute('data-favorited') === 'true';
        const action = isFavorited ? 'remove' : 'add';
        
        btn.disabled = true;
        const originalText = document.getElementById('favoriteBtnText').textContent;
        document.getElementById('favoriteBtnText').textContent = '處理中...';
        
        fetch('toggleFavorite.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'bookId=' + bookId + '&action=' + action
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const newFavorited = !isFavorited;
                btn.setAttribute('data-favorited', newFavorited);
                btn.classList.toggle('favorited', newFavorited);
                
                const icon = btn.querySelector('.favorite-icon');
                icon.textContent = newFavorited ? '❤️' : '🤍';
                document.getElementById('favoriteBtnText').textContent = newFavorited ? '已收藏' : '加入收藏';
                
                document.getElementById('favoriteCount').textContent = data.favoriteCount;
                
                showToast(newFavorited ? '✅ 已加入收藏' : '✅ 已取消收藏');
            } else {
                alert('❌ 操作失敗: ' + (data.message || '未知錯誤'));
                document.getElementById('favoriteBtnText').textContent = originalText;
            }
        })
        .catch(error => {
            alert('❌ 系統錯誤');
            document.getElementById('favoriteBtnText').textContent = originalText;
        })
        .finally(() => {
            btn.disabled = false;
        });
    }

    function showToast(message) {
        const toast = document.createElement('div');
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            background-color: #333;
            color: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 10000;
            font-size: 14px;
            animation: slideIn 0.3s ease-out;
        `;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.animation = 'slideOut 0.3s ease-out';
            setTimeout(() => toast.remove(), 300);
        }, 2000);
    }

    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from { transform: translateX(400px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(400px); opacity: 0; }
        }
    `;
    document.head.appendChild(style);
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
                <p class="mb-2">題目：國北護二手書交易網</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
                <a class="btn btn-link" href="informAgainst.jsp" target="_blank" rel="noopener noreferrer">舉報不佳上傳書籍區</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書交易網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

</body>
</html>