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
        response.sendRedirect("signUp.jsp");
        return;
    }

    // ========== 2. 取得並驗證參數 ==========
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String department = request.getParameter("department");
    
    // 檢查必要參數是否存在且不為空
    if (name == null || email == null || password == null || department == null ||
        name.trim().isEmpty() || email.trim().isEmpty() || 
        password.trim().isEmpty() || department.trim().isEmpty()) {
        response.sendRedirect("signUp.jsp?status=invalid");
        return;
    }
    
    // 移除前後空白
    name = name.trim();
    email = email.trim();
    password = password.trim();
    department = department.trim();
    
    // ========== 3. 生成6位數驗證碼 ==========
    String verificationCode = String.format("%06d", new Random().nextInt(1000000));
    
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean success = false;
    
    try {
        // ========== 4. 連接資料庫 ==========
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ========== 5. 檢查信箱是否已存在 ==========
        String checkSql = "SELECT COUNT(*) FROM users WHERE username = ?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        
        if (rs.next() && rs.getInt(1) > 0) {
            // 信箱已存在，導向註冊頁面並顯示錯誤
            rs.close();
            ps.close();
            response.sendRedirect("signUp.jsp?status=IDexist");
            return;
        }
        
        // 關閉查詢資源
        rs.close();
        ps.close();
        
        // ========== 6. 插入新用戶資料 ==========
        String sql = "INSERT INTO users (name, username, password, department, verificationCode, isVerified) " +
                     "VALUES (?, ?, ?, ?, ?, False)";
        ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, email);      // username 設為 email
        ps.setString(3, password);   // 建議:實際應用應該加密密碼
        ps.setString(4, department);
        ps.setString(5, verificationCode);
        
        int rowsAffected = ps.executeUpdate();
        
        if (rowsAffected > 0) {
            success = true;
            
            // ========== 7. 發送驗證信 ==========
            try {
                sendVerificationEmail(email, name, verificationCode);
            } catch (Exception mailEx) {
                // 記錄郵件發送失敗，但不中斷流程
                System.err.println("郵件發送失敗: " + mailEx.getMessage());
                mailEx.printStackTrace();
            }
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        System.err.println("SQL錯誤: " + e.getMessage());
        response.sendRedirect("signUp.jsp?status=error");
        return;
        
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        System.err.println("找不到資料庫驅動程式: " + e.getMessage());
        response.sendRedirect("signUp.jsp?status=error");
        return;
        
    } catch (Exception e) {
        e.printStackTrace();
        System.err.println("系統錯誤: " + e.getMessage());
        response.sendRedirect("signUp.jsp?status=error");
        return;
        
    } finally {
        // ========== 8. 關閉資源 ==========
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    
    // ========== 9. 註冊成功，導向驗證頁面 ==========
    if (success) {
        String encodedEmail = URLEncoder.encode(email, "UTF-8");
        response.sendRedirect("verifyEmail.jsp?email=" + encodedEmail);
    } else {
        response.sendRedirect("signUp.jsp?status=error");
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
        message.setSubject("【北護二手書交易網】信箱驗證碼");
        
        // HTML 郵件內容
        String emailContent = "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='utf-8'></head>" +
            "<body style='font-family: Microsoft JhengHei, sans-serif; padding: 20px; background: #f5f5f5;'>" +
            "<div style='max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; margin-bottom: 30px;'>" +
            "<h1 style='color: #667eea; margin: 0;'>📚</h1>" +
            "<h2 style='color: #333; margin: 10px 0;'>歡迎加入北護二手書交易網！</h2>" +
            "</div>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>親愛的 <strong>" + userName + "</strong>：</p>" +
            "<p style='color: #555; font-size: 16px; line-height: 1.6;'>感謝您註冊我們的平台！為了確保您的帳號安全，請使用以下驗證碼完成註冊：</p>" +
            "<div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px; margin: 30px 0;'>" +
            "<p style='color: white; margin: 0 0 10px 0; font-size: 14px;'>您的驗證碼</p>" +
            "<h1 style='color: white; letter-spacing: 10px; font-size: 42px; margin: 0; font-weight: bold;'>" + code + "</h1>" +
            "</div>" +
            "<div style='background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;'>" +
            "<p style='color: #856404; margin: 0; font-size: 14px;'>⚠️ 此驗證碼將在 <strong>30分鐘後</strong> 失效。</p>" +
            "</div>" +
            "<p style='color: #666; font-size: 14px; line-height: 1.6;'>如果您沒有註冊此帳號，請忽略此信件。</p>" +
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