<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.DecimalFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>統計數據 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .stats-container {
            max-width: 1400px;
            margin: 100px auto 50px;
            padding: 20px;
        }
        .page-header {
            text-align: center;
            margin-bottom: 50px;
            color: #333;
        }
        .page-header h1 {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .page-header p {
            color: #666;
            font-size: 16px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            text-align: center;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .stat-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        .stat-value {
            font-size: 42px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .stat-label {
            font-size: 16px;
            color: #7f8c8d;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .chart-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .chart-title {
            font-size: 22px;
            font-weight: bold;
            color: #333;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 3px solid #3498db;
        }
        .table-container {
            overflow-x: auto;
        }
        .stats-table {
            width: 100%;
            border-collapse: collapse;
        }
        .stats-table th {
            background-color: #3498db;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        .stats-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #ecf0f1;
        }
        .stats-table tr:hover {
            background-color: #f8f9fa;
        }
        .rank-badge {
            display: inline-block;
            width: 30px;
            height: 30px;
            line-height: 30px;
            border-radius: 50%;
            background-color: #3498db;
            color: white;
            font-weight: bold;
            text-align: center;
        }
        .rank-badge.gold {
            background: linear-gradient(135deg, #FFD700, #FFA500);
        }
        .rank-badge.silver {
            background: linear-gradient(135deg, #C0C0C0, #808080);
        }
        .rank-badge.bronze {
            background: linear-gradient(135deg, #CD7F32, #8B4513);
        }
        .error-message {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        .loading {
            text-align: center;
            padding: 50px;
            color: #666;
        }
        .price-range {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        .price-range:last-child {
            border-bottom: none;
        }
        .price-label {
            font-weight: 600;
            color: #555;
        }
        .price-bar {
            flex: 1;
            margin: 0 20px;
            height: 25px;
            background-color: #ecf0f1;
            border-radius: 12px;
            overflow: hidden;
            position: relative;
        }
        .price-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #3498db, #2ecc71);
            transition: width 0.8s ease;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-right: 10px;
            color: white;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<div class="stats-container">
    <div class="page-header">
        <h1>📊 系統統計數據</h1>
        <p>北護二手書交易網的即時數據分析</p>
    </div>

<%
    Connection con = null;
    Statement smt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        smt = con.createStatement();
        
        // 統計總書籍數
        rs = smt.executeQuery("SELECT COUNT(*) as total FROM books");
        int totalBooks = 0;
        if(rs.next()) totalBooks = rs.getInt("total");
        rs.close();
        
        // 統計總刊登數
        rs = smt.executeQuery("SELECT COUNT(*) as total FROM bookListings");
        int totalListings = 0;
        if(rs.next()) totalListings = rs.getInt("total");
        rs.close();
        
        // 統計總會員數
        rs = smt.executeQuery("SELECT COUNT(*) as total FROM members");
        int totalMembers = 0;
        if(rs.next()) totalMembers = rs.getInt("total");
        rs.close();
        
        // 統計待審核書籍
        rs = smt.executeQuery("SELECT COUNT(*) as total FROM bookListings WHERE Approved = 'Pending'");
        int pendingBooks = 0;
        if(rs.next()) pendingBooks = rs.getInt("total");
        rs.close();
        
        // 統計總交易次數（假設有交易表）
        int totalTransactions = 0;
        try {
            rs = smt.executeQuery("SELECT COUNT(*) as total FROM transactions");
            if(rs.next()) totalTransactions = rs.getInt("total");
            rs.close();
        } catch(Exception e) {
            // 如果沒有交易表則忽略
        }
        
        // 統計平均價格
        rs = smt.executeQuery("SELECT AVG(CDBL(price)) as avgPrice FROM bookListings WHERE price IS NOT NULL AND price <> ''");
        double avgPrice = 0;
        if(rs.next()) avgPrice = rs.getDouble("avgPrice");
        rs.close();
        
        DecimalFormat df = new DecimalFormat("#,##0");
        DecimalFormat dfPrice = new DecimalFormat("#,##0.00");
%>

    <!-- 核心統計卡片 -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">📚</div>
            <div class="stat-value"><%= df.format(totalBooks) %></div>
            <div class="stat-label">總書籍數</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon">📝</div>
            <div class="stat-value"><%= df.format(totalListings) %></div>
            <div class="stat-label">總刊登數</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon">👥</div>
            <div class="stat-value"><%= df.format(totalMembers) %></div>
            <div class="stat-label">註冊會員數</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon">⏳</div>
            <div class="stat-value"><%= df.format(pendingBooks) %></div>
            <div class="stat-label">待審核書籍</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-value">NT$<%= dfPrice.format(avgPrice) %></div>
            <div class="stat-label">平均售價</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon">🔄</div>
            <div class="stat-value"><%= df.format(totalTransactions) %></div>
            <div class="stat-label">總交易次數</div>
        </div>
    </div>

    <!-- 最熱門書籍 TOP 10 -->
    <div class="chart-section">
        <h3 class="chart-title">🔥 最熱門書籍 TOP 10</h3>
        <div class="table-container">
            <table class="stats-table">
                <thead>
                    <tr>
                        <th style="width: 60px;">排名</th>
                        <th>書名</th>
                        <th>作者</th>
                        <th style="width: 120px;">刊登次數</th>
                    </tr>
                </thead>
                <tbody>
<%
        rs = smt.executeQuery(
            "SELECT TOP 10 b.title, b.author, COUNT(*) as listingCount " +
            "FROM books b " +
            "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
            "GROUP BY b.title, b.author " +
            "ORDER BY COUNT(*) DESC"
        );
        
        int rank = 1;
        while(rs.next()) {
            String rankClass = "";
            if(rank == 1) rankClass = "gold";
            else if(rank == 2) rankClass = "silver";
            else if(rank == 3) rankClass = "bronze";
%>
                    <tr>
                        <td><span class="rank-badge <%= rankClass %>"><%= rank %></span></td>
                        <td><%= rs.getString("title") %></td>
                        <td><%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></td>
                        <td><strong><%= rs.getInt("listingCount") %></strong> 次</td>
                    </tr>
<%
            rank++;
        }
        rs.close();
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 價格分佈統計 -->
    <div class="chart-section">
        <h3 class="chart-title">💵 書籍價格分佈</h3>
<%
        // 價格區間統計
        Map<String, Integer> priceRanges = new LinkedHashMap<>();
        priceRanges.put("0-100元", 0);
        priceRanges.put("101-200元", 0);
        priceRanges.put("201-300元", 0);
        priceRanges.put("301-500元", 0);
        priceRanges.put("500元以上", 0);
        
        rs = smt.executeQuery("SELECT price FROM bookListings WHERE price IS NOT NULL AND price <> ''");
        int totalPriceCount = 0;
        
        while(rs.next()) {
            try {
                double price = Double.parseDouble(rs.getString("price"));
                totalPriceCount++;
                
                if(price <= 100) priceRanges.put("0-100元", priceRanges.get("0-100元") + 1);
                else if(price <= 200) priceRanges.put("101-200元", priceRanges.get("101-200元") + 1);
                else if(price <= 300) priceRanges.put("201-300元", priceRanges.get("201-300元") + 1);
                else if(price <= 500) priceRanges.put("301-500元", priceRanges.get("301-500元") + 1);
                else priceRanges.put("500元以上", priceRanges.get("500元以上") + 1);
            } catch(Exception e) {
                // 忽略無效價格
            }
        }
        rs.close();
        
        for(Map.Entry<String, Integer> entry : priceRanges.entrySet()) {
            int count = entry.getValue();
            double percentage = totalPriceCount > 0 ? (count * 100.0 / totalPriceCount) : 0;
%>
        <div class="price-range">
            <div class="price-label"><%= entry.getKey() %></div>
            <div class="price-bar">
                <div class="price-bar-fill" style="width: <%= percentage %>%">
                    <%= count %> 本
                </div>
            </div>
            <div style="width: 80px; text-align: right; color: #7f8c8d;">
                <%= String.format("%.1f%%", percentage) %>
            </div>
        </div>
<%
        }
%>
    </div>

    <!-- 最活躍賣家 TOP 10 -->
    <div class="chart-section">
        <h3 class="chart-title">👤 最活躍賣家 TOP 10</h3>
        <div class="table-container">
            <table class="stats-table">
                <thead>
                    <tr>
                        <th style="width: 60px;">排名</th>
                        <th>會員 ID</th>
                        <th>姓名</th>
                        <th style="width: 120px;">刊登數量</th>
                    </tr>
                </thead>
                <tbody>
<%
        rs = smt.executeQuery(
            "SELECT TOP 10 m.userId, m.name, COUNT(*) as listingCount " +
            "FROM members m " +
            "INNER JOIN bookListings bl ON m.userId = bl.userId " +
            "GROUP BY m.userId, m.name " +
            "ORDER BY COUNT(*) DESC"
        );
        
        rank = 1;
        while(rs.next()) {
            String rankClass = "";
            if(rank == 1) rankClass = "gold";
            else if(rank == 2) rankClass = "silver";
            else if(rank == 3) rankClass = "bronze";
%>
                    <tr>
                        <td><span class="rank-badge <%= rankClass %>"><%= rank %></span></td>
                        <td><%= rs.getString("userId") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><strong><%= rs.getInt("listingCount") %></strong> 本</td>
                    </tr>
<%
            rank++;
        }
        rs.close();
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 書籍狀態統計 -->
    <div class="chart-section">
        <h3 class="chart-title">📋 書籍審核狀態統計</h3>
        <div class="table-container">
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>狀態</th>
                        <th>數量</th>
                        <th>百分比</th>
                    </tr>
                </thead>
                <tbody>
<%
        Map<String, String> statusNames = new LinkedHashMap<>();
        statusNames.put("Approved", "已通過");
        statusNames.put("Pending", "待審核");
        statusNames.put("Rejected", "未通過");
        
        for(Map.Entry<String, String> status : statusNames.entrySet()) {
            rs = smt.executeQuery(
                "SELECT COUNT(*) as count FROM bookListings WHERE Approved = '" + status.getKey() + "'"
            );
            int count = 0;
            if(rs.next()) count = rs.getInt("count");
            double percentage = totalListings > 0 ? (count * 100.0 / totalListings) : 0;
            rs.close();
%>
                    <tr>
                        <td><%= status.getValue() %></td>
                        <td><strong><%= count %></strong> 本</td>
                        <td><%= String.format("%.1f%%", percentage) %></td>
                    </tr>
<%
        }
%>
                </tbody>
            </table>
        </div>
    </div>

<%
    } catch (Exception e) {
        out.println("<div class='error-message'>");
        out.println("<h3>⚠️ 載入統計數據時發生錯誤</h3>");
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

<!-- Footer -->
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
                <a class="btn btn-link" href="statistics.jsp">統計數據</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank">系統使用回饋表單</a>
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

<script>
// 動畫效果 - 數字遞增
document.addEventListener('DOMContentLoaded', function() {
    const statValues = document.querySelectorAll('.stat-value');
    
    statValues.forEach(el => {
        const text = el.textContent.trim();
        const match = text.match(/[\d,]+/);
        
        if (match) {
            const targetValue = parseInt(match[0].replace(/,/g, ''));
            if (!isNaN(targetValue)) {
                animateValue(el, 0, targetValue, 1500, text);
            }
        }
    });
});

function animateValue(el, start, end, duration, originalText) {
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;
    const prefix = originalText.includes('NT$') ? 'NT$' : '';
    const isDecimal = originalText.includes('.');
    
    const timer = setInterval(() => {
        current += increment;
        if (current >= end) {
            current = end;
            clearInterval(timer);
        }
        
        if (isDecimal) {
            el.textContent = prefix + current.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        } else {
            el.textContent = prefix + Math.floor(current).toLocaleString();
        }
    }, 16);
}

// 價格條動畫
window.addEventListener('load', function() {
    const priceBars = document.querySelectorAll('.price-bar-fill');
    priceBars.forEach(bar => {
        const width = bar.style.width;
        bar.style.width = '0%';
        setTimeout(() => {
            bar.style.width = width;
        }, 100);
    });
});
</script>

</body>
</html>