<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>北護二手書交易網</title>
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
            margin: 80px auto;
        }
        .book-card {
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 10px;
            overflow: hidden;
            transition: 0.2s ease-in-out;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            position: relative
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
        .quick-favorite {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(255, 255, 255, 0.9);
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            transition: all 0.3s;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            z-index: 100;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .quick-favorite:hover {
            transform: scale(1.15);
            background-color: white;
        }
        .quick-favorite.favorited {
            background-color: #ff6b6b;
            color: white;
        }
        .error-message {
            text-align: center;
            padding: 40px;
            color: #d9534f;
            font-size: 16px;
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<br>
<%
    Connection con = null;
    Statement smt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        // 修改 SQL 查詢，明確處理資料類型轉換
        String sql = "SELECT " +
                     "bl.listingId, " +
                     "b.bookId, " +
                     "b.title, " +
                     "b.author, " +
                     "bl.price, " +
                     "b.createdAt, " +
                     "bl.photo, " +
                     "bl.condition, " +
                     "bl.quantity, " +
                     "bl.Approved, " +
                     "bl.isDelisted " +
                     "FROM bookListings bl " +
                     "INNER JOIN books b ON bl.bookId = b.bookId " +
                     "ORDER BY bl.listedAt DESC";
        
        smt = con.createStatement();
        rs = smt.executeQuery(sql);
        
        // 取得使用者的收藏清單
        String currentUserId = (String) session.getAttribute("userId");
        boolean isLoggedIn = (currentUserId != null && !currentUserId.trim().isEmpty());
        Set<String> favoritedBooks = new HashSet<>();
        
        if (isLoggedIn) {
            String favSql = "SELECT bookId FROM favorites WHERE userId = ?";
            PreparedStatement favPstmt = con.prepareStatement(favSql);
            favPstmt.setString(1, currentUserId);
            ResultSet favRs = favPstmt.executeQuery();
            while (favRs.next()) {
                favoritedBooks.add(favRs.getString("bookId"));
            }
            favRs.close();
            favPstmt.close();
        }
%>

<div class="book-grid">
<%
        int cardIndex = 0;
        int displayCount = 0;
        
        while(rs.next()) {
            // 不檢查審核狀態，顯示所有書籍（包含待審核、未通過的）
            
            String listingId = rs.getString("listingId");
            String bookId = rs.getString("bookId");
            String title = rs.getString("title");
            String author = rs.getString("author");
            String price = rs.getString("price");
            Timestamp createdAt = rs.getTimestamp("createdAt");
            String dateStr = (createdAt != null) ? createdAt.toString().split(" ")[0] : "";
            String photoStr = rs.getString("photo");
            
            // 檢查是否已收藏
            boolean isFavorited = favoritedBooks.contains(bookId);
            
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
        <a class="book-link" href="bookDetail.jsp?listingId=<%= listingId %>">
            <button class="quick-favorite <%= isFavorited ? "favorited" : "" %>" 
                    onclick="quickToggleFavorite(event, '<%= bookId %>', this)"
                    title="<%= isFavorited ? "取消收藏" : "加入收藏" %>"
                    data-book-id="<%= bookId %>">
                <%= isFavorited ? "❤️" : "🤍" %>
            </button>
            
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
                <div class="book-author">作者:<%= author != null ? author : "未提供" %></div>
                <div class="book-price">NT$<%= (price != null && !price.trim().isEmpty()) ? (int) Float.parseFloat(price) : 0 %></div>
                <div class="book-date">出版日期:<%= dateStr %></div>
            </div>
        </a>
    </div>
<%
        }
        
        // 如果沒有任何書籍顯示
        if (displayCount == 0) {
%>
    <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #999;">
        <h3>目前沒有可顯示的書籍</h3>
        <p>請稍後再回來查看，或聯繫管理員了解更多資訊。</p>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<div class='error-message'>");
        out.println("<h3>載入書籍資料時發生錯誤</h3>");
        out.println("<p>錯誤訊息: " + e.getMessage() + "</p>");
        out.println("<p>請聯繫系統管理員或稍後再試。</p>");
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

const isLoggedIn = <%= (session.getAttribute("userId") != null && !((String)session.getAttribute("userId")).trim().isEmpty()) %>;

function quickToggleFavorite(event, bookId, button) {
    event.preventDefault();
    event.stopPropagation();
    
    if (!isLoggedIn) {
        if (confirm('您需要先登入才能收藏書籍\n\n是否前往登入頁面？')) {
            window.location.href = 'login.jsp?redirect=' + encodeURIComponent(window.location.href);
        }
        return;
    }
    
    const isFavorited = button.classList.contains('favorited');
    const action = isFavorited ? 'remove' : 'add';
    
    button.disabled = true;
    
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
            button.classList.toggle('favorited');
            button.textContent = button.classList.contains('favorited') ? '❤️' : '🤍';
            button.title = button.classList.contains('favorited') ? '取消收藏' : '加入收藏';
            showQuickToast(button.classList.contains('favorited') ? '已加入收藏' : '已取消收藏', button);
        } else {
            alert('操作失敗: ' + (data.message || '未知錯誤'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('系統錯誤');
    })
    .finally(() => {
        button.disabled = false;
    });
}

function showQuickToast(message, button) {
    const toast = document.createElement('div');
    toast.textContent = message;
    toast.style.cssText = `
        position: absolute;
        top: 50px;
        right: 10px;
        background-color: rgba(0, 0, 0, 0.8);
        color: white;
        padding: 8px 15px;
        border-radius: 20px;
        font-size: 12px;
        z-index: 200;
        pointer-events: none;
        animation: toastFade 2s ease-out;
    `;
    
    button.parentElement.appendChild(toast);
    setTimeout(() => toast.remove(), 2000);
}

const toastStyle = document.createElement('style');
toastStyle.textContent = `
    @keyframes toastFade {
        0% { opacity: 0; transform: translateY(-10px); }
        20% { opacity: 1; transform: translateY(0); }
        80% { opacity: 1; transform: translateY(0); }
        100% { opacity: 0; transform: translateY(-10px); }
    }
`;
document.head.appendChild(toastStyle);
</script>

<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目:國北護二手書交易網</p>
                <p class="mb-2">系所:健康事業管理系</p>
                <p class="mb-2">專題組員:黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
                <a class="btn btn-link" href="informAgainst.jsp" target="_blank" rel="noopener noreferrer">舉報不佳上傳書籍區</a>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">管理員專區</h5>
                <a class="btn btn-link" href="adminLogin.jsp">管理員</a>
                
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書交易網. @All Rights Reserved.</p>
    </div>
</div>

</body>
</html>