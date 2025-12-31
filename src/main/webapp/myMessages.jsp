<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // 在任何 HTML 輸出之前先檢查登入狀態
    String userId = (String) session.getAttribute("userId");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

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
            margin: -30px auto 40px;
            padding: 20px;
        }
        
        .page-header {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
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
        
        .conversation-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            transition: all 0.3s;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 20px;
            position: relative;
        }
        
        .conversation-card:hover {
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.12);
            transform: translateY(-2px);
        }
        
        .conversation-card.unread {
            border-left: 4px solid #ff7043;
            background: linear-gradient(to right, #fff8f5 0%, #ffffff 100%);
        }
        
        .conversation-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            font-weight: bold;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(129, 199, 132, 0.3);
        }
        
        .conversation-content {
            flex: 1;
            min-width: 0;
        }
        
        .conversation-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        
        .conversation-name {
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }
        
        .conversation-time {
            color: #999;
            font-size: 13px;
        }
        
        .book-title {
            color: #66bb6a;
            font-size: 14px;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .last-message {
            color: #666;
            font-size: 14px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .unread-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #ff7043 0%, #ff5722 100%);
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            box-shadow: 0 2px 6px rgba(255, 112, 67, 0.3);
        }
        
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
            
            .conversation-card {
                flex-direction: column;
                text-align: center;
            }
            
            .unread-badge {
                top: 10px;
                right: 10px;
            }
        }
    </style>
</head>
<body>

<%@ include file="menu.jsp"%>

<%
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 將 userId 轉換為整數
        int currentUserId = Integer.parseInt(userId);
        
        // 宣告變數
        int totalConversations = 0;
        int totalUnreadCount = 0;
        
        // 查詢總對話數（修正：senderId 和 receiverId 現在是 INTEGER）
        String totalSQL = "SELECT COUNT(DISTINCT conversationId) as total FROM messages " +
                         "WHERE senderId = ? OR receiverId = ?";
        pstmt = con.prepareStatement(totalSQL);
        pstmt.setInt(1, currentUserId);  // 改用 setInt
        pstmt.setInt(2, currentUserId);
        ResultSet totalRs = pstmt.executeQuery();
        if (totalRs.next()) {
            totalConversations = totalRs.getInt("total");
        }
        totalRs.close();
        pstmt.close();
        
        // 查詢未讀對話數
        String unreadSQL = "SELECT COUNT(DISTINCT conversationId) as unread FROM messages " +
                          "WHERE receiverId = ? AND isRead = false";
        pstmt = con.prepareStatement(unreadSQL);
        pstmt.setInt(1, currentUserId);  // 改用 setInt
        ResultSet unreadRs = pstmt.executeQuery();
        if (unreadRs.next()) {
            totalUnreadCount = unreadRs.getInt("unread");
        }
        unreadRs.close();
        pstmt.close();
        
        // 取得篩選條件
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";
%>

<div class="messages-container">
    <div class="page-header">
        <h1><i class="fas fa-inbox"></i> 我的訊息</h1>
        <div class="stats-bar">
            <div class="stat-item">
                <i class="fas fa-comments"></i> 對話數: <strong><%= totalConversations %></strong>
            </div>
            <div class="stat-item">
                <i class="fas fa-envelope"></i> 未讀: <strong><%= totalUnreadCount %></strong>
            </div>
        </div>
    </div>
    
    <div class="filter-tabs">
        <button class="filter-btn <%= filter.equals("all") ? "active" : "" %>" 
                onclick="location.href='myMessages.jsp?filter=all'">
            <i class="fas fa-list"></i> 全部對話
        </button>
        <button class="filter-btn <%= filter.equals("unread") ? "active" : "" %>" 
                onclick="location.href='myMessages.jsp?filter=unread'">
            <i class="fas fa-envelope"></i> 未讀訊息
            <% if (totalUnreadCount > 0) { %>
                <span style="background: white; color: #66bb6a; padding: 2px 8px; border-radius: 10px; margin-left: 5px;"><%= totalUnreadCount %></span>
            <% } %>
        </button>
    </div>
    
    <%
        // 查詢對話列表（修正 JOIN 語法）
        String sql = 
            "SELECT m.conversationId, m.senderId, m.receiverId, m.bookId, " +
            "m.message as lastMessage, m.sentAt as lastMessageTime, m.senderType as lastSenderType, " +
            "b.title, bl.photo, bl.price, " +
            "sender.name as senderName, receiver.name as receiverName, " +
            "(SELECT COUNT(*) FROM messages m2 " +
            " WHERE m2.conversationId = m.conversationId " +
            " AND m2.isRead = false " +
            " AND m2.receiverId = ?) as unreadInConv " +
            "FROM messages m " +
            "INNER JOIN bookListings bl ON m.bookId = bl.listingId " +
            "INNER JOIN books b ON bl.bookId = b.bookId " +
            "INNER JOIN users sender ON m.senderId = sender.userId " +
            "INNER JOIN users receiver ON m.receiverId = receiver.userId " +
            "WHERE (m.senderId = ? OR m.receiverId = ?) " +
            "AND m.messageId IN (" +
            "  SELECT MAX(m3.messageId) FROM messages m3 " +
            "  WHERE m3.conversationId = m.conversationId" +
            ")";
        
        if (filter.equals("unread")) {
            sql += " AND EXISTS (" +
                  "  SELECT 1 FROM messages m4 " +
                  "  WHERE m4.conversationId = m.conversationId " +
                  "  AND m4.isRead = false " +
                  "  AND m4.receiverId = ?" +
                  ")";
        }
        
        sql += " ORDER BY m.sentAt DESC";
        
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, currentUserId);  // unreadInConv 子查詢
        pstmt.setInt(2, currentUserId);  // senderId
        pstmt.setInt(3, currentUserId);  // receiverId
        if (filter.equals("unread")) {
            pstmt.setInt(4, currentUserId);  // 未讀篩選
        }
        
        rs = pstmt.executeQuery();
        
        boolean hasConversations = false;
        while (rs.next()) {
            hasConversations = true;
            
            String conversationId = rs.getString("conversationId");
            int senderId = rs.getInt("senderId");
            int receiverId = rs.getInt("receiverId");
            String senderName = rs.getString("senderName");
            String receiverName = rs.getString("receiverName");
            String bookTitle = rs.getString("title");
            String lastMessage = rs.getString("lastMessage");
            Timestamp lastMessageTime = rs.getTimestamp("lastMessageTime");
            String lastSenderType = rs.getString("lastSenderType");
            int unreadInConv = rs.getInt("unreadInConv");
            
            // 判斷對方是誰
            boolean iAmSender = (currentUserId == senderId);
            String otherPersonName = iAmSender ? receiverName : senderName;
            
            // 取得對方名字的第一個字元作為頭像
            String otherPersonInitial = otherPersonName.substring(0, 1);
            
            // 格式化時間（保持原有邏輯）
            long diff = System.currentTimeMillis() - lastMessageTime.getTime();
            String timeAgo = "";
            if (diff < 60000) {
                timeAgo = "剛剛";
            } else if (diff < 3600000) {
                timeAgo = (diff / 60000) + "分鐘前";
            } else if (diff < 86400000) {
                timeAgo = (diff / 3600000) + "小時前";
            } else if (diff < 604800000) {
                timeAgo = (diff / 86400000) + "天前";
            } else {
                SimpleDateFormat sdf = new SimpleDateFormat("MM/dd");
                timeAgo = sdf.format(lastMessageTime);
            }
            
            // 判斷最後一則訊息是誰發的
            String messagePrefix = iAmSender ? "我：" : otherPersonName + "：";
    %>
    
    <div class="conversation-card <%= unreadInConv > 0 ? "unread" : "" %>" 
         onclick="location.href='conversation.jsp?conversationId=<%= conversationId %>'">
        <div class="conversation-avatar">
            <%= otherPersonInitial %>
        </div>
        <div class="conversation-content">
            <div class="conversation-header">
                <span class="conversation-name"><%= otherPersonName %></span>
                <span class="conversation-time"><%= timeAgo %></span>
            </div>
            <div class="book-title">
                <i class="fas fa-book"></i> <%= bookTitle %>
            </div>
            <div class="last-message">
                <%= messagePrefix %><%= lastMessage %>
            </div>
        </div>
        <% if (unreadInConv > 0) { %>
        <div class="unread-badge"><%= unreadInConv %></div>
        <% } %>
    </div>
    
    <%
        }
        
        if (!hasConversations) {
    %>
    
    <div class="empty-state">
        <i class="fas fa-inbox"></i>
        <h3>目前沒有對話</h3>
        <p>當您與其他使用者聯繫時,對話會顯示在這裡</p>
        <button class="btn btn-primary" onclick="location.href='index.jsp'" style="margin-top: 20px;">
            <i class="fas fa-home"></i> 返回首頁
        </button>
    </div>
    
    <%
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    %>
        <div style="background-color: #ffebee; color: #c62828; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <i class="fas fa-exclamation-circle"></i> 系統發生錯誤:<%= e.getMessage() %>
        </div>
    <%
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    %>
</div>

<%@ include file="footer.jsp"%>

</body>
</html>