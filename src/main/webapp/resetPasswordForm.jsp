<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />

<%
    String token = request.getParameter("token");
    boolean validToken = false;
    String email = "";
    
    if (token != null && !token.trim().isEmpty()) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
            
            // 檢查 token 是否有效且未過期
            String sql = "SELECT username, resetTokenExpiry FROM users WHERE resetToken = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, token);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                Timestamp expiry = rs.getTimestamp("resetTokenExpiry");
                Timestamp now = new Timestamp(System.currentTimeMillis());
                
                if (expiry != null && expiry.after(now)) {
                    validToken = true;
                    email = rs.getString("username");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>重設密碼 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .form-container {
            max-width: 450px;
            margin: 100px auto;
        }
        .card {
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }
        .card-header {
            background-color: #667eea;
            color: white;
            font-weight: bold;
            text-align: center;
            font-size: 1.3rem;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
            padding: 15px;
        }
        .btn-primary {
            background-color: #667eea;
            border-color: #667eea;
        }
        .password-requirements {
            font-size: 13px;
            color: #666;
            margin-top: 8px;
        }
        .password-requirements li {
            margin-bottom: 3px;
        }
    </style>
    <script>
        function validatePassword() {
            var password = document.getElementById("newPassword").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            
            if (password.length < 6) {
                alert("密碼長度至少需要 6 個字元");
                return false;
            }
            
            if (password !== confirmPassword) {
                alert("兩次輸入的密碼不一致，請重新確認");
                return false;
            }
            
            return true;
        }
        
        function togglePassword(inputId) {
            var input = document.getElementById(inputId);
            if (input.type === "password") {
                input.type = "text";
            } else {
                input.type = "password";
            }
        }
    </script>
</head>
<body>

<div class="form-container">
    <div class="card">
        <div class="card-header">🔐 重設密碼</div>
        <div class="card-body">
            <% if (!validToken) { %>
                <div class="alert alert-danger">
                    <strong>❌ 連結已失效</strong><br>
                    此重設密碼連結已過期或無效。<br>
                    可能的原因：
                    <ul>
                        <li>連結已超過 30 分鐘</li>
                        <li>連結已被使用過</li>
                        <li>連結不正確</li>
                    </ul>
                    請重新申請重設密碼。
                </div>
                <a href="forgetPassword.jsp" class="btn btn-primary w-100">重新申請</a>
            <% } else { %>
                <div class="alert alert-info">
                    <strong>📧 帳號：</strong><%= email %>
                </div>
                
                <form action="updatePassword.jsp" method="post" onsubmit="return validatePassword()">
                    <input type="hidden" name="token" value="<%= token %>">
                    
                    <div class="mb-3">
                        <label for="newPassword" class="form-label">新密碼：</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="newPassword" 
                                   name="newPassword" required minlength="6">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="togglePassword('newPassword')">
                                👁️
                            </button>
                        </div>
                        <ul class="password-requirements">
                            <li>長度至少 6 個字元</li>
                            <li>建議包含英文字母、數字</li>
                        </ul>
                    </div>
                    
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label">確認新密碼：</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="confirmPassword" 
                                   name="confirmPassword" required minlength="6">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="togglePassword('confirmPassword')">
                                👁️
                            </button>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100">確認重設密碼</button>
                </form>
            <% } %>
            
            <div class="mt-3 text-center">
                <a href="login.jsp" class="btn btn-link">返回登入頁</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>