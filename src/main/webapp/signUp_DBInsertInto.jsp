<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<html>
<body>
<%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

    // ✅ 改用 PreparedStatement，並加入 name 欄位
    String sql = "INSERT INTO users (name, username, password) VALUES (?, ?, ?)"; // ← ★ 新增 name 欄位
    PreparedStatement ps = con.prepareStatement(sql);

    // ✅ 對應 signUp.jsp 表單欄位
    ps.setString(1, request.getParameter("name")); // ← ★ 新增這行
    ps.setString(2, request.getParameter("username"));
    ps.setString(3, request.getParameter("password"));

    try {
        ps.executeUpdate(); // ← 改為使用 ps 執行
        ps.close();         // ← 關閉 ps
        con.close();
        response.sendRedirect("login.jsp?status=newmember");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red'>錯誤訊息：" + e.getMessage() + "</p>");
        response.sendRedirect("signUp.jsp?status=IDexist");
    }
%>
</body>
</html>