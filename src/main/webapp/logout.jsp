<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<html>
<head><title>登出</title></head>
<body>
<%
// ✅ 修正：使用 "userId" 而非 "username"
String userId = (String) session.getAttribute("userId");

if(userId != null) {
    Connection con = null;
    PreparedStatement pstmt = null;
    
    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ✅ 修正：使用 Now() 而非 NOW()，使用 PreparedStatement 防止 SQL Injection
        String updateLogoutTime = "UPDATE users SET lastLogout=Now() WHERE userId=?";
        pstmt = con.prepareStatement(updateLogoutTime);
        pstmt.setString(1, userId);
        
        int rowsUpdated = pstmt.executeUpdate();
        
        // 除錯用（可選）
        // System.out.println("登出更新成功，影響 " + rowsUpdated + " 筆記錄");
        
    } catch(Exception e) {
        // 即使更新失敗也要登出
        e.printStackTrace();
        // 可選：記錄到日誌
        // System.err.println("登出時間更新失敗: " + e.getMessage());
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(con != null) try { con.close(); } catch(Exception e) {}
    }
}

// >>> 清除 session
session.invalidate();

response.sendRedirect("index.jsp");
%>
</body>
</html>