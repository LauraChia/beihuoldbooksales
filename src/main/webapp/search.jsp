<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">

<head>
    <meta charset="utf-8">
    <title>搜尋結果 - 二手書交易網</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet">

    <!-- Stylesheets -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }

        /* 頁面標題區塊 - 綠色漸層 */
        .page-header {
            background: linear-gradient(135deg, #66bb6a 0%, #66bb6a 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 0;
            box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
        }
        
        .page-header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 600;
        }

        .page-header .search-title {
            font-size: 18px;
            margin-top: 10px;
            opacity: 0.95;
        }

        /* 搜尋資訊框 - 綠色系 */
        .search-info-container {
            background: white;
            margin: 30px auto;
            max-width: 1200px;
            padding: 0;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .search-info {
            background: #e8f5e9;
            border-left: 4px solid #66bb6a;
            padding: 20px 30px;
            color: #2e7d32;
            font-size: 15px;
        }
        
        .search-info strong {
            color: #1b5e20;
            font-weight: 600;
        }

        .search-info small {
            display: block;
            margin-top: 8px;
            color: #558b2f;
        }

        /* 書籍網格容器 */
        .book-grid-wrapper {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px 40px 60px;
        }

        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
        }

        /* 書籍卡片 - 加入綠色系 hover 效果 */
        .book-card {
            background-color: white;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        .book-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 24px rgba(102, 187, 106, 0.25);
            border-color: #81c784;
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
            background-color: #f5f5f5;
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
            padding: 15px 16px;
        }
        
        .book-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            height: 40px;
            overflow: hidden;
            line-height: 20px;
        }
        
        .book-author {
            color: #666;
            font-size: 14px;
            margin-bottom: 8px;
        }
        
        .book-price {
            color: #66bb6a;
            font-weight: bold;
            font-size: 18px;
            margin-bottom: 6px;
        }
        
        .book-date {
            font-size: 13px;
            color: #999;
        }

        /* 圖片指示器 - 綠色系 */
        .image-indicator {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background-color: rgba(102, 187, 106, 0.9);
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            z-index: 10;
        }
        
        .image-dots {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 6px;
            z-index: 10;
        }
        
        .dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: rgba(255,255,255,0.5);
            transition: all 0.3s;
        }
        
        .dot.active {
            background-color: white;
            transform: scale(1.2);
        }
        
        .no-image {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #bbb;
            font-size: 14px;
        }

        /* 無結果顯示 - 綠色系 */
        .no-results {
            text-align: center;
            padding: 80px 20px;
            margin: 60px auto;
            max-width: 600px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }
        
        .no-results i {
            font-size: 80px;
            color: #c8e6c9;
            margin-bottom: 20px;
        }
        
        .no-results h4 {
            color: #555;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .no-results p {
            color: #999;
            font-size: 15px;
            margin-bottom: 25px;
        }

        .no-results .btn {
            background: white;
            border: 2px solid #66bb6a;
            color: #66bb6a;
            padding: 12px 32px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .no-results .btn:hover {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 187, 106, 0.4);
        }

        /* 響應式設計 */
        @media (max-width: 768px) {
            .page-header h1 {
                font-size: 24px;
            }
            
            .page-header .search-title {
                font-size: 16px;
            }

            .book-grid-wrapper {
                padding: 20px 20px 40px;
            }

            .book-grid {
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                gap: 15px;
            }

            .search-info {
                padding: 15px 20px;
                font-size: 14px;
            }
        }
      .no-results .btn {
    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
    border: none;
    color: #333;
    padding: 12px 32px;
    border-radius: 8px;
    font-weight: 500;
    transition: all 0.3s;
    text-decoration: none;
    display: inline-block;
    box-shadow: 0 2px 8px rgba(102, 187, 106, 0.3);
}

.no-results .btn:hover {
    background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
    color: #333;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(102, 187, 106, 0.5);
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
    if("title".equals(type)) typeDisplay = "書名";
    else if("author".equals(type)) typeDisplay = "作者";
    else if("department".equals(type)) typeDisplay = "系所";
    else if("teacher".equals(type)) typeDisplay = "授課老師";
    else if("course".equals(type)) typeDisplay = "使用課程";

    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");

    // 將搜尋關鍵字拆分成多個字詞（支援空格分隔）
    List<String> keywords = new ArrayList<>();
    if(query != null && !query.trim().isEmpty()) {
        String[] parts = query.trim().split("\\s+");
        for(String part : parts) {
            if(!part.isEmpty()) {
                keywords.add(part);
            }
        }
    }

    // 系所簡稱對應表
    Map<String, String[]> deptMap = new HashMap<>();
    deptMap.put("護理", new String[]{"護理"});
    deptMap.put("護理系", new String[]{"護理"});
    deptMap.put("護理學系", new String[]{"護理"});
    deptMap.put("助產", new String[]{"助產"});
    deptMap.put("助產系", new String[]{"助產"});
    deptMap.put("醫護", new String[]{"醫護教育"});
    deptMap.put("醫護系", new String[]{"醫護教育"});
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
    deptMap.put("人工智慧", new String[]{"人工智慧"});
    deptMap.put("AI", new String[]{"人工智慧"});
    deptMap.put("大數據", new String[]{"大數據"});
    deptMap.put("通識", new String[]{"通識教育"});

    // 根據搜尋類型決定是否需要 JOIN courses 表
    boolean needCourseJoin = "department".equals(type) || "teacher".equals(type) || "course".equals(type);
    
    StringBuilder sql = new StringBuilder();
    List<String> paramList = new ArrayList<>();
    
    if (needCourseJoin) {
        sql.append("SELECT DISTINCT b.bookId, b.title, b.author, bl.listingId, bl.price, bl.photo, bl.listedAt ");
        sql.append("FROM books b ");
        sql.append("INNER JOIN bookListings bl ON b.bookId = bl.bookId ");
        sql.append("INNER JOIN book_course_relations bcr ON b.bookId = bcr.bookId ");
        sql.append("INNER JOIN courses c ON bcr.courseId = c.courseId ");
        sql.append("WHERE bl.isDelisted = false");
    } else {
        sql.append("SELECT b.bookId, b.title, b.author, bl.listingId, bl.price, bl.photo, bl.listedAt ");
        sql.append("FROM books b ");
        sql.append("INNER JOIN bookListings bl ON b.bookId = bl.bookId ");
        sql.append("WHERE bl.isDelisted = false");
    }
    
    // 建立 WHERE 條件
    if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) {
        if("department".equals(type)) {
            // 處理系所簡稱
            List<String> searchTerms = new ArrayList<>();
            if(deptMap.containsKey(query)) {
                searchTerms.addAll(Arrays.asList(deptMap.get(query)));
            } else {
                searchTerms.addAll(keywords);
            }
            
            if(!searchTerms.isEmpty()) {
                sql.append(" AND (");
                for(int i = 0; i < searchTerms.size(); i++) {
                    if(i > 0) sql.append(" OR ");
                    sql.append("LOWER(c.department) LIKE ?");
                    paramList.add("%" + searchTerms.get(i).toLowerCase() + "%");
                }
                sql.append(")");
            }
        } else if("teacher".equals(type)) {
            if(!keywords.isEmpty()) {
                sql.append(" AND (");
                for(int i = 0; i < keywords.size(); i++) {
                    if(i > 0) sql.append(" OR ");
                    sql.append("LOWER(c.teacher) LIKE ?");
                    paramList.add("%" + keywords.get(i).toLowerCase() + "%");
                }
                sql.append(")");
            }
        } else if("course".equals(type)) {
            if(!keywords.isEmpty()) {
                sql.append(" AND (");
                for(int i = 0; i < keywords.size(); i++) {
                    if(i > 0) sql.append(" OR ");
                    sql.append("LOWER(c.courseName) LIKE ?");
                    paramList.add("%" + keywords.get(i).toLowerCase() + "%");
                }
                sql.append(")");
            }
        } else if("title".equals(type)) {
            // 書名搜尋：使用完整查詢字串，不分割
            if(query != null && !query.trim().isEmpty()) {
                sql.append(" AND LOWER(b.title) LIKE ?");
                paramList.add("%" + query.trim().toLowerCase() + "%");
            }
        } else if("author".equals(type)) {
            // 作者搜尋：使用完整查詢字串,不分割
            if(query != null && !query.trim().isEmpty()) {
                sql.append(" AND LOWER(b.author) LIKE ?");
                paramList.add("%" + query.trim().toLowerCase() + "%");
            }
        }
    }
    
    sql.append(" ORDER BY bl.listedAt DESC");

    out.println("<!-- Debug SQL: " + sql.toString() + " -->");
    out.println("<!-- Param Count: " + paramList.size() + " -->");
    
    // 使用 PreparedStatement 防止 SQL 注入
    PreparedStatement pstmt = con.prepareStatement(sql.toString());
    
    // 設定參數
    for(int i = 0; i < paramList.size(); i++) {
        pstmt.setString(i + 1, paramList.get(i));
    }
    
    ResultSet rs = pstmt.executeQuery();

    // 計算結果數量
    int resultCount = 0;
    List<Map<String, Object>> resultList = new ArrayList<>();
    
    while(rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("bookId", rs.getString("bookId"));
        row.put("listingId", rs.getString("listingId"));
        row.put("title", rs.getString("title"));
        row.put("author", rs.getString("author"));
        row.put("price", rs.getString("price"));
        row.put("listedAt", rs.getString("listedAt"));
        row.put("photo", rs.getString("photo"));
        resultList.add(row);
        resultCount++;
    }
    
    rs.close();
    pstmt.close();
%>

<!-- 頁面標題 -->
<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-search"></i> 搜尋結果</h1>
        <% if(query != null && !query.trim().isEmpty()) { %>
        <div class="search-title">
            搜尋「<%= typeDisplay %>」：「<%= query %>」
        </div>
        <% } %>
    </div>
</div>

<!-- 搜尋資訊顯示 -->
<% if(query != null && !query.trim().isEmpty()) { %>
<div class="search-info-container">
    <div class="search-info">
        <i class="fas fa-info-circle"></i>
        搜尋「<strong><%= typeDisplay %></strong>」包含「<strong><%= query %></strong>」
        - 找到 <strong><%= resultCount %></strong> 筆結果
        <% if(keywords.size() > 1) { %>
            <small>搜尋關鍵字：<%= String.join("、", keywords.subList(0, Math.min(5, keywords.size()))) %><%= keywords.size() > 5 ? "..." : "" %></small>
        <% } %>
    </div>
</div>
<% } %>

<% if(resultCount == 0) { %>
    <!-- 無結果顯示 -->
    <div class="book-grid-wrapper">
        <div class="no-results">
    <i class="fas fa-search"></i>
    <h4>找不到相符的書籍</h4>
    <p>請嘗試使用其他關鍵字或搜尋條件</p>
    <a href="index.jsp" class="btn">
        返回首頁
    </a>
</div>
    </div>
<% } else { %>
    <!-- 有結果時顯示書籍列表 -->
    <div class="book-grid-wrapper">
        <div class="book-grid">
        <%
            int cardIndex = 0;
            for(Map<String, Object> row : resultList) {
                String bookId = (String) row.get("bookId");
                String listingId = (String) row.get("listingId");
                String title = (String) row.get("title");
                String author = (String) row.get("author");
                String price = (String) row.get("price");
                String listedAt = (String) row.get("listedAt");
                String photoStr = (String) row.get("photo");
                
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
        %>
            <a class="book-link" href="bookDetail.jsp?listingId=<%= listingId %>">
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
                        <div class="book-price">NT$ <%= (int) Float.parseFloat(price) %></div>
                        <div class="book-date"><i class="far fa-calendar-alt"></i> <%= listedAt != null ? listedAt.split(" ")[0] : "" %></div>
                    </div>
                </div>
            </a>
        <%
            }
        %>
        </div>
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

<!-- Footer -->
<%@ include file="footer.jsp"%>

</body>
</html>