<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    StringBuilder json = new StringBuilder("{");
    
    try {
        String loggedInUserId = (String) session.getAttribute("userId");
        
        if (loggedInUserId == null || loggedInUserId.trim().isEmpty()) {
            json.append("\"success\":false,\"message\":\"請先登入\"");
            json.append("}");
            out.print(json.toString());
            return;
        }
        
        String reviewIdStr = request.getParameter("reviewId");
        String action = request.getParameter("action");
        
        if (reviewIdStr == null || action == null) {
            json.append("\"success\":false,\"message\":\"參數錯誤\"");
            json.append("}");
            out.print(json.toString());
            return;
        }
        
        int reviewId = Integer.parseInt(reviewIdStr);
        
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        boolean success = false;
        String message = "";
        
        if ("like".equals(action)) {
            // 檢查是否已按讚
            String checkSql = "SELECT COUNT(*) as cnt FROM reviewLikes WHERE reviewId = ? AND userId = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setInt(1, reviewId);
            checkStmt.setString(2, loggedInUserId);
            ResultSet checkRs = checkStmt.executeQuery();
            checkRs.next();
            int exists = checkRs.getInt("cnt");
            checkRs.close();
            checkStmt.close();
            
            if (exists > 0) {
                success = false;
                message = "您已經按過讚了";
            } else {
                // 新增按讚記錄
                String insertSql = "INSERT INTO reviewLikes (reviewId, userId, createAt) VALUES (?, ?, Now())";
                PreparedStatement insertStmt = con.prepareStatement(insertSql);
                insertStmt.setInt(1, reviewId);
                insertStmt.setString(2, loggedInUserId);
                insertStmt.executeUpdate();
                insertStmt.close();
                
                // 更新按讚數
                String updateSql = "UPDATE reviews SET likeCount = likeCount + 1 WHERE reviewId = ?";
                PreparedStatement updateStmt = con.prepareStatement(updateSql);
                updateStmt.setInt(1, reviewId);
                updateStmt.executeUpdate();
                updateStmt.close();
                
                success = true;
            }
            
        } else if ("unlike".equals(action)) {
            // 取消按讚
            String deleteSql = "DELETE FROM reviewLikes WHERE reviewId = ? AND userId = ?";
            PreparedStatement deleteStmt = con.prepareStatement(deleteSql);
            deleteStmt.setInt(1, reviewId);
            deleteStmt.setString(2, loggedInUserId);
            int deleted = deleteStmt.executeUpdate();
            deleteStmt.close();
            
            if (deleted > 0) {
                // 更新按讚數
                String updateSql = "UPDATE reviews SET likeCount = CASE WHEN likeCount > 0 THEN likeCount - 1 ELSE 0 END WHERE reviewId = ?";
                PreparedStatement updateStmt = con.prepareStatement(updateSql);
                updateStmt.setInt(1, reviewId);
                updateStmt.executeUpdate();
                updateStmt.close();
                
                success = true;
            } else {
                success = false;
                message = "取消失敗";
            }
        }
        
        // 取得最新的按讚數
        String countSql = "SELECT likeCount FROM reviews WHERE reviewId = ?";
        PreparedStatement countStmt = con.prepareStatement(countSql);
        countStmt.setInt(1, reviewId);
        ResultSet countRs = countStmt.executeQuery();
        int likeCount = 0;
        if (countRs.next()) {
            likeCount = countRs.getInt("likeCount");
        }
        countRs.close();
        countStmt.close();
        
        con.close();
        
        // 組裝 JSON 回應
        json.append("\"success\":").append(success);
        if (!message.isEmpty()) {
            json.append(",\"message\":\"").append(message).append("\"");
        }
        json.append(",\"likeCount\":").append(likeCount);
        
    } catch (Exception e) {
        json = new StringBuilder("{");
        json.append("\"success\":false,\"message\":\"系統錯誤：").append(e.getMessage().replace("\"", "\\\"")).append("\"");
    }
    
    json.append("}");
    out.print(json.toString());
%>