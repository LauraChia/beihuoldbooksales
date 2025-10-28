<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
if(request.getParameter("username") != null &&
	request.getParameter("password") != null){

    // 連線設定：載入 Access Driver
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
	Statement smt = con.createStatement();

	// SQL 查詢帳號密碼是否正確
	String sql = "SELECT * FROM users WHERE username='" +
	             request.getParameter("username") + "' AND password='" +
	             request.getParameter("password") + "'";
	ResultSet rs = smt.executeQuery(sql);

	if(rs.next()){
		session.setAttribute("userId", rs.getString("userId"));
		session.setAttribute("username", rs.getString("username"));
		// ✅ 登入成功，導回首頁
		response.sendRedirect("index.jsp");
	}else{
		// 登入失敗，導回登入頁並帶狀態參數
		response.sendRedirect("login.jsp?status=loginerror");
	}

	// 👉 新增：關閉資料庫連線（避免占用資源）
	rs.close();
	smt.close();
	con.close();
}
%>