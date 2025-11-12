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
        footer {
            background-color: #343a40;
            color: #ced4da;
            padding: 40px 0 20px;
            font-size: 14px;
        }
        footer a {
            color: #adb5bd;
            text-decoration: none;
        }
        footer a:hover {
            color: white;
        }
    </style>
</head>
<body>

<div class="form-container">
    <div class="card">
        <div class="card-header">忘記密碼</div>
        <div class="card-body">
            <form action="resetPassword.jsp" method="post">
                <div class="mb-3">
                    <label for="input" class="form-label">請輸入註冊時的帳號：</label>
                    <input type="text" class="form-control" id="input" name="input" required>
                </div>
                <button type="submit" class="btn btn-success w-100">查詢</button>
            </form>
            <div class="mt-3 text-center">
                <a href="login.jsp" class="btn btn-link">返回登入頁</a>
            </div>
        </div>
    </div>
</div>

<!-- Footer Start -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：北護二手書拍賣系統</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025 二手書拍賣網. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->

</body>
</html>
