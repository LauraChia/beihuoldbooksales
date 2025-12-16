<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.DecimalFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 檢查管理員登入狀態
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>網站數據統計 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft JhengHei', Arial, sans-serif;
            background: #f5f5f5;
        }
        
        .header {
            background: linear-gradient(135deg, #81c408 0%, #81c408 100%);
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 24px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .logout-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid white;
            padding: 8px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
        }
        
        .logout-btn:hover {
            background: white;
            color: #81c408;
        }
        
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .back-btn {
            display: inline-block;
            background: white;
            color: #81c408;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            margin-bottom: 20px;
            transition: all 0.3s;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-icon {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .chart-section {
            background: white;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .chart-section h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #81c408;
            font-size: 20px;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            margin-top: 20px;
        }
        
        .top-books {
            list-style: none;
            padding: 0;
        }
        
        .top-books li {
            background: #f8f9fa;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            transition: all 0.3s;
        }
        
        .top-books li:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        
        .book-rank {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 15px;
            font-size: 16px;
        }
        
        .book-info {
            flex: 1;
        }
        
        .book-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            font-size: 15px;
        }
        
        .book-meta {
            color: #666;
            font-size: 13px;
        }
        
        .category-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .category-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            border-left: 4px solid #81c408;
            transition: all 0.3s;
        }
        
        .category-item:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        
        .category-item .cat-name {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        .category-item .cat-count {
            color: #81c408;
            font-size: 1.2em;
            font-weight: bold;
        }
        
        .error-message {
            background: white;
            padding: 20px;
            border-radius: 10px;
            color: #d9534f;
            text-align: center;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }
        
        /* 顏色配置 */
        .books-color { color: #2196f3; }
        .listings-color { color: #9c27b0; }
        .available-color { color: #4caf50; }
        .sold-color { color: #ff9800; }
        .users-color { color: #00bcd4; }
        .favorites-color { color: #e91e63; }
        .revenue-color { color: #8bc34a; }
        .price-color { color: #ff5722; }
        .rate-color { color: #81c408; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>📊 網站數據統計</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="adminDashboard.jsp" class="logout-btn">返回後台</a>
                <a href="adminLogin.jsp?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>

<%
    Connection con = null;
    Statement smt = null;
    ResultSet rs = null;
    
    // 統計數據變數
    int totalBooks = 0;
    int totalListings = 0;
    int soldBooks = 0;
    int availableBooks = 0;
    int totalUsers = 0;
    int totalFavorites = 0;
    double totalRevenue = 0;
    double avgPrice = 0;
    double successRate = 0;
    
    // 價格分布
    int price0_100 = 0, price100_300 = 0, price300_500 = 0, price500plus = 0;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        smt = con.createStatement();
        
        // 查詢總書籍數（books 表）
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM books");
        if(rs.next()) totalBooks = rs.getInt("count");
        rs.close();
        
        // 查詢總上架數（bookListings 表）
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE isDelisted = FALSE");
        if(rs.next()) totalListings = rs.getInt("count");
        rs.close();
        
        // 查詢在售書籍數
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE isDelisted = FALSE AND quantity > 0");
        if(rs.next()) availableBooks = rs.getInt("count");
        rs.close();
        
        // 查詢已售出書籍數
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE quantity = 0");
        if(rs.next()) soldBooks = rs.getInt("count");
        rs.close();
        
        // 查詢用戶總數
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM users");
        if(rs.next()) totalUsers = rs.getInt("count");
        rs.close();
        
        // 查詢收藏總數
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM favorites");
        if(rs.next()) totalFavorites = rs.getInt("count");
        rs.close();
        
        // 查詢總交易金額
        rs = smt.executeQuery("SELECT SUM(price) as total FROM bookListings WHERE quantity = 0");
        if(rs.next()) totalRevenue = rs.getDouble("total");
        rs.close();
        
        // 查詢平均書價
        rs = smt.executeQuery("SELECT AVG(price) as avg FROM bookListings WHERE isDelisted = FALSE");
        if(rs.next()) avgPrice = rs.getDouble("avg");
        rs.close();
        
        // 計算成交率
        if(totalListings > 0) {
            successRate = (double)soldBooks / totalListings * 100;
        }
        
        // 查詢價格分布
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE price < 100 AND isDelisted = FALSE");
        if(rs.next()) price0_100 = rs.getInt("count");
        rs.close();
        
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE price >= 100 AND price < 300 AND isDelisted = FALSE");
        if(rs.next()) price100_300 = rs.getInt("count");
        rs.close();
        
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE price >= 300 AND price < 500 AND isDelisted = FALSE");
        if(rs.next()) price300_500 = rs.getInt("count");
        rs.close();
        
        rs = smt.executeQuery("SELECT COUNT(*) as count FROM bookListings WHERE price >= 500 AND isDelisted = FALSE");
        if(rs.next()) price500plus = rs.getInt("count");
        rs.close();
        
    } catch(Exception e) {
        out.println("<div class='error-message'>");
        out.println("<h3>❌ 載入數據時發生錯誤</h3>");
        out.println("<p>錯誤訊息: " + e.getMessage() + "</p>");
        out.println("</div>");
        e.printStackTrace();
    }
    
    DecimalFormat df = new DecimalFormat("#,###");
    DecimalFormat df2 = new DecimalFormat("#,###.0");
%>

    <div class="container">
        <a href="adminDashboard.jsp" class="back-btn">← 返回管理後台</a>
        
        <!-- 核心統計卡片 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon">📚</div>
                <div class="stat-number books-color"><%= df.format(totalBooks) %></div>
                <div class="stat-label">書籍資料庫</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">📋</div>
                <div class="stat-number listings-color"><%= df.format(totalListings) %></div>
                <div class="stat-label">累計上架次數</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">🛒</div>
                <div class="stat-number available-color"><%= df.format(availableBooks) %></div>
                <div class="stat-label">目前在售書籍</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">✅</div>
                <div class="stat-number sold-color"><%= df.format(soldBooks) %></div>
                <div class="stat-label">成功售出</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">🎓</div>
                <div class="stat-number users-color"><%= df.format(totalUsers) %></div>
                <div class="stat-label">註冊學生數</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">❤️</div>
                <div class="stat-number favorites-color"><%= df.format(totalFavorites) %></div>
                <div class="stat-label">總收藏數</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">💰</div>
                <div class="stat-number revenue-color">$<%= df.format(totalRevenue) %></div>
                <div class="stat-label">累計交易金額</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">💵</div>
                <div class="stat-number price-color">$<%= df2.format(avgPrice) %></div>
                <div class="stat-label">平均書籍價格</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">🎯</div>
                <div class="stat-number rate-color"><%= df2.format(successRate) %>%</div>
                <div class="stat-label">書籍成交率</div>
            </div>
        </div>
        
        <!-- 書籍狀態分布圖 -->
        <div class="chart-section">
            <h2>📊 書籍狀態分布</h2>
            <div class="chart-container">
                <canvas id="statusChart"></canvas>
            </div>
        </div>
        
        <!-- 價格分布圖 -->
        <div class="chart-section">
            <h2>💰 書籍價格分布</h2>
            <div class="chart-container">
                <canvas id="priceChart"></canvas>
            </div>
        </div>
        
        <!-- 最受歡迎書籍 TOP 10 -->
        <div class="chart-section">
            <h2>🔥 最受歡迎書籍 TOP 10（依收藏數）</h2>
            <ul class="top-books">
                <%
                    try {
                        String topBooksSql = "SELECT TOP 10 " +
                                            "b.title, " +
                                            "b.author, " +
                                            "bl.price, " +
                                            "COUNT(f.bookId) as favoriteCount " +
                                            "FROM books b " +
                                            "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
                                            "LEFT JOIN favorites f ON b.bookId = f.bookId " +
                                            "WHERE bl.isDelisted = FALSE " +
                                            "GROUP BY b.bookId, b.title, b.author, bl.price " +
                                            "ORDER BY favoriteCount DESC";
                        
                        rs = smt.executeQuery(topBooksSql);
                        int rank = 1;
                        boolean hasData = false;
                        
                        while(rs.next()) {
                            hasData = true;
                            String title = rs.getString("title");
                            String author = rs.getString("author");
                            double price = rs.getDouble("price");
                            int favCount = rs.getInt("favoriteCount");
                %>
                    <li>
                        <div class="book-rank"><%= rank++ %></div>
                        <div class="book-info">
                            <div class="book-title"><%= title %></div>
                            <div class="book-meta">
                                作者: <%= author != null ? author : "未提供" %> | 
                                收藏數: <%= favCount %> 次 | 
                                售價: $<%= df.format(price) %>
                            </div>
                        </div>
                    </li>
                <%
                        }
                        
                        if(!hasData) {
                %>
                    <li>
                        <div class="empty-state">
                            <div style="font-size: 48px;">📚</div>
                            <p>目前沒有資料</p>
                        </div>
                    </li>
                <%
                        }
                        
                        rs.close();
                    } catch(Exception e) {
                        out.println("<li style='text-align:center; padding:20px; color:#d9534f;'>載入資料時發生錯誤: " + e.getMessage() + "</li>");
                    }
                %>
            </ul>
        </div>
        
        <!-- 書籍狀況分布 -->
        <div class="chart-section">
            <h2>📖 書籍狀況分布</h2>
            <div class="category-list">
                <%
                    try {
                        String conditionSql = "SELECT condition, COUNT(*) as count " +
                                             "FROM bookListings " +
                                             "WHERE isDelisted = FALSE " +
                                             "GROUP BY condition " +
                                             "ORDER BY count DESC";
                        
                        rs = smt.executeQuery(conditionSql);
                        boolean hasConditions = false;
                        
                        while(rs.next()) {
                            hasConditions = true;
                            String condition = rs.getString("condition");
                            int count = rs.getInt("count");
                %>
                    <div class="category-item">
                        <div class="cat-name"><%= condition != null && !condition.isEmpty() ? condition : "未分類" %></div>
                        <div class="cat-count"><%= count %> 本</div>
                    </div>
                <%
                        }
                        
                        if(!hasConditions) {
                            out.println("<div class='empty-state'>目前沒有資料</div>");
                        }
                        
                        rs.close();
                    } catch(Exception e) {
                        out.println("<p style='color:#d9534f;'>載入狀況統計時發生錯誤</p>");
                    }
                %>
            </div>
        </div>
    </div>

<script>
    // 書籍狀態分布圖
    const statusCtx = document.getElementById('statusChart').getContext('2d');
    new Chart(statusCtx, {
        type: 'doughnut',
        data: {
            labels: ['在售中', '已售出'],
            datasets: [{
                data: [<%= availableBooks %>, <%= soldBooks %>],
                backgroundColor: ['#4caf50', '#ff9800'],
                borderWidth: 2,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        font: { size: 14 },
                        padding: 20
                    }
                }
            }
        }
    });
    
    // 價格分布圖
    const priceCtx = document.getElementById('priceChart').getContext('2d');
    new Chart(priceCtx, {
        type: 'bar',
        data: {
            labels: ['0-99元', '100-299元', '300-499元', '500元以上'],
            datasets: [{
                label: '書籍數量',
                data: [<%= price0_100 %>, <%= price100_300 %>, <%= price300_500 %>, <%= price500plus %>],
                backgroundColor: '#81c408',
                borderColor: '#6ba006',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1 }
                }
            }
        }
    });
</script>

<%
    // 關閉資料庫連接
    try {
        if(rs != null) rs.close();
        if(smt != null) smt.close();
        if(con != null) con.close();
    } catch(SQLException e) {
        e.printStackTrace();
    }
%>

</body>
</html>