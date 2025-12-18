<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 檢查管理員登入狀態
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 處理發布公告
String action = request.getParameter("action");
String announcementId = request.getParameter("announcementId");
String message = "";
String messageType = "";

if ("publish".equals(action)) {
    String announcementMsg = request.getParameter("announcementMsg");
    
    if (announcementMsg != null && !announcementMsg.trim().isEmpty()) {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        try {
            // 獲取所有用戶ID
            String getUsersSql = "SELECT userId FROM users";
            Statement getUsersStmt = con.createStatement();
            ResultSet usersRs = getUsersStmt.executeQuery(getUsersSql);
            
            int sentCount = 0;
            
            // 為每個用戶創建通知
            String insertSql = "INSERT INTO notifications (userId, message, isRead, createdAt) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmt = con.prepareStatement(insertSql);
            
            while (usersRs.next()) {
                String userId = usersRs.getString("userId");
                pstmt.setString(1, userId);
                pstmt.setString(2, announcementMsg);
                pstmt.setBoolean(3, false);
                pstmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
                pstmt.executeUpdate();
                sentCount++;
            }
            
            pstmt.close();
            usersRs.close();
            getUsersStmt.close();
            
            message = "✅ 系統公告已成功發送給 " + sentCount + " 位用戶";
            messageType = "success";
            
        } catch (Exception e) {
            message = "❌ 發送失敗: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } finally {
            con.close();
        }
    } else {
        message = "⚠️ 請輸入公告內容";
        messageType = "warning";
    }
}

// 處理刪除公告記錄
if ("delete".equals(action) && announcementId != null) {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    try {
        String deleteSql = "DELETE FROM notifications WHERE notificationId = ?";
        PreparedStatement pstmt = con.prepareStatement(deleteSql);
        pstmt.setInt(1, Integer.parseInt(announcementId));
        pstmt.executeUpdate();
        pstmt.close();
        
        message = "✅ 公告記錄已刪除";
        messageType = "success";
    } catch (Exception e) {
        message = "❌ 刪除失敗: " + e.getMessage();
        messageType = "danger";
    } finally {
        con.close();
    }
}
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理員公告 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
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
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            animation: slideDown 0.3s ease-out;
        }
        
        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
        }
        
        @keyframes slideDown {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
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
        
        .publish-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }
        
        .publish-card h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: 'Microsoft JhengHei', Arial, sans-serif;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #81c408;
            box-shadow: 0 0 0 3px rgba(129, 196, 8, 0.1);
        }
        
        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }
        
        .btn-publish {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-publish:hover {
            background: linear-gradient(135deg, #6ba006 0%, #5a8905 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 196, 8, 0.3);
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
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #81c408;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .history-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .history-card h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .announcement-item {
            background: #f8f9fa;
            border-left: 4px solid #81c408;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }
        
        .announcement-item:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transform: translateX(5px);
        }
        
        .announcement-content {
            margin-bottom: 10px;
            color: #333;
            line-height: 1.6;
        }
        
        .announcement-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
            color: #666;
        }
        
        .announcement-time {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-delete {
            background: #dc3545;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s;
        }
        
        .btn-delete:hover {
            background: #c82333;
            transform: translateY(-2px);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 20px;
            color: #ddd;
        }
        
        .char-count {
            text-align: right;
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
        
        .tips-box {
            background: #e8f5e9;
            border-left: 4px solid #4caf50;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }
        
        .tips-box h4 {
            color: #2e7d32;
            margin-bottom: 10px;
            font-size: 14px;
        }
        
        .tips-box ul {
            margin: 0;
            padding-left: 20px;
            color: #558b2f;
        }
        
        .tips-box li {
            margin: 5px 0;
            font-size: 13px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>📢 管理員公告</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="adminDashboard.jsp" class="logout-btn">返回後台</a>
                <a href="adminLogin.jsp?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <a href="adminDashboard.jsp" class="back-btn">← 返回管理後台</a>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <%
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            
            // 統計數據
            String statsSql = "SELECT COUNT(*) as totalUsers FROM users";
            Statement statsStmt = con.createStatement();
            ResultSet statsRs = statsStmt.executeQuery(statsSql);
            int totalUsers = 0;
            if (statsRs.next()) {
                totalUsers = statsRs.getInt("totalUsers");
            }
            statsRs.close();
            statsStmt.close();
            
            // 計算今日發送的公告數
            String todaySql = "SELECT COUNT(DISTINCT message) as todayCount FROM notifications " +
                            "WHERE FORMAT(createdAt, 'yyyy-MM-dd') = FORMAT(NOW(), 'yyyy-MM-dd')";
            Statement todayStmt = con.createStatement();
            ResultSet todayRs = todayStmt.executeQuery(todaySql);
            int todayCount = 0;
            if (todayRs.next()) {
                todayCount = todayRs.getInt("todayCount");
            }
            todayRs.close();
            todayStmt.close();
        %>
        
        <!-- 統計卡片 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number"><%= totalUsers %></div>
                <div class="stat-label">📊 總用戶數</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= todayCount %></div>
                <div class="stat-label">📮 今日已發送</div>
            </div>
        </div>
        
        <!-- 發布公告表單 -->
        <div class="publish-card">
            <h2>
                <i class="fas fa-bullhorn"></i>
                管理員發布公告
            </h2>
            
            <form method="post" action="?action=publish">
                <div class="form-group">
                    <label class="form-label">管理員公告內容 *</label>
                    <textarea 
                        name="announcementMsg" 
                        class="form-control" 
                        placeholder="請輸入要發送給所有用戶的系統通知內容..."
                        required
                        maxlength="500"
                        id="announcementMsg"
                        onkeyup="updateCharCount()"></textarea>
                    <div class="char-count">
                        <span id="charCount">0</span> / 500 字
                    </div>
                </div>
                
                <button type="submit" class="btn-publish">
                    <i class="fas fa-paper-plane"></i> 發送通知給所有用戶
                </button>
                
                <div class="tips-box">
                    <h4><i class="fas fa-lightbulb"></i> 發送提示</h4>
                    <ul>
                        <li>公告將立即發送給所有註冊用戶</li>
                        <li>用戶可在「管理員公告」頁面查看公告</li>
                        <li>建議公告內容簡潔明確，不超過 200 字</li>
                        <li>重要公告可使用 ⚠️ 📢 ✅ 等表情符號增加辨識度</li>
                    </ul>
                </div>
            </form>
        </div>
        
        <!-- 公告歷史記錄 -->
        <div class="history-card">
            <h2>
                <i class="fas fa-history"></i>
                最近發送記錄
            </h2>
            
            <%
            
            // 查詢最近的公告記錄（去重複，只顯示每則公告一次）
            String historySql = "SELECT n.message, MIN(n.createdAt) as createdAt, " +
                              "COUNT(*) as sentCount, MIN(n.notificationId) as notificationId " +
                              "FROM notifications n " +
                              "GROUP BY n.message " +
                              "ORDER BY MIN(n.createdAt) DESC";
            
            Statement historyStmt = con.createStatement();
            ResultSet historyRs = historyStmt.executeQuery(historySql);
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                boolean hasHistory = false;
                
                while (historyRs.next()) {
                    hasHistory = true;
                    int notificationId = historyRs.getInt("notificationId");
                    String msg = historyRs.getString("message");
                    Timestamp createdAt = historyRs.getTimestamp("createdAt");
                    int sentCount = historyRs.getInt("sentCount");
                    
                    String timeStr = sdf.format(createdAt);
            %>
            
            <div class="announcement-item">
                <div class="announcement-content">
                    <%= msg %>
                </div>
                <div class="announcement-meta">
                    <div class="announcement-time">
                        <i class="far fa-clock"></i>
                        <%= timeStr %>
                        <span style="margin-left: 15px;">
                            <i class="fas fa-users"></i>
                            已發送給 <%= sentCount %> 位用戶
                        </span>
                    </div>
                    <button 
                        class="btn-delete" 
                        onclick="deleteAnnouncement(<%= notificationId %>)">
                        <i class="fas fa-trash"></i> 刪除
                    </button>
                </div>
            </div>
            
            <%
                }
                
                if (!hasHistory) {
            %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <h3>尚無發送記錄</h3>
                <p>發布的管理員公告將顯示在這裡</p>
            </div>
            <%
                }
                
                historyRs.close();
                historyStmt.close();
                con.close();
            %>
        </div>
    </div>
    
    <script>
        function updateCharCount() {
            const textarea = document.getElementById('announcementMsg');
            const charCount = document.getElementById('charCount');
            charCount.textContent = textarea.value.length;
        }
        
        function deleteAnnouncement(id) {
            if (confirm('確定要刪除這則公告記錄嗎？\n注意：這只會刪除記錄，不會刪除用戶已收到的通知。')) {
                window.location.href = '?action=delete&announcementId=' + id;
            }
        }
    </script>
</body>
</html>