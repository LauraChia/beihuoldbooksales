<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>

<%
// 定義管理員帳號密碼（使用 HashMap 儲存）
Map<String, String> adminUsers = new HashMap<>();
// 格式：adminUsers.put("帳號", "密碼");
adminUsers.put("122114914", "Laurajia40");  // 管理員1
adminUsers.put("122114119", "456");  // 管理員2
adminUsers.put("122114107", "789");  // 管理員3
adminUsers.put("122114128", "145");  // 管理員4
adminUsers.put("student1", "ntunhs2024"); // 學生管理員1
// 可以繼續新增更多管理員帳號

// 處理登入請求
String action = request.getParameter("action");
String message = "";
String messageType = "";

if ("login".equals(action)) {
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    if (username != null && password != null && !username.trim().isEmpty() && !password.trim().isEmpty()) {
        // 檢查帳號是否存在且密碼正確
        if (adminUsers.containsKey(username) && adminUsers.get(username).equals(password)) {
            // 登入成功，建立 session
            session.setAttribute("adminUser", username);
            session.setAttribute("loginTime", new java.util.Date().toString());
            response.sendRedirect("adminDashboard.jsp");
            return;
        } else {
            message = "帳號或密碼錯誤！";
            messageType = "error";
        }
    } else {
        message = "請輸入帳號和密碼！";
        messageType = "error";
    }
}
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理員登入 - 北護二手書交易網</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft JhengHei', Arial, sans-serif;
            background: linear-gradient(135deg,  #f5f5f5 0%,  #f5f5f5 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .login-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            width: 100%;
            max-width: 400px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .login-header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .login-header p {
            color: #666;
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: all 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .login-btn {
    width: 100%;
    padding: 14px;
    background: #00954f; /* 你指定的顏色 */
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
}

.login-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(0, 149, 79, 0.3);
}

.login-btn:active {
    transform: translateY(0);
    box-shadow: none;
}
        
        .message {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }
        
        .message.error {
            background-color: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: #0fac03;
            text-decoration: none;
            font-size: 14px;
        }
        
        .back-link a:hover {
            text-decoration: underline;
        }
        
        .security-note {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 12px;
            margin-top: 20px;
            border-radius: 5px;
            font-size: 12px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>🔒 管理員登入</h1>
            <p>北護二手書交易網管理系統</p>
        </div>
        
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <form method="post" action="adminLogin.jsp">
            <input type="hidden" name="action" value="login">
            
            <div class="form-group">
                <label for="username">管理員帳號</label>
                <input type="text" id="username" name="username" 
                       placeholder="請輸入帳號" required autocomplete="username">
            </div>
            
            <div class="form-group">
                <label for="password">密碼</label>
                <input type="password" id="password" name="password" 
                       placeholder="請輸入密碼" required autocomplete="current-password">
            </div>
            
            <button type="submit" class="login-btn">登入</button>
        </form>
        
        <div class="back-link">
            <a href="index.jsp">← 返回首頁</a>
        </div>
        
        <div class="security-note">
            ⚠️ 此為管理員專用登入系統，僅供授權人員使用。
        </div>
    </div>
</body>
</html>