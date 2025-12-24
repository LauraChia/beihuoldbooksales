<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>我的收藏 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        .favorites-container {
            max-width: 1200px;
            margin: -30px auto 0;
            padding: 20px;
        }
        
        /* 頁面標題 - 單一淺綠色 */
        .page-header {
            background: #81c784;
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
        }
        
        .page-header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 600;
        }
        
        .page-header p {
            margin: 15px 0 0 0;
            opacity: 0.95;
            font-size: 16px;
        }
        
        .stats-bar {
            display: flex;
            gap: 20px;
            margin-top: 15px;
        }
        
        .stat-item {
            background: rgba(255, 255, 255, 0.25);
            padding: 10px 20px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
            padding: 20px 0;
        }
        
        .book-card {
            background-color: white;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s ease;
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
        
        .book-image {
            width: 100%;
            height: 260px;
            object-fit: cover;
            background-color: #f0f0f0;
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
        
        /* 🔧 修改：作者顏色改為 #666，與首頁一致 */
        .book-author {
            color: #666;
            font-size: 14px;
            margin-bottom: 6px;
        }
        
        /* 🔧 修改：價格顏色改為 #d9534f (紅色)，與首頁一致 */
        .book-price {
            color: #d9534f;
            font-weight: bold;
            font-size: 15px;
        }
        
        /* 🔧 修改：日期顏色改為 #888，與首頁一致 */
        .book-date {
            font-size: 13px;
            color: #888;
        }
        
        /* 取消收藏按鈕 - 改用淺綠色 */
        .remove-favorite {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(255, 255, 255, 0.95);
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            z-index: 10;
            color: #ff7043;
        }
        
        .remove-favorite:hover {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        /* 空狀態 */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .empty-state-icon {
            font-size: 80px;
            margin-bottom: 20px;
            color: #c8e6c9;
        }
        
        .empty-state h3 {
            color: #66bb6a;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #999;
            margin-bottom: 30px;
        }
        
        /* 前往瀏覽按鈕 - 改用淺綠色漸層 */
        .btn-browse {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            font-weight: 500;
        }
        
        .btn-browse:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
            color: white;
        }
        
        .favorite-time {
            font-size: 12px;
            color: #999;
            margin-top: 4px;
        }
        
        /* Toast 提示 */
        .toast-message {
            position: fixed;
            top: 100px;
            right: 20px;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
            z-index: 10000;
            font-size: 14px;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes fadeOut {
            from { 
                opacity: 1; 
                transform: scale(1); 
            }
            to { 
                opacity: 0; 
                transform: scale(0.8); 
            }
        }
        
        /* 響應式設計 */
        @media (max-width: 768px) {
            .favorites-container {
                margin-top: 20px;
                padding: 15px;
            }
            
            .page-header h1 {
                font-size: 24px;
            }
            
            .stats-bar {
                flex-direction: column;
                gap: 10px;
            }
            
            .book-grid {
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                gap: 15px;
            }
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<%
    // 檢查是否登入
    String userId = (String) session.getAttribute("userId");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=myFavorites.jsp");
        return;
    }
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 查詢使用者的收藏書籍
	String sql = "SELECT f.favoriteId, f.createdAt as favoriteTime, " +
	             "b.bookId, b.title, b.author, bl.price, bl.listedAt, bl.photo, bl.listingId " +
	             "FROM favorites f " +
	             "INNER JOIN books b ON f.bookId = b.bookId " +
	             "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
	             "WHERE f.userId = '" + userId + "' " +
	             "AND bl.isDelisted = false " +  // 只顯示未下架的書籍
	             "ORDER BY f.createdAt DESC";
    
    Statement smt = con.createStatement();
    ResultSet rs = smt.executeQuery(sql);
    
    List<Map<String, String>> favoriteBooks = new ArrayList<>();
    while (rs.next()) {
        Map<String, String> book = new HashMap<>();
        book.put("favoriteId", rs.getString("favoriteId"));
        book.put("bookId", rs.getString("bookId"));
        book.put("titleBook", rs.getString("title"));
        book.put("author", rs.getString("author"));
        book.put("price", rs.getString("price"));
        book.put("date", rs.getString("listedAt"));
        book.put("favoriteTime", rs.getString("favoriteTime"));
        book.put("listingId", rs.getString("listingId"));
        
        // 處理圖片
        String photoStr = rs.getString("photo");
        String photo = "assets/images/about.png"; // 預設圖片
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String firstPhoto = photoStr.split(",")[0].trim();
            photo = firstPhoto;
        }
        book.put("photo", photo);
        
        favoriteBooks.add(book);
    }
    
    rs.close();
    smt.close();
    con.close();
%>

<div class="favorites-container">
    <!-- 頁面標題 -->
    <div class="page-header">
        <h1><i class="fas fa-heart"></i> 我的收藏</h1>
        <div class="stats-bar">
            <div class="stat-item">
                <i class="fas fa-book"></i> 已收藏: <strong><%= favoriteBooks.size() %></strong> 本書籍
            </div>
        </div>
    </div>

    <% if (favoriteBooks.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon">
                <i class="far fa-heart"></i>
            </div>
            <h3>還沒有收藏任何書籍</h3>
            <p>開始探索並收藏您喜歡的書籍吧！</p>
            <a href="index.jsp" class="btn-browse">
                <i class="fas fa-search"></i> 前往瀏覽書籍
            </a>
        </div>
    <% } else { %>
        <div class="book-grid">
            <% for (Map<String, String> book : favoriteBooks) { %>
                <div class="book-card" id="card-<%= book.get("bookId") %>">
                    <button class="remove-favorite" 
                            onclick="removeFavorite('<%= book.get("bookId") %>', '<%= book.get("favoriteId") %>')"
                            title="取消收藏">
                        <i class="fas fa-heart"></i>
                    </button>
                    
                    <a class="book-link" href="bookDetail.jsp?listingId=<%= book.get("bookId") %>">
                        <img src="<%= book.get("photo") %>" 
                             alt="<%= book.get("titleBook") %>" 
                             class="book-image"
                             onerror="this.src='assets/images/about.png'">
                        
                        <div class="book-info">
                            <div class="book-title"><%= book.get("titleBook") %></div>
                            <!-- 🔧 修改：移除圖標，只保留「作者：」文字 -->
                            <div class="book-author">作者：<%= book.get("author") %></div>
                            <!-- 🔧 修改：移除圖標，保持與首頁一致 -->
                            <div class="book-price">NT$<%= (int) Float.parseFloat(book.get("price")) %></div>
                            <!-- 🔧 修改：改為「出版日期：」文字格式 -->
                            <div class="book-date">出版日期：<%= book.get("date") != null ? book.get("date").split(" ")[0] : "" %></div>
                            <div class="favorite-time"><i class="far fa-clock"></i> 收藏於：<%= book.get("favoriteTime").split(" ")[0] %></div>
                        </div>
                    </a>
                </div>
            <% } %>
        </div>
    <% } %>
</div>

<script>
function removeFavorite(bookId, favoriteId) {
    if (!confirm('確定要取消收藏這本書嗎？')) {
        return;
    }
    
    fetch('toggleFavorite.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'bookId=' + bookId + '&action=remove'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 移除卡片動畫
            const card = document.getElementById('card-' + bookId);
            card.style.animation = 'fadeOut 0.3s ease-out';
            
            setTimeout(() => {
                card.remove();
                
                // 檢查是否還有書籍
                const remaining = document.querySelectorAll('.book-card').length;
                if (remaining === 0) {
                    location.reload(); // 重新載入頁面顯示空狀態
                }
            }, 300);
            
            showToast('✅ 已取消收藏');
        } else {
            alert('❌ 取消收藏失敗');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('❌ 系統錯誤');
    });
}

function showToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast-message';
    toast.innerHTML = '<i class="fas fa-check-circle"></i> ' + message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 2000);
}
</script>

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
                <a class="btn btn-link" href="myFavorites.jsp">我的收藏</a>
            </div>
        </div>
    </div>
</div>
<!-- Footer End -->

</body>
</html>