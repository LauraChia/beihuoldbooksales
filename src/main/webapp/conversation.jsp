<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>對話 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        /* CSS 保持不變 */
        body {
            background-color: #f0f2f5;
            font-family: "Microsoft JhengHei", sans-serif;
            margin: 0;
            padding: 0;
        }
        
        .chat-container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            max-width: 900px;
            margin: 0 auto;
            background: white;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
        }
        
        .chat-header {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .header-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .back-button {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }
        
        .back-button:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .other-person-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: white;
            color: #66bb6a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: bold;
        }
        
        .header-info h5 {
            margin: 0;
            font-size: 18px;
        }
        
        .header-info small {
            opacity: 0.9;
            font-size: 13px;
        }
        
        .book-info-bar {
            background: #f8fdf9;
            padding: 15px 20px;
            border-bottom: 1px solid #e8f5e9;
            display: flex;
            align-items: center;
            gap: 15px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .book-info-bar:hover {
            background: #f1f8f4;
        }
        
        .book-info-bar img {
            width: 50px;
            height: 65px;
            object-fit: cover;
            border-radius: 5px;
        }
        
        .book-details h6 {
            margin: 0;
            color: #66bb6a;
            font-weight: 600;
            font-size: 15px;
        }
        
        .book-price {
            color: #d9534f;
            font-weight: bold;
            font-size: 16px;
        }
        
        .messages-area {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f9f9f9;
        }
        
        .message-group {
            margin-bottom: 20px;
        }
        
        .message-date {
            text-align: center;
            color: #999;
            font-size: 12px;
            margin: 20px 0 10px 0;
        }
        
        .message {
            display: flex;
            margin-bottom: 10px;
            animation: slideIn 0.3s;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .message.sent {
            justify-content: flex-end;
        }
        
        .message.received {
            justify-content: flex-start;
        }
        
        .message-bubble {
            max-width: 70%;
            padding: 12px 16px;
            border-radius: 18px;
            position: relative;
            word-wrap: break-word;
        }
        
        .message.sent .message-bubble {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }
        
        .message.received .message-bubble {
            background: white;
            color: #333;
            border-bottom-left-radius: 4px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }
        
        .message-time {
            font-size: 11px;
            margin-top: 4px;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .message.sent .message-time {
            justify-content: flex-end;
            color: rgba(255, 255, 255, 0.8);
        }
        
        .message.received .message-time {
            color: #999;
        }
        
        .read-status {
            font-size: 10px;
        }
        
        .input-area {
            background: white;
            padding: 15px 20px;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .input-area textarea {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 20px;
            padding: 10px 15px;
            resize: none;
            font-family: "Microsoft JhengHei", sans-serif;
            font-size: 14px;
            max-height: 100px;
        }
        
        .input-area textarea:focus {
            outline: none;
            border-color: #81c784;
        }
        
        .send-button {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            border: none;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            font-size: 18px;
        }
        
        .send-button:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .send-button:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        
        .empty-messages {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-messages i {
            font-size: 60px;
            color: #c8e6c9;
            margin-bottom: 15px;
        }
        
        @media (max-width: 768px) {
            .chat-container {
                height: 100vh;
            }
            
            .message-bubble {
                max-width: 85%;
            }
        }
    </style>
</head>
<body>

<%
    String conversationId = request.getParameter("conversationId");
    String userIdStr = (String) session.getAttribute("userId");
    
    if (userIdStr == null || userIdStr.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = Integer.parseInt(userIdStr);
    
    if (conversationId == null || conversationId.trim().isEmpty()) {
        response.sendRedirect("myMessages.jsp");
        return;
    }
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String otherPersonName = "";
    String bookTitle = "";
    String bookPrice = "";
    String bookPhoto = "";
    String bookId = "";
    String listingId = "";
    boolean iAmBuyer = false;
    int otherPersonId = 0;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 取得對話基本資訊
        // 需要從 bookListings 找出 sellerId 來判斷誰是買家誰是賣家
        String infoSQL = "SELECT m.senderId, m.receiverId, m.bookId, m.senderType, " +
                        "b.title, bl.photo, bl.price, bl.listingId, bl.sellerId, " +
                        "sender.name as senderName, receiver.name as receiverName " +
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
            int senderId = rs.getInt("senderId");
            int receiverId = rs.getInt("receiverId");
            int sellerId = rs.getInt("sellerId");
            String senderName = rs.getString("senderName");
            String receiverName = rs.getString("receiverName");
            
            // 🔴 判斷我是買家還是賣家
            iAmBuyer = (userId != sellerId);
            
            // 🔴 判斷對方是誰
            if (userId == senderId) {
                otherPersonId = receiverId;
                otherPersonName = receiverName;
            } else {
                otherPersonId = senderId;
                otherPersonName = senderName;
            }
            
            bookTitle = rs.getString("title");
            bookPrice = rs.getString("price");
            bookPhoto = rs.getString("photo");
            bookId = rs.getString("bookId");
            listingId = rs.getString("listingId");
            
            // 處理圖片
            if (bookPhoto != null && !bookPhoto.trim().isEmpty()) {
                String[] photoArray = bookPhoto.split(",");
                bookPhoto = photoArray[0].trim();
                if (!bookPhoto.startsWith("assets/")) {
                    bookPhoto = "assets/images/member/" + bookPhoto;
                }
            } else {
                bookPhoto = "assets/images/about.png";
            }
        } else {
            response.sendRedirect("myMessages.jsp");
            return;
        }
        rs.close();
        pstmt.close();
        
        //標記對方發送給我的訊息為已讀
        String markReadSQL = "UPDATE messages SET isRead = true " +
                           "WHERE conversationId = ? " +
                           "AND receiverId = ? " +
                           "AND isRead = false";
        pstmt = con.prepareStatement(markReadSQL);
        pstmt.setString(1, conversationId);
        pstmt.setInt(2, userId);  // 我是接收者
        pstmt.executeUpdate();
        pstmt.close();
%>

<div class="chat-container">
    <!-- 聊天室標題列 -->
    <div class="chat-header">
        <div class="header-left">
            <button class="back-button" onclick="location.href='myMessages.jsp'">
                <i class="fas fa-arrow-left"></i>
            </button>
            <div class="other-person-avatar">
                <%= otherPersonName.substring(0, 1) %>
            </div>
            <div class="header-info">
                <h5><%= otherPersonName %></h5>
                <small><i class="fas fa-circle" style="color: #4caf50; font-size: 8px;"></i> 線上</small>
            </div>
        </div>
    </div>
    
    <!-- 書籍資訊列 -->
    <div class="book-info-bar" onclick="location.href='bookDetail.jsp?listingId=<%= listingId %>'">
        <img src="<%= bookPhoto %>" alt="書籍封面" onerror="this.src='assets/images/about.png'">
        <div class="book-details">
            <h6><i class="fas fa-book"></i> <%= bookTitle %></h6>
            <div class="book-price">NT$ <%= (int)Float.parseFloat(bookPrice) %></div>
        </div>
        <div style="margin-left: auto; color: #999;">
            <i class="fas fa-chevron-right"></i>
        </div>
    </div>
    
    <!-- 訊息區域 -->
    <div class="messages-area" id="messagesArea">
        <%
            // 查詢所有訊息
            String messagesSQL = "SELECT messageId, senderId, senderType, message, sentAt, isRead " +
                               "FROM messages " +
                               "WHERE conversationId = ? " +
                               "ORDER BY sentAt ASC";
            
            pstmt = con.prepareStatement(messagesSQL);
            pstmt.setString(1, conversationId);
            rs = pstmt.executeQuery();
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            String lastDate = "";
            
            boolean hasMessages = false;
            while (rs.next()) {
                hasMessages = true;
                
                int msgSenderId = rs.getInt("senderId");
                String senderType = rs.getString("senderType");
                String message = rs.getString("message");
                Timestamp sentAt = rs.getTimestamp("sentAt");
                boolean isRead = rs.getBoolean("isRead");
                
                // 判斷是我發送的還是對方發送的
                boolean iSent = (userId == msgSenderId);
                
                // 顯示日期分隔
                String currentDate = dateFormat.format(sentAt);
                if (!currentDate.equals(lastDate)) {
                    lastDate = currentDate;
                    
                    // 轉換日期顯示
                    Calendar sentCal = Calendar.getInstance();
                    sentCal.setTime(sentAt);
                    Calendar today = Calendar.getInstance();
                    Calendar yesterday = Calendar.getInstance();
                    yesterday.add(Calendar.DATE, -1);
                    
                    String dateStr = "";
                    if (sentCal.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                        sentCal.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)) {
                        dateStr = "今天";
                    } else if (sentCal.get(Calendar.YEAR) == yesterday.get(Calendar.YEAR) &&
                              sentCal.get(Calendar.DAY_OF_YEAR) == yesterday.get(Calendar.DAY_OF_YEAR)) {
                        dateStr = "昨天";
                    } else {
                        SimpleDateFormat displayDateFormat = new SimpleDateFormat("MM月dd日");
                        dateStr = displayDateFormat.format(sentAt);
                    }
        %>
        <div class="message-date"><%= dateStr %></div>
        <%
                }
        %>
        
        <div class="message <%= iSent ? "sent" : "received" %>">
            <div class="message-bubble">
                <div><%= message %></div>
                <div class="message-time">
                    <%= timeFormat.format(sentAt) %>
                    <% if (iSent) { %>
                        <span class="read-status"><%= isRead ? "✓✓" : "✓" %></span>
                    <% } %>
                </div>
            </div>
        </div>
        
        <%
            }
            
            if (!hasMessages) {
        %>
        <div class="empty-messages">
            <i class="fas fa-comments"></i>
            <p>還沒有訊息，開始對話吧！</p>
        </div>
        <%
            }
        %>
    </div>
    
    <!-- 輸入區域 -->
    <div class="input-area">
        <textarea id="messageInput" 
                  placeholder="輸入訊息..." 
                  rows="1"
                  onkeypress="handleKeyPress(event)"
                  oninput="autoResize(this)"></textarea>
        <button class="send-button" onclick="sendMessage()" id="sendBtn">
            <i class="fas fa-paper-plane"></i>
        </button>
    </div>
</div>

<script>
    const conversationId = '<%= conversationId %>';
    const userId = <%= userId %>;
    const iAmBuyer = <%= iAmBuyer %>;
    const otherPersonId = <%= otherPersonId %>;
    const bookId = '<%= listingId %>';
    
    // 頁面載入時滾動到底部
    window.onload = function() {
        scrollToBottom();
    };
    
    function scrollToBottom() {
        const messagesArea = document.getElementById('messagesArea');
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }
    
    function autoResize(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = Math.min(textarea.scrollHeight, 100) + 'px';
    }
    
    function handleKeyPress(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            sendMessage();
        }
    }
    
    function sendMessage() {
        const messageInput = document.getElementById('messageInput');
        const message = messageInput.value.trim();
        
        if (!message) {
            return;
        }
        
        const sendBtn = document.getElementById('sendBtn');
        sendBtn.disabled = true;
        
        // 傳送參數
        const formData = new URLSearchParams();
        formData.append('conversationId', conversationId);
        formData.append('message', message);
        formData.append('senderId', userId);
        formData.append('receiverId', otherPersonId);
        formData.append('bookId', bookId);
        formData.append('senderType', iAmBuyer ? 'buyer' : 'seller');
        
        fetch('sendMessage.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                messageInput.value = '';
                messageInput.style.height = 'auto';
                location.reload();
            } else {
                alert('❌ 發送失敗: ' + data.message);
            }
        })
        .catch(error => {
            alert('❌ 系統錯誤: ' + error);
        })
        .finally(() => {
            sendBtn.disabled = false;
        });
    }
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    %>
        <div style="padding: 20px; text-align: center;">
            <p style="color: #c62828;">系統發生錯誤：<%= e.getMessage() %></p>
            <button onclick="location.href='myMessages.jsp'" class="btn btn-primary">返回訊息列表</button>
        </div>
    <%
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    %>

</body>
</html>