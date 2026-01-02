<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>書籍詳情 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
    background-color: #f8f9fa;
    font-family: "Microsoft JhengHei", sans-serif;
}

/* 頁面標題 - 使用綠色系 */
.page-header {
    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
    color: white;
    padding: 40px 0;
    margin-bottom: 40px;
    box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
}

.page-header h1 {
    margin: 0;
    font-size: 32px;
    font-weight: 600;
}

.page-header .breadcrumb {
    background: transparent;
    padding: 0;
    margin: 10px 0 0 0;
    font-size: 14px;
}

.page-header .breadcrumb a {
    color: white;
    opacity: 0.9;
    text-decoration: none;
}

.page-header .breadcrumb a:hover {
    opacity: 1;
    text-decoration: underline;
}

.page-header .breadcrumb-item.active {
    color: white;
    opacity: 0.7;
}

.page-header .breadcrumb-item + .breadcrumb-item::before {
    color: white;
    opacity: 0.7;
}

.back-button {
    background-color: white;
    border: 2px solid #81c784;
    color: #66bb6a;
    padding: 10px 20px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 20px;
}

.back-button:hover {
    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
    color: white;
    transform: translateX(-5px);
    box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
}

.book-detail {
    display: flex;
    justify-content: center;
    align-items: flex-start;
    gap: 40px;
    padding: 0 40px 40px;
    max-width: 1400px;
    margin: 0 auto;
}

.image-gallery {
    position: relative;
    width: 400px;
    flex-shrink: 0;
}

.image-container {
    position: relative;
    width: 100%;
    height: 500px;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(0,0,0,0.12);
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
    background-color: rgba(129, 199, 132, 0.9);
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
    transition: all 0.3s;
    z-index: 10;
}

.image-nav:hover {
    background-color: #66bb6a;
    transform: translateY(-50%) scale(1.1);
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
    width: 80px;
    height: 100px;
    border-radius: 8px;
    object-fit: cover;
    cursor: pointer;
    border: 3px solid transparent;
    transition: all 0.3s;
    flex-shrink: 0;
}

.thumbnail:hover {
    transform: scale(1.05);
    border-color: #c8e6c9;
}

.thumbnail.active {
    border-color: #66bb6a;
    box-shadow: 0 2px 8px rgba(102, 187, 106, 0.4);
}

.image-counter {
    position: absolute;
    bottom: 10px;
    right: 10px;
    background-color: rgba(102, 187, 106, 0.9);
    color: white;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 500;
    z-index: 10;
}

.status-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
    z-index: 10;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.status-approved {
    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
    color: white;
}

.status-pending {
    background: linear-gradient(135deg, #ffb74d 0%, #ffa726 100%);
    color: white;
}

.status-rejected {
    background: linear-gradient(135deg, #e57373 0%, #ef5350 100%);
    color: white;
}

.detail-info {
    flex: 1;
    max-width: 700px;
}

.detail-header {
    margin-bottom: 20px;
}

.detail-header h2 {
    font-weight: bold;
    margin: 0 0 10px 0;
    color: #333;
    font-size: 28px;
}

.price {
    font-size: 32px;
    color: #e53935;
    font-weight: bold;
    margin: 15px 0;
}

.info-section {
    background-color: white;
    border-radius: 12px;
    padding: 25px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    border: 1px solid #e0e0e0;
}

.info-section h3 {
    font-size: 18px;
    font-weight: bold;
    color: #66bb6a;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 2px solid #c8e6c9;
    display: flex;
    align-items: center;
    gap: 8px;
}

.info-item {
    margin: 14px 0;
    color: #555;
    line-height: 1.8;
    display: flex;
    align-items: flex-start;
}

.info-item strong {
    color: #333;
    min-width: 140px;
    display: inline-block;
    font-weight: 600;
}

.info-item .value {
    flex: 1;
}

.action-buttons {
    display: flex;
    gap: 15px;
    margin-top: 30px;
    flex-wrap: wrap;
    align-items: center;
}

.btn-action {
    padding: 14px 30px;
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

.btn-contact {
    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
    color: white;
}

.btn-contact:hover {
    background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
}

.btn-contact:disabled {
    background-color: #ccc;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}

.btn-favorite {
    background-color: #fff;
    color: #ff6b6b;
    padding: 14px 30px;
    border: 2px solid #ff6b6b;
    border-radius: 8px;
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

.favorite-wrapper {
    text-align: center;
}

.favorite-count {
    font-size: 13px;
    color: #666;
    margin-top: 5px;
}

.btn-secondary {
    background-color: white;
    border: 2px solid #66bb6a;
    color: #66bb6a;
    text-decoration: none;
}

.btn-secondary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(102, 187, 106, 0.2);
    text-decoration: none;
}

.alert {
    padding: 18px 25px;
    margin: 0 40px 30px;
    max-width: 1400px;
    margin-left: auto;
    margin-right: auto;
    border-radius: 10px;
    animation: slideIn 0.3s;
    border-left: 4px solid;
}

.alert-warning {
    background-color: #fff8e1;
    border-color: #ffb74d;
    color: #f57c00;
}

.alert-info {
    background-color: #e3f2fd;
    border-color: #42a5f5;
    color: #1976d2;
}

.alert strong {
    font-size: 16px;
    display: block;
    margin-bottom: 5px;
}

.no-image {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: #999;
    font-size: 16px;
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
    animation: slideInModal 0.3s;
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
    background-color: #66bb6a;
    color: white;
}

.btn-send:hover {
    background-color: #4caf50;
}

.btn-cancel {
    background-color: #6c757d;
    color: white;
}

.btn-cancel:hover {
    background-color: #5a6268;
}

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

@keyframes fadeIn {
    from {opacity: 0;}
    to {opacity: 1;}
}

@keyframes slideIn {
    from { transform: translateY(-20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

@keyframes slideInModal {
    from {transform: translateY(-50px); opacity: 0;}
    to {transform: translateY(0); opacity: 1;}
}

@media (max-width: 1024px) {
    .book-detail {
        flex-direction: column;
        padding: 0 20px 40px;
    }
    
    .image-gallery {
        width: 100%;
        max-width: 500px;
        margin: 0 auto;
    }
    
    .detail-info {
        width: 100%;
        max-width: 100%;
    }
    
    .alert {
        margin: 0 20px 30px;
    }
}
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-book"></i> 書籍詳情</h1>
    </div>
</div>

<%
    String listingId = request.getParameter("listingId");
    
    String currentUserId = (String) session.getAttribute("userId");
    boolean isLoggedIn = (loggedInUserId != null && !loggedInUserId.trim().isEmpty());
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
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
        
        String countFavSql = "SELECT COUNT(*) as total FROM favorites WHERE bookId = " + bookId;
        ResultSet countRs = smt.executeQuery(countFavSql);
        if (countRs.next()) {
            favoriteCount = countRs.getInt("total");
        }
        countRs.close();
        
     	// 取得有無筆記資訊
        String remarks = rs.getString("remarks");
        String hasNotes = (remarks != null && !remarks.trim().isEmpty()) ? remarks : "未提供";
        
        // 檢查是否已有對話串
        String existingConversationId = "";
        if (isLoggedIn && !isOwnBook) {
            int currentUserIdInt = Integer.parseInt(loggedInUserId);
            int sellerIdInt = Integer.parseInt(sellerId);
            
            String checkConvSQL = "SELECT conversationId FROM messages " +
                                 "WHERE bookId = " + listingId + " " +
                                 "AND ((senderId = " + currentUserIdInt + " AND receiverId = " + sellerIdInt + ") " +
                                 "OR (senderId = " + sellerIdInt + " AND receiverId = " + currentUserIdInt + ")) " +
                                 "ORDER BY messageId LIMIT 1";
            ResultSet convRs = smt.executeQuery(checkConvSQL);
            if (convRs.next()) {
                existingConversationId = convRs.getString("conversationId");
            }
            convRs.close();
        }
%>

<div style="max-width: 1400px; margin: 0 auto; padding: 0 40px;">
    <button class="back-button" onclick="window.location.href='index.jsp'">
        <i class="fas fa-arrow-left"></i> 返回首頁
    </button>
</div>

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
                    <button class="image-nav prev" onclick="changeImage(-1)">
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <button class="image-nav next" onclick="changeImage(1)">
                        <i class="fas fa-chevron-right"></i>
                    </button>
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
        
        <!-- 基本資訊 -->
        <div class="info-section">
            <h3><i class="fas fa-book"></i> 基本資訊</h3>
            <div class="info-item">
                <strong>作者：</strong>
                <span class="value"><%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>出版日期：</strong>
                <span class="value"><%= rs.getString("publishDate") != null ? rs.getString("publishDate").split(" ")[0] : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>書籍版本：</strong>
                <span class="value"><%= rs.getString("edition") != null && !rs.getString("edition").trim().isEmpty() ? rs.getString("edition") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>ISBN：</strong>
                <span class="value"><%= rs.getString("ISBN") != null && !rs.getString("ISBN").trim().isEmpty() ? rs.getString("ISBN") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>書籍狀況：</strong>
                <span class="value"><%= rs.getString("condition") %></span>
            </div>
            <div class="info-item">
                <strong>有無筆記：</strong>
                <span class="value"><%= hasNotes %></span>
            </div>
            <div class="info-item">
                <strong>剩餘數量：</strong>
                <span class="value"><%= rs.getString("quantity") %> 本</span>
            </div>
        </div>
        
        <!-- 課程資訊 -->
        <div class="info-section">
            <h3><i class="fas fa-graduation-cap"></i> 課程資訊</h3>
            <div class="info-item">
                <strong>使用系所：</strong>
                <span class="value"><%= rs.getString("department") != null ? rs.getString("department") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>使用課程：</strong>
                <span class="value"><%= rs.getString("courseName") != null ? rs.getString("courseName") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>授課老師：</strong>
                <span class="value"><%= rs.getString("teacher") != null ? rs.getString("teacher") : "未提供" %></span>
            </div>
        </div>
        
        <!-- 賣家與上架資訊 -->
<div class="info-section">
    <h3><i class="fas fa-info-circle"></i> 賣家與上架資訊</h3>
    <div class="info-item">
        <strong>賣家：</strong>
        <span class="value"><%= rs.getString("sellerName") %></span>
    </div>
    <div class="info-item">
        <strong>上架日期：</strong>
        <span class="value"><%= rs.getString("listedAt").split(" ")[0] %></span>
    </div>
    <%
        String expiryDateStr = rs.getString("expiryDate");
        String displayExpiryDate = "未設定";
        
        if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
            try {
                SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date date = dbFormat.parse(expiryDateStr.split(" ")[0]);
                displayExpiryDate = displayFormat.format(date);
            } catch (Exception e) {
                displayExpiryDate = expiryDateStr.split(" ")[0];
            }
        }
    %>
    <div class="info-item">
        <strong>下架日期：</strong>
        <span class="value"><%= displayExpiryDate %></span>
    </div>
    <div class="info-item">
        <strong>審核狀態：</strong>
        <span class="value <%= statusClass.replace("status-", "") %>"><%= statusText %></span>
    </div>
</div>

        <div class="action-buttons">
            <% if (!isOwnBook) { %>
                <div class="tooltip-wrapper">
                    <button class="btn-action btn-contact" onclick="handleContactSeller()" id="contactBtn">
                        <i class="fas fa-comments"></i> <%= existingConversationId.isEmpty() ? "我要購買" : "繼續對話" %>
                    </button>
                    <span class="custom-tooltip">
                        <%= existingConversationId.isEmpty() ? 
                            "點擊後將開啟訊息視窗，<br>您可以向賣家表達購買意願" : 
                            "點擊進入您與賣家的對話" %>
                        <br><small>(需要先登入)</small>
                    </span>
                </div>
            <% } else { %>
                <button class="btn-action btn-contact" disabled>
                    <i class="fas fa-user"></i> 這是您的書籍
                </button>
            <% } %>
            
            <div class="favorite-wrapper">
		        <% if (!isOwnBook) { %>
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
		        <% } else { %>
		            <button class="btn-favorite" disabled>
		                <span class="favorite-icon">🤍</span>
		                <span>無法收藏自己的書籍</span>
		            </button>
		            <div class="favorite-count">
		                <span id="favoriteCount"><%= favoriteCount %></span> 人收藏
		            </div>
		        <% } %>
		    </div>
            
            <button class="btn-action btn-secondary" onclick="window.location.href='index.jsp'">
                <i class="fas fa-home"></i> 返回首頁
            </button>
        </div>
    </div>
</div>

<script>
    const isLoggedIn = <%= isLoggedIn %>;
    const isOwnBook = <%= isOwnBook %>;
    const existingConversationId = '<%= existingConversationId %>';
    const currentUserId = '<%= isLoggedIn ? loggedInUserId : "" %>';
    const sellerId = '<%= sellerId %>';
    const bookId = '<%= listingId %>';
    
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
        
        // 如果已有對話，直接跳轉到對話頁面
        if (existingConversationId) {
            window.location.href = 'conversation.jsp?conversationId=' + existingConversationId;
        } else {
            openModal();
        }
    }
    
    function openModal() {
        document.getElementById('contactModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
    
    function closeModal() {
        document.getElementById('contactModal').style.display = 'none';
        document.body.style.overflow = 'auto';
        document.getElementById('messageText').value = '';
    }
    
    window.onclick = function(event) {
        const modal = document.getElementById('contactModal');
        if (event.target == modal) {
            closeModal();
        }
    }

    // 發送第一則訊息並建立對話串
    function sendFirstMessage() {
        const messageText = document.getElementById('messageText').value.trim();
        
        if (!messageText) {
            alert('請輸入訊息內容');
            return;
        }
        
        if (messageText.length < 10) {
            alert('訊息內容至少需要10個字元');
            return;
        }
        
        const sendBtn = document.querySelector('.btn-send');
        const originalText = sendBtn.textContent;
        sendBtn.textContent = '發送中...';
        sendBtn.disabled = true;
        
        // 生成 conversationId: buyer_seller_bookId
        const conversationId = currentUserId + '_' + sellerId + '_' + bookId;
        
        const formData = new URLSearchParams();
        formData.append('conversationId', conversationId);
        formData.append('senderId', currentUserId);
        formData.append('receiverId', sellerId);
        formData.append('bookId', bookId);
        formData.append('message', messageText);
        formData.append('senderType', 'buyer'); // 買家發起對話
        
        fetch('sendMessage.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ 訊息已成功發送!\n\n即將進入對話頁面...');
                closeModal();
                // 跳轉到對話頁面
                window.location.href = 'conversation.jsp?conversationId=' + conversationId;
            } else {
                alert('❌ 發送失敗: ' + (data.message || '未知錯誤'));
                sendBtn.textContent = originalText;
                sendBtn.disabled = false;
            }
        })
        .catch(error => {
            alert('❌ 系統錯誤: ' + error.message);
            sendBtn.textContent = originalText;
            sendBtn.disabled = false;
        });
    }
    
    function toggleFavorite() {
        // 添加自己书籍的检查
        if (isOwnBook) {
            alert('❌ 無法收藏自己的書籍');
            return;
        }
        
        if (!isLoggedIn) {
            if (confirm('您需要先登入才能收藏書籍\n\n是否前往登入頁面?')) {
                window.location.href = 'login.jsp?redirect=' + encodeURIComponent(window.location.href);
            }
            return;
        }
        
        const btn = document.getElementById('favoriteBtn');
        const bookIdParam = btn.getAttribute('data-book-id');
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
            body: 'bookId=' + bookIdParam + '&action=' + action
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
            animation: slideInToast 0.3s ease-out;
        `;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.animation = 'slideOutToast 0.3s ease-out';
            setTimeout(() => toast.remove(), 300);
        }, 2000);
    }

    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInToast {
            from { transform: translateX(400px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes slideOutToast {
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

<!-- Footer -->
<%@ include file="footer.jsp"%>

</body>
</html>