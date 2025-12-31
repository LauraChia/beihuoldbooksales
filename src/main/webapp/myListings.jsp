<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
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
    <title>我的上架 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        /* 頁面標題 - 淺綠色 */
        .page-header {
            background: #81c784;
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
        
        .page-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
            font-size: 16px;
        }
        
        .controls-bar {
            max-width: 1200px;
            margin: 0 auto 30px;
            padding: 0 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .stats-info {
            display: flex;
            gap: 20px;
            align-items: center;
        }
        
        .stat-item {
            background-color: white;
            padding: 10px 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .stat-item .icon {
            font-size: 24px;
        }
        
        .stat-item .info {
            display: flex;
            flex-direction: column;
        }
        
        .stat-item .label {
            font-size: 12px;
            color: #666;
        }
        
        .stat-item .value {
            font-size: 18px;
            font-weight: bold;
            color: #66bb6a;
        }
        
        .sort-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .sort-label {
            font-weight: bold;
            color: #555;
        }
        
        .sort-select {
            padding: 8px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            background-color: white;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s;
            outline: none;
        }
        
        .sort-select:hover {
            border-color: #81c784;
        }
        
        .sort-select:focus {
            border-color: #81c784;
            box-shadow: 0 0 0 3px rgba(129, 199, 132, 0.1);
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
        }
        
        .filter-btn {
            padding: 8px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            background-color: white;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
            font-weight: 500;
            color: #666;
        }
        
        .filter-btn:hover {
            border-color: #81c784;
            color: #66bb6a;
            background: #f1f8f4;
        }
        
        .filter-btn.active {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            border-color: transparent;
            color: white;
        }
        
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
            padding: 0 40px 40px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .book-card {
            background-color: white;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            overflow: hidden;
            transition: 0.2s ease-in-out;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            position: relative;
        }
              
        .book-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.12);
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
            background-color: #f0f0f0;
        }
        
        .book-img {
            width: 100%;
            height: 260px;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            transition: opacity 0.5s ease;
            opacity: 0;
        }
        
        .book-img.active {
            opacity: 1;
        }
        
        .status-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 5px 12px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: bold;
            z-index: 10;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
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
        
        .status-delisted {
            background: linear-gradient(135deg, #bdbdbd 0%, #9e9e9e 100%);
            color: white;
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
            color: #e53935;
            font-weight: bold;
            font-size: 15px;
        }
        
        .book-date {
            font-size: 13px;
            color: #888;
        }
        
        .book-quantity {
            font-size: 13px;
            color: #555;
            margin-top: 5px;
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
        
        .image-dots {
            position: absolute;
            bottom: 8px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 5px;
            z-index: 10;
        }
        
        .dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background-color: rgba(255,255,255,0.5);
            transition: background-color 0.3s;
        }
        
        .dot.active {
            background-color: white;
        }
        
        .no-image {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            font-size: 14px;
        }
        
        .action-buttons {
            position: absolute;
            top: 10px;
            right: 10px;
            display: flex;
            gap: 5px;
            z-index: 100;
        }
        
        .action-btn {
            background-color: rgba(255, 255, 255, 0.9);
            border: none;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .action-btn:hover {
            transform: scale(1.15);
            background-color: white;
        }
        
        .btn-edit {
            color: #42a5f5;
        }
        
        .btn-delete {
            color: #ef5350;
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 40px;
            grid-column: 1/-1;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .empty-state .icon {
            font-size: 80px;
            margin-bottom: 20px;
            color: #c8e6c9;
        }
        
        .empty-state h3 {
            color: #66bb6a;
            margin-bottom: 15px;
        }
        
        .empty-state p {
            color: #999;
            margin-bottom: 25px;
        }
        
        .btn-primary-custom {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            font-weight: 500;
        }
        
        .btn-primary-custom:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 16px;
        }
        
        @media (max-width: 768px) {
            .controls-bar {
                flex-direction: column;
                align-items: stretch;
            }
            
            .stats-info {
                flex-direction: column;
                width: 100%;
            }
            
            .stat-item {
                width: 100%;
            }
            
            .sort-controls {
                width: 100%;
                justify-content: space-between;
            }
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-books"></i> 我的上架</h1>
        <p>管理您所有上架的二手書籍</p>
    </div>
</div>

<%
    Connection con = null;
    Statement smt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        // 獲取排序參數
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "newest";
        }
        
        // 獲取篩選參數
        String filterStatus = request.getParameter("filter");
        if (filterStatus == null || filterStatus.isEmpty()) {
            filterStatus = "all";
        }
        
        // 構建 SQL 查詢
        String sql = "SELECT " +
                     "bl.listingId, " +
                     "b.bookId, " +
                     "b.title, " +
                     "b.author, " +
                     "bl.price, " +
                     "bl.listedAt, " +
                     "bl.photo, " +
                     "bl.condition, " +
                     "bl.quantity, " +
                     "bl.Approved, " +
                     "bl.isDelisted " +
                     "FROM bookListings bl " +
                     "INNER JOIN books b ON bl.bookId = b.bookId " +
                     "WHERE bl.sellerId = '" + currentUserId + "' ";
        
        // 添加篩選條件
        if (!filterStatus.equals("all")) {
	    if (filterStatus.equals("approved")) {
	        sql += "AND bl.Approved = 'TRUE' AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) ";
	    } else if (filterStatus.equals("pending")) {
	        sql += "AND (bl.Approved IS NULL OR bl.Approved = '') AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) ";  // 修改這裡
	    } else if (filterStatus.equals("rejected")) {  // 新增這個條件
	        sql += "AND bl.Approved = 'FALSE' AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) ";
	    } else if (filterStatus.equals("delisted")) {
	        sql += "AND bl.isDelisted = TRUE ";
	    }
	}
        
        // 添加排序
        if (sortBy.equals("newest")) {
            sql += "ORDER BY bl.listedAt DESC";
        } else if (sortBy.equals("oldest")) {
            sql += "ORDER BY bl.listedAt ASC";
        } else if (sortBy.equals("price_high")) {
            sql += "ORDER BY bl.price DESC";
        } else if (sortBy.equals("price_low")) {
            sql += "ORDER BY bl.price ASC";
        } else if (sortBy.equals("title")) {
            sql += "ORDER BY b.title ASC";
        }
        
        smt = con.createStatement();
        rs = smt.executeQuery(sql);
        
        // 計算統計資訊
        String statsSql = "SELECT " +
                 "COUNT(*) as total, " +
                 "SUM(CASE WHEN bl.Approved = 'TRUE' AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) THEN 1 ELSE 0 END) as approved, " +
                 "SUM(CASE WHEN (bl.Approved IS NULL OR bl.Approved = '') AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) THEN 1 ELSE 0 END) as pending, " +  // 修改這裡
                 "SUM(CASE WHEN bl.Approved = 'FALSE' AND (bl.isDelisted IS NULL OR bl.isDelisted = FALSE) THEN 1 ELSE 0 END) as rejected, " +  // 新增這行
                 "SUM(CASE WHEN bl.isDelisted = TRUE THEN 1 ELSE 0 END) as delisted " +
                 "FROM bookListings bl " +
                 "WHERE bl.sellerId = '" + currentUserId + "'";
        
        ResultSet statsRs = smt.executeQuery(statsSql);
        int totalBooks = 0;
        int approvedBooks = 0;
        int pendingBooks = 0;
        int rejectedBooks = 0;  // 新增這行
        int delistedBooks = 0;

        if (statsRs.next()) {
            totalBooks = statsRs.getInt("total");
            approvedBooks = statsRs.getInt("approved");
            pendingBooks = statsRs.getInt("pending");
            rejectedBooks = statsRs.getInt("rejected");  // 新增這行
            delistedBooks = statsRs.getInt("delisted");
        }
        statsRs.close();
%>

<div class="controls-bar">
    <div class="stats-info">
        <div class="stat-item">
            <span class="icon"><i class="fas fa-books"></i></span>
            <div class="info">
                <span class="label">總上架數</span>
                <span class="value"><%= totalBooks %></span>
            </div>
        </div>
        <div class="stat-item">
            <span class="icon"><i class="fas fa-check-circle"></i></span>
            <div class="info">
                <span class="label">已通過</span>
                <span class="value"><%= approvedBooks %></span>
            </div>
        </div>
        <div class="stat-item">
            <span class="icon"><i class="fas fa-clock"></i></span>
            <div class="info">
                <span class="label">待審核</span>
                <span class="value"><%= pendingBooks %></span>
            </div>
        </div>
        <div class="stat-item">
            <span class="icon"><i class="fas fa-times-circle"></i></span>
            <div class="info">
                <span class="label">未通過</span>
                <span class="value"><%= rejectedBooks %></span>
            </div>
        </div>
    </div>
    
    <div class="filter-buttons">
        <button class="filter-btn <%= filterStatus.equals("all") ? "active" : "" %>" 
                onclick="changeFilter('all')">
            <i class="fas fa-list"></i> 全部
        </button>
        <button class="filter-btn <%= filterStatus.equals("approved") ? "active" : "" %>" 
                onclick="changeFilter('approved')">
            <i class="fas fa-check-circle"></i> 已通過
        </button>
        <button class="filter-btn <%= filterStatus.equals("pending") ? "active" : "" %>" 
                onclick="changeFilter('pending')">
            <i class="fas fa-clock"></i> 待審核
        </button>
        <button class="filter-btn <%= filterStatus.equals("rejected") ? "active" : "" %>" 
                onclick="changeFilter('rejected')">
            <i class="fas fa-times-circle"></i> 未通過
        </button>
        <button class="filter-btn <%= filterStatus.equals("delisted") ? "active" : "" %>" 
                onclick="changeFilter('delisted')">
            <i class="fas fa-ban"></i> 已下架
        </button>
    </div>
    
    <div class="sort-controls">
        <span class="sort-label">排序：</span>
        <select class="sort-select" onchange="changeSort(this.value)" id="sortSelect">
            <option value="newest" <%= sortBy.equals("newest") ? "selected" : "" %>>最新上架</option>
            <option value="oldest" <%= sortBy.equals("oldest") ? "selected" : "" %>>最早上架</option>
            <option value="price_high" <%= sortBy.equals("price_high") ? "selected" : "" %>>價格高到低</option>
            <option value="price_low" <%= sortBy.equals("price_low") ? "selected" : "" %>>價格低到高</option>
            <option value="title" <%= sortBy.equals("title") ? "selected" : "" %>>書名排序</option>
        </select>
    </div>
</div>

<div class="book-grid">
<%
        int cardIndex = 0;
        int displayCount = 0;
        
        while(rs.next()) {
            String listingId = rs.getString("listingId");
            String bookId = rs.getString("bookId");
            String title = rs.getString("title");
            String author = rs.getString("author");
            String price = rs.getString("price");
            Timestamp listedAt = rs.getTimestamp("listedAt");
            String dateStr = (listedAt != null) ? listedAt.toString().split(" ")[0] : "";
            String photoStr = rs.getString("photo");
            String quantity = rs.getString("quantity");
            String approved = rs.getString("Approved");
            Boolean isDelisted = rs.getBoolean("isDelisted");
            
         	// 判斷狀態
            String statusText = "待審核";
            String statusClass = "status-pending";

            if (isDelisted != null && isDelisted) {
                statusText = "已下架";
                statusClass = "status-delisted";
            } else if ("TRUE".equalsIgnoreCase(approved)) {
                statusText = "已通過";  // 改為「已通過」
                statusClass = "status-approved";
            } else if ("FALSE".equalsIgnoreCase(approved)) {
                statusText = "未通過";  // 改為「未通過」
                statusClass = "status-rejected";
            }
            
            // 分割圖片路徑
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
            
            int photoCount = photoList.size();
            String cardId = "card-" + cardIndex;
            cardIndex++;
            displayCount++;
%>
    <div class="book-card" data-card-id="<%= cardId %>">
        <a class="book-link" href="myListingDetail.jsp?listingId=<%= listingId %>">
            <div class="status-badge <%= statusClass %>"><%= statusText %></div>
            
		<div class="action-buttons" onclick="event.preventDefault();">
		    <% if (isDelisted != null && isDelisted) { %>
		        <!-- 已下架：只顯示編輯按鈕 -->
		        <button class="action-btn btn-edit" 
		                onclick="editListing('<%= listingId %>')"
		                title="編輯並重新上架">
		            <i class="fas fa-edit"></i>
		        </button>
		    <% } else { %>
		        <!-- 未下架：只顯示下架按鈕 -->
		        <button class="action-btn btn-delete" 
		                onclick="deleteListing('<%= listingId %>', '<%= title %>')"
		                title="下架">
		            <i class="fas fa-trash"></i>
		        </button>
		    <% } %>
		</div>
            
            <div class="book-images" id="<%= cardId %>">
                <% if (photoList.isEmpty()) { %>
                    <div class="no-image">無圖片</div>
                <% } else { %>
                    <% for (int i = 0; i < photoList.size(); i++) { %>
                        <img src="<%= photoList.get(i) %>" 
                             alt="書籍圖片<%= (i+1) %>" 
                             class="book-img <%= (i == 0) ? "active" : "" %>"
                             onerror="this.src='assets/images/about.png'">
                    <% } %>
                    
                    <% if (photoCount > 1) { %>
                        <span class="image-indicator"><span class="current-img">1</span>/<%= photoCount %></span>
                        <div class="image-dots">
                            <% for (int i = 0; i < photoCount; i++) { %>
                                <span class="dot <%= (i == 0) ? "active" : "" %>"></span>
                            <% } %>
                        </div>
                    <% } %>
                <% } %>
            </div>
            <div class="book-info">
                <div class="book-title"><%= title %></div>
                <div class="book-author">作者：<%= author != null ? author : "未提供" %></div>
                <div class="book-price">NT$<%= (price != null && !price.trim().isEmpty()) ? (int) Float.parseFloat(price) : 0 %></div>
                <div class="book-date">上架日期：<%= dateStr %></div>
                <div class="book-quantity">剩餘數量：<%= quantity %> 本</div>
            </div>
        </a>
    </div>
<%
        }
        
        if (displayCount == 0) {
%>
    <div class="empty-state">
        <div class="icon"><i class="fas fa-box-open"></i></div>
        <h3>目前沒有符合條件的書籍</h3>
        <p>您尚未上架任何書籍，或目前篩選條件下沒有資料</p>
        <a href="shop.jsp" class="btn-primary-custom">
            <i class="fas fa-plus"></i> 立即上架書籍
        </a>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<div style='grid-column: 1/-1; text-align: center; padding: 40px; color: #ef5350;'>");
        out.println("<h3>載入資料時發生錯誤</h3>");
        out.println("<p>錯誤訊息: " + e.getMessage() + "</p>");
        out.println("</div>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (smt != null) smt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</div>

<script>
function changeSort(sortValue) {
    const currentUrl = new URL(window.location.href);
    currentUrl.searchParams.set('sortBy', sortValue);
    window.location.href = currentUrl.toString();
}

function changeFilter(filterValue) {
    const currentUrl = new URL(window.location.href);
    currentUrl.searchParams.set('filter', filterValue);
    window.location.href = currentUrl.toString();
}

function editListing(listingId) {
    window.location.href = 'editListing.jsp?listingId=' + listingId;
}

function deleteListing(listingId, bookTitle) {
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

// 圖片輪播功能
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.book-card');
    
    cards.forEach(card => {
        const cardId = card.getAttribute('data-card-id');
        const container = document.getElementById(cardId);
        if (!container) return;
        
        const images = container.querySelectorAll('.book-img');
        const dots = container.querySelectorAll('.dot');
        const indicator = container.querySelector('.current-img');
        
        if (images.length <= 1) return;
        
        let currentIndex = 0;
        let intervalId = null;
        
        function showImage(index) {
            images.forEach(img => img.classList.remove('active'));
            dots.forEach(dot => dot.classList.remove('active'));
            
            images[index].classList.add('active');
            dots[index].classList.add('active');
            
            if (indicator) {
                indicator.textContent = index + 1;
            }
        }
        
        function nextImage() {
            currentIndex = (currentIndex + 1) % images.length;
            showImage(currentIndex);
        }
        
        card.addEventListener('mouseenter', function() {
            intervalId = setInterval(nextImage, 800);
        });
        
        card.addEventListener('mouseleave', function() {
            if (intervalId) {
                clearInterval(intervalId);
                intervalId = null;
            }
            currentIndex = 0;
            showImage(0);
        });
    });
});
</script>

<%@ include file="footer.jsp"%>
 
 </body>