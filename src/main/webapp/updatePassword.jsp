<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />

<%
    // 檢查請求方法
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("forgetPassword.jsp");
        return;
    }

    String token = request.getParameter("token");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    
    // 參數驗證
    if (token == null || token.trim().isEmpty() || 
        newPassword == null || newPassword.trim().isEmpty() ||
        confirmPassword == null || confirmPassword.trim().isEmpty()) {
        response.sendRedirect("forgetPassword.jsp?status=error");
        return;
    }
    
    // 驗證密碼一致性
    if (!newPassword.equals(confirmPassword)) {
        response.sendRedirect("resetPasswordForm.jsp?token=" + token + "&status=mismatch");
        return;
    }
    
    // 驗證密碼長度
    if (newPassword.length() < 6) {
        response.sendRedirect("resetPasswordForm.jsp?token=" + token + "&status=short");
        return;
    }
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean success = false;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 驗證 token 是否有效且未過期
        String checkSql = "SELECT username, resetTokenExpiry FROM users WHERE resetToken = ?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, token);
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            response.sendRedirect("resetPasswordForm.jsp?token=" + token + "&status=invalid");
            return;
        }
        
        Timestamp expiry = rs.getTimestamp("resetTokenExpiry");
        Timestamp now = new Timestamp(System.currentTimeMillis());
        
        if (expiry == null || expiry.before(now)) {
            response.sendRedirect("resetPasswordForm.jsp?token=" + token + "&status=expired");
            return;
        }
        
        String email = rs.getString("username");
        rs.close();
        ps.close();
        
        // 更新密碼並清除 token
        // 注意：實際應用中應該使用密碼雜湊（如 BCrypt）
        String updateSql = "UPDATE users SET password = ?, resetToken = NULL, resetTokenExpiry = NULL WHERE username = ?";
        ps = con.prepareStatement(updateSql);
        ps.setString(1, newPassword);  // 建議改用 BCrypt.hashpw(newPassword, BCrypt.gensalt())
        ps.setString(2, email);
        
        int rowsUpdated = ps.executeUpdate();
        
        if (rowsUpdated > 0) {
            success = true;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("密碼更新錯誤: " + e.getMessage());
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    
    if (success) {
        // 重設成功，導向登入頁面
        response.sendRedirect("login.jsp?status=resetSuccess");
    } else {
        response.sendRedirect("resetPasswordForm.jsp?token=" + token + "&status=error");
    }
%>