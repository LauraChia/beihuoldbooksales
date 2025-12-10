<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // ⭐ 重要：清理輸出緩衝區，避免警告訊息混入 JSON
    out.clearBuffer();
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    JSONObject result = new JSONObject();
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // 資料庫連線
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 取得當前時間
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String currentTime = sdf.format(new java.util.Date()); 
        
        // 1. 先查詢需要下架的書籍（下架時間已過且尚未下架）
        String selectSql = "SELECT listingId, bookId, sellerId, title, expiryDate " +
                          "FROM bookListings bl " +
                          "INNER JOIN books b ON bl.bookId = b.bookId " +
                          "WHERE bl.expiryDate <= ? " +
                          "AND bl.isDelisted = FALSE";
        
        pstmt = con.prepareStatement(selectSql);
        pstmt.setString(1, currentTime);
        rs = pstmt.executeQuery();
        
        List<Map<String, String>> expiredBooks = new ArrayList<>();
        
        while (rs.next()) {
            Map<String, String> book = new HashMap<>();
            book.put("listingId", rs.getString("listingId"));
            book.put("bookId", rs.getString("bookId"));
            book.put("sellerId", rs.getString("sellerId"));
            book.put("title", rs.getString("title"));
            book.put("expiryDate", rs.getString("expiryDate"));
            expiredBooks.add(book);
        }
        
        rs.close();
        pstmt.close();
        
        // 2. 執行下架操作
        int expiredCount = 0;
        
        if (!expiredBooks.isEmpty()) {
            String updateSql = "UPDATE bookListings SET isDelisted = TRUE, delistedAt = ? WHERE listingId = ?";
            pstmt = con.prepareStatement(updateSql);
            
            for (Map<String, String> book : expiredBooks) {
                pstmt.setString(1, currentTime);
                pstmt.setString(2, book.get("listingId"));
                int updated = pstmt.executeUpdate();
                
                if (updated > 0) {
                    expiredCount++;
                }
            }
            
            pstmt.close();
        }
        
        // 3. 回傳結果
        result.put("success", true);
        result.put("expiredCount", expiredCount);
        result.put("checkTime", currentTime);
        result.put("message", "成功下架 " + expiredCount + " 本書籍");
        
        // 回傳詳細資訊（僅供管理員檢視）
        List<String> expiredTitles = new ArrayList<>();
        for (Map<String, String> book : expiredBooks) {
            expiredTitles.add(book.get("title"));
        }
        result.put("expiredBooks", expiredTitles);
        
    } catch (Exception e) {
        result.put("success", false);
        result.put("error", e.getMessage());
        result.put("errorType", e.getClass().getName());
        
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            // 忽略關閉錯誤
        }
    }
    
    // ⭐ 重要：確保只輸出 JSON，不要有其他內容
    out.print(result.toString());
    out.flush();
%>