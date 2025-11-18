<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // ✅ 修正：統一使用 "userId"
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userAccessId = (String) session.getAttribute("userId");
    String username = "";
    String name = "";
    String department = "";
    String lastLogin = "";
    String lastLogout = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "SELECT username, name, department, lastLogin, lastLogout FROM users WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, userAccessId);
        rs = ps.executeQuery();

        if (rs.next()) {
            username = rs.getString("username");
            name = rs.getString("name");
            department = rs.getString("department");
            
            // ✅ 修正：正確取得 lastLogin 和 lastLogout
            Timestamp loginTimestamp = rs.getTimestamp("lastLogin");
            Timestamp logoutTimestamp = rs.getTimestamp("lastLogout");
            
            // 格式化時間顯示
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            lastLogin = (loginTimestamp != null) ? sdf.format(loginTimestamp) : "尚未登入";
            lastLogout = (logoutTimestamp != null) ? sdf.format(logoutTimestamp) : "尚未登出";

            // ✅ 避免 null 顯示
            if (username == null) username = "";
            if (name == null) name = "";
            if (department == null) department = "";
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
    </style>
</head>
<body>
    <%@ include file="menu.jsp" %>
    
    <div class="container mt-5 pt-5">
        <div class="card p-4 shadow-sm">
            <h4 class="mb-4">個人資料</h4>
            <p><strong>帳號：</strong><%= username %></p>
            <p><strong>暱稱：</strong><%= name %></p>
            <p><strong>就讀系所：</strong><%= department %></p>
            <p><strong>上次登入：</strong><%= lastLogin %></p>
            <p><strong>上次登出：</strong><%= lastLogout %></p>
            
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
                int cardIndex = 0;
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
                    String cardId = "profile-card-" + cardIndex;
                    cardIndex++;
        %>
            <a class="book-link" href="bookDetail.jsp?bookId=<%= bookId %>">
                <div class="book-card" data-card-id="<%= cardId %>">
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
                        <div class="book-author">作者：<%= author %></div>
                        <div class="book-price">NT$<%= (int)Float.parseFloat(price) %></div>
                        <div class="book-date">上架日期：<%= date.split(" ")[0] %></div>
                    </div>
                </div>
            </a>
        <%
                }

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

<!-- 圖片輪播 JavaScript -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.book-card');
    
    cards.forEach(card => {
        const cardId = card.getAttribute('data-card-id');
        const container = document.getElementById(cardId);
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