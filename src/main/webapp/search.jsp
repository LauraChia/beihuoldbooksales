<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">

<head>
    <meta charset="utf-8">
    <title>二手書交易網 - 搜尋結果</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet">

    <!-- Stylesheets -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">

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
            margin: 100px auto 60px;
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
        .no-results {
            text-align: center;
            padding: 80px 20px;
            margin: 150px auto 100px;
            max-width: 600px;
        }
        .no-results i {
            font-size: 80px;
            color: #ccc;
            margin-bottom: 20px;
        }
        .no-results h4 {
            color: #666;
            margin-bottom: 15px;
        }
        .no-results p {
            color: #999;
            font-size: 14px;
        }
        .search-info {
            background-color: white;
            padding: 15px 25px;
            border-radius: 8px;
            margin: 120px auto 20px;
            max-width: 1200px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .search-info strong {
            color: #d9534f;
        }
    </style>
</head>

<body>
    <%@ include file="menu.jsp" %>

<%
    // 取得搜尋參數
    String type = request.getParameter("type");
    String query = request.getParameter("query");

    // 搜尋類型的中文顯示
    String typeDisplay = "";
    if("titleBook".equals(type)) typeDisplay = "書名";
    else if("author".equals(type)) typeDisplay = "作者";
    else if("department".equals(type)) typeDisplay = "系所";

    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt = con.createStatement();

    String sql = "SELECT * FROM book";
    if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) {
        // 如果是搜尋系所，加入簡稱對應
        if("department".equals(type)) {
            // 建立系所簡稱對應表
            Map<String, String[]> deptMap = new HashMap<>();
            
            // 護理學院
            deptMap.put("護理", new String[]{"護理"});
            deptMap.put("護理系", new String[]{"護理"});
            deptMap.put("護理學系", new String[]{"護理"});
            deptMap.put("助產", new String[]{"助產"});
            deptMap.put("助產系", new String[]{"助產"});
            deptMap.put("醫護", new String[]{"醫護教育"});
            deptMap.put("醫護系", new String[]{"醫護教育"});
            
            // 健康科技學院
            deptMap.put("資管", new String[]{"資訊管理"});
            deptMap.put("資管系", new String[]{"資訊管理"});
            deptMap.put("資訊管理系", new String[]{"資訊管理"});
            deptMap.put("健管", new String[]{"健康事業管理"});
            deptMap.put("健管系", new String[]{"健康事業管理"});
            deptMap.put("健康事業管理系", new String[]{"健康事業管理"});
            deptMap.put("長照", new String[]{"長期照護"});
            deptMap.put("長照系", new String[]{"長期照護"});
            deptMap.put("長期照護系", new String[]{"長期照護"});
            deptMap.put("休閒", new String[]{"休閒產業"});
            deptMap.put("休閒系", new String[]{"休閒產業"});
            deptMap.put("語聽", new String[]{"語言治療", "聽力"});
            deptMap.put("語聽系", new String[]{"語言治療", "聽力"});
            
            // 人類發展與健康學院
            deptMap.put("嬰幼", new String[]{"嬰幼兒保育"});
            deptMap.put("嬰幼系", new String[]{"嬰幼兒保育"});
            deptMap.put("嬰幼兒保育系", new String[]{"嬰幼兒保育"});
            deptMap.put("幼保", new String[]{"嬰幼兒保育"});
            deptMap.put("幼保系", new String[]{"嬰幼兒保育"});
            deptMap.put("運保", new String[]{"運動保健"});
            deptMap.put("運保系", new String[]{"運動保健"});
            deptMap.put("運動保健系", new String[]{"運動保健"});
            deptMap.put("生死", new String[]{"生死與健康心理諮商"});
            deptMap.put("生死系", new String[]{"生死與健康心理諮商"});
            
            // 智慧健康照護跨領域學院
            deptMap.put("人工智慧", new String[]{"人工智慧"});
            deptMap.put("AI", new String[]{"人工智慧"});
            deptMap.put("大數據", new String[]{"大數據"});
            
            // 通識教育中心
            deptMap.put("通識", new String[]{"通識教育"});
            
            // 檢查是否為簡稱
            if(deptMap.containsKey(query)) {
                String[] keywords = deptMap.get(query);
                sql += " WHERE (";
                for(int i = 0; i < keywords.length; i++) {
                    if(i > 0) sql += " OR ";
                    sql += type + " LIKE '%" + keywords[i] + "%'";
                }
                sql += ")";
            } else {
                // 不是簡稱，使用原本的模糊搜尋
                sql += " WHERE " + type + " LIKE '%" + query + "%'";
            }
        } else {
            sql += " WHERE " + type + " LIKE '%" + query + "%'";
        }
    }
    sql += " ORDER BY createdAt DESC";

    ResultSet rs = smt.executeQuery(sql);

    // 計算結果數量
    int resultCount = 0;
    if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) {
        String sqlCount = "";
        
        // 如果是搜尋系所，使用相同的簡稱邏輯
        if("department".equals(type)) {
            Map<String, String[]> deptMap = new HashMap<>();
            // 護理學院
            deptMap.put("護理", new String[]{"護理"});
            deptMap.put("助產", new String[]{"助產"});
            deptMap.put("醫護", new String[]{"醫護教育"});
            
            // 健康科技學院
            deptMap.put("資管", new String[]{"資訊管理"});
            deptMap.put("健管", new String[]{"健康事業管理"});
            deptMap.put("長照", new String[]{"長期照護"});
            deptMap.put("休閒", new String[]{"休閒產業"});
            deptMap.put("語聽", new String[]{"語言治療", "聽力"});
            
            // 人類發展與健康學院
            deptMap.put("嬰幼", new String[]{"嬰幼兒保育"});
            deptMap.put("幼保", new String[]{"嬰幼兒保育"});
            deptMap.put("幼保系", new String[]{"嬰幼兒保育"});
            deptMap.put("運保", new String[]{"運動保健"});
            deptMap.put("生死", new String[]{"生死與健康心理諮商"});
            
            // 智慧健康照護跨領域學院
            deptMap.put("人工智慧", new String[]{"人工智慧"});
            deptMap.put("AI", new String[]{"人工智慧"});
            deptMap.put("大數據", new String[]{"大數據"});
            
            // 通識教育中心
            deptMap.put("通識", new String[]{"通識教育"});
            
            if(deptMap.containsKey(query)) {
                String[] keywords = deptMap.get(query);
                sqlCount = "SELECT COUNT(*) AS cnt FROM book WHERE (";
                for(int i = 0; i < keywords.length; i++) {
                    if(i > 0) sqlCount += " OR ";
                    sqlCount += type + " LIKE ?";
                }
                sqlCount += ")";
                
                PreparedStatement psCount = con.prepareStatement(sqlCount);
                for(int i = 0; i < keywords.length; i++) {
                    psCount.setString(i + 1, "%" + keywords[i] + "%");
                }
                ResultSet rsCount = psCount.executeQuery();
                if(rsCount.next()) {
                    resultCount = rsCount.getInt("cnt");
                }
                rsCount.close();
                psCount.close();
            } else {
                sqlCount = "SELECT COUNT(*) AS cnt FROM book WHERE " + type + " LIKE ?";
                PreparedStatement psCount = con.prepareStatement(sqlCount);
                psCount.setString(1, "%" + query + "%");
                ResultSet rsCount = psCount.executeQuery();
                if(rsCount.next()) {
                    resultCount = rsCount.getInt("cnt");
                }
                rsCount.close();
                psCount.close();
            }
        } else {
            sqlCount = "SELECT COUNT(*) AS cnt FROM book WHERE " + type + " LIKE ?";
            PreparedStatement psCount = con.prepareStatement(sqlCount);
            psCount.setString(1, "%" + query + "%");
            ResultSet rsCount = psCount.executeQuery();
            if(rsCount.next()) {
                resultCount = rsCount.getInt("cnt");
            }
            rsCount.close();
            psCount.close();
        }
    } else {
        String sqlCount = "SELECT COUNT(*) AS cnt FROM book";
        PreparedStatement psCount = con.prepareStatement(sqlCount);
        ResultSet rsCount = psCount.executeQuery();
        if(rsCount.next()) {
            resultCount = rsCount.getInt("cnt");
        }
        rsCount.close();
        psCount.close();
    }
%>

<!-- 搜尋資訊顯示 -->
<% if(query != null && !query.trim().isEmpty()) { %>
<div class="search-info">
    搜尋「<strong><%= typeDisplay %></strong>」包含「<strong><%= query %></strong>」
    - 找到 <strong><%= resultCount %></strong> 筆結果
</div>
<% } %>

<% if(resultCount == 0) { %>
    <!-- 無結果顯示 -->
    <div class="no-results">
        <i class="fas fa-search"></i>
        <h4>找不到相符的書籍</h4>
        <p>請嘗試使用其他關鍵字或搜尋條件</p>
        <a href="index.jsp" class="btn btn-primary mt-3">
            <i class="fas fa-home me-2"></i>返回首頁
        </a>
    </div>
<% } else { %>
    <!-- 有結果時顯示書籍列表 -->
    <div class="book-grid">
    <%
        int cardIndex = 0;
        while(rs.next()) {
            String bookId = rs.getString("bookId");
            String title = rs.getString("titleBook");
            String author = rs.getString("author");
            String price = rs.getString("price");
            String date = rs.getString("date");
            String photoStr = rs.getString("photo");
            
            // 分割圖片路徑 - 支援多張圖片
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
            String cardId = "card-" + cardIndex;
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
                    <div class="book-price">NT$<%= (int) Float.parseFloat(price) %></div>
                    <div class="book-date">出版日期：<%= date != null ? date.split(" ")[0] : "" %></div>
                </div>
            </div>
        </a>
    <%
        }
    %>
    </div>
<% } %>

<%
    con.close();
%>

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
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書拍賣網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

</body>
</html>