<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<html>
<body>
	<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String name = new String(request.getParameter("name"));
	String username = new String(request.getParameter("username"));
	String password = new String(request.getParameter("password"));
	//try{
		//smt.executeUpdate("INSERT INTO users (name,username, password) VALUES('"+username+"','"+password+"')");
		//con.close();
		//response.sendRedirect("login.jsp?status=newmember");
	//}catch (Exception e){
		//response.sendRedirect("signUp.jsp?status=IDexist");
	//}
	try {
    smt.executeUpdate("INSERT INTO users (name, username, password) VALUES('" + name + "','" + username + "','" + password + "')");
    con.close();
    response.sendRedirect("login.jsp?status=newmember");

} catch (Exception e) {
    e.printStackTrace(); // 在 console 顯示真實錯誤
    out.println("<p style='color:red'>錯誤訊息：" + e.getMessage() + "</p>");
}
	%>
</body>
</html>
