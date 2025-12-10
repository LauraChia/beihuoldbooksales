<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
// 處理登入請求
if (request.getMethod().equals("POST")) {
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        String sql = "SELECT * FROM admins WHERE username = ? AND password = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, password);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // 登入成功
            session.setAttribute("adminId", rs.getString("adminId"));
            session.setAttribute("adminUsername", rs.getString("username"));
            
            // 記錄登入日誌
            String logSql = "INSERT INTO adminLogs (adminId, action, logTime) VALUES (?, ?, NOW())";
            PreparedStatement logPstmt = con.prepareStatement(logSql);
            logPstmt.setString(1, rs.getString("adminId"));
            logPstmt.setString(2, "登入系統");
            logPstmt.executeUpdate();
            logPstmt.close();
            
            response.sendRedirect("adminDashboard.jsp");
            return;
        } else {
            request.setAttribute("error", "帳號或密碼錯誤");
        }
    } catch (Exception e) {
        request.setAttribute("error", "系統錯誤: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (con != null) con.close();
    }
}
%>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>管理員登入 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 420px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h2 {
            color: #333;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .login-header p {
            color: #666;
            font-size: 14px;
        }
        .admin-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
            color: white;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: block;
        }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.3s;
        }
        .form-control:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            background-color: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }
        .back-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <div class="admin-icon">🔐</div>
            <h2>管理員登入</h2>
            <p>北護二手書交易網管理系統</p>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <form method="post" action="adminLogin.jsp">
            <div class="form-group">
                <label class="form-label">管理員帳號</label>
                <input type="text" name="username" class="form-control" 
                       placeholder="請輸入管理員帳號" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">密碼</label>
                <input type="password" name="password" class="form-control" 
                       placeholder="請輸入密碼" required>
            </div>
            
            <button type="submit" class="btn-login">登入管理系統</button>
        </form>
        
        <div class="back-link">
            <a href="index.jsp">← 返回網站首頁</a>
        </div>
    </div>
</body>
</html>