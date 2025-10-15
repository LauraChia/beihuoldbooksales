<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<html>
<body>
 <%
 try {
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
Statement smt= con.createStatement();
String titleBook = request.getParameter("bookname") != null ? request.getParameter("bookname") : "";
String author = request.getParameter("author") != null ? request.getParameter("author") : "";
String price = request.getParameter("price") != null ? request.getParameter("price") : "";
String date = request.getParameter("date") != null ? request.getParameter("date") : "";
String photo = request.getParameter("bookphoto") != null ? request.getParameter("bookphoto") : "";
String contact = request.getParameter("contact") != null ? request.getParameter("contact") : "";
String remarks = request.getParameter("memo") != null ? request.getParameter("memo") : "";

	smt.executeUpdate("INSERT INTO book(titleBook, author, price,[date],photo,contact,remarks) VALUES('"+titleBook+"', '"+author+"', '"+price+"','"+date+"','"+photo+"','"+contact+"','"+remarks+"');");
	con.close();
    %>
    <script>
    alert("資料已成功送出！"); // 跳出成功訊息
    window.location.href = "index.jsp"; // 跳轉到首頁 (將 index.jsp 替換為實際首頁路徑)
</script>
<%
    } catch (Exception e) {
        out.println("<script>alert('資料送出失敗，請稍後再試。');</script>");
        e.printStackTrace();
    }
%>
</body>
</html>