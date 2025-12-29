<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>驗證信箱 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .verify-container {
            max-width: 450px;
            width: 100%;
            padding: 20px;
        }
        
        .verify-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            padding: 40px;
            text-align: center;
        }
        
        .verify-icon {
            width: 80px;
            height: 80px;
            background-color: #e7f3ff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
        }
        
        .verify-title {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .verify-subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        .verify-email {
            background-color: #f8f9fa;
            padding: 10px;
            border-radius: 6px;
            color: #0d6efd;
            font-weight: 500;
            margin-bottom: 30px;
        }
        
        .code-input-group {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .code-input {
            width: 50px;
            height: 60px;
            font-size: 24px;
            font-weight: bold;
            text-align: center;
            border: 2px solid #ddd;
            border-radius: 8px;
            transition: border-color 0.2s;
        }
        
        .code-input:focus {
            border-color: #0d6efd;
            outline: none;
        }
        
        .btn-verify {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 6px;
            margin-top: 10px;
        }
        
        .resend-link {
            color: #666;
            font-size: 14px;
            margin-top: 20px;
        }
        
        .resend-link a {
            color: #0d6efd;
            text-decoration: none;
            font-weight: 500;
        }
        
        .resend-link a:hover {
            text-decoration: underline;
        }
        
        .alert-custom {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 6px;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .success-custom {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
    <div class="verify-container">
        <div class="verify-card">
            <div class="verify-icon">📧</div>
            <h2 class="verify-title">驗證您的信箱</h2>
            <p class="verify-subtitle">我們已發送驗證碼至：</p>
            <div class="verify-email"><%= request.getParameter("email") %></div>
            
            <%
                String status = request.getParameter("status");
                if ("invalid".equals(status)) {
            %>
                <div class="alert-custom">
                    ⚠️ 驗證碼錯誤，請重新輸入！
                </div>
            <% } else if ("expired".equals(status)) { %>
                <div class="alert-custom">
                    ⚠️ 驗證碼已過期，請重新發送！
                </div>
            <% } else if ("resent".equals(status)) { %>
                <div class="alert-custom success-custom">
                    ✓ 驗證碼已重新發送至您的信箱！
                </div>
            <% } %>
            
            <form action="verifyEmail_process.jsp" method="post" id="verifyForm">
                <input type="hidden" name="email" value="<%= request.getParameter("email") %>">
                
                <div class="code-input-group">
                    <input type="text" class="code-input" maxlength="1" id="code1" name="code1" required>
                    <input type="text" class="code-input" maxlength="1" id="code2" name="code2" required>
                    <input type="text" class="code-input" maxlength="1" id="code3" name="code3" required>
                    <input type="text" class="code-input" maxlength="1" id="code4" name="code4" required>
                    <input type="text" class="code-input" maxlength="1" id="code5" name="code5" required>
                    <input type="text" class="code-input" maxlength="1" id="code6" name="code6" required>
                </div>
                
                <button type="submit" class="btn btn-primary btn-verify">驗證</button>
            </form>
            
            <div class="resend-link">
                沒收到驗證碼？<a href="resendVerification.jsp?email=<%= request.getParameter("email") %>">重新發送</a>
            </div>
        </div>
    </div>

    <script>
        // 自動跳轉到下一個輸入框
        const inputs = document.querySelectorAll('.code-input');
        
        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                if (e.target.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });
            
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
                    inputs[index - 1].focus();
                }
            });
            
            // 只允許數字
            input.addEventListener('keypress', (e) => {
                if (!/[0-9]/.test(e.key)) {
                    e.preventDefault();
                }
            });
        });
        
        // 自動聚焦第一個輸入框
        inputs[0].focus();
    </script>
    
    <script src="js/bootstrap.bundle.min.js"></script>
    
</body>
</html>