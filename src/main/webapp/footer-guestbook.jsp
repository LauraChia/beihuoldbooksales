<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
    // 初始化留言列表
    if (application.getAttribute("guestbookMessages") == null) {
        application.setAttribute("guestbookMessages", new ArrayList<Map<String, String>>());
    }
    
    @SuppressWarnings("unchecked")
    ArrayList<Map<String, String>> guestbookMessages = 
        (ArrayList<Map<String, String>>) application.getAttribute("guestbookMessages");
    
    // 處理新留言提交
    if (request.getMethod().equals("POST") && "postMessage".equals(request.getParameter("action"))) {
        String author = request.getParameter("guestAuthor");
        String content = request.getParameter("guestContent");
        
        if (author != null && !author.trim().isEmpty() && 
            content != null && !content.trim().isEmpty()) {
            
            Map<String, String> message = new HashMap<>();
            message.put("author", author.trim());
            message.put("content", content.trim());
            message.put("time", new SimpleDateFormat("MM/dd HH:mm").format(new Date()));
            
            guestbookMessages.add(0, message);
            
            // 限制最多顯示50則留言
            if (guestbookMessages.size() > 50) {
                guestbookMessages.remove(guestbookMessages.size() - 1);
            }
        }
        
        response.sendRedirect(request.getRequestURI() + "#guestbook");
        return;
    }
%>

<style>
    /* 淺綠色主題 */
    .footer-guestbook {
        background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
        padding: 60px 20px 40px;
        margin-top: 80px;
    }
    
    .guestbook-container {
        max-width: 1200px;
        margin: 0 auto;
    }
    
    .guestbook-title {
        text-align: center;
        color: #155724;
        font-size: 2em;
        margin-bottom: 15px;
        font-weight: 700;
    }
    
    .guestbook-subtitle {
        text-align: center;
        color: #19692c;
        margin-bottom: 40px;
        font-size: 1.1em;
    }
    
    .guestbook-content {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 30px;
        margin-bottom: 40px;
    }
    
    .guestbook-form {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.3);
    }
    
    .guestbook-form h3 {
        color: #155724;
        margin-bottom: 20px;
        font-size: 1.3em;
    }
    
    .guest-form-group {
        margin-bottom: 15px;
    }
    
    .guest-form-group label {
        display: block;
        margin-bottom: 6px;
        color: #155724;
        font-weight: 600;
        font-size: 0.95em;
    }
    
    .guest-form-group input,
    .guest-form-group textarea {
        width: 100%;
        padding: 10px 12px;
        border: 2px solid #e0e0e0;
        border-radius: 6px;
        font-size: 0.95em;
        font-family: inherit;
        transition: border-color 0.3s;
    }
    
    .guest-form-group input:focus,
    .guest-form-group textarea:focus {
        outline: none;
        border-color: #28a745;
    }
    
    .guest-form-group textarea {
        resize: vertical;
        min-height: 100px;
    }
    
    .guest-submit-btn {
        background: linear-gradient(135deg, #28a745 0%, #218838 100%);
        color: white;
        padding: 12px 30px;
        border: none;
        border-radius: 6px;
        font-size: 1em;
        font-weight: 600;
        cursor: pointer;
        width: 100%;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .guest-submit-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
    }
    
    .guestbook-messages {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.3);
        max-height: 500px;
        overflow-y: auto;
    }
    
    .guestbook-messages h3 {
        color: #155724;
        margin-bottom: 20px;
        font-size: 1.3em;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .message-count {
        font-size: 0.85em;
        color: #19692c;
        font-weight: normal;
    }
    
    .guest-message {
        background: #e2f0d9;
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 12px;
        border-left: 4px solid #28a745;
        transition: transform 0.2s;
    }
    
    .guest-message:hover {
        transform: translateX(5px);
    }
    
    .guest-message-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        font-size: 0.9em;
    }
    
    .guest-author {
        color: #28a745;
        font-weight: 700;
    }
    
    .guest-time {
        color: #19692c;
        font-size: 0.9em;
    }
    
    .guest-content {
        color: #155724;
        line-height: 1.5;
        font-size: 0.95em;
    }
    
    .no-messages {
        text-align: center;
        color: #19692c;
        padding: 40px 20px;
        font-size: 1em;
    }
    
    .footer-copyright {
        text-align: center;
        color: #19692c;
        margin-top: 30px;
        padding-top: 20px;
        border-top: 1px solid rgba(0,0,0,0.05);
        font-size: 0.9em;
    }
    
    /* 自定義滾動條 */
    .guestbook-messages::-webkit-scrollbar {
        width: 8px;
    }
    
    .guestbook-messages::-webkit-scrollbar-track {
        background: #d4edda;
        border-radius: 4px;
    }
    
    .guestbook-messages::-webkit-scrollbar-thumb {
        background: #28a745;
        border-radius: 4px;
    }
    
    .guestbook-messages::-webkit-scrollbar-thumb:hover {
        background: #218838;
    }
    
    @media (max-width: 968px) {
        .guestbook-content {
            grid-template-columns: 1fr;
        }
        
        .guestbook-messages {
            max-height: 400px;
        }
    }
    
    @media (max-width: 600px) {
        .footer-guestbook {
            padding: 40px 15px 30px;
        }
        
        .guestbook-title {
            font-size: 1.6em;
        }
        
        .guestbook-form,
        .guestbook-messages {
            padding: 20px;
        }
    }
</style>

<footer id="guestbook" class="footer-guestbook">
    <div class="guestbook-container">
        <h2 class="guestbook-title">📝 分享交流區訪客留言板</h2>
        <p class="guestbook-subtitle">留下您的足跡，分享您的想法</p>
        
        <div class="guestbook-content">
            <!-- 留言表單 -->
            <div class="guestbook-form">
                <h3>✍️ 發表留言</h3>
                <form method="post" action="#guestbook">
                    <input type="hidden" name="action" value="postMessage">
                    
                    <div class="guest-form-group">
                        <label for="guestAuthor">姓名(匿名也可) *</label>
                        <input type="text" id="guestAuthor" name="guestAuthor" 
                               required placeholder="請輸入您的名稱" maxlength="30">
                    </div>
                    
                    <div class="guest-form-group">
                        <label for="guestContent">留言內容 *</label>
                        <textarea id="guestContent" name="guestContent" 
                                  required placeholder="寫下您的留言..." maxlength="300"></textarea>
                    </div>
                    
                    <button type="submit" class="guest-submit-btn">送出留言</button>
                </form>
            </div>
            
            <!-- 留言列表 -->
            <div class="guestbook-messages">
                <h3>
                    💬 最新留言
                    <span class="message-count">(<%= guestbookMessages.size() %>)</span>
                </h3>
                
                <% if (guestbookMessages.isEmpty()) { %>
                    <div class="no-messages">
                        還沒有人留言，快來留言！
                    </div>
                <% } else { %>
                    <% 
                        // 只顯示最新的10則留言
                        int displayCount = Math.min(guestbookMessages.size(), 10);
                        for (int i = 0; i < displayCount; i++) {
                            Map<String, String> msg = guestbookMessages.get(i);
                    %>
                        <div class="guest-message">
                            <div class="guest-message-header">
                                <span class="guest-author"><%= msg.get("author") %></span>
                                <span class="guest-time"><%= msg.get("time") %></span>
                            </div>
                            <div class="guest-content">
                                <%= msg.get("content").replace("\n", "<br>") %>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
        
        <div class="footer-copyright">
            <div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：國北護二手書交易網</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
            
                <a class="btn btn-link" href="index.jsp">首頁</a>
                
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書交易網. @All Rights Reserved.</p>
    </div>
</div>
        </div>
    </div>
</footer>
