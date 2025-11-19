<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    try {
        // 檢查登入
        String userId = (String) session.getAttribute("userId");
        if (userId == null || userId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"請先登入\"}");
            return;
        }
        
        String messageId = request.getParameter("messageId");
        
        if (messageId == null || messageId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"缺少訊息ID\"}");
            return;
        }
        
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            
            // 刪除訊息 (只能刪除自己收到的訊息)
            String sql = "DELETE FROM messages WHERE messageId = ? AND sellerId = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, messageId);
            pstmt.setString(2, userId);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                out.print("{\"success\": true, \"message\": \"訊息已刪除\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"找不到該訊息或您無權操作\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"系統錯誤: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\": false, \"message\": \"系統發生錯誤\"}");
    }
%>