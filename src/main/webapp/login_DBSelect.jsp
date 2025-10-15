<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<%
if(request.getParameter("username") !=null &&
	request.getParameter("password") !=null){
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String getMemberData = "SELECT * FROM users where username='"+
			request.getParameter("username")+"' AND password='" +
			request.getParameter("password")+"'";
	ResultSet members = smt.executeQuery(getMemberData);
	if(members.next()){
		session.setAttribute("accessId",request.getParameter("password"));
		//session.setMaxInactiveInterval(20); 自動登出
		response.sendRedirect("index.jsp");
	}else
		response.sendRedirect("login.jsp?status=loginerror");
}
%>