<%@page contentType="text/html; charset=UTF-8"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />

<%
// 取得登入的賣家 ID
String userId = (String) session.getAttribute("userId");
String username = (String) session.getAttribute("username");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection con = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
List<Map<String, String>> expiredBooks = new ArrayList<>();

try {
    // 連接資料庫
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    
    // 取得今天日期
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new java.util.Date());
    
    // 查詢「這個賣家」的過期書籍
    String sql = "SELECT bookId, titleBook, author, price, expiryDate, uploadDate " +
                 "FROM book " +
                 "WHERE userId = ? AND expiryDate < ? AND (isExpired = 'N' OR isExpired IS NULL)";
    
    pstmt = con.prepareStatement(sql);
    pstmt.setString(1, userId);
    pstmt.setString(2, today);
    rs = pstmt.executeQuery();
    
    // 儲存過期書籍資料
    while (rs.next()) {
        Map<String, String> book = new HashMap<>();
        book.put("bookId", rs.getString("bookId"));
        book.put("titleBook", rs.getString("titleBook"));
        book.put("author", rs.getString("author"));
        book.put("price", rs.getString("price"));
        book.put("expiryDate", rs.getString("expiryDate"));
        book.put("uploadDate", rs.getString("uploadDate"));
        expiredBooks.add(book);
        
        // 同時更新書籍狀態為「已過期」
        String updateSQL = "UPDATE book SET isExpired = 'Y' WHERE bookId = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateSQL);
        updateStmt.setString(1, rs.getString("bookId"));
        updateStmt.executeUpdate();
        updateStmt.close();
    }
    
    rs.close();
    pstmt.close();
    con.close();
    
} catch (Exception e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>書籍到期通知 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: "Microsoft JhengHei", sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .notification-container {
            background: white;
            border-radius: 20px;
            max-width: 650px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            animation: slideIn 0.5s ease;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .notification-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
            padding: 35px;
            text-align: center;
            color: white;
        }
        
        .notification-header .icon {
            font-size: 4.5rem;
            margin-bottom: 15px;
            animation: bell 1s ease-in-out infinite;
        }
        
        @keyframes bell {
            0%, 100% { transform: rotate(0deg); }
            25% { transform: rotate(15deg); }
            75% { transform: rotate(-15deg); }
        }
        
        .notification-header h2 {
            margin: 10px 0 5px 0;
            font-weight: 700;
            font-size: 1.8rem;
        }
        
        .notification-header .subtitle {
            font-size: 1.1rem;
            opacity: 0.95;
        }
        
        .notification-body {
            padding: 35px;
        }
        
        .seller-info {
            background: #f8f9fa;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            text-align: center;
            border-left: 4px solid #667eea;
        }
        
        .seller-info strong {
            color: #667eea;
            font-size: 1.1rem;
        }
        
        .message {
            font-size: 1.1rem;
            line-height: 1.8;
            color: #495057;
            margin-bottom: 25px;
            padding: 20px;
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            border-radius: 8px;
        }
        
        .book-list {
            max-height: 350px;
            overflow-y: auto;
            margin-bottom: 25px;
        }
        
        .book-item {
            background: linear-gradient(135deg, #fff5f5 0%, #ffe5e5 100%);
            border-left: 5px solid #dc3545;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }
        
        .book-item:hover {
            transform: translateX(8px);
            box-shadow: 0 5px 20px rgba(220, 53, 69, 0.2);
        }
        
        .book-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: #212529;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .book-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-bottom: 12px;
        }
        
        .info-item {
            font-size: 0.95rem;
            color: #6c757d;
        }
        
        .info-item strong {
            color: #495057;
            display: inline-block;
            min-width: 80px;
        }
        
        .expired-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #dc3545;
            color: white;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .btn-container {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn-custom {
            padding: 15px 35px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            font-size: 1.05rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(102, 126, 234, 0.5);
        }
        
        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }
        
        .btn-secondary:hover {
            background: #f8f9fa;
            transform: translateY(-3px);
        }
        
        .no-expired {
            text-align: center;
            padding: 50px 20px;
        }
        
        .no-expired .icon {
            font-size: 6rem;
            margin-bottom: 25px;
            animation: bounce 1s ease infinite;
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-15px); }
        }
        
        .no-expired h3 {
            color: #28a745;
            margin-bottom: 15px;
            font-size: 1.8rem;
        }
        
        .no-expired p {
            color: #6c757d;
            font-size: 1.15rem;
            line-height: 1.6;
        }
        
        /* 滾動條樣式 */
        .book-list::-webkit-scrollbar {
            width: 10px;
        }
        
        .book-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        
        .book-list::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
        }
        
        .book-list::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #5568d3 0%, #6a3f8f 100%);
        }
        
        @media (max-width: 768px) {
            .book-info {
                grid-template-columns: 1fr;
            }
            .btn-container {
                flex-direction: column;
            }
            .btn-custom {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>

<div class="notification-container">
    <% if (expiredBooks.size() > 0) { %>
    <!-- 有過期書籍 -->
    <div class="notification-header">
        <div class="icon">🔔</div>
        <h2>書籍到期通知</h2>
        <p class="subtitle">您有 <%= expiredBooks.size() %> 本書籍已到期下架</p>
    </div>
    
    <div class="notification-body">
        <div class="seller-info">
            👤 賣家：<strong><%= username %></strong>
        </div>
        
        <div class="message">
            ⚠️ <strong>提醒您：</strong><br>
            以下書籍已到達上架期限，系統已自動下架。如需繼續販售，請重新上架。
        </div>
        
        <div class="book-list">
            <% for (Map<String, String> book : expiredBooks) { %>
            <div class="book-item">
                <div class="book-title">
                    📚 <%= book.get("titleBook") %>
                </div>
                <div class="book-info">
                    <div class="info-item">
                        <strong>作者：</strong><%= book.get("author") %>
                    </div>
                    <div class="info-item">
                        <strong>價格：</strong>NT$ <%= book.get("price") %>
                    </div>
                    <div class="info-item">
                        <strong>上架日：</strong><%= book.get("uploadDate") != null ? book.get("uploadDate") : "未知" %>
                    </div>
                    <div class="info-item">
                        <strong>到期日：</strong><%= book.get("expiryDate") %>
                    </div>
                </div>
                <span class="expired-badge">⏰ 已自動下架</span>
            </div>
            <% } %>
        </div>
        
        <div class="btn-container">
            <a href="shop.jsp" class="btn-custom btn-primary">
                📤 重新上架
            </a>
            <a href="index.jsp" class="btn-custom btn-secondary">
                🏠 返回首頁
            </a>
        </div>
    </div>
    
    <% } else { %>
    <!-- 沒有過期書籍 -->
    <div class="notification-header" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);">
        <div class="icon">✅</div>
        <h2>一切正常！</h2>
    </div>
    
    <div class="notification-body">
        <div class="seller-info">
            👤 賣家：<strong><%= username %></strong>
        </div>
        
        <div class="no-expired">
            <div class="icon">🎉</div>
            <h3>太好了！</h3>
            <p>您目前沒有過期的書籍</p>
            <p style="margin-top: 10px; font-size: 1rem;">
                所有上架的書籍都在有效期限內
            </p>
        </div>
        
        <div class="btn-container">
            <a href="index.jsp" class="btn-custom btn-primary">
                🏠 返回首頁
            </a>
        </div>
    </div>
    <% } %>
</div>

</body>
</html>