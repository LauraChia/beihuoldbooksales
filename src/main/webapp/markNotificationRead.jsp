<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String userId = (String) session.getAttribute("userId");
    String notificationId = request.getParameter("notificationId");
    
    if (userId == null) {
        out.print("{\"success\": false, \"message\": \"未登入\"}");
        return;
    }
    
    if (notificationId == null) {
        out.print("{\"success\": false, \"message\": \"缺少通知ID\"}");
        return;
    }
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        // 確認這則通知屬於當前使用者
        String checkSql = "SELECT userId FROM notifications WHERE notificationId = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, notificationId);
        ResultSet rs = checkStmt.executeQuery();
        
        if (!rs.next() || !rs.getString("userId").equals(userId)) {
            out.print("{\"success\": false, \"message\": \"無權限操作此通知\"}");
            rs.close();
            checkStmt.close();
            con.close();
            return;
        }
        rs.close();
        checkStmt.close();
        
        // 標記為已讀
        String updateSql = "UPDATE notifications SET isRead = true WHERE notificationId = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateSql);
        updateStmt.setString(1, notificationId);
        int rowsAffected = updateStmt.executeUpdate();
        
        updateStmt.close();
        con.close();
        
        if (rowsAffected > 0) {
            out.print("{\"success\": true, \"message\": \"已標記為已讀\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"更新失敗\"}");
        }
        
    } catch (Exception e) {
        out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    }
%>