<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 檢查管理員登入狀態
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 處理審核操作
String action = request.getParameter("action");
String listingId = request.getParameter("listingId");
String message = "";
String messageType = "";

if (action != null && listingId != null) {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    try {
        String approvalStatus = "";
        if ("approve".equals(action)) {
            approvalStatus = "TRUE";
            message = "✅ 書籍已審核通過";
            messageType = "success";
        } else if ("reject".equals(action)) {
            approvalStatus = "FALSE";
            message = "❌ 書籍已拒絕上架";
            messageType = "danger";
        } else if ("pending".equals(action)) {
            approvalStatus = "待審核";
            message = "⏳ 書籍已設為待審核";
            messageType = "warning";
        }
        
        if (!approvalStatus.isEmpty()) {
            String updateSql = "UPDATE bookListings SET Approved = ? WHERE listingId = ?";
            PreparedStatement pstmt = con.prepareStatement(updateSql);
            pstmt.setString(1, approvalStatus);
            pstmt.setInt(2, Integer.parseInt(listingId));
            pstmt.executeUpdate();
            pstmt.close();
        }
    } catch (Exception e) {
        message = "❌ 操作失敗: " + e.getMessage();
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
    <title>書籍審核管理 - 北護二手書交易網</title>
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
        
        .pending { color: #ff9800; }
        .approved { color: #4caf50; }
        .rejected { color: #f44336; }
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
        
        .book-image {
            width: 80px;
            height: 100px;
            object-fit: cover;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-approved {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
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
        }
        
        .btn-approve {
            background-color: #28a745;
            color: white;
        }
        
        .btn-approve:hover {
            background-color: #218838;
            transform: translateY(-2px);
        }
        
        .btn-reject {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-reject:hover {
            background-color: #c82333;
            transform: translateY(-2px);
        }
        
        .btn-pending {
            background-color: #ffc107;
            color: #333;
        }
        
        .btn-pending:hover {
            background-color: #e0a800;
            transform: translateY(-2px);
        }
        
        .btn-view {
            background-color: #17a2b8;
            color: white;
        }
        
        .btn-view:hover {
            background-color: #138496;
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
        }
        
        .book-details h4 {
            margin: 0 0 5px 0;
            font-size: 16px;
            color: #333;
        }
        
        .book-details p {
            margin: 2px 0;
            font-size: 13px;
            color: #666;
        }
        
        .price {
            color: #d9534f;
            font-weight: bold;
            font-size: 16px;
        }

        .info-note {
            background: #e7f3ff;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
            color: #1565c0;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>📚 書籍審核管理</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="adminDashboard.jsp" class="logout-btn">返回後台</a>
                <a href="adminLogin.jsp?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <a href="adminDashboard.jsp" class="back-btn">← 返回管理後台</a>
        
        <div class="info-note">
            💡 此頁面僅顯示上架中的書籍，已下架的書籍不會出現在列表中
        </div>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <%
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            
            // 統計各狀態數量（排除已下架的書籍）
            String statsSql = "SELECT Approved, COUNT(*) as count FROM bookListings " +
                            "WHERE status <> '已下架' " +
                            "GROUP BY Approved";
            Statement statsStmt = con.createStatement();
            ResultSet statsRs = statsStmt.executeQuery(statsSql);
            
            int pendingCount = 0, approvedCount = 0, rejectedCount = 0, totalCount = 0;
            
            while (statsRs.next()) {
                String status = statsRs.getString("Approved");
                int count = statsRs.getInt("count");
                totalCount += count;
                
                if ("待審核".equals(status) || status == null) {
                    pendingCount = count;
                } else if ("TRUE".equalsIgnoreCase(status) || "已審核".equals(status)) {
                    approvedCount = count;
                } else if ("FALSE".equalsIgnoreCase(status) || "未通過".equals(status)) {
                    rejectedCount = count;
                }
            }
            statsRs.close();
            statsStmt.close();
        %>
        
        <!-- 統計卡片 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number pending"><%= pendingCount %></div>
                <div class="stat-label">待審核</div>
            </div>
            <div class="stat-card">
                <div class="stat-number approved"><%= approvedCount %></div>
                <div class="stat-label">已通過</div>
            </div>
            <div class="stat-card">
                <div class="stat-number rejected"><%= rejectedCount %></div>
                <div class="stat-label">已拒絕</div>
            </div>
            <div class="stat-card">
                <div class="stat-number total"><%= totalCount %></div>
                <div class="stat-label">總計（上架中）</div>
            </div>
        </div>
        
        <!-- 篩選標籤 -->
        <div class="filter-tabs">
            <a href="?filter=all" class="filter-tab <%= request.getParameter("filter") == null || "all".equals(request.getParameter("filter")) ? "active" : "" %>">
                全部 (<%= totalCount %>)
            </a>
            <a href="?filter=pending" class="filter-tab <%= "pending".equals(request.getParameter("filter")) ? "active" : "" %>">
                待審核 (<%= pendingCount %>)
            </a>
            <a href="?filter=approved" class="filter-tab <%= "approved".equals(request.getParameter("filter")) ? "active" : "" %>">
                已通過 (<%= approvedCount %>)
            </a>
            <a href="?filter=rejected" class="filter-tab <%= "rejected".equals(request.getParameter("filter")) ? "active" : "" %>">
                已拒絕 (<%= rejectedCount %>)
            </a>
        </div>
        
        <!-- 書籍列表 -->
        <div class="book-table">
            <table>
                <thead>
                    <tr>
                        <th style="width: 100px;">圖片</th>
                        <th>書籍資訊</th>
                        <th style="width: 100px;">價格</th>
                        <th style="width: 120px;">賣家</th>
                        <th style="width: 100px;">上架日期</th>
                        <th style="width: 100px;">審核狀態</th>
                        <th style="width: 200px;">操作</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String filter = request.getParameter("filter");
                        // 關鍵修改：加入 status <> '已下架' 條件，排除已下架的書籍
                        String sql = "SELECT bl.listingId, bl.bookId, bl.price, bl.photo, bl.Approved, " +
                                   "bl.listedAt, bl.status, b.title, b.author, u.name AS sellerName " +
                                   "FROM bookListings bl " +
                                   "INNER JOIN books b ON bl.bookId = b.bookId " +
                                   "INNER JOIN users u ON bl.sellerId = u.userId " +
                                   "WHERE bl.status <> '已下架' ";
                        
                        if ("pending".equals(filter)) {
                            sql += "AND (bl.Approved = '待審核' OR bl.Approved IS NULL) ";
                        } else if ("approved".equals(filter)) {
                            sql += "AND (bl.Approved = 'TRUE' OR bl.Approved = '已審核') ";
                        } else if ("rejected".equals(filter)) {
                            sql += "AND (bl.Approved = 'FALSE' OR bl.Approved = '未通過') ";
                        }
                        
                        sql += "ORDER BY bl.listedAt DESC";
                        
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        boolean hasBooks = false;
                        while (rs.next()) {
                            hasBooks = true;
                            String photoStr = rs.getString("photo");
                            String photoPath = "assets/images/about.png";
                            
                            if (photoStr != null && !photoStr.trim().isEmpty()) {
                                String firstPhoto = photoStr.split(",")[0].trim();
                                if (!firstPhoto.startsWith("assets/")) {
                                    firstPhoto = "assets/images/member/" + firstPhoto;
                                }
                                photoPath = firstPhoto;
                            }
                            
                            String approvalStatus = rs.getString("Approved");
                            String statusText = "待審核";
                            String statusClass = "status-pending";
                            
                            if ("TRUE".equalsIgnoreCase(approvalStatus) || "已審核".equals(approvalStatus)) {
                                statusText = "已通過";
                                statusClass = "status-approved";
                            } else if ("FALSE".equalsIgnoreCase(approvalStatus) || "未通過".equals(approvalStatus)) {
                                statusText = "已拒絕";
                                statusClass = "status-rejected";
                            }
                    %>
                    <tr>
                        <td>
                            <img src="<%= photoPath %>" 
                                 alt="書籍圖片" 
                                 class="book-image"
                                 onerror="this.src='assets/images/about.png'">
                        </td>
                        <td>
                            <div class="book-details">
                                <h4><%= rs.getString("title") %></h4>
                                <p>作者: <%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></p>
                                <p>書籍ID: <%= rs.getString("bookId") %></p>
                                <p>上架ID: <%= rs.getString("listingId") %></p>
                            </div>
                        </td>
                        <td>
                            <span class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></span>
                        </td>
                        <td><%= rs.getString("sellerName") %></td>
                        <td><%= rs.getString("listedAt").split(" ")[0] %></td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= statusText %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="bookDetail.jsp?listingId=<%= rs.getString("listingId") %>" 
                                   class="btn-action btn-view" 
                                   target="_blank">
                                    👁️ 查看
                                </a>
                                <a href="?action=approve&listingId=<%= rs.getString("listingId") %><%= filter != null ? "&filter=" + filter : "" %>" 
                                   class="btn-action btn-approve"
                                   onclick="return confirm('確定要通過這本書的審核嗎？')">
                                    ✓ 通過
                                </a>
                                <a href="?action=reject&listingId=<%= rs.getString("listingId") %><%= filter != null ? "&filter=" + filter : "" %>" 
                                   class="btn-action btn-reject"
                                   onclick="return confirm('確定要拒絕這本書的上架嗎？')">
                                    ✗ 拒絕
                                </a>
                                <a href="?action=pending&listingId=<%= rs.getString("listingId") %><%= filter != null ? "&filter=" + filter : "" %>" 
                                   class="btn-action btn-pending"
                                   onclick="return confirm('確定要改為待審核狀態嗎？')">
                                    ⏳ 待審
                                </a>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        
                        if (!hasBooks) {
                    %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div style="font-size: 64px;">📚</div>
                                <h3>暫無書籍資料</h3>
                                <p>目前沒有符合條件的上架中書籍</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        
                        rs.close();
                        stmt.close();
                        con.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>