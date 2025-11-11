<%@page contentType="text/html" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>會員註冊 - 北護二手書交易網</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Microsoft JhengHei', sans-serif;
        }
        .signup-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            margin: 20px;
        }
        .signup-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .signup-header h2 {
            color: #333;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .signup-header p {
            color: #666;
            font-size: 14px;
        }
        .form-label {
            font-weight: 600;
            color: #555;
            margin-bottom: 8px;
        }
        .form-control, .form-select {
            border-radius: 5px;
            padding: 12px;
            border: 1px solid #ddd;
        }
        .form-control:focus, .form-select:focus {
            border-color: #0d6efd;
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
        }
        .btn-signup {
            width: 100%;
            padding: 10px 20px;
            border-radius: 5px;
            background-color: #198754;
            border: none;
            color: white;
            font-weight: normal;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .btn-signup:hover {
            background-color: #157347;
            opacity: 1;
        }
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .login-link a {
            color: #0d6efd;
            text-decoration: none;
            font-weight: 600;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .alert {
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .text-danger {
            color: #d9534f;
        }
        .department-row {
            display: flex;
            gap: 10px;
        }
        .department-row .form-select {
            flex: 1;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <div class="signup-header">
            <h2>📚 會員註冊</h2>
            <p>加入北護二手書交易網</p>
        </div>

        <%
            String status = request.getParameter("status");
            if ("IDexist".equals(status)) {
        %>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <strong>⚠️ 此信箱已被註冊！</strong>請使用其他信箱或直接登入。
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <%
            } else if ("error".equals(status)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <strong>❌ 註冊失敗！</strong>系統發生錯誤，請稍後再試。
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <%
            } else if ("invalid".equals(status)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <strong>❌ 資料不完整！</strong>請填寫所有必填欄位。
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <%
            }
        %>

        <form action="signUp_DBInsertInto.jsp" method="POST" onsubmit="return validateForm()">
            <div class="mb-3">
                <label for="name" class="form-label">暱稱 <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="name" name="name" required 
                       placeholder="請輸入您的暱稱" maxlength="50">
            </div>

            <div class="mb-3">
                <label for="email" class="form-label">Email信箱 <span class="text-danger">*</span></label>
                <input type="email" class="form-control" id="email" name="email" required 
                       placeholder="example@ntunhs.edu.tw">
                <small class="text-muted">此信箱將作為您的登入帳號</small>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">密碼 <span class="text-danger">*</span></label>
                <input type="password" class="form-control" id="password" name="password" required 
                       placeholder="至少6個字元" minlength="6" maxlength="50">
            </div>

            <div class="mb-3">
                <label for="confirmPassword" class="form-label">確認密碼 <span class="text-danger">*</span></label>
                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required 
                       placeholder="請再次輸入密碼">
            </div>

            <div class="mb-3">
                <label for="college" class="form-label">就讀系所 <span class="text-danger">*</span></label>
                <div class="department-row">
                    <select class="form-select" id="college" onchange="updateDepartment()" required>
                        <option value="">請選擇學院</option>
                        <option value="護理學院">護理學院</option>
                        <option value="健康科技學院">健康科技學院</option>
                        <option value="人類發展與健康學院">人類發展與健康學院</option>
                        <option value="智慧健康照護跨領域學院">智慧健康照護跨領域學院</option>
                        <option value="通識教育中心">通識教育中心</option>
                    </select>
                    <select class="form-select" id="department" name="department" required>
                        <option value="">請先選擇學院</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="btn btn-signup">立即註冊</button>
        </form>

        <div class="login-link">
            已有帳號？<a href="login.jsp">立即登入</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 系所選項資料
        const departmentOptions = {
            "護理學院": ["護理系所", "護理助產及婦女健康系所", "醫護教育暨數位學習系所", "高齡健康照護系所"],
            "健康科技學院": ["資訊管理系所", "健康事業管理系所", "長期照護系所", "休閒產業與健康促進系所", "語言治療與聽力學系所"],
            "人類發展與健康學院": ["嬰幼兒保育系所", "運動保健系所", "生死與健康心理諮商系所"],
            "智慧健康照護跨領域學院": ["人工智慧與健康大數據系所"],
            "通識教育中心": ["英文", "國文", "其他"]
        };

        // 更新系所選單
        function updateDepartment() {
            const college = document.getElementById("college").value;
            const deptSelect = document.getElementById("department");
            deptSelect.innerHTML = "<option value=''>請選擇系所</option>";

            if (college && departmentOptions[college]) {
                departmentOptions[college].forEach(dept => {
                    const option = document.createElement("option");
                    option.value = dept;
                    option.textContent = dept;
                    deptSelect.appendChild(option);
                });
            }
        }

        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const email = document.getElementById('email').value;
            const college = document.getElementById('college').value;
            const department = document.getElementById('department').value;

            // 檢查密碼是否一致
            if (password !== confirmPassword) {
                alert('❌ 密碼與確認密碼不一致！');
                return false;
            }

            // 檢查密碼長度
            if (password.length < 6) {
                alert('❌ 密碼長度至少需要6個字元！');
                return false;
            }

            // 檢查email格式
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert('❌ 請輸入有效的Email格式！');
                return false;
            }

            // 檢查系所是否已選擇
            if (!college || !department) {
                alert('❌ 請選擇學院和系所！');
                return false;
            }

            return true;
        }

        // 即時檢查密碼是否一致
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (confirmPassword && password !== confirmPassword) {
                this.setCustomValidity('密碼不一致');
            } else {
                this.setCustomValidity('');
            }
        });
    </script>
</body>
</html>