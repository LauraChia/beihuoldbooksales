<%@ page language="java" contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
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

// 設定檔案名稱
SimpleDateFormat fileNameFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
String fileName = "下架記錄_" + fileNameFormat.format(new java.util.Date()) + ".xls";
response.setHeader("Content-Disposition", "attachment; filename=\"" + new String(fileName.getBytes("UTF-8"), "ISO-8859-1") + "\"");

// 獲取篩選參數
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");
String sellerSearch = request.getParameter("sellerSearch");
String bookSearch = request.getParameter("bookSearch");
String reasonFilter = request.getParameter("reasonFilter");
String statusFilter = request.getParameter("statusFilter");

List<Map<String, String>> records = new ArrayList<>();

try {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection conn = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 構建查詢條件
    StringBuilder whereClause = new StringBuilder("WHERE (bl.isDelisted = True OR bl.isDelisted = -1)");
    List<Object> params = new ArrayList<>();
    
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
    
    // 查詢所有符合條件的記錄（不分頁）
    String recordsSQL = 
        "SELECT " +
        "bl.listingId, bl.delistedAt, bl.listedAt, bl.expiryDate, " +
        "bl.delistReason, bl.delistedBy, bl.relistingCount, bl.price, " +
        "b.title, b.ISBN, b.author, " +
        "u.name as sellerName, u.username as sellerEmail " +
        "FROM bookListings bl " +
        "JOIN books b ON bl.bookId = b.bookId " +
        "JOIN users u ON bl.sellerId = u.userId " +
        whereClause.toString() + " " +
        "ORDER BY bl.delistedAt DESC";
    
    PreparedStatement stmt = conn.prepareStatement(recordsSQL);
    for (int i = 0; i < params.size(); i++) {
        Object param = params.get(i);
        if (param instanceof java.sql.Timestamp) {
            stmt.setTimestamp(i + 1, (java.sql.Timestamp)param);
        } else {
            stmt.setString(i + 1, param.toString());
        }
    }
    
    ResultSet rs = stmt.executeQuery();
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
    stmt.close();
    conn.close();
    
} catch (Exception e) {
    out.println("<html><body><h3>資料庫錯誤: " + e.getMessage() + "</h3></body></html>");
    e.printStackTrace();
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>下架記錄匯出</title>
</head>
<body>
    <table border="1">
        <thead>
            <tr style="background-color: #81c408; color: white; font-weight: bold;">
                <th>下架時間</th>
                <th>書籍名稱</th>
                <th>ISBN</th>
                <th>作者</th>
                <th>賣家姓名</th>
                <th>賣家Email</th>
                <th>售價</th>
                <th>上架時間</th>
                <th>原到期日</th>
                <th>下架原因</th>
                <th>執行者</th>
                <th>重新上架次數</th>
                <th>刊登編號</th>
            </tr>
        </thead>
        <tbody>
            <% 
            if (records.isEmpty()) { 
            %>
                <tr>
                    <td colspan="13" style="text-align: center;">查無資料</td>
                </tr>
            <% 
            } else {
                for (Map<String, String> record : records) { 
                    String reason = record.get("delistReason");
                    String reasonText = "";
                    
                    if ("AUTO_EXPIRED".equals(reason)) {
                        reasonText = "自動到期";
                    } else if ("MANUAL_ADMIN".equals(reason)) {
                        reasonText = "管理員下架";
                    } else if ("VIOLATION".equals(reason)) {
                        reasonText = "違規下架";
                    } else if ("USER_REQUEST".equals(reason)) {
                        reasonText = "使用者下架";
                    } else {
                        reasonText = reason != null ? reason : "未知";
                    }
            %>
                <tr>
                    <td><%= record.get("delistedAt") %></td>
                    <td><%= record.get("title") %></td>
                    <td><%= record.get("ISBN") != null ? record.get("ISBN") : "" %></td>
                    <td><%= record.get("author") != null ? record.get("author") : "" %></td>
                    <td><%= record.get("sellerName") %></td>
                    <td><%= record.get("sellerEmail") %></td>
                    <td><%= record.get("price") %></td>
                    <td><%= record.get("listedAt") %></td>
                    <td><%= record.get("expiryDate") %></td>
                    <td><%= reasonText %></td>
                    <td><%= record.get("delistedBy") != null ? record.get("delistedBy") : "系統" %></td>
                    <td><%= record.get("relistingCount") %></td>
                    <td><%= record.get("listingId") %></td>
                </tr>
            <% 
                }
            } 
            %>
        </tbody>
        <tfoot>
            <tr style="background-color: #f0f0f0; font-weight: bold;">
                <td colspan="13">
                    匯出時間: <%= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()) %> | 
                    匯出人員: <%= adminUser %> | 
                    總筆數: <%= records.size() %>
                </td>
            </tr>
            <% if (startDate != null || endDate != null || sellerSearch != null || bookSearch != null || reasonFilter != null) { %>
            <tr>
                <td colspan="13" style="background-color: #ffffcc;">
                    <strong>查詢條件:</strong>
                    <% if (startDate != null && !startDate.isEmpty()) { %>
                        開始日期: <%= startDate %> |
                    <% } %>
                    <% if (endDate != null && !endDate.isEmpty()) { %>
                        結束日期: <%= endDate %> |
                    <% } %>
                    <% if (sellerSearch != null && !sellerSearch.isEmpty()) { %>
                        賣家: <%= sellerSearch %> |
                    <% } %>
                    <% if (bookSearch != null && !bookSearch.isEmpty()) { %>
                        書名: <%= bookSearch %> |
                    <% } %>
                    <% if (reasonFilter != null && !reasonFilter.isEmpty() && !"ALL".equals(reasonFilter)) { %>
                        下架原因: <%= reasonFilter %> |
                    <% } %>
                    <% if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) { %>
                        狀態: <%= "RELISTED".equals(statusFilter) ? "已重新上架" : "尚未重新上架" %>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </tfoot>
    </table>
</body>
</html>
