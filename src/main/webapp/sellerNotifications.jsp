<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>我的通知 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .notification-container {
            max-width: 900px;
            margin: 100px auto 50px;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .notification-item {
            padding: 20px;
            border-left: 4px solid #ffc107;
            background: #fff9e6;
            margin-bottom: 15px;
            border-radius: 5px;
            position: relative;
        }
        .notification-item.read {
            background: #f8f9fa;
            border-left-color: #dee2e6;
            opacity: 0.7;
        }
        .notification-date {
            color: #666;
            font-size: 13px;
            margin-bottom: 8px;
        }
        .notification-message {
            color: #333;
            line-height: 1.6;
        }
        .mark-read-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #28a745;
            color: white;
            border: none;
            padding: 5px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        .mark-read-btn:hover {
            background: #218838;
        }
        .no-notifications {
            text-align: center;
            padding: 50px;
            color: #999;
        }
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
            border-bottom: 2px solid #e9ecef;
        }
        .filter-tab {
            padding: 10px 20px;
            cursor: pointer;
            border: none;
            background: none;
            color: #666;
            font-weight: 500;
            border-bottom: 3px solid transparent;
        }
        .filter-tab.active {
            color: #d9534f;
            border-bottom-color: #d9534f;
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp" %>

<div class="notification-container">
    <h3 style="margin-bottom: 30px;">🔔 我的通知</h3>
    
    <div class="filter-tabs">
        <button class="filter-tab active" onclick="filterNotifications('all')">全部通知</button>
        <button class="filter-tab" onclick="filterNotifications('unread')">未讀通知</button>
        <button class="filter-tab" onclick="filterNotifications('read')">已讀通知</button>
    </div>

    <div id="notificationList">
<%
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        String sql = "SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, userId);
        ResultSet rs = pstmt.executeQuery();
        
        boolean hasNotifications = false;
        
        while (rs.next()) {
            hasNotifications = true;
            int notificationId = rs.getInt("notificationId");
            String message = rs.getString("message");
            String createdAt = rs.getString("createdAt");
            boolean isRead = rs.getBoolean("isRead");
%>
        <div class="notification-item <%= isRead ? "read" : "" %>" data-status="<%= isRead ? "read" : "unread" %>">
            <div class="notification-date">📅 <%= createdAt %></div>
            <div class="notification-message"><%= message %></div>
            <% if (!isRead) { %>
            <button class="mark-read-btn" onclick="markAsRead(<%= notificationId %>, this)">
                標記為已讀
            </button>
            <% } %>
        </div>
<%
        }
        
        if (!hasNotifications) {
%>
        <div class="no-notifications">
            <p style="font-size: 48px; margin-bottom: 15px;">📭</p>
            <p>目前沒有任何通知</p>
        </div>
<%
        }
        
        rs.close();
        pstmt.close();
        con.close();
        
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>錯誤: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>
    </div>
</div>

<script>
function markAsRead(notificationId, button) {
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
            const item = button.closest('.notification-item');
            item.classList.add('read');
            item.setAttribute('data-status', 'read');
            button.remove();
        } else {
            alert('操作失敗: ' + (data.message || '未知錯誤'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('系統錯誤');
    });
}

function filterNotifications(filter) {
    const items = document.querySelectorAll('.notification-item');
    const tabs = document.querySelectorAll('.filter-tab');
    
    // 更新 tab 樣式
    tabs.forEach(tab => tab.classList.remove('active'));
    event.target.classList.add('active');
    
    // 過濾通知
    items.forEach(item => {
        if (filter === 'all') {
            item.style.display = 'block';
        } else {
            const status = item.getAttribute('data-status');
            item.style.display = (status === filter) ? 'block' : 'none';
        }
    });
}
</script>

</body>
</html>