<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.net.URLEncoder"%>
<%@ page import="jakarta.mail.*" %>
<%@ page import="jakarta.mail.internet.*" %>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />

<%
    // ========== 1. 檢查請求方法 ==========
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("verifyEmail.jsp");
        return;
    }

    // ========== 2. 取得並驗證參數 ==========
    String email = request.getParameter("email");
    
    // 檢查必要參數是否存在且不為空
    if (email == null || email.trim().isEmpty()) {
        response.sendRedirect("verifyEmail.jsp?status=invalid");
        return;
    }
    
    email = email.trim();
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean success = false;
    String userName = "";
    
    try {
        // ========== 3. 連接資料庫 ==========
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ========== 4. 檢查用戶是否存在且未驗證 ==========
        String checkSql = "SELECT name, isVerified FROM users WHERE username = ?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            // 用戶不存在
            rs.close();
            ps.close();
            response.sendRedirect("verifyEmail.jsp?status=notfound&email=" + URLEncoder.encode(email, "UTF-8"));
            return;
        }
        
        userName = rs.getString("name");
        boolean isVerified = rs.getBoolean("isVerified");
        
        if (isVerified) {
            // 用戶已經驗證過了
            rs.close();
            ps.close();
            response.sendRedirect("login.jsp?status=already_verified");
            return;
        }
        
        rs.close();
        ps.close();
        
        // ========== 5. 生成新的6位數驗證碼 ==========
        String newVerificationCode = String.format("%06d", new Random().nextInt(1000000));
        
        // ========== 6. 更新資料庫中的驗證碼 ==========
        String updateSql = "UPDATE users SET verificationCode = ? WHERE username = ?";
        ps = con.prepareStatement(updateSql);
        ps.setString(1, newVerificationCode);
        ps.setString(2, email);
        
        int rowsAffected = ps.executeUpdate();
        
        if (rowsAffected > 0) {
            success = true;
            
            // ========== 7. 發送新的驗證信 ==========
            try {
                sendVerificationEmail(email, userName, newVerificationCode);
            } catch (Exception mailEx) {
                // 記錄郵件發送失敗
                System.err.println("郵件發送失敗: " + mailEx.getMessage());
                mailEx.printStackTrace();
                // 郵件發送失敗，但驗證碼已更新
                response.sendRedirect("verifyEmail.jsp?status=mail_error&email=" + URLEncoder.encode(email, "UTF-8"));
                return;
            }
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        System.err.println("SQL錯誤: " + e.getMessage());
        response.sendRedirect("verifyEmail.jsp?status=error&email=" + URLEncoder.encode(email, "UTF-8"));
        return;
        
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        System.err.println("找不到資料庫驅動程式: " + e.getMessage());
        response.sendRedirect("verifyEmail.jsp?status=error&email=" + URLEncoder.encode(email, "UTF-8"));
        return;
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("系統錯誤: " + e.getMessage());
        response.sendRedirect("verifyEmail.jsp?status=error&email=" + URLEncoder.encode(email, "UTF-8"));
        return;
        
    } finally {
        // ========== 8. 關閉資源 ==========
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    
    // ========== 9. 重新發送成功，導回驗證頁面 ==========
    if (success) {
        String encodedEmail = URLEncoder.encode(email, "UTF-8");
        response.sendRedirect("verifyEmail.jsp?status=resent&email=" + encodedEmail);
    } else {
        response.sendRedirect("verifyEmail.jsp?status=error&email=" + URLEncoder.encode(email, "UTF-8"));
    }
%>

<%!
    /**
     * 發送驗證信件方法
     * @param toEmail 收件者信箱
     * @param userName 使用者姓名
     * @param code 驗證碼
     */
    private void sendVerificationEmail(String toEmail, String userName, String code) 
            throws MessagingException {
        
        // SMTP 設定
        final String from = "ntunhs.booksystem@gmail.com";
        final String password = "stnz fbov iozy yfyl";
        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        // 建立郵件會話
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, password);
            }
        });
        
        // 建立郵件訊息
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("【北護二手書交易網】重新發送驗證碼");
        
        // HTML 郵件內容
        String emailContent = "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='utf-8'></head>" +
            "<body style='font-family: Microsoft JhengHei, sans-serif; padding: 20px; background: #f5f5f5;'>" +
            "<div style='max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; margin-bottom: 30px;'>" +
            "<h1 style='color: #667eea; margin: 0;'>📚</h1>" +
            "<h2 style='color: #333; margin: 10px 0;'>北護二手書交易網</h2>" +
            "<p style='color: #666; margin: 5px 0;'>重新發送驗證碼</p>" +
            "</div>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>親愛的 <strong>" + userName + "</strong>：</p>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>您已申請重新發送驗證碼，請使用以下新的驗證碼完成註冊：</p>" +
            "<div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px; margin: 30px 0;'>" +
            "<p style='color: white; margin: 0 0 10px 0; font-size: 14px;'>您的新驗證碼</p>" +
            "<h1 style='color: white; letter-spacing: 10px; font-size: 42px; margin: 0; font-weight: bold;'>" + code + "</h1>" +
            "</div>" +
            "<div style='background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;'>" +
            "<p style='color: #856404; margin: 0; font-size: 14px;'>⚠️ 此驗證碼將在 <strong>30分鐘後</strong> 失效。</p>" +
            "<p style='color: #856404; margin: 10px 0 0 0; font-size: 14px;'>⚠️ 舊的驗證碼已經失效，請使用新的驗證碼。</p>" +
            "</div>" +
            "<p style='color: #666; font-size: 14px; line-height: 1.6;'>如果您沒有申請重新發送驗證碼，請忽略此信件。</p>" +
            "<hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'>" +
            "<p style='color: #999; font-size: 12px; text-align: center; margin: 0;'>© 2025 北護二手書交易網 | 本郵件由系統自動發送，請勿直接回覆</p>" +
            "</div>" +
            "</body>" +
            "</html>";
        
        message.setContent(emailContent, "text/html; charset=UTF-8");
        
        // 發送郵件
        Transport.send(message);
    }
%>