<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<%
if(request.getParameter("username") != null &&
   request.getParameter("password") != null){
    
    Connection con = null;
    PreparedStatement pstmt = null;
    PreparedStatement updateStmt = null;
    ResultSet paperrs = null;
    
    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ✅ 使用 PreparedStatement 防止 SQL Injection
        String getpaperdata = "SELECT * FROM users WHERE username=? AND password=?";
        pstmt = con.prepareStatement(getpaperdata);
        pstmt.setString(1, request.getParameter("username"));
        pstmt.setString(2, request.getParameter("password"));
        paperrs = pstmt.executeQuery();
        
        if(paperrs.next()){
            // ✅ 統一使用 "userId" 作為 session 屬性名稱
            session.setAttribute("userId", paperrs.getString("userId"));
            session.setAttribute("username", paperrs.getString("username"));
            
            // ✅ 更新登入時間 - MS Access 使用 Now() 而非 NOW()
            String updateLoginTime = "UPDATE users SET lastLogin=Now() WHERE userId=?";
            updateStmt = con.prepareStatement(updateLoginTime);
            updateStmt.setInt(1, paperrs.getInt("userId"));
            updateStmt.executeUpdate();
            
            response.sendRedirect("index.jsp");
        } else {
            out.println("帳號密碼不符！請重新登入");
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("系統錯誤：" + e.getMessage());
    } finally {
        if(paperrs != null) try { paperrs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(updateStmt != null) try { updateStmt.close(); } catch(Exception e) {}
        if(con != null) try { con.close(); } catch(Exception e) {}
    }
}
%>
<html>
<head>
    <title>登入</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <link rel="icon" type="image/png" href="assets/images/icons/favicon.ico"/>
    <link rel="stylesheet" type="text/css" href="assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="assets/fonts/font-awesome-4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="assets/fonts/Linearicons-Free-v1.0.0/icon-font.min.css">
    <link rel="stylesheet" type="text/css" href="assets/vendor/animate/animate.css">
    <link rel="stylesheet" type="text/css" href="assets/vendor/css-hamburgers/hamburgers.min.css">
    <link rel="stylesheet" type="text/css" href="assets/vendor/animsition/css/animsition.min.css">
    <link rel="stylesheet" type="text/css" href="assets/vendor/select2/select2.min.css">
    <link rel="stylesheet" type="text/css" href="assets/vendor/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" type="text/css" href="assets/css/util.css">
    <link rel="stylesheet" type="text/css" href="assets/css/main.css">
    
    <style>
        /* 統一配色樣式 - 綠色主題 */
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        .container-login100 {
            background-color: #f5f5f5 !important;
            background-image: none !important;
        }
        
        .wrap-login100 {
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 10px;
        }
        
        .login100-form-title {
            color: #333;
        }
        
        .txt1 {
            color: #666;
        }
        
        .txt2 {
            color: #198754;
        }
        
        .txt2:hover {
            color: #157347;
        }
        
        .input100 {
            border-bottom-color: #ddd;
            color: #333;
        }
        
        .focus-input100::before {
            background-color: #198754;
        }
        
        .login100-form-btn {
            background: #198754;
            background: linear-gradient(to right, #198754, #157347);
        }
        
        .login100-form-btn:hover {
            background: #157347;
        }
        
        /* 錯誤訊息樣式 */
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 15px;
            border: 1px solid #f5c6cb;
        }
        
        .warning-message {
            background-color: #fff3cd;
            color: #856404;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 15px;
            border: 1px solid #ffeaa7;
        }
    </style>
</head>
<body>
    <div class="limiter">
        <div class="container-login100">
            <div class="wrap-login100 p-l-110 p-r-110 p-t-62 p-b-33">
                <form class="login100-form validate-form flex-sb flex-w" action="login_DBSelect.jsp" method="post">
                    <span class="login100-form-title p-b-53">
                        登入
                    </span>
                    
                    <%
                        String status = request.getParameter("status");
                        if ("loginerror".equals(status)) {
                    %>
                        <div class="error-message w-full">
                            <i class="fa fa-exclamation-circle"></i> 帳號或密碼錯誤，請重新輸入！
                        </div>
                    <%
                        } else if ("notverified".equals(status)) {
                    %>
                        <div class="warning-message w-full">
                            <i class="fa fa-exclamation-triangle"></i> 請先完成信箱驗證！
                        </div>
                    <%
                        } else if ("error".equals(status)) {
                    %>
                        <div class="error-message w-full">
                            <i class="fa fa-exclamation-circle"></i> 系統錯誤，請稍後再試！
                        </div>
                    <%
                        }
                    %>
                    
                    <div class="p-t-31 p-b-9">
                        <span class="txt1">帳號</span>
                    </div>
                    <div class="wrap-input100 validate-input" data-validate="請輸入帳號">
                        <input class="input100" type="text" name="username" required>
                        <span class="focus-input100"></span>
                    </div>
                    
                    <div class="p-t-13 p-b-9">
                        <span class="txt1">密碼</span>
                        <a href="forgetPassword.jsp" class="txt2 bo1 m-l-5">忘記密碼</a>
                    </div>
                    <div class="wrap-input100 validate-input" data-validate="請輸入密碼">
                        <input class="input100" type="password" name="password" required>
                        <span class="focus-input100"></span>
                    </div>

                    <div class="container-login100-form-btn m-t-17">
                        <button class="login100-form-btn">
                            登入
                        </button>
                    </div>
                    
                    <div class="w-full text-center p-t-55">
                        <span class="txt2">
                            尚無帳號？
                        </span>
                        <a href="signUp.jsp" class="txt2 bo1">
                            立馬註冊
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div id="dropDownSelect1"></div>
    
    <script src="assets/vendor/jquery/jquery-3.2.1.min.js"></script>
    <script src="assets/vendor/animsition/js/animsition.min.js"></script>
    <script src="assets/vendor/bootstrap/js/popper.js"></script>
    <script src="assets/vendor/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/vendor/select2/select2.min.js"></script>
    <script src="assets/vendor/daterangepicker/moment.min.js"></script>
    <script src="assets/vendor/daterangepicker/daterangepicker.js"></script>
    <script src="assets/vendor/countdowntime/countdowntime.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>