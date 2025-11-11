<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// ========== 修改1: 新增 - 檢查請求方法 ==========
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("login.jsp");
    return;
}

if(request.getParameter("username") != null &&
	request.getParameter("password") != null){

    // ========== 修改2: 新增 - 取得並驗證參數 ==========
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    // 檢查參數是否為空
    if (username.trim().isEmpty() || password.trim().isEmpty()) {
        response.sendRedirect("login.jsp?status=loginerror");
        return;
    }
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        // ========== 修改3: 新增 - 載入資料庫驅動 ==========
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // ========== 修改4: 改用 PreparedStatement 防止 SQL Injection ==========
        // 原代碼:
        // String sql = "SELECT * FROM users WHERE username='" + 
        //              request.getParameter("username") + "' AND password='" +
        //              request.getParameter("password") + "'";
        // ResultSet rs = smt.executeQuery(sql);
        
        // 新代碼:
        String sql = "SELECT userId, username, name, department, isVerified FROM users WHERE username = ? AND password = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        ps.setString(2, password);
        rs = ps.executeQuery();

        if(rs.next()){
            // ========== 修改5: 新增 - 檢查信箱驗證狀態 ==========
            boolean isVerified = rs.getBoolean("isVerified");
            
            if (!isVerified) {
                // 未驗證信箱,導向驗證頁面
                response.sendRedirect("verifyEmail.jsp?email=" + 
                    java.net.URLEncoder.encode(username, "UTF-8") + 
                    "&status=notverified");
                return;
            }
            
            // ========== 修改6: 統一 Session 屬性名稱 ==========
            // 原代碼:
            // session.setAttribute("accessId", request.getParameter("userId"));
            
            // 新代碼: 從 ResultSet 取得正確的值
            session.setAttribute("userId", rs.getString("userId"));
            session.setAttribute("username", rs.getString("username"));
            session.setAttribute("name", rs.getString("name"));
            session.setAttribute("department", rs.getString("department"));
            
            // ========== 修改7: 新增 - 設定 Session 過期時間(可選) ==========
            // session.setMaxInactiveInterval(30 * 60); // 30分鐘
            
            // 登入成功,導回首頁
            response.sendRedirect("index.jsp");
        } else {
            // ========== 修改8: 改善錯誤處理 ==========
            // 原代碼: out.println("帳號密碼不符！請重新登入");
            
            // 新代碼: 導向登入頁並顯示錯誤訊息
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
        // ========== 修改9: 新增 - 確保資源正確關閉 ==========
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
%>