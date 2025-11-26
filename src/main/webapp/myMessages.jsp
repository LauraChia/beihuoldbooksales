<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>我的訊息 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
		body {
		    background-color: #f8f9fa;
		    font-family: "Microsoft JhengHei", sans-serif;
		}
		
		.messages-container {
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
		
		/* 篩選標籤區 */
		.filter-tabs {
		    display: flex;
		    gap: 10px;
		    margin-bottom: 20px;
		    background: white;
		    padding: 15px;
		    border-radius: 10px;
		    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
		}
		
		.filter-btn {
		    padding: 10px 20px;
		    border: 2px solid #e0e0e0;
		    background: white;
		    border-radius: 8px;
		    cursor: pointer;
		    transition: all 0.3s;
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
		    color: white;
		    border-color: transparent;
		}
		
		/* 訊息卡片 */
		.message-card {
		    background: white;
		    border-radius: 12px;
		    padding: 25px;
		    margin-bottom: 15px;
		    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
		    transition: all 0.3s;
		    border-left: 4px solid transparent;
		}
		
		.message-card:hover {
		    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.12);
		    transform: translateY(-2px);
		}
		
		.message-card.unread {
		    border-left-color: #ff7043;
		    background: linear-gradient(to right, #fff8f5 0%, #ffffff 100%);
		}
		
		.message-header {
		    display: flex;
		    justify-content: space-between;
		    align-items: center;
		    margin-bottom: 15px;
		}
		
		.buyer-info {
		    display: flex;
		    align-items: center;
		    gap: 15px;
		}
		
		/* 買家頭像 - 改用淺綠色漸層 */
		.buyer-avatar {
		    width: 50px;
		    height: 50px;
		    border-radius: 50%;
		    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
		    display: flex;
		    align-items: center;
		    justify-content: center;
		    color: white;
		    font-size: 20px;
		    font-weight: bold;
		    box-shadow: 0 2px 8px rgba(129, 199, 132, 0.3);
		}
		
		.buyer-details h5 {
		    margin: 0;
		    font-size: 18px;
		    color: #333;
		}
		
		.buyer-details small {
		    color: #666;
		}
		
		.message-time {
		    color: #999;
		    font-size: 14px;
		    text-align: right;
		}
		
		/* 書籍資訊區塊 */
		.book-info {
		    background: #f8fdf9;
		    padding: 15px;
		    border-radius: 8px;
		    margin-bottom: 15px;
		    display: flex;
		    align-items: center;
		    gap: 15px;
		    border: 1px solid #e8f5e9;
		}
		
		.book-info img {
		    width: 60px;
		    height: 80px;
		    object-fit: cover;
		    border-radius: 5px;
		}
		
		.book-details h6 {
		    margin: 0;
		    color: #66bb6a;
		    font-weight: 600;
		}
		
		/* 訊息內容 */
		.message-content {
		    padding: 15px;
		    background: #f9f9f9;
		    border-radius: 8px;
		    margin-bottom: 15px;
		    line-height: 1.6;
		    border-left: 3px solid #81c784;
		}
		
		/* 聯絡資訊 - 改用更柔和的綠色 */
		.contact-info {
		    background: linear-gradient(to right, #e8f5e9 0%, #f1f8f4 100%);
		    padding: 10px 15px;
		    border-radius: 8px;
		    margin-bottom: 15px;
		    display: flex;
		    align-items: center;
		    gap: 10px;
		    border-left: 3px solid #81c784;
		}
		
		.contact-info i {
		    color: #66bb6a;
		}
		
		/* 操作按鈕 */
		.action-buttons {
		    display: flex;
		    gap: 10px;
		    flex-wrap: wrap;
		}
		
		.btn-mark-read {
		    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
		    color: white;
		    border: none;
		    padding: 8px 16px;
		    border-radius: 6px;
		    cursor: pointer;
		    transition: all 0.3s;
		    font-weight: 500;
		}
		
		.btn-mark-read:hover {
		    background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
		    box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
		    transform: translateY(-2px);
		}
		
		.btn-view-book {
		    background: white;
		    color: #66bb6a;
		    border: 2px solid #81c784;
		    padding: 8px 16px;
		    border-radius: 6px;
		    cursor: pointer;
		    transition: all 0.3s;
		    font-weight: 500;
		}
		
		.btn-view-book:hover {
		    background: #f1f8f4;
		    border-color: #66bb6a;
		    transform: translateY(-2px);
		}
		
		.btn-delete {
		    background: white;
		    color: #e57373;
		    border: 2px solid #ef9a9a;
		    padding: 8px 16px;
		    border-radius: 6px;
		    cursor: pointer;
		    transition: all 0.3s;
		    font-weight: 500;
		}
		
		.btn-delete:hover {
		    background: #ffebee;
		    border-color: #e57373;
		    transform: translateY(-2px);
		}
		
		/* 空狀態 */
		.empty-state {
		    text-align: center;
		    padding: 60px 20px;
		    background: white;
		    border-radius: 12px;
		}
		
		.empty-state i {
		    font-size: 80px;
		    color: #c8e6c9;
		    margin-bottom: 20px;
		}
		
		.empty-state h3 {
		    color: #66bb6a;
		}
		
		/* 未讀徽章 */
		.badge-unread {
		    background: linear-gradient(135deg, #ff7043 0%, #ff5722 100%);
		    color: white;
		    padding: 4px 10px;
		    border-radius: 12px;
		    font-size: 12px;
		    font-weight: bold;
		    box-shadow: 0 2px 6px rgba(255, 112, 67, 0.3);
		}
		
		/* 錯誤訊息 */
		.error-message {
		    background-color: #ffebee;
		    color: #c62828;
		    padding: 15px;
		    border-radius: 8px;
		    margin: 20px 0;
		    border: 1px solid #ef9a9a;
		}
		
		/* 響應式設計 */
		@media (max-width: 768px) {
		    .messages-container {
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
		    
		    .message-header {
		        flex-direction: column;
		        align-items: flex-start;
		        gap: 10px;
		    }
		    
		    .message-time {
		        text-align: left;
		    }
		    
		    .action-buttons {
		        flex-direction: column;
		    }
		    
		    .action-buttons button {
		        width: 100%;
		    }
		}
    </style>
</head>
<body>

<%@ include file="menu.jsp"%>

<%
    // === 1. 驗證登入狀態 ===
    String sellerId = (String) session.getAttribute("userId");
    if (sellerId == null || sellerId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // === 2. 建立資料庫連線 ===
    Connection con = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmtUnread = null;
    PreparedStatement pstmtMessages = null;
    ResultSet totalRs = null;
    ResultSet unreadRs = null;
    ResultSet rs = null;
    
    int totalMessages = 0;
    int unreadMessages = 0;
    
    try {
        // ✅ 統一使用標準連線方式
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // === 3. 查詢總訊息數 ===
        String totalSQL = "SELECT COUNT(*) as total FROM messages WHERE sellerId = ?";
        pstmt = con.prepareStatement(totalSQL);
        pstmt.setString(1, sellerId);
        totalRs = pstmt.executeQuery();
        
        if (totalRs.next()) {
            totalMessages = totalRs.getInt("total");
        }
        
        // === 4. 查詢未讀訊息數 ===
        String unreadSQL = "SELECT COUNT(*) as unread FROM messages WHERE sellerId = ? AND isRead = false";
        pstmtUnread = con.prepareStatement(unreadSQL);
        pstmtUnread.setString(1, sellerId);
        unreadRs = pstmtUnread.executeQuery();
        
        if (unreadRs.next()) {
            unreadMessages = unreadRs.getInt("unread");
        }
        
        // === 5. 取得篩選條件 ===
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";
        
        // === 6. 查詢訊息列表 (使用 PreparedStatement) ===
        String sql = "SELECT m.messageId, m.buyerId, m.sellerId, m.bookId, m.message, m.contactInfo, m.isRead, m.sentAt, " +
                    "b.titleBook, b.photo, b.price, " +
                    "u.name as buyerName, u.username as buyerEmail " +
                    "FROM (messages m " +
                    "INNER JOIN book b ON m.bookId = b.bookId) " +
                    "INNER JOIN users u ON m.buyerId = u.userId " +
                    "WHERE m.sellerId = ?";
        
        if (filter.equals("unread")) {
            sql += " AND m.isRead = false";
        }
        
        sql += " ORDER BY m.sentAt DESC";
        
        pstmtMessages = con.prepareStatement(sql);
        pstmtMessages.setString(1, sellerId);
        rs = pstmtMessages.executeQuery();
%>

<div class="messages-container" >
    <!-- 頁面標題 -->
    <div class="page-header">
        <h1><i class="fas fa-inbox"></i> 我的訊息</h1>
        <div class="stats-bar">
            <div class="stat-item">
                <i class="fas fa-envelope"></i> 總訊息數: <strong><%= totalMessages %></strong>
            </div>
            <div class="stat-item">
                <i class="fas fa-envelope-open"></i> 未讀: <strong><%= unreadMessages %></strong>
            </div>
        </div>
    </div>
    
    <!-- 篩選按鈕 -->
    <div class="filter-tabs">
        <button class="filter-btn <%= filter.equals("all") ? "active" : "" %>" 
                onclick="location.href='myMessages.jsp?filter=all'">
            <i class="fas fa-list"></i> 全部訊息
        </button>
        <button class="filter-btn <%= filter.equals("unread") ? "active" : "" %>" 
                onclick="location.href='myMessages.jsp?filter=unread'">
            <i class="fas fa-envelope"></i> 未讀訊息 
            <% if (unreadMessages > 0) { %>
                <span class="badge-unread"><%= unreadMessages %></span>
            <% } %>
        </button>
    </div>
    
    <!-- 訊息列表 -->
    <%
        boolean hasMessages = false;
        while (rs.next()) {
            hasMessages = true;
            
            int messageId = rs.getInt("messageId");
            String bookTitle = rs.getString("titleBook");
            String photo = rs.getString("photo");
            String price = rs.getString("price");
            String message = rs.getString("message");
            String buyerName = rs.getString("buyerName");
            String buyerEmail = rs.getString("buyerEmail");
            String contactInfo = rs.getString("contactInfo");
            boolean isRead = rs.getBoolean("isRead");
            Timestamp sentAt = rs.getTimestamp("sentAt");
            int bookId = rs.getInt("bookId");
            
            // 處理圖片路徑
            if (photo != null && !photo.trim().isEmpty()) {
                String[] photoArray = photo.split(",");
                photo = photoArray[0].trim();
                if (!photo.startsWith("assets/")) {
                    photo = "assets/images/member/" + photo;
                }
            } else {
                photo = "assets/images/about.png";
            }
            
            // 格式化時間
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            String timeStr = sdf.format(sentAt);
            
            // 計算時間差
            long diff = System.currentTimeMillis() - sentAt.getTime();
            String timeAgo = "";
            if (diff < 60000) {
                timeAgo = "剛剛";
            } else if (diff < 3600000) {
                timeAgo = (diff / 60000) + "分鐘前";
            } else if (diff < 86400000) {
                timeAgo = (diff / 3600000) + "小時前";
            } else {
                timeAgo = (diff / 86400000) + "天前";
            }
    %>
    
    <div class="message-card <%= !isRead ? "unread" : "" %>">
        <div class="message-header">
            <div class="buyer-info">
                <div class="buyer-avatar">
                    <%= buyerName != null ? buyerName.substring(0, 1) : "?" %>
                </div>
                <div class="buyer-details">
                    <h5><%= buyerName != null ? buyerName : "匿名買家" %></h5>
                    <small><i class="fas fa-envelope"></i> <%= buyerEmail != null ? buyerEmail : "" %></small>
                </div>
            </div>
            <div class="message-time">
                <% if (!isRead) { %>
                    <span class="badge-unread">未讀</span>
                <% } %>
                <div><i class="far fa-clock"></i> <%= timeAgo %></div>
                <small><%= timeStr %></small>
            </div>
        </div>
        
        <!-- 書籍資訊 -->
        <div class="book-info">
            <img src="<%= photo %>" alt="書籍封面" onerror="this.src='assets/images/about.png'">
            <div class="book-details">
                <h6><i class="fas fa-book"></i> <%= bookTitle %></h6>
                <div class="text-danger"><strong>NT$ <%= price != null ? (int)Float.parseFloat(price) : 0 %></strong></div>
            </div>
        </div>
        
        <!-- 買家訊息 -->
        <div class="message-content">
            <strong>📝 買家留言：</strong><br>
            <%= message != null ? message : "" %>
        </div>
        
        <!-- 買家聯絡方式 -->
        <% if (contactInfo != null && !contactInfo.trim().isEmpty()) { %>
        <div class="contact-info">
            <i class="fas fa-phone-alt"></i>
            <strong>買家聯絡方式：</strong><%= contactInfo %>
        </div>
        <% } %>
        
        <!-- 操作按鈕 -->
        <div class="action-buttons">
            <% if (!isRead) { %>
            <button class="btn-mark-read" onclick="markAsRead(<%= messageId %>)">
                <i class="fas fa-check"></i> 標記已讀
            </button>
            <% } %>
            <button class="btn-view-book" onclick="location.href='bookDetail.jsp?bookId=<%= bookId %>'">
                <i class="fas fa-eye"></i> 查看書籍
            </button>
            <button class="btn-delete" onclick="deleteMessage(<%= messageId %>)">
                <i class="fas fa-trash"></i> 刪除
            </button>
        </div>
    </div>
    
    <%
        }
        
        if (!hasMessages) {
    %>
    <!-- 空狀態 -->
    <div class="empty-state">
        <i class="fas fa-inbox"></i>
        <h3>目前沒有訊息</h3>
        <p>當有買家對您的書籍感興趣時，訊息會顯示在這裡</p>
        <button class="btn btn-primary" onclick="location.href='index.jsp'">
            返回首頁
        </button>
    </div>
    <%
        }
        
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        System.err.println("找不到資料庫驅動程式: " + e.getMessage());
    %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i> 系統錯誤：找不到資料庫驅動程式
        </div>
    <%
    } catch (SQLException e) {
        e.printStackTrace();
        System.err.println("SQL錯誤: " + e.getMessage());
    %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i> 資料庫錯誤：<%= e.getMessage() %>
        </div>
    <%
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("系統錯誤: " + e.getMessage());
    %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i> 系統發生錯誤，請稍後再試
        </div>
    <%
    } finally {
        // ✅ 確保所有資源正確關閉
        try {
            if (rs != null) rs.close();
            if (totalRs != null) totalRs.close();
            if (unreadRs != null) unreadRs.close();
            if (pstmt != null) pstmt.close();
            if (pstmtUnread != null) pstmtUnread.close();
            if (pstmtMessages != null) pstmtMessages.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    %>
</div>

<script>
function markAsRead(messageId) {
    if (confirm('確定要標記為已讀嗎？')) {
        fetch('markMessageRead.jsp?messageId=' + messageId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('操作失敗: ' + data.message);
            }
        })
        .catch(error => {
            alert('系統錯誤: ' + error);
        });
    }
}

function deleteMessage(messageId) {
    if (confirm('確定要刪除這則訊息嗎？\n刪除後將無法復原！')) {
        fetch('deleteMessage.jsp?messageId=' + messageId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ 訊息已刪除');
                location.reload();
            } else {
                alert('❌ 刪除失敗: ' + data.message);
            }
        })
        .catch(error => {
            alert('❌ 系統錯誤: ' + error);
        });
    }
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
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書交易網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

</body>
</html>