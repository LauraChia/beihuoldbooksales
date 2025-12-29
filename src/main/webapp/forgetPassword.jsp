<%@page contentType="text/html" pageEncoding="utf-8"%>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>忘記密碼 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .form-container {
            max-width: 400px;
            margin: 100px auto;
        }
        .card {
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }
        .card-header {
            background-color: #28a745;
            color: white;
            font-weight: bold;
            text-align: center;
            font-size: 1.3rem;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
            padding: 15px;
        }
        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
        }
        a.btn-link {
            text-decoration: none;
            color: #28a745;
        }
        a.btn-link:hover {
            text-decoration: underline;
        }
        .info-text {
            background-color: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-size: 14px;
            color: #0d47a1;
        }
    </style>
</head>
<body>

<div class="form-container">
    <div class="card">
        <div class="card-header">忘記密碼</div>
        <div class="card-body">
            <div class="info-text">
                🔒 為了您的帳號安全，我們將發送重設密碼連結到您的註冊信箱。
            </div>
            
            <%
                String status = request.getParameter("status");
                if ("sent".equals(status)) {
            %>
                <div class="alert alert-success">
                    ✅ 重設密碼信件已發送！<br>
                    請檢查您的信箱（包含垃圾郵件匣），並在 <strong>30分鐘內</strong> 點擊連結重設密碼。
                </div>
            <%
                } else if ("notfound".equals(status)) {
            %>
                <div class="alert alert-danger">
                    ❌ 查無此帳號，請確認您的信箱是否正確。
                </div>
            <%
                } else if ("error".equals(status)) {
            %>
                <div class="alert alert-danger">
                    ❌ 系統發生錯誤，請稍後再試。
                </div>
            <%
                }
            %>
            
            <form action="sendResetPasswordEmail.jsp" method="post">
                <div class="mb-3">
                    <label for="email" class="form-label">請輸入註冊時的電子郵件：</label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="example@email.com" required>
                    <small class="text-muted">我們會發送重設密碼的連結到此信箱</small>
                </div>
                <button type="submit" class="btn btn-success w-100">發送重設連結</button>
            </form>
            <div class="mt-3 text-center">
                <a href="login.jsp" class="btn btn-link">返回登入頁</a>
            </div>
        </div>
    </div>
</div>

<%@ include file="footer.jsp"%>

</body>
</html>