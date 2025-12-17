<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<%
// 檢查是否已登入
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 處理登出
String action = request.getParameter("action");
if ("logout".equals(action)) {
    session.invalidate();
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 獲取篩選參數
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");
String sellerSearch = request.getParameter("sellerSearch");
String bookSearch = request.getParameter("bookSearch");
String reasonFilter = request.getParameter("reasonFilter");
String statusFilter = request.getParameter("statusFilter");
int currentPage = 1;
int recordsPerPage = 20;

try {
    currentPage = Integer.parseInt(request.getParameter("page"));
} catch (Exception e) {
    currentPage = 1;
}

// 統計數據
int totalRecords = 0;
int autoExpired = 0;
int manualDelisted = 0;
int violation = 0;
int userRequested = 0;
int relisted = 0;

List<Map<String, String>> records = new ArrayList<>();

try {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection conn = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 構建查詢條件
    StringBuilder whereClause = new StringBuilder("WHERE (bl.isDelisted = True OR bl.isDelisted = -1)");
    List<Object> params = new ArrayList<>();  // 改用 Object 以支援不同類型
    
    if (startDate != null && !startDate.isEmpty()) {
        whereClause.append(" AND bl.delistedAt >= ?");
        params.add(java.sql.Timestamp.valueOf(startDate + " 00:00:00"));
    }
    if (endDate != null && !endDate.isEmpty()) {
        whereClause.append(" AND bl.delistedAt <= ?");
        params.add(java.sql.Timestamp.valueOf(endDate + " 23:59:59"));
    }
    if (sellerSearch != null && !sellerSearch.trim().isEmpty()) {
        whereClause.append(" AND (u.name LIKE ? OR u.username LIKE ?)");
        params.add("%" + sellerSearch.trim() + "%");
        params.add("%" + sellerSearch.trim() + "%");
    }
    if (bookSearch != null && !bookSearch.trim().isEmpty()) {
        whereClause.append(" AND b.title LIKE ?");
        params.add("%" + bookSearch.trim() + "%");
    }
    if (reasonFilter != null && !reasonFilter.isEmpty() && !"ALL".equals(reasonFilter)) {
        whereClause.append(" AND bl.delistReason = ?");
        params.add(reasonFilter);
    }
    if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
        if ("RELISTED".equals(statusFilter)) {
            whereClause.append(" AND bl.relistingCount > 0");
        } else if ("DELISTED".equals(statusFilter)) {
            whereClause.append(" AND bl.relistingCount = 0");
        }
    }
    
    // 查詢統計數據
    String statsSQL = "SELECT " +
        "COUNT(*) as total, " +
        "SUM(IIF(delistReason = 'AUTO_EXPIRED', 1, 0)) as auto, " +
        "SUM(IIF(delistReason = 'MANUAL_ADMIN', 1, 0)) as manual, " +
        "SUM(IIF(delistReason = 'VIOLATION', 1, 0)) as violation, " +
        "SUM(IIF(delistReason = 'USER_REQUEST', 1, 0)) as userReq, " +
        "SUM(IIF(relistingCount > 0, 1, 0)) as relisted " +
        "FROM bookListings bl " +
        "JOIN books b ON bl.bookId = b.bookId " +
        "JOIN users u ON bl.sellerId = u.userId " + 
        whereClause.toString();
    
    PreparedStatement statsStmt = conn.prepareStatement(statsSQL);
    for (int i = 0; i < params.size(); i++) {
        Object param = params.get(i);
        if (param instanceof java.sql.Timestamp) {
            statsStmt.setTimestamp(i + 1, (java.sql.Timestamp)param);
        } else {
            statsStmt.setString(i + 1, param.toString());
        }
    }
    
    ResultSet statsRs = statsStmt.executeQuery();
    if (statsRs.next()) {
        totalRecords = statsRs.getInt("total");
        autoExpired = statsRs.getInt("auto");
        manualDelisted = statsRs.getInt("manual");
        violation = statsRs.getInt("violation");
        userRequested = statsRs.getInt("userReq");
        relisted = statsRs.getInt("relisted");
    }
    statsRs.close();
    statsStmt.close();
    
    // 查詢詳細記錄 - 使用 Access 的分頁方式
    int topCount = currentPage * recordsPerPage;
    String recordsSQL = 
        "SELECT TOP " + recordsPerPage + " * FROM (" +
        "    SELECT TOP " + topCount + " " +
        "    bl.listingId, bl.delistedAt, bl.listedAt, bl.expiryDate, " +
        "    bl.delistReason, bl.delistedBy, bl.relistingCount, bl.price, " +
        "    b.title, b.ISBN, b.author, " +
        "    u.name as sellerName, u.username as sellerEmail " +
        "    FROM bookListings bl " +
        "    JOIN books b ON bl.bookId = b.bookId " +
        "    JOIN users u ON bl.sellerId = u.userId " +
        whereClause.toString() + " " +
        "    ORDER BY bl.delistedAt DESC" +
        ") AS temp " +
        "ORDER BY delistedAt ASC";
    
    PreparedStatement recordsStmt = conn.prepareStatement(recordsSQL);
    for (int i = 0; i < params.size(); i++) {
        Object param = params.get(i);
        if (param instanceof java.sql.Timestamp) {
            recordsStmt.setTimestamp(i + 1, (java.sql.Timestamp)param);
        } else {
            recordsStmt.setString(i + 1, param.toString());
        }
    }
    
    ResultSet rs = recordsStmt.executeQuery();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    while (rs.next()) {
        Map<String, String> record = new HashMap<>();
        record.put("listingId", rs.getString("listingId"));
        record.put("delistedAt", rs.getTimestamp("delistedAt") != null ? 
            sdf.format(rs.getTimestamp("delistedAt")) : "");
        record.put("listedAt", rs.getTimestamp("listedAt") != null ? 
            sdf.format(rs.getTimestamp("listedAt")) : "");
        record.put("expiryDate", rs.getTimestamp("expiryDate") != null ? 
            sdf.format(rs.getTimestamp("expiryDate")) : "");
        record.put("delistReason", rs.getString("delistReason"));
        record.put("delistedBy", rs.getString("delistedBy"));
        record.put("relistingCount", rs.getString("relistingCount"));
        record.put("price", rs.getString("price"));
        record.put("title", rs.getString("title"));
        record.put("ISBN", rs.getString("ISBN"));
        record.put("author", rs.getString("author"));
        record.put("sellerName", rs.getString("sellerName"));
        record.put("sellerEmail", rs.getString("sellerEmail"));
        records.add(record);
    }
    
    rs.close();
    recordsStmt.close();
    conn.close();
    
} catch (Exception e) {
    out.println("<div class='error'>資料庫錯誤: " + e.getMessage() + "</div>");
    e.printStackTrace();
}

int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>下架紀錄查詢 - 北護二手書交易網</title>
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
        
        .page-title {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .page-title h2 {
            color: #333;
            font-size: 26px;
            margin-bottom: 5px;
        }
        
        .page-title p {
            color: #666;
            font-size: 14px;
        }
        
        .filter-section {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .filter-section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 18px;
            border-bottom: 2px solid #81c408;
            padding-bottom: 10px;
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .filter-item {
            display: flex;
            flex-direction: column;
        }
        
        .filter-item label {
            color: #555;
            font-size: 14px;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        .filter-item input,
        .filter-item select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .filter-item input:focus,
        .filter-item select:focus {
            outline: none;
            border-color: #81c408;
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .btn {
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: #81c408;
            color: white;
        }
        
        .btn-primary:hover {
            background: #6ba307;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(129, 196, 8, 0.3);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        
        .stat-card .icon {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .stat-card .number {
            font-size: 28px;
            font-weight: bold;
            color: #81c408;
            margin-bottom: 5px;
        }
        
        .stat-card .label {
            color: #666;
            font-size: 14px;
        }
        
        .table-section {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .table-header h3 {
            color: #333;
            font-size: 18px;
        }
        
        .export-btn {
            background: #28a745;
            color: white;
            padding: 8px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .export-btn:hover {
            background: #218838;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1200px;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        th {
            background: #f8f9fa;
            color: #333;
            font-weight: 600;
            font-size: 14px;
            white-space: nowrap;
        }
        
        td {
            color: #555;
            font-size: 13px;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-auto {
            background: #e3f2fd;
            color: #1976d2;
        }
        
        .badge-manual {
            background: #fff3e0;
            color: #f57c00;
        }
        
        .badge-violation {
            background: #ffebee;
            color: #c62828;
        }
        
        .badge-user {
            background: #f3e5f5;
            color: #7b1fa2;
        }
        
        .badge-relisted {
            background: #e8f5e9;
            color: #2e7d32;
        }
        
        .detail-btn {
            background: #81c408;
            color: white;
            padding: 5px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s;
        }
        
        .detail-btn:hover {
            background: #6ba307;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 25px;
        }
        
        .pagination a,
        .pagination span {
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            text-decoration: none;
            color: #333;
            transition: all 0.3s;
        }
        
        .pagination a:hover {
            background: #81c408;
            color: white;
            border-color: #81c408;
        }
        
        .pagination .active {
            background: #81c408;
            color: white;
            border-color: #81c408;
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 16px;
        }
        
        .error {
            background: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>📚 北護二手書交易網 - 管理後台</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <a href="adminDashboard.jsp" class="back-btn">← 返回管理後台</a>
        
        <div class="page-title">
            <h2>📊 下架紀錄查詢</h2>
            <p>查詢和管理所有書籍下架記錄，包含自動到期、手動下架、違規處理等</p>
        </div>
        
        <!-- 篩選區 -->
        <div class="filter-section">
            <h3>🔍 查詢條件</h3>
            <form method="GET" action="">
                <div class="filter-grid">
                    <div class="filter-item">
                        <label>開始日期</label>
                        <input type="date" name="startDate" value="<%= startDate != null ? startDate : "" %>">
                    </div>
                    <div class="filter-item">
                        <label>結束日期</label>
                        <input type="date" name="endDate" value="<%= endDate != null ? endDate : "" %>">
                    </div>
                    <div class="filter-item">
                        <label>賣家姓名/帳號</label>
                        <input type="text" name="sellerSearch" placeholder="輸入賣家姓名或Email" 
                               value="<%= sellerSearch != null ? sellerSearch : "" %>">
                    </div>
                    <div class="filter-item">
                        <label>書籍名稱</label>
                        <input type="text" name="bookSearch" placeholder="輸入書名關鍵字" 
                               value="<%= bookSearch != null ? bookSearch : "" %>">
                    </div>
                    <div class="filter-item">
                        <label>下架原因</label>
                        <select name="reasonFilter">
                            <option value="ALL" <%= "ALL".equals(reasonFilter) || reasonFilter == null ? "selected" : "" %>>全部</option>
                            <option value="自動到期下架" <%= "自動到期下架".equals(reasonFilter) ? "selected" : "" %>>自動到期</option>
                            <option value="管理員下架" <%= "管理員下架".equals(reasonFilter) ? "selected" : "" %>>管理員下架</option>
                            <option value="違規下架" <%= "違規下架".equals(reasonFilter) ? "selected" : "" %>>違規下架</option>
                            <option value="使用者自行下架" <%= "使用者自行下架".equals(reasonFilter) ? "selected" : "" %>>使用者自行下架</option>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label>重新上架狀態</label>
                        <select name="statusFilter">
                            <option value="ALL" <%= "ALL".equals(statusFilter) || statusFilter == null ? "selected" : "" %>>全部</option>
                            <option value="RELISTED" <%= "RELISTED".equals(statusFilter) ? "selected" : "" %>>已重新上架</option>
                            <option value="DELISTED" <%= "DELISTED".equals(statusFilter) ? "selected" : "" %>>尚未重新上架</option>
                        </select>
                    </div>
                </div>
                <div class="filter-buttons">
                    <button type="submit" class="btn btn-primary">🔍 查詢</button>
                    <a href="delistingRecords.jsp" class="btn btn-secondary">清除條件</a>
                </div>
            </form>
        </div>
        
        <!-- 統計區 -->
        <div class="stats-section">
            <div class="stat-card">
                <div class="icon">📦</div>
                <div class="number"><%= totalRecords %></div>
                <div class="label">總下架筆數</div>
            </div>
            <div class="stat-card">
                <div class="icon">⏰</div>
                <div class="number"><%= autoExpired %></div>
                <div class="label">自動到期</div>
            </div>
            <div class="stat-card">
                <div class="icon">👨‍💼</div>
                <div class="number"><%= manualDelisted %></div>
                <div class="label">管理員下架</div>
            </div>
            <div class="stat-card">
                <div class="icon">⚠️</div>
                <div class="number"><%= violation %></div>
                <div class="label">違規下架</div>
            </div>
            <div class="stat-card">
                <div class="icon">👤</div>
                <div class="number"><%= userRequested %></div>
                <div class="label">使用者下架</div>
            </div>
            <div class="stat-card">
                <div class="icon">🔄</div>
                <div class="number"><%= relisted %></div>
                <div class="label">已重新上架</div>
            </div>
        </div>
        
        <!-- 資料表格區 -->
        <div class="table-section">
            <div class="table-header">
                <h3>📋 下架記錄明細 (共 <%= totalRecords %> 筆)</h3>
                <button class="export-btn" onclick="exportToExcel()">📥 匯出 Excel</button>
            </div>
            
            <% if (records.isEmpty()) { %>
                <div class="no-data">
                    😔 查無下架記錄
                </div>
            <% } else { %>
                <table id="recordsTable">
                    <thead>
                        <tr>
                            <th>下架時間</th>
                            <th>書籍資訊</th>
                            <th>ISBN</th>
                            <th>作者</th>
                            <th>賣家</th>
                            <th>售價</th>
                            <th>上架時間</th>
                            <th>原到期日</th>
                            <th>下架原因</th>
                            <th>執行者</th>
                            <th>重新上架次數</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> record : records) { 
                            String reason = record.get("delistReason");
                            String badgeClass = "";
                            String reasonText = "";
                            
                            if ("AUTO_EXPIRED".equals(reason)) {
                                badgeClass = "badge-auto";
                                reasonText = "自動到期";
                            } else if ("MANUAL_ADMIN".equals(reason)) {
                                badgeClass = "badge-manual";
                                reasonText = "管理員下架";
                            } else if ("VIOLATION".equals(reason)) {
                                badgeClass = "badge-violation";
                                reasonText = "違規下架";
                            } else if ("USER_REQUEST".equals(reason)) {
                                badgeClass = "badge-user";
                                reasonText = "使用者下架";
                            } else {
                                badgeClass = "badge-auto";
                                reasonText = reason != null ? reason : "未知";
                            }
                            
                            int relistCount = 0;
                            try {
                                relistCount = Integer.parseInt(record.get("relistingCount"));
                            } catch (Exception e) {}
                        %>
                        <tr>
                            <td><%= record.get("delistedAt") %></td>
                            <td><strong><%= record.get("title") %></strong></td>
                            <td><%= record.get("ISBN") != null ? record.get("ISBN") : "-" %></td>
                            <td><%= record.get("author") != null ? record.get("author") : "-" %></td>
                            <td>
                                <%= record.get("sellerName") %><br>
                                <small style="color: #999;"><%= record.get("sellerEmail") %></small>
                            </td>
                            <td>NT$ <%= record.get("price") %></td>
                            <td><%= record.get("listedAt") %></td>
                            <td><%= record.get("expiryDate") %></td>
                            <td><span class="badge <%= badgeClass %>"><%= reasonText %></span></td>
                            <td><%= record.get("delistedBy") != null ? record.get("delistedBy") : "系統" %></td>
                            <td>
                                <% if (relistCount > 0) { %>
                                    <span class="badge badge-relisted"><%= relistCount %> 次</span>
                                <% } else { %>
                                    <span style="color: #999;">0 次</span>
                                <% } %>
                            </td>
                            <td>
                                <button class="detail-btn" onclick="viewDetail('<%= record.get("listingId") %>')">
                                    詳情
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <!-- 分頁 -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="?page=<%= currentPage - 1 %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>&sellerSearch=<%= sellerSearch != null ? sellerSearch : "" %>&bookSearch=<%= bookSearch != null ? bookSearch : "" %>&reasonFilter=<%= reasonFilter != null ? reasonFilter : "" %>&statusFilter=<%= statusFilter != null ? statusFilter : "" %>">
                            « 上一頁
                        </a>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    
                    for (int i = startPage; i <= endPage; i++) { 
                        if (i == currentPage) {
                    %>
                        <span class="active"><%= i %></span>
                    <% } else { %>
                        <a href="?page=<%= i %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>&sellerSearch=<%= sellerSearch != null ? sellerSearch : "" %>&bookSearch=<%= bookSearch != null ? bookSearch : "" %>&reasonFilter=<%= reasonFilter != null ? reasonFilter :
                        "" %>&statusFilter=<%= statusFilter != null ? statusFilter : "" %>">
                            <%= i %>
                        </a>
                    <% } 
                    } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <a href="?page=<%= currentPage + 1 %>&startDate=<%= startDate != null ? startDate : "" %>&endDate=<%= endDate != null ? endDate : "" %>&sellerSearch=<%= sellerSearch != null ? sellerSearch : "" %>&bookSearch=<%= bookSearch != null ? bookSearch : "" %>&reasonFilter=<%= reasonFilter != null ? reasonFilter : "" %>&statusFilter=<%= statusFilter != null ? statusFilter : "" %>">
                            下一頁 »
                        </a>
                    <% } %>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>
    
    <script>
        // 查看詳情
        function viewDetail(listingId) {
            // 可以導向詳細頁面或彈出模態框
            window.location.href = 'listingDetail.jsp?id=' + listingId;
        }
        
        // 匯出Excel功能
        function exportToExcel() {
            const table = document.getElementById('recordsTable');
            if (!table) {
                alert('無資料可匯出');
                return;
            }
            
            // 取得篩選參數
            const urlParams = new URLSearchParams(window.location.search);
            const params = [];
            
            ['startDate', 'endDate', 'sellerSearch', 'bookSearch', 'reasonFilter', 'statusFilter'].forEach(key => {
                const value = urlParams.get(key);
                if (value) {
                    params.push(key + '=' + encodeURIComponent(value));
                }
            });
            
            // 導向匯出頁面
            window.location.href = 'exportDelistingRecords.jsp?' + params.join('&');
        }
        
        // 確認登出
        document.querySelector('.logout-btn')?.addEventListener('click', function(e) {
            if (!confirm('確定要登出嗎？')) {
                e.preventDefault();
            }
        });
        
        // 自動提交表單（可選）
        const form = document.querySelector('form');
        const selects = form.querySelectorAll('select');
        
        // 如果需要選擇後自動查詢，取消下面的註解
        /*
        selects.forEach(select => {
            select.addEventListener('change', function() {
                form.submit();
            });
        });
        */
        
        // 日期範圍驗證
        const startDateInput = document.querySelector('input[name="startDate"]');
        const endDateInput = document.querySelector('input[name="endDate"]');
        
        if (startDateInput && endDateInput) {
            endDateInput.addEventListener('change', function() {
                if (startDateInput.value && endDateInput.value) {
                    if (new Date(endDateInput.value) < new Date(startDateInput.value)) {
                        alert('結束日期不能早於開始日期');
                        endDateInput.value = '';
                    }
                }
            });
        }
        
        // 顯示載入完成訊息
        console.log('下架記錄查詢頁面載入完成');
        console.log('總記錄數: <%= totalRecords %>');
        console.log('當前頁數: <%= currentPage %> / <%= totalPages %>');
    </script>
</body>
</html>