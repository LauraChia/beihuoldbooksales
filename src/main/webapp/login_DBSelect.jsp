<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 檢查請求方法
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("login.jsp");
    return;
}

if(request.getParameter("username") != null &&
    request.getParameter("password") != null){

    // 取得並驗證參數
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    // 檢查參數是否為空
    if (username.trim().isEmpty() || password.trim().isEmpty()) {
        response.sendRedirect("login.jsp?status=loginerror");
        return;
    }
    
    Connection con = null;
    PreparedStatement ps = null;
    PreparedStatement updatePs = null;  // ⭐ 新增：用於更新登入時間
    ResultSet rs = null;
    
    try {
        // 載入資料庫驅動
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // 查詢使用者
        String sql = "SELECT userId, username, name, department, isVerified FROM users WHERE username = ? AND password = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        ps.setString(2, password);
        rs = ps.executeQuery();

        if(rs.next()){
            // 檢查信箱驗證狀態
            boolean isVerified = rs.getBoolean("isVerified");
            
            if (!isVerified) {
                // 未驗證信箱,導向驗證頁面
                response.sendRedirect("verifyEmail.jsp?email=" + 
                    java.net.URLEncoder.encode(username, "UTF-8") + 
                    "&status=notverified");
                return;
            }
            
            // 取得 userId
            String userId = rs.getString("userId");
            
            // ⭐⭐⭐ 關鍵修正：更新登入時間 ⭐⭐⭐
            try {
                // MS Access 使用 Now() 函數取得當前時間
                String updateSql = "UPDATE users SET lastLogin = Now() WHERE userId = ?";
                updatePs = con.prepareStatement(updateSql);
                updatePs.setString(1, userId);
                int updated = updatePs.executeUpdate();
                
                // Debug 輸出（可選）
                System.out.println("更新登入時間 - userId: " + userId + ", 影響筆數: " + updated);
                
            } catch(SQLException updateEx) {
                // 如果更新失敗，記錄錯誤但不影響登入流程
                System.err.println("更新登入時間失敗: " + updateEx.getMessage());
            }
            
            // 設定 Session
            session.setAttribute("userId", userId);
            session.setAttribute("username", rs.getString("username"));
            session.setAttribute("name", rs.getString("name"));
            session.setAttribute("department", rs.getString("department"));
            
            // 設定 Session 過期時間(30分鐘)
            session.setMaxInactiveInterval(30 * 60);
            
            // 登入成功,導回首頁
            response.sendRedirect("index.jsp");
            
        } else {
            // 帳號密碼錯誤
            response.sendRedirect("login.jsp?status=loginerror");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        System.err.println("SQL錯誤: " + e.getMessage());
        response.sendRedirect("login.jsp?status=error");
        
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        System.err.println("找不到資料庫驅動程式: " + e.getMessage());
        response.sendRedirect("login.jsp?status=error");
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("系統錯誤: " + e.getMessage());
        response.sendRedirect("login.jsp?status=error");
        
    } finally {
        // 確保資源正確關閉
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (updatePs != null) try { updatePs.close(); } catch (Exception e) {}  // ⭐ 新增
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
%>