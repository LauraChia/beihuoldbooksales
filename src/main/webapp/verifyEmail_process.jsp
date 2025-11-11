<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<html>
<body>
<%
    // 【修改1】參數名稱改為 username (實際上是 email)
    String username = request.getParameter("email");  // 前端仍使用 email 參數名
    String code1 = request.getParameter("code1");
    String code2 = request.getParameter("code2");
    String code3 = request.getParameter("code3");
    String code4 = request.getParameter("code4");
    String code5 = request.getParameter("code5");
    String code6 = request.getParameter("code6");

    // 組合驗證碼
    String inputCode = code1 + code2 + code3 + code4 + code5 + code6;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // 【修改2】SQL 查詢改用 username 欄位
        String sql = "SELECT verificationCode, isVerified FROM users WHERE username = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();

        if (rs.next()) {
            String storedCode = rs.getString("verificationCode");
            // 【修改3】改用 getObject 並轉型，處理 Access 的布林值
            Object isVerifiedObj = rs.getObject("isVerified");
            boolean isVerified = (isVerifiedObj != null && (Boolean)isVerifiedObj);

            // 檢查是否已驗證
            if (isVerified) {
                response.sendRedirect("login.jsp?status=already_verified");
                return;
            }

            // 驗證碼比對
            if (inputCode.equals(storedCode)) {
                // 【修改4】UPDATE 語句改用 username，使用 True 和空字串
                String updateSql = "UPDATE users SET isVerified = True, verificationCode = '' WHERE username = ?";
                PreparedStatement psUpdate = con.prepareStatement(updateSql);
                psUpdate.setString(1, username);
                psUpdate.executeUpdate();
                psUpdate.close();

                // 驗證成功，導向登入頁面
                response.sendRedirect("login.jsp?status=verified");
            } else {
                // 驗證碼錯誤
                response.sendRedirect("verifyEmail.jsp?email=" + username + "&status=invalid");
            }
        } else {
            // 找不到用戶
            response.sendRedirect("signUp.jsp?status=error");
        }

    } catch (Exception e) {
        e.printStackTrace();
        // 【修改5】增加錯誤訊息輸出
        out.println("<p style='color:red'>錯誤：" + e.getMessage() + "</p>");
        response.sendRedirect("verifyEmail.jsp?email=" + username + "&status=error");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
</body>
</html>