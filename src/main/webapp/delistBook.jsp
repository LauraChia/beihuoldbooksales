<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.JSONObject"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject jsonResponse = new JSONObject();

    try {
        // 檢查是否登入
        String currentUserId = (String) session.getAttribute("userId");
        if (currentUserId == null || currentUserId.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "請先登入");
            out.print(jsonResponse.toString());
            return;
        }

        // 獲取參數
        String listingId = request.getParameter("listingId");

        if (listingId == null || listingId.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "缺少必要參數");
            out.print(jsonResponse.toString());
            return;
        }

        // 連接資料庫
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");

        // 先檢查此書籍是否屬於當前用戶
        String checkSql = "SELECT sellerId FROM bookListings WHERE listingId = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, listingId);
        ResultSet rs = checkStmt.executeQuery();

        if (!rs.next()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "找不到此書籍");
            rs.close();
            checkStmt.close();
            con.close();
            out.print(jsonResponse.toString());
            return;
        }

        String sellerId = rs.getString("sellerId");
        if (!currentUserId.equals(sellerId)) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "您沒有權限下架此書籍");
            rs.close();
            checkStmt.close();
            con.close();
            out.print(jsonResponse.toString());
            return;
        }

        rs.close();
        checkStmt.close();

        // 執行下架操作（設置 isDelisted 為 TRUE，並記錄下架時間、原因和操作者）
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String currentTime = sdf.format(new java.util.Date());

        String updateSql = "UPDATE bookListings SET isDelisted = TRUE, delistedAt = ?, delistReason = ?, delistedBy = ? WHERE listingId = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateSql);
        updateStmt.setString(1, currentTime);        // 記錄下架時間
        updateStmt.setString(2, "使用者自行下架");  // 設定下架原因
        updateStmt.setString(3, currentUserId);      // 記錄下架的使用者ID
        updateStmt.setString(4, listingId);          // 書籍ID

        int rowsAffected = updateStmt.executeUpdate();

        if (rowsAffected > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "書籍已成功下架");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "下架失敗,請稍後再試");
        }

        updateStmt.close();
        con.close();

    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "系統錯誤: " + e.getMessage());
        e.printStackTrace();
    }

    out.print(jsonResponse.toString());
%>