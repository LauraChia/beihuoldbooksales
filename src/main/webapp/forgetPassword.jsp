<%@ page contentType="text/html; charset=UTF-8" %>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>忘記密碼 - 北護二手書拍賣網</title>
    <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background-color:#d8f3dc;"> <!-- 淺綠色背景 -->
<div class="container mt-5 pt-5">
    <div class="card p-4 shadow-sm">
        <h4 class="mb-3 text-center">忘記密碼</h4>
        <form action="resetPassword.jsp" method="post">
            <label for="input" class="form-label">請輸入註冊時的電子郵件或帳號：</label>
            <input type="text" class="form-control mb-3" id="input" name="input" required>
            <button type="submit" class="btn btn-success w-100">查詢</button>
        </form>
        <a href="login.jsp" class="btn btn-link w-100 mt-2">返回登入頁</a>
    </div>
</div>
</body>
</html>