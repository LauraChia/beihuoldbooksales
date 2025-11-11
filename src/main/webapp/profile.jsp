<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userAccessId = (String) session.getAttribute("userId");
    String username = "";
    String name = "";
    String email = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "SELECT username, name, email FROM users WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, userAccessId);
        rs = ps.executeQuery();

        if (rs.next()) {
         username = rs.getString("username");
            name = rs.getString("name");
            email = rs.getString("email");

            // ✅ 避免 null 顯示
            if (username == null) username = "";
            if (name == null) name = "";
            if (email == null) email = "";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>個人資料 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .card-section {
            max-width: 1200px;
            margin: 40px auto;
        }
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
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
        /* ✅ 修改：增加 background-color */
        .book-images {
            position: relative;
            width: 100%;
            height: 260px;
            overflow: hidden;
            background-color: #f0f0f0;
        }
        /* ✅ 修改：改用 opacity 淡入淡出效果 */
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
        /* ✅ 新增：active 狀態顯示圖片 */
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
        /* ✅ 新增：圓點指示器 */
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
        /* ✅ 新增：無圖片樣式 */
        .no-image {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp" %>
<div class="container mt-5 pt-5">
        <div class="card p-4 shadow-sm">
   <h4 class="mb-4">個人資料</h4>
             <p>帳號：<%= username %></p>
             <p>使用者名稱：<%=name %></p>
             <p>電子郵件：<%= email %></p>
 
             <a href="editProfile.jsp" class="btn btn-primary">編輯資料</a>
         </div>
     </div>
    
            
    
    <div class="card-section">
        <h4 class="mb-4">我的上架紀錄</h4>

        <%
            Connection con2 = null;
            PreparedStatement ps2 = null;
            ResultSet rs2 = null;

            try {
                con2 = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
                String sql2 = "SELECT bookId, titleBook, author, price, date, photo FROM book WHERE userId = ? ORDER BY date DESC";
                ps2 = con2.prepareStatement(sql2);
                ps2.setString(1, userAccessId);
                rs2 = ps2.executeQuery();

                boolean hasBooks = false;
                int cardIndex = 0; // ✅ 新增：卡片索引
        %>
        <div class="book-grid">
        <%
                while(rs2.next()) {
                    hasBooks = true;
                    String bookId = rs2.getString("bookId");
                    String title = rs2.getString("titleBook") != null ? rs2.getString("titleBook") : "";
                    String author = rs2.getString("author") != null ? rs2.getString("author") : "";
                    String price = rs2.getString("price") != null ? rs2.getString("price") : "0";
                    String date = rs2.getString("date") != null ? rs2.getString("date") : "";
                    String photoStr = rs2.getString("photo");
                    
                    // ✅ 修改：改用 List 處理多張圖片
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
                    
                    int photoCount = photoList.size();
                    String cardId = "profile-card-" + cardIndex; // ✅ 新增：唯一卡片 ID
                    cardIndex++;
        %>
            <a class="book-link" href="bookDetail.jsp?bookId=<%= bookId %>">
                <!-- ✅ 修改：加入 data-card-id 屬性 -->
                <div class="book-card" data-card-id="<%= cardId %>">
                    <!-- ✅ 修改：加入唯一 ID -->
                    <div class="book-images" id="<%= cardId %>">
                        <% if (photoList.isEmpty()) { %>
                            <!-- ✅ 新增：無圖片顯示 -->
                            <div class="no-image">無圖片</div>
                        <% } else { %>
                            <!-- ✅ 修改：動態產生所有圖片 -->
                            <% for (int i = 0; i < photoList.size(); i++) { %>
                                <img src="<%= photoList.get(i) %>" 
                                     alt="書籍圖片<%= (i+1) %>" 
                                     class="book-img <%= (i == 0) ? "active" : "" %>"
                                     onerror="this.src='assets/images/about.png'">
                            <% } %>
                            
                            <!-- ✅ 修改：只在多張圖片時顯示指示器 -->
                            <% if (photoCount > 1) { %>
                                <span class="image-indicator"><span class="current-img">1</span>/<%= photoCount %></span>
                                <!-- ✅ 新增：圓點指示器 -->
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
                        <div class="book-author">作者：<%= author %></div>
                        <div class="book-price">NT$<%= (int)Float.parseFloat(price) %></div>
                        <div class="book-date">上架日期：<%= date.split(" ")[0] %></div>
                    </div>
                </div>
            </a>
        <%
                } // while

                if(!hasBooks) {
        %>
            <p>您還沒有上架任何書籍。</p>
        <%
                }
        %>
        </div>
        <%
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                if(rs2 != null) try { rs2.close(); } catch(Exception e) {}
                if(ps2 != null) try { ps2.close(); } catch(Exception e) {}
                if(con2 != null) try { con2.close(); } catch(Exception e) {}
            }
        %>
    </div>
</div>

<!-- ✅ 新增：圖片輪播 JavaScript -->
<script>
// 自動輪播圖片
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.book-card');
    
    cards.forEach(card => {
        const cardId = card.getAttribute('data-card-id');
        const container = document.getElementById(cardId);
        const images = container.querySelectorAll('.book-img');
        const dots = container.querySelectorAll('.dot');
        const indicator = container.querySelector('.current-img');
        
        if (images.length <= 1) return; // 只有一張圖片不需要輪播
        
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
        
        // 滑鼠移入時開始輪播
        card.addEventListener('mouseenter', function() {
            intervalId = setInterval(nextImage, 800); // 每0.8秒切換
        });
        
        // 滑鼠移出時停止輪播並回到第一張
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
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025 二手書拍賣網. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>