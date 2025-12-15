<%@page contentType="text/plain" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="jakarta.mail.*"%>
<%@page import="jakarta.mail.internet.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    out.clearBuffer();
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String currentTime = sdf.format(new java.util.Date());

        // 1. 查詢需要下架的書籍（含賣家資訊）
        String selectSql = "SELECT bl.listingId, bl.bookId, bl.sellerId, b.title, bl.expiryDate, " +
                          "u.name as sellerName, u.username as sellerEmail " +
                          "FROM bookListings bl " +
                          "INNER JOIN books b ON bl.bookId = b.bookId " +
                          "INNER JOIN users u ON bl.sellerId = u.userId " +
                          "WHERE bl.expiryDate <= ? AND bl.isDelisted = FALSE";

        pstmt = con.prepareStatement(selectSql);
        pstmt.setString(1, currentTime);
        rs = pstmt.executeQuery();

        List<Map<String, String>> expiredBooks = new ArrayList<>();

        while (rs.next()) {
            Map<String, String> book = new HashMap<>();
            book.put("listingId", rs.getString("listingId"));
            book.put("bookId", rs.getString("bookId"));
            book.put("sellerId", rs.getString("sellerId"));
            book.put("title", rs.getString("title"));
            book.put("expiryDate", rs.getString("expiryDate"));
            book.put("sellerName", rs.getString("sellerName"));
            book.put("sellerEmail", rs.getString("sellerEmail"));
            expiredBooks.add(book);
        }

        rs.close();
        pstmt.close();

        // 2. 執行下架操作
        if (!expiredBooks.isEmpty()) {
            // 下架書籍（加入 delistReason 和 delistedBy）
            String updateSql = "UPDATE bookListings SET isDelisted = TRUE, delistedAt = ?, " +
                              "delistReason = ?, delistedBy = ? WHERE listingId = ?";
            pstmt = con.prepareStatement(updateSql);

            for (Map<String, String> book : expiredBooks) {
                pstmt.setString(1, currentTime);
                pstmt.setString(2, "自動到期下架");
                pstmt.setString(3, "系統自動執行");
                pstmt.setString(4, book.get("listingId"));
                int updated = pstmt.executeUpdate();

                if (updated > 0) {
                    // 3. 新增系統通知
                    try {
                        String notifySql = "INSERT INTO notifications (userId, message, createdAt, isRead) " +
                                          "VALUES (?, ?, ?, ?)";
                        PreparedStatement notifyStmt = con.prepareStatement(notifySql);
                        notifyStmt.setString(1, book.get("sellerId"));
                        notifyStmt.setString(2, 
                            "📦 書籍下架通知：您的書籍《" + book.get("title") + "》已到達下架時間（" + 
                            book.get("expiryDate") + "），系統已自動將其下架。若需重新上架，請至「我的書籍」進行操作。");
                        notifyStmt.setString(3, currentTime);
                        notifyStmt.setBoolean(4, false);
                        notifyStmt.executeUpdate();
                        notifyStmt.close();
                    } catch (Exception notifyEx) {
                        // 通知失敗不影響主流程
                    }

                    // 4. 發送郵件通知
                    try {
                        sendDelistingEmail(
                            book.get("sellerEmail"),
                            book.get("sellerName"),
                            book.get("title"),
                            book.get("expiryDate")
                        );
                    } catch (Exception emailEx) {
                        // 郵件發送失敗不影響主流程
                    }
                }
            }

            pstmt.close();
        }

    } catch (Exception e) {
        // 記錄錯誤但不輸出（可選擇性記錄到日誌檔）

    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            // 忽略關閉錯誤
        }
    }
%>

<%!
// 郵件發送方法
private void sendDelistingEmail(String toEmail, String userName, String bookTitle, String expiryDate) 
    throws Exception {
    
    // ⚙️ 郵件伺服器設定（請根據你的環境修改）
    Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");  // SMTP 伺服器
    props.put("mail.smtp.port", "587");              // SMTP 埠號
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    
    // 系統郵件帳號（需要設定應用程式密碼）
    final String systemEmail = "ntunhs.booksystem@gmail.com";
    final String systemPassword = "stnz fbov iozy yfyl";
    
    Session session = Session.getInstance(props, new Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(systemEmail, systemPassword);
        }
    });
    
    Message message = new MimeMessage(session);
    message.setFrom(new InternetAddress(systemEmail, "二手書交易平台"));
    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
    message.setSubject("📦 書籍下架通知");
    
    // HTML 郵件內容
    String emailBody = 
        "<html><body style='font-family: Arial, sans-serif;'>" +
        "<div style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
        "<h2 style='color: #333;'>📦 書籍已自動下架</h2>" +
        "<p>親愛的 <strong>" + userName + "</strong>，您好：</p>" +
        "<p>您的書籍已到達設定的下架時間：</p>" +
        "<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 15px 0;'>" +
        "<p><strong>📚 書名：</strong>" + bookTitle + "</p>" +
        "<p><strong>⏰ 下架時間：</strong>" + expiryDate + "</p>" +
        "</div>" +
        "<p>系統已自動將此書籍下架。</p>" +
        "<p>若需要重新上架，請登入平台至<strong>「我的書籍」</strong>進行操作。</p>" +
        "<hr style='margin: 20px 0; border: none; border-top: 1px solid #ddd;'>" +
        "<p style='font-size: 12px; color: #888;'>此為系統自動發送的通知郵件，請勿直接回覆。</p>" +
        "</div>" +
        "</body></html>";
    
    message.setContent(emailBody, "text/html; charset=UTF-8");
    Transport.send(message);
}
%>