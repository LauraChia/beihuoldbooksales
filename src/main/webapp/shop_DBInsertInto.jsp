<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<html>
<body>
<%
try {
	request.setCharacterEncoding("UTF-8");
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt= con.createStatement();

    String titleBook = request.getParameter("titleBook");
    String author = request.getParameter("author");
    String price = request.getParameter("price");
    String date = request.getParameter("date");
    String contact = request.getParameter("contact");
    String remarks = request.getParameter("remarks");
    String condition = request.getParameter("condition");
    String department = request.getParameter("department");
    String ISBN = request.getParameter("ISBN");
    String userId = request.getParameter("userId");

    String sql = "INSERT INTO book(titleBook, author, price, [date], contact, remarks, [condition], department, ISBN, userId, createdAt) " +
            "VALUES('" + titleBook + "', '" + author + "', '" + price + "', '" + date + "', '" + contact + "', '" + remarks + "', '" + condition + "', '" + department + "', '" + ISBN + "', '" + userId + "', NOW())";

	smt.executeUpdate(sql);
	con.close();
%>
<script>
alert("資料已成功送出！");
window.location.href = "index.jsp";
</script>
<%
} catch (Exception e) {
    out.println("<script>alert('資料送出失敗，請稍後再試。');</script>");
    e.printStackTrace();
}
%>
</body>
</html>