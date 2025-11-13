<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.security.SecureRandom"%>
<%@ page import="jakarta.mail.*" %>
<%@ page import="jakarta.mail.internet.*" %>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />

<%
    // 檢查請求方法
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("forgetPassword.jsp");
        return;
    }

    String email = request.getParameter("email");
    
    // 驗證 email 參數
    if (email == null || email.trim().isEmpty()) {
        response.sendRedirect("forgetPassword.jsp?status=error");
        return;
    }
    
    email = email.trim();
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        // 連接資料庫
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 檢查此信箱是否存在
        String checkSql = "SELECT name, username FROM users WHERE username = ?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            // 信箱不存在（但不要讓使用者知道具體原因，避免帳號枚舉攻擊）
            response.sendRedirect("forgetPassword.jsp?status=notfound");
            return;
        }
        
        String userName = rs.getString("name");
        rs.close();
        ps.close();
        
        // 生成安全的重設 token (32 字元)
        String resetToken = generateSecureToken(32);
        
        // 計算過期時間（30分鐘後）
        Timestamp expiryTime = new Timestamp(System.currentTimeMillis() + 30 * 60 * 1000);
        
        // 將 token 存入資料庫
        String updateSql = "UPDATE users SET resetToken = ?, resetTokenExpiry = ? WHERE username = ?";
        ps = con.prepareStatement(updateSql);
        ps.setString(1, resetToken);
        ps.setTimestamp(2, expiryTime);
        ps.setString(3, email);
        
        int rowsUpdated = ps.executeUpdate();
        
        if (rowsUpdated > 0) {
            // 發送重設密碼郵件
            try {
                sendResetPasswordEmail(email, userName, resetToken);
                response.sendRedirect("forgetPassword.jsp?status=sent");
            } catch (Exception mailEx) {
                System.err.println("郵件發送失敗: " + mailEx.getMessage());
                mailEx.printStackTrace();
                response.sendRedirect("forgetPassword.jsp?status=error");
            }
        } else {
            response.sendRedirect("forgetPassword.jsp?status=error");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("系統錯誤: " + e.getMessage());
        response.sendRedirect("forgetPassword.jsp?status=error");
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<%!
    /**
     * 生成安全的隨機 token
     * @param length token 長度
     * @return 隨機 token 字串
     */
    private String generateSecureToken(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder token = new StringBuilder(length);
        
        for (int i = 0; i < length; i++) {
            token.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return token.toString();
    }
    
    /**
     * 發送重設密碼信件
     * @param toEmail 收件者信箱
     * @param userName 使用者姓名
     * @param token 重設密碼 token
     */
    private void sendResetPasswordEmail(String toEmail, String userName, String token) 
            throws MessagingException, java.io.UnsupportedEncodingException {
        
        final String from = "ntunhs.booksystem@gmail.com";
        final String password = "stnz fbov iozy yfyl";
        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, password);
            }
        });
        
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("【北護二手書交易網】重設密碼通知");
        
        // 建構重設密碼連結（需要根據你的實際網域調整）
        String resetLink = "http://localhost:8081/book/resetPasswordForm.jsp?token=" + 
                          java.net.URLEncoder.encode(token, "UTF-8");
        
        String emailContent = "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='utf-8'></head>" +
            "<body style='font-family: Microsoft JhengHei, sans-serif; padding: 20px; background: #f5f5f5;'>" +
            "<div style='max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; margin-bottom: 30px;'>" +
            "<h1 style='color: #ff6b6b; margin: 0;'>🔐</h1>" +
            "<h2 style='color: #333; margin: 10px 0;'>密碼重設申請</h2>" +
            "</div>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>親愛的 <strong>" + userName + "</strong>：</p>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>我們收到了您重設密碼的請求。請點擊下方按鈕以重設您的密碼：</p>" +
            "<div style='text-align: center; margin: 30px 0;'>" +
            "<a href='" + resetLink + "' style='display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 40px; text-decoration: none; border-radius: 25px; font-size: 16px; font-weight: bold;'>重設密碼</a>" +
            "</div>" +
            "<div style='background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;'>" +
            "<p style='color: #856404; margin: 0; font-size: 14px;'>⚠️ 此連結將在 <strong>30分鐘後</strong> 失效。</p>" +
            "</div>" +
            "<p style='color: #666; font-size: 14px; line-height: 1.6;'>如果按鈕無法點擊，請複製以下連結到瀏覽器：</p>" +
            "<p style='background: #f5f5f5; padding: 10px; border-radius: 4px; word-break: break-all; font-size: 12px; color: #666;'>" + resetLink + "</p>" +
            "<div style='background: #f8d7da; border-left: 4px solid #dc3545; padding: 15px; margin: 20px 0; border-radius: 4px;'>" +
            "<p style='color: #721c24; margin: 0; font-size: 14px;'>⚠️ <strong>重要提醒</strong></p>" +
            "<p style='color: #721c24; margin: 5px 0 0 0; font-size: 13px;'>如果您沒有申請重設密碼，請忽略此信件。您的帳號仍然是安全的。</p>" +
            "</div>" +
            "<hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'>" +
            "<p style='color: #999; font-size: 12px; text-align: center; margin: 0;'>© 2025 北護二手書交易網 | 本郵件由系統自動發送，請勿直接回覆</p>" +
            "</div>" +
            "</body>" +
            "</html>";
        
        message.setContent(emailContent, "text/html; charset=UTF-8");
        Transport.send(message);
    }
%>