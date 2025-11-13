<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>忘記密碼查詢結果 - 北護二手書交易網</title>
    <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background-color:#d8f3dc;"> <!-- 淺綠色背景 -->
<div class="container mt-5 pt-5">
    <div class="card p-4 shadow-sm">
        <h4 class="mb-3 text-center">查詢結果</h4>
        <%
            request.setCharacterEncoding("UTF-8");
            String input = request.getParameter("input");
            Connection con = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
                con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

                String sql = "SELECT name, username, email, password FROM users WHERE username = ? OR email = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, input);
                pstmt.setString(2, input);
                rs = pstmt.executeQuery();

                if (rs.next()) {
        %>
                    <div class="alert alert-success">
                        <strong>查詢成功！</strong><br>
                        使用者名稱：<%= rs.getString("name") %><br>
                        帳號：<%= rs.getString("username") %><br>
                        電子郵件：<%= rs.getString("email") %><br>
                        密碼：<%= rs.getString("password") %>
                    </div>
                    <a href="index.jsp" class="btn btn-success w-100 mt-3">回首頁</a>
        <%
                } else {
        %>
                    <div class="alert alert-danger">
                        查無此使用者，請確認輸入的電子郵件是否正確。
                    </div>
                    <a href="forgetPassword.jsp" class="btn btn-secondary w-100 mt-3">返回</a>
        <%
                }
            } catch (Exception e) {
        %>
                <div class="alert alert-danger">
                    系統發生錯誤：<%= e.getMessage() %>
                </div>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception e) {}
                if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                if (con != null) try { con.close(); } catch (Exception e) {}
            }
        %>
    </div>
</div>
</body>
</html>