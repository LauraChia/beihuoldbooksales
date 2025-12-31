<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="jakarta.mail.*"%>
<%@page import="jakarta.mail.internet.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    try {
        // 檢查是否登入
        String userIdStr = (String) session.getAttribute("userId");
        String userName = (String) session.getAttribute("name");
        
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"請先登入\"}");
            return;
        }
        
        int userId = Integer.parseInt(userIdStr);
        
        // 取得參數
        String conversationId = request.getParameter("conversationId");
        String message = request.getParameter("message");
        String senderType = request.getParameter("senderType");
        String senderIdParam = request.getParameter("senderId");
        String receiverIdParam = request.getParameter("receiverId");
        String bookId = request.getParameter("bookId");
        
        // 驗證必要資料
        if (conversationId == null || conversationId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"缺少對話ID\"}");
            return;
        }
        
        if (message == null || message.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"訊息內容不可為空\"}");
            return;
        }
        
        if (senderType == null || (!senderType.equals("buyer") && !senderType.equals("seller"))) {
            out.print("{\"success\": false, \"message\": \"發送者類型錯誤\"}");
            return;
        }
        
        if (senderIdParam == null || receiverIdParam == null || bookId == null) {
            out.print("{\"success\": false, \"message\": \"缺少必要參數\"}");
            return;
        }
        
        int senderId = Integer.parseInt(senderIdParam);
        int receiverId = Integer.parseInt(receiverIdParam);
        
        // 驗證發送者身份
        if (userId != senderId) {
            out.print("{\"success\": false, \"message\": \"發送者身份驗證失敗\"}");
            return;
        }
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            
            // 取得對話資訊（用於郵件通知）
            String bookTitle = "";
            String receiverEmail = "";
            String receiverName = "";
            
            // 先嘗試從現有訊息中查詢
            String infoSQL = "SELECT " +
                           "b.title, " +
                           "bl.sellerId, " +
                           "sender.name as senderName, sender.username as senderEmail, sender.userId as senderUserId, " +
                           "receiver.name as receiverName, receiver.username as receiverEmail, receiver.userId as receiverUserId " +
                           "FROM messages m " +
                           "INNER JOIN bookListings bl ON m.bookId = bl.listingId " +
                           "INNER JOIN books b ON bl.bookId = b.bookId " +
                           "INNER JOIN users sender ON m.senderId = sender.userId " +
                           "INNER JOIN users receiver ON m.receiverId = receiver.userId " +
                           "WHERE m.conversationId = ? " +
                           "ORDER BY m.messageId LIMIT 1";

            pstmt = con.prepareStatement(infoSQL);
            pstmt.setString(1, conversationId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 如果找到現有訊息，從中取得資訊
                bookTitle = rs.getString("title");
                
                int firstSenderUserId = rs.getInt("senderUserId");
                int firstReceiverUserId = rs.getInt("receiverUserId");
                
                if (receiverId == firstSenderUserId) {
                    receiverEmail = rs.getString("senderEmail");
                    receiverName = rs.getString("senderName");
                } else {
                    receiverEmail = rs.getString("receiverEmail");
                    receiverName = rs.getString("receiverName");
                }
                rs.close();
                pstmt.close();
            } else {
                // 如果是第一次對話，直接從 bookListings 和 users 查詢
                rs.close();
                pstmt.close();
                
                String firstMsgSQL = "SELECT " +
                                   "b.title, " +
                                   "u.name, u.username " +
                                   "FROM bookListings bl " +
                                   "INNER JOIN books b ON bl.bookId = b.bookId " +
                                   "INNER JOIN users u ON u.userId = ? " +
                                   "WHERE bl.listingId = ?";
                
                pstmt = con.prepareStatement(firstMsgSQL);
                pstmt.setInt(1, receiverId);
                pstmt.setString(2, bookId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    bookTitle = rs.getString("title");
                    receiverName = rs.getString("name");
                    receiverEmail = rs.getString("username");
                } else {
                    out.print("{\"success\": false, \"message\": \"找不到書籍或使用者資料\"}");
                    return;
                }
                rs.close();
                pstmt.close();
            }
            
            // 插入訊息
            String insertSQL = "INSERT INTO messages " +
                             "(conversationId, senderId, receiverId, bookId, senderType, message, sentAt, isRead) " +
                             "VALUES (?, ?, ?, ?, ?, ?, Now(), No)";
            
            pstmt = con.prepareStatement(insertSQL);
            pstmt.setString(1, conversationId);
            pstmt.setInt(2, senderId);
            pstmt.setInt(3, receiverId);
            pstmt.setString(4, bookId);
            pstmt.setString(5, senderType);
            pstmt.setString(6, message);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // 發送郵件通知給對方
                try {
                    if (receiverEmail != null && !receiverEmail.trim().isEmpty()) {
                        sendEmailNotification(receiverEmail, receiverName, userName, bookTitle, message, conversationId);
                        System.out.println("郵件通知已發送到: " + receiverEmail);
                    }
                } catch (Exception e) {
                    System.out.println("郵件發送失敗: " + e.getMessage());
                    e.printStackTrace();
                }
                
                out.print("{\"success\": true, \"message\": \"訊息已成功發送\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"訊息發送失敗\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"系統錯誤: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            try {
                if (rs != null) rs.close();
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

<%!
    private void sendEmailNotification(String toEmail, String toName, String senderName, 
                                      String bookTitle, String messageContent, String conversationId) 
            throws Exception {
        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        final String username = "ntunhs.booksystem@gmail.com";
        final String password = "stnz fbov iozy yfyl";
        
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        Message emailMessage = new MimeMessage(mailSession);
        emailMessage.setFrom(new InternetAddress(username, "北護二手書交易網"));
        emailMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        emailMessage.setSubject("【北護二手書】" + senderName + " 回覆了您的訊息");
        
        String emailContent = 
            "<html><body style='font-family: Microsoft JhengHei, sans-serif;'>" +
            "<div style='max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;'>" +
            
            "<div style='background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%); color: white; padding: 25px; border-radius: 10px 10px 0 0;'>" +
            "<h2 style='margin: 0; font-size: 24px;'>💬 您有新訊息</h2>" +
            "</div>" +
            
            "<div style='background: white; padding: 30px; border-radius: 0 0 10px 10px;'>" +
            "<p style='font-size: 16px; color: #333;'>親愛的 <strong style='color: #66bb6a;'>" + toName + "</strong>，您好！</p>" +
            
            "<p style='font-size: 16px; color: #333;'><strong style='color: #667eea;'>" + senderName + "</strong> 剛剛回覆了關於書籍「<strong>" + bookTitle + "</strong>」的訊息：</p>" +
            
            "<div style='background-color: #f8fdf9; padding: 20px; border-left: 4px solid #81c784; margin: 20px 0; border-radius: 5px;'>" +
            "<p style='margin: 0; white-space: pre-wrap; line-height: 1.6; color: #333;'>" + messageContent + "</p>" +
            "</div>" +
            
            "<div style='text-align: center; margin: 30px 0;'>" +
            "<a href='http://localhost:8081/book/conversation.jsp?conversationId=" + conversationId + "' " +
            "style='background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%); color: white; " +
            "padding: 15px 40px; text-decoration: none; border-radius: 25px; display: inline-block; " +
            "font-weight: bold; font-size: 16px; box-shadow: 0 4px 12px rgba(129, 199, 132, 0.3);'>" +
            "💬 立即查看並回覆" +
            "</a>" +
            "</div>" +
            
            "<div style='background-color: #fff3cd; padding: 15px; border-radius: 5px; border: 1px solid #ffc107; margin-top: 20px;'>" +
            "<p style='margin: 0; color: #856404; font-size: 14px;'>" +
            "<strong>💡 提醒：</strong>對方正在等待您的回覆，請盡快處理！" +
            "</p>" +
            "</div>" +
            
            "</div>" +
            
            "<div style='text-align: center; padding: 20px; color: #888; font-size: 12px;'>" +
            "<p style='margin: 5px 0;'>此為系統自動發送的郵件，請勿直接回覆。</p>" +
            "<p style='margin: 5px 0;'>如有任何問題，請登入系統查看。</p>" +
            "</div>" +
            
            "</div>" +
            "</body></html>";
        
        emailMessage.setContent(emailContent, "text/html; charset=utf-8");
        Transport.send(emailMessage);
    }
%>