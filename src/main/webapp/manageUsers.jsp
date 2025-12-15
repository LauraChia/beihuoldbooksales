<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.*" %>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 檢查管理員登入狀態
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 處理表單提交
String action = request.getParameter("action");
String message = "";
String messageType = "";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String dbURL = "jdbc:ucanaccess://"+objDBConfig.FilePath()+";";

try {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    conn = DriverManager.getConnection(dbURL);
    
    if (action != null) {
        if (action.equals("add")) {
            // 新增使用者
            String name = request.getParameter("name");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String contact = request.getParameter("contact");
            String department = request.getParameter("department");
            
            String sql = "INSERT INTO users (name, username, password, contact, department, isVerified, lastLogin) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setString(2, username);
            pstmt.setString(3, password);
            pstmt.setString(4, contact);
            pstmt.setString(5, department);
            pstmt.setBoolean(6, false);
            pstmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                message = "✅ 使用者新增成功";
                messageType = "success";
            } else {
                message = "❌ 使用者新增失敗";
                messageType = "danger";
            }
            pstmt.close();
        } 
        else if (action.equals("edit")) {
            // 編輯使用者
            int userId = Integer.parseInt(request.getParameter("userId"));
            String name = request.getParameter("name");
            String username = request.getParameter("username");
            String contact = request.getParameter("contact");
            String department = request.getParameter("department");
            
            String sql = "UPDATE users SET name=?, username=?, contact=?, department=? WHERE userId=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setString(2, username);
            pstmt.setString(3, contact);
            pstmt.setString(4, department);
            pstmt.setInt(5, userId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                message = "✅ 使用者資料更新成功";
                messageType = "success";
            } else {
                message = "❌ 使用者資料更新失敗";
                messageType = "danger";
            }
            pstmt.close();
        }
        else if (action.equals("delete")) {
            // 刪除使用者
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            String sql = "DELETE FROM users WHERE userId=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                message = "✅ 使用者刪除成功";
                messageType = "success";
            } else {
                message = "❌ 使用者刪除失敗";
                messageType = "danger";
            }
            pstmt.close();
        }
        else if (action.equals("resetPassword")) {
            // 重設密碼
            int userId = Integer.parseInt(request.getParameter("userId"));
            String newPassword = request.getParameter("newPassword");
            
            String sql = "UPDATE users SET password=?, resetToken=NULL, resetTokenExpiry=NULL WHERE userId=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newPassword);
            pstmt.setInt(2, userId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                message = "✅ 密碼重設成功";
                messageType = "success";
            } else {
                message = "❌ 密碼重設失敗";
                messageType = "danger";
            }
            pstmt.close();
        }
        else if (action.equals("toggleVerification")) {
            // 切換驗證狀態
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean currentStatus = Boolean.parseBoolean(request.getParameter("currentStatus"));
            
            String sql = "UPDATE users SET isVerified=? WHERE userId=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, !currentStatus);
            pstmt.setInt(2, userId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                message = "✅ 驗證狀態更新成功";
                messageType = "success";
            } else {
                message = "❌ 驗證狀態更新失敗";
                messageType = "danger";
            }
            pstmt.close();
        }
    }
    
} catch (Exception e) {
    message = "❌ 操作失敗: " + e.getMessage();
    messageType = "danger";
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>使用者管理 - 北護二手書交易網</title>
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
        
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-tab {
            padding: 10px 20px;
            background: white;
            border: 2px solid #ddd;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
            text-decoration: none;
            color: #333;
        }
        
        .filter-tab:hover {
            border-color: #81c408;
            color: #81c408;
        }
        
        .filter-tab.active {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
            border-color: transparent;
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
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .verified { color: #4caf50; }
        .unverified { color: #ff9800; }
        .total { color: #2196f3; }
        
        .book-table {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 14px;
        }
        
        tr:hover {
            background-color: #f8f9fa;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-verified {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-unverified {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            color: white;
        }
        
        .btn-info {
            background-color: #17a2b8;
        }
        
        .btn-info:hover {
            background-color: #138496;
            transform: translateY(-2px);
        }
        
        .btn-warning {
            background-color: #ffc107;
            color: #333;
        }
        
        .btn-warning:hover {
            background-color: #e0a800;
            transform: translateY(-2px);
        }
        
        .btn-success {
            background-color: #28a745;
        }
        
        .btn-success:hover {
            background-color: #218838;
            transform: translateY(-2px);
        }
        
        .btn-danger {
            background-color: #dc3545;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
            transform: translateY(-2px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(129, 196, 8, 0.4);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 20px;
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #81c408;
            text-decoration: none;
            font-size: 14px;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 1000;
            overflow-y: auto;
        }
        
        .modal-content {
            background: white;
            margin: 50px auto;
            padding: 0;
            width: 90%;
            max-width: 600px;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
            animation: slideDown 0.3s ease-out;
        }
        
        .modal-header {
            background: linear-gradient(135deg, #81c408 0%, #6ba006 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 1.8em;
        }
        
        .close {
            color: white;
            font-size: 35px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
            transition: all 0.3s;
        }
        
        .close:hover {
            transform: rotate(90deg);
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            font-size: 16px;
            transition: all 0.3s;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #81c408;
            box-shadow: 0 0 0 3px rgba(129, 196, 8, 0.1);
        }
        
        .search-bar {
            padding: 20px;
            background: white;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .search-bar input {
            flex: 1;
            padding: 12px 20px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            font-size: 16px;
            transition: all 0.3s;
        }
        
        .search-bar input:focus {
            outline: none;
            border-color: #81c408;
            box-shadow: 0 0 0 3px rgba(129, 196, 8, 0.1);
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>👥 使用者管理</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="adminDashboard.jsp" class="logout-btn">返回後台</a>
                <a href="adminLogin.jsp?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <a href="adminDashboard.jsp" class="back-link">← 返回管理後台</a>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <%
            try {
                if (conn == null || conn.isClosed()) {
                    conn = DriverManager.getConnection(dbURL);
                }
                
                // 統計各狀態數量
                String statsSql = "SELECT isVerified, COUNT(*) as count FROM users GROUP BY isVerified";
                Statement statsStmt = conn.createStatement();
                ResultSet statsRs = statsStmt.executeQuery(statsSql);
                
                int verifiedCount = 0, unverifiedCount = 0, totalCount = 0;
                
                while (statsRs.next()) {
                    boolean isVerified = statsRs.getBoolean("isVerified");
                    int count = statsRs.getInt("count");
                    totalCount += count;
                    
                    if (isVerified) {
                        verifiedCount = count;
                    } else {
                        unverifiedCount = count;
                    }
                }
                statsRs.close();
                statsStmt.close();
        %>
        
        <!-- 統計卡片 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number verified"><%= verifiedCount %></div>
                <div class="stat-label">已驗證</div>
            </div>
            <div class="stat-card">
                <div class="stat-number unverified"><%= unverifiedCount %></div>
                <div class="stat-label">未驗證</div>
            </div>
            <div class="stat-card">
                <div class="stat-number total"><%= totalCount %></div>
                <div class="stat-label">總計</div>
            </div>
        </div>
        
        <!-- 搜尋列與新增按鈕 -->
        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="🔍 搜尋使用者（姓名、帳號、部門）..." onkeyup="searchUsers()">
            <button class="btn-primary" onclick="openAddModal()">➕ 新增使用者</button>
        </div>
        
        <!-- 篩選標籤 -->
        <div class="filter-tabs">
            <a href="?filter=all" class="filter-tab <%= request.getParameter("filter") == null || "all".equals(request.getParameter("filter")) ? "active" : "" %>">
                全部 (<%= totalCount %>)
            </a>
            <a href="?filter=verified" class="filter-tab <%= "verified".equals(request.getParameter("filter")) ? "active" : "" %>">
                已驗證 (<%= verifiedCount %>)
            </a>
            <a href="?filter=unverified" class="filter-tab <%= "unverified".equals(request.getParameter("filter")) ? "active" : "" %>">
                未驗證 (<%= unverifiedCount %>)
            </a>
        </div>
        
        <!-- 使用者列表 -->
        <div class="book-table">
            <table id="usersTable">
                <thead>
                    <tr>
                        <th style="width: 80px;">ID</th>
                        <th>姓名</th>
                        <th>帳號</th>
                        <th>聯絡方式</th>
                        <th>部門</th>
                        <th style="width: 100px;">驗證狀態</th>
                        <th style="width: 150px;">最後登入</th>
                        <th style="width: 280px;">操作</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String filter = request.getParameter("filter");
                        String sql = "SELECT * FROM users";
                        
                        if ("verified".equals(filter)) {
                            sql += " WHERE isVerified = TRUE";
                        } else if ("unverified".equals(filter)) {
                            sql += " WHERE isVerified = FALSE";
                        }
                        
                        sql += " ORDER BY userId DESC";
                        
                        Statement stmt = conn.createStatement();
                        rs = stmt.executeQuery(sql);
                        
                        boolean hasUsers = false;
                        while (rs.next()) {
                            hasUsers = true;
                            int userId = rs.getInt("userId");
                            String name = rs.getString("name");
                            String username = rs.getString("username");
                            String contact = rs.getString("contact");
                            String department = rs.getString("department");
                            boolean isVerified = rs.getBoolean("isVerified");
                            Timestamp lastLogin = rs.getTimestamp("lastLogin");
                            
                            String statusText = isVerified ? "已驗證" : "未驗證";
                            String statusClass = isVerified ? "status-verified" : "status-unverified";
                    %>
                    <tr>
                        <td><%= userId %></td>
                        <td><%= name != null ? name : "" %></td>
                        <td><%= username != null ? username : "" %></td>
                        <td><%= contact != null ? contact : "" %></td>
                        <td><%= department != null ? department : "" %></td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= isVerified ? "✓" : "✗" %> <%= statusText %>
                            </span>
                        </td>
                        <td><%= lastLogin != null ? lastLogin.toString().split("\\.")[0] : "從未登入" %></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-action btn-info" onclick="openEditModal(<%= userId %>, '<%= name != null ? name.replace("'", "\\'") : "" %>', '<%= username != null ? username.replace("'", "\\'") : "" %>', '<%= contact != null ? contact.replace("'", "\\'") : "" %>', '<%= department != null ? department.replace("'", "\\'") : "" %>')">✏️ 編輯</button>
                                <button class="btn-action btn-warning" onclick="openResetPasswordModal(<%= userId %>, '<%= name != null ? name.replace("'", "\\'") : "" %>')">🔑 重設</button>
                                <form method="post" style="display:inline;" onsubmit="return confirm('確定要切換驗證狀態嗎？');">
                                    <input type="hidden" name="action" value="toggleVerification">
                                    <input type="hidden" name="userId" value="<%= userId %>">
                                    <input type="hidden" name="currentStatus" value="<%= isVerified %>">
                                    <button type="submit" class="btn-action btn-success">
                                        <%= isVerified ? "❌ 取消" : "✓ 驗證" %>
                                    </button>
                                </form>
                                <form method="post" style="display:inline;" onsubmit="return confirm('確定要刪除此使用者嗎？此操作無法復原！');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="<%= userId %>">
                                    <button type="submit" class="btn-action btn-danger">🗑️ 刪除</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        
                        if (!hasUsers) {
                    %>
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <div style="font-size: 64px;">👥</div>
                                <h3>暫無使用者資料</h3>
                                <p>目前沒有符合條件的使用者</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        
                        rs.close();
                        stmt.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='8' style='color:red;text-align:center;'>錯誤：" + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (Exception e) {}
                        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                        if (conn != null) try { conn.close(); } catch (Exception e) {}
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- 新增使用者 Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>➕ 新增使用者</h2>
                <span class="close" onclick="closeAddModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form method="post">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-group">
                        <label>姓名 *</label>
                        <input type="text" name="name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>帳號 *</label>
                        <input type="text" name="username" required>
                    </div>
                    
                    <div class="form-group">
                        <label>密碼 *</label>
                        <input type="password" name="password" required>
                    </div>
                    
                    <div class="form-group">
                        <label>聯絡方式</label>
                        <input type="text" name="contact">
                    </div>
                    
                    <div class="form-group">
                        <label>部門</label>
                        <input type="text" name="department">
                    </div>
                    
                    <button type="submit" class="btn-primary" style="width:100%;">✓ 新增使用者</button>
                </form>
            </div>
        </div>
    </div>
    
    <!-- 編輯使用者 Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>✏️ 編輯使用者</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form method="post">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="userId" id="editUserId">
                    
                    <div class="form-group">
                        <label>姓名 *</label>
                        <input type="text" name="name" id="editName" required>
                    </div>
                    
                    <div class="form-group">
                        <label>帳號 *</label>
                        <input type="text" name="username" id="editUsername" required>
                    </div>
                    
                    <div class="form-group">
                        <label>聯絡方式</label>
                        <input type="text" name="contact" id="editContact">
                    </div>
                    
                    <div class="form-group">
                        <label>部門</label>
                        <input type="text" name="department" id="editDepartment">
                    </div>
                    
                    <button type="submit" class="btn-primary" style="width:100%;">✓ 更新資料</button>
                </form>
            </div>
    
    <!-- 編輯使用者 Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>✏️ 編輯使用者</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form method="post">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="userId" id="editUserId">
                    
                    <div class="form-group">
                        <label>姓名 *</label>
                        <input type="text" name="name" id="editName" required>
                    </div>
                    
                    <div class="form-group">
                        <label>帳號 *</label>
                        <input type="text" name="username" id="editUsername" required>
                    </div>
                    
                    <div class="form-group">
                        <label>聯絡方式</label>
                        <input type="text" name="contact" id="editContact">
                    </div>
                    
                    <div class="form-group">
                        <label>部門</label>
                        <input type="text" name="department" id="editDepartment">
                    </div>
                    
                    <button type="submit" class="btn btn-primary" style="width:100%;">✓ 更新資料</button>
                </form>
            </div>
        </div>
    </div>
    
    <!-- 重設密碼 Modal -->
    <div id="resetPasswordModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>🔑 重設密碼</h2>
                <span class="close" onclick="closeResetPasswordModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form method="post">
                    <input type="hidden" name="action" value="resetPassword">
                    <input type="hidden" name="userId" id="resetUserId">
                    
                    <div class="form-group">
                        <label>使用者</label>
                        <input type="text" id="resetUserName" disabled style="background:#f0f0f0;">
                    </div>
                    
                    <div class="form-group">
                        <label>新密碼 *</label>
                        <input type="password" name="newPassword" required>
                    </div>
                    
                    <div class="form-group">
                        <label>確認新密碼 *</label>
                        <input type="password" id="confirmPassword" required>
                    </div>
                    
                    <button type="submit" class="btn btn-warning" style="width:100%;" onclick="return validatePassword()">🔑 重設密碼</button>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // 新增 Modal
        function openAddModal() {
            document.getElementById('addModal').style.display = 'block';
        }
        
        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
        }
        
        // 編輯 Modal
        function openEditModal(userId, name, username, contact, department) {
            document.getElementById('editUserId').value = userId;
            document.getElementById('editName').value = name;
            document.getElementById('editUsername').value = username;
            document.getElementById('editContact').value = contact || '';
            document.getElementById('editDepartment').value = department || '';
            document.getElementById('editModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }
        
        // 重設密碼 Modal
        function openResetPasswordModal(userId, name) {
            document.getElementById('resetUserId').value = userId;
            document.getElementById('resetUserName').value = name;
            document.getElementById('resetPasswordModal').style.display = 'block';
        }
        
        function closeResetPasswordModal() {
            document.getElementById('resetPasswordModal').style.display = 'none';
        }
        
        // 驗證密碼
        function validatePassword() {
            var newPassword = document.querySelector('input[name="newPassword"]').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                alert('密碼與確認密碼不相符！');
                return false;
            }
            
            return confirm('確定要重設此使用者的密碼嗎？');
        }
        
        // 搜尋功能
        function searchUsers() {
            var input = document.getElementById('searchInput');
            var filter = input.value.toUpperCase();
            var table = document.getElementById('usersTable');
            var tr = table.getElementsByTagName('tr');
            
            for (var i = 1; i < tr.length; i++) {
                var td = tr[i].getElementsByTagName('td');
                var found = false;
                
                for (var j = 0; j < td.length - 1; j++) {
                    if (td[j]) {
                        var txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    tr[i].style.display = '';
                } else {
                    tr[i].style.display = 'none';
                }
            }
        }
        
        // 點擊 Modal 外部關閉
        window.onclick = function(event) {
            var addModal = document.getElementById('addModal');
            var editModal = document.getElementById('editModal');
            var resetModal = document.getElementById('resetPasswordModal');
            
            if (event.target == addModal) {
                closeAddModal();
            }
            if (event.target == editModal) {
                closeEditModal();
            }
            if (event.target == resetModal) {
                closeResetPasswordModal();
            }
        }
        
    </script>
    <div style="display: flex; justify-content: center; align-items: center; min-height: 10vh;">
    <button type="button" class="btn btn-primary btn-lg" onclick="window.location.href='adminDashboard.jsp'">返回後台</button>
</div>
</div>
</body>
</html>