<%@page contentType="application/json" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="jakarta.mail.*"%>
<%@page import="jakarta.mail.internet.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    try {
        // 檢查是否登入
        String buyerId = (String) session.getAttribute("userId");
        String buyerUsername = (String) session.getAttribute("username");
        String buyerName = (String) session.getAttribute("name");
        
        System.out.println("=== 偵錯資訊 ===");
        System.out.println("buyerId: " + buyerId);
        System.out.println("buyerUsername: " + buyerUsername);
        System.out.println("buyerName: " + buyerName);
        
        if (buyerId == null || buyerId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"請先登入\"}");
            return;
        }
        
        // 取得表單資料
        String bookId = request.getParameter("bookId");
        String sellerId = request.getParameter("sellerId");
        String sellerEmail = request.getParameter("sellerEmail");
        String message = request.getParameter("message");
        
        // 偵錯：印出所有參數
        System.out.println("bookId: " + bookId);
        System.out.println("sellerId: " + sellerId);
        System.out.println("sellerEmail: " + sellerEmail);
        System.out.println("message: " + message);
        
        // 驗證必要資料 (sellerEmail 可以是空的)
        if (bookId == null || bookId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"缺少書籍ID\"}");
            return;
        }
        
        if (sellerId == null || sellerId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"缺少賣家ID\"}");
            return;
        }
        
        if (message == null || message.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"訊息內容不可為空\"}");
            return;
        }
        
        // 防止買家聯絡自己
        if (buyerId.equals(sellerId)) {
            out.print("{\"success\": false, \"message\": \"無法聯絡自己的書籍\"}");
            return;
        }
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            
            // 取得書籍資訊
            String bookQuery = "SELECT titleBook FROM book WHERE bookId = ?";
            pstmt = con.prepareStatement(bookQuery);
            pstmt.setString(1, bookId);
            rs = pstmt.executeQuery();
            
            String bookTitle = "";
            if (rs.next()) {
                bookTitle = rs.getString("titleBook");
            } else {
                out.print("{\"success\": false, \"message\": \"找不到書籍資料\"}");
                return;
            }
            rs.close();
            pstmt.close();
            
            // 檢查是否在短時間內重複發送（防止濫用）
            String checkQuery = "SELECT COUNT(*) as cnt FROM messages " +
                              "WHERE buyerId = ? AND sellerId = ? AND bookId = ? " +
                              "AND sentAt > DateAdd('n', -5, Now())";
            pstmt = con.prepareStatement(checkQuery);
            pstmt.setString(1, buyerId);
            pstmt.setString(2, sellerId);
            pstmt.setString(3, bookId);
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt("cnt") > 0) {
                out.print("{\"success\": false, \"message\": \"請勿在短時間內重複發送訊息\"}");
                return;
            }
            rs.close();
            pstmt.close();
            
            // 將訊息存入資料庫
            String insertQuery = "INSERT INTO messages " +
                               "(buyerId, sellerId, bookId, message, isRead, sentAt) " +
                               "VALUES (?, ?, ?, ?, No, Now())";
            pstmt = con.prepareStatement(insertQuery);
            pstmt.setString(1, buyerId);
            pstmt.setString(2, sellerId);
            pstmt.setString(3, bookId);
            pstmt.setString(4, message);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                System.out.println("訊息已成功存入資料庫");
                
                // 發送郵件通知賣家（可選）
                try {
                    if (sellerEmail != null && !sellerEmail.trim().isEmpty()) {
                        sendEmailNotification(sellerEmail, buyerName, bookTitle, message);
                        System.out.println("郵件通知已發送到: " + sellerEmail);
                    } else {
                        System.out.println("賣家沒有提供email，跳過郵件通知");
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
            System.out.println("資料庫錯誤: " + e.getMessage());
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
        System.out.println("頂層錯誤: " + e.getMessage());
        out.print("{\"success\": false, \"message\": \"系統發生錯誤\"}");
    }
%>

<%!
    private void sendEmailNotification(String toEmail, String buyerName, String bookTitle, String messageContent) 
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
        emailMessage.setSubject("【北護二手書】有人對您的書籍《" + bookTitle + "》感興趣");
        
        String emailContent = 
            "<html><body style='font-family: Microsoft JhengHei, sans-serif;'>" +
            "<h2 style='color: #d9534f;'>📚 您有新的購買詢問</h2>" +
            "<p>親愛的賣家，您好！</p>" +
            "<p>會員 <strong>" + (buyerName != null ? buyerName : "匿名買家") + "</strong> 對您的書籍感興趣：</p>" +
            "<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #d9534f; margin: 20px 0;'>" +
            "<p><strong>書籍名稱：</strong>" + bookTitle + "</p>" +
            "<p><strong>買家訊息：</strong></p>" +
            "<p style='white-space: pre-wrap;'>" + messageContent + "</p>" +
            "</div>" +
            "<p>請登入系統查看完整訊息並與買家聯繫。</p>" +
            "<hr style='margin: 30px 0;'>" +
            "<p style='color: #888; font-size: 12px;'>此為系統自動發送的郵件，請勿直接回覆。</p>" +
            "</body></html>";
        
        emailMessage.setContent(emailContent, "text/html; charset=utf-8");
        Transport.send(emailMessage);
    }
%>