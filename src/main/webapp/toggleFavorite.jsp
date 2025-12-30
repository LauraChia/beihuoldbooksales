<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    try {
        // 檢查使用者是否登入
        String userId = (String) session.getAttribute("userId");
        if (userId == null || userId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"請先登入\"}");
            return;
        }
        
        // 取得參數
        String bookId = request.getParameter("bookId");
        String action = request.getParameter("action"); // "add" 或 "remove"
        
        if (bookId == null || action == null) {
            out.print("{\"success\": false, \"message\": \"缺少必要參數\"}");
            return;
        }
        
        // 連接資料庫
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        boolean success = false;
        int favoriteCount = 0;
        
        if (action.equals("add")) {
            // 檢查是否已收藏
            String checkSql = "SELECT COUNT(*) as cnt FROM favorites WHERE userId = ? AND bookId = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, userId);
            checkStmt.setInt(2, Integer.parseInt(bookId));
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (checkRs.next() && checkRs.getInt("cnt") > 0) {
                out.print("{\"success\": false, \"message\": \"您已經收藏過此書籍\"}");
                checkRs.close();
                checkStmt.close();
                con.close();
                return;
            }
            checkRs.close();
            checkStmt.close();
            
            // 新增收藏
            String insertSql = "INSERT INTO favorites (userId, bookId, createdAt) VALUES (?, ?, Now())";
            PreparedStatement insertStmt = con.prepareStatement(insertSql);
            insertStmt.setString(1, userId);
            insertStmt.setInt(2, Integer.parseInt(bookId));
            
            int rowsAffected = insertStmt.executeUpdate();
            success = (rowsAffected > 0);
            insertStmt.close();
            
        } else if (action.equals("remove")) {
            // 取消收藏
            String deleteSql = "DELETE FROM favorites WHERE userId = ? AND bookId = ?";
            PreparedStatement deleteStmt = con.prepareStatement(deleteSql);
            deleteStmt.setString(1, userId);
            deleteStmt.setInt(2, Integer.parseInt(bookId));
            
            int rowsAffected = deleteStmt.executeUpdate();
            success = (rowsAffected > 0);
            deleteStmt.close();
        }
        
        // 取得最新的收藏數量
        String countSql = "SELECT COUNT(*) as total FROM favorites WHERE bookId = ?";
        PreparedStatement countStmt = con.prepareStatement(countSql);
        countStmt.setInt(1, Integer.parseInt(bookId));
        ResultSet countRs = countStmt.executeQuery();
        
        if (countRs.next()) {
            favoriteCount = countRs.getInt("total");
        }
        
        countRs.close();
        countStmt.close();
        con.close();
        
        // 回傳結果
        out.print("{");
        out.print("\"success\": " + success + ",");
        out.print("\"favoriteCount\": " + favoriteCount + ",");
        out.print("\"message\": \"" + (success ? "操作成功" : "操作失敗") + "\"");
        out.print("}");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\": false, \"message\": \"系統錯誤: " + e.getMessage() + "\"}");
    }
%>