<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>系統通知 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        .notification-container {
            max-width: 1200px;
            margin: -30px auto 0;
            padding: 20px;
        }
        
        /* 頁面標題 - 淺綠色 */
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
        
        /* 通知卡片 */
        .notification-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 15px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }
        
        .notification-card:hover {
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.12);
            transform: translateY(-2px);
        }
        
        .notification-card.unread {
            border-left-color: #ff7043;
            background: linear-gradient(to right, #fff8f5 0%, #ffffff 100%);
        }
        
        .notification-card.read {
            opacity: 0.7;
            border-left-color: #e0e0e0;
        }
        
        .notification-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .notification-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            box-shadow: 0 2px 8px rgba(129, 199, 132, 0.3);
        }
        
        .notification-time {
            color: #999;
            font-size: 14px;
            text-align: right;
        }
        
        /* 通知內容 */
        .notification-content {
            padding: 15px;
            background: #f9f9f9;
            border-radius: 8px;
            margin-bottom: 15px;
            line-height: 1.6;
            border-left: 3px solid #81c784;
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
            .notification-container {
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
            
            .notification-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .notification-time {
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
<%@ include file="menu.jsp" %>

<%
    Connection con = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmtUnread = null;
    PreparedStatement pstmtNotifications = null;
    ResultSet totalRs = null;
    ResultSet unreadRs = null;
    ResultSet rs = null;
    
    int totalNotifications = 0;
    int unreadNotifications = 0;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 查詢總通知數
        String totalSQL = "SELECT COUNT(*) as total FROM notifications WHERE userId = ?";
        pstmt = con.prepareStatement(totalSQL);
        pstmt.setString(1, userId);
        totalRs = pstmt.executeQuery();
        
        if (totalRs.next()) {
            totalNotifications = totalRs.getInt("total");
        }
        
        // 查詢未讀通知數
        String unreadSQL = "SELECT COUNT(*) as unread FROM notifications WHERE userId = ? AND isRead = false";
        pstmtUnread = con.prepareStatement(unreadSQL);
        pstmtUnread.setString(1, userId);
        unreadRs = pstmtUnread.executeQuery();
        
        if (unreadRs.next()) {
            unreadNotifications = unreadRs.getInt("unread");
        }
        
        // 取得篩選條件
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";
        
        // 查詢通知列表
        String sql = "SELECT * FROM notifications WHERE userId = ?";
        
        if (filter.equals("unread")) {
            sql += " AND isRead = false";
        } else if (filter.equals("read")) {
            sql += " AND isRead = true";
        }
        
        sql += " ORDER BY createdAt DESC";
        
        pstmtNotifications = con.prepareStatement(sql);
        pstmtNotifications.setString(1, userId);
        rs = pstmtNotifications.executeQuery();
%>

<div class="notification-container">
    <!-- 頁面標題 -->
    <div class="page-header">
        <h1><i class="fas fa-bell"></i> 系統通知</h1>
        <div class="stats-bar">
            <div class="stat-item">
                <i class="fas fa-list"></i> 總通知數: <strong><%= totalNotifications %></strong>
            </div>
            <div class="stat-item">
                <i class="fas fa-envelope"></i> 未讀: <strong><%= unreadNotifications %></strong>
            </div>
        </div>
    </div>
    
    <!-- 篩選按鈕 -->
    <div class="filter-tabs">
        <button class="filter-btn <%= filter.equals("all") ? "active" : "" %>" 
                onclick="location.href='sellerNotifications.jsp?filter=all'">
            <i class="fas fa-list"></i> 全部通知
        </button>
        <button class="filter-btn <%= filter.equals("unread") ? "active" : "" %>" 
                onclick="location.href='sellerNotifications.jsp?filter=unread'">
            <i class="fas fa-envelope"></i> 未讀通知
            <% if (unreadNotifications > 0) { %>
                <span class="badge-unread"><%= unreadNotifications %></span>
            <% } %>
        </button>
        <button class="filter-btn <%= filter.equals("read") ? "active" : "" %>" 
                onclick="location.href='sellerNotifications.jsp?filter=read'">
            <i class="fas fa-envelope-open"></i> 已讀通知
        </button>
    </div>

    <!-- 通知列表 -->
    <%
        boolean hasNotifications = false;
        
        while (rs.next()) {
            hasNotifications = true;
            int notificationId = rs.getInt("notificationId");
            String message = rs.getString("message");
            Timestamp createdAt = rs.getTimestamp("createdAt");
            boolean isRead = rs.getBoolean("isRead");
            
            // 格式化時間
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            String timeStr = sdf.format(createdAt);
            
            // 計算時間差
            long diff = System.currentTimeMillis() - createdAt.getTime();
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
    
    <div class="notification-card <%= !isRead ? "unread" : "read" %>" data-status="<%= isRead ? "read" : "unread" %>">
        <div class="notification-header">
            <div class="d-flex align-items-center gap-3">
                <div class="notification-icon">
                    <i class="fas fa-bell"></i>
                </div>
                <div>
                    <% if (!isRead) { %>
                        <span class="badge-unread">未讀</span>
                    <% } else { %>
                        <span class="text-muted">已讀</span>
                    <% } %>
                </div>
            </div>
            <div class="notification-time">
                <div><i class="far fa-clock"></i> <%= timeAgo %></div>
                <small><%= timeStr %></small>
            </div>
        </div>
        
        <!-- 通知內容 -->
        <div class="notification-content">
            <strong>📢 系統訊息：</strong><br>
            <%= message %>
        </div>
        
        <!-- 操作按鈕 -->
        <div class="action-buttons">
            <% if (!isRead) { %>
            <button class="btn-mark-read" onclick="markAsRead(<%= notificationId %>)">
                <i class="fas fa-check"></i> 標記已讀
            </button>
            <% } %>
            <button class="btn-delete" onclick="deleteNotification(<%= notificationId %>)">
                <i class="fas fa-trash"></i> 刪除
            </button>
        </div>
    </div>
    
    <%
        }
        
        if (!hasNotifications) {
    %>
    <!-- 空狀態 -->
    <div class="empty-state">
        <i class="fas fa-bell-slash"></i>
        <h3>目前沒有通知</h3>
        <p>系統通知會顯示在這裡</p>
        <button class="btn btn-primary" onclick="location.href='index.jsp'">
            返回首頁
        </button>
    </div>
    <%
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i> 系統錯誤：<%= e.getMessage() %>
        </div>
    <%
    } finally {
        try {
            if (rs != null) rs.close();
            if (totalRs != null) totalRs.close();
            if (unreadRs != null) unreadRs.close();
            if (pstmt != null) pstmt.close();
            if (pstmtUnread != null) pstmtUnread.close();
            if (pstmtNotifications != null) pstmtNotifications.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
</div>

<script>
function markAsRead(notificationId) {
    fetch('markNotificationRead.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'notificationId=' + notificationId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('操作失敗: ' + (data.message || '未知錯誤'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('系統錯誤');
    });
}

function deleteNotification(notificationId) {
    if (confirm('確定要刪除這則通知嗎？\n刪除後將無法復原！')) {
        fetch('deleteNotification.jsp?notificationId=' + notificationId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ 通知已刪除');
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