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

    String titleBook = request.getParameter("titleBook") != null ? request.getParameter("titleBook") : "";
    String author = request.getParameter("author") != null ? request.getParameter("author") : "";
    String price = request.getParameter("price") != null ? request.getParameter("price") : "";
    String date = request.getParameter("date") != null ? request.getParameter("date") : "";
    String photo = request.getParameter("photo") != null ? request.getParameter("photo") : "";
    String contact = request.getParameter("contact") != null ? request.getParameter("contact") : "";
    String remarks = request.getParameter("remarks") != null ? request.getParameter("remarks") : "";
    String condition = request.getParameter("condition") != null ? request.getParameter("condition") : "";
    String department = request.getParameter("department") != null ? request.getParameter("department") : "";
    String ISBN = request.getParameter("ISBN") != null ? request.getParameter("ISBN") : "";
    String username = request.getParameter("username") != null ? request.getParameter("username") : "";
    String userId = request.getParameter("userId") != null ? request.getParameter("userId") : "";

    String sql = "INSERT INTO book(titleBook, author, price, [date], photo, contact, remarks, condition, department, ISBN, username, userId) "
               + "VALUES('"+titleBook+"', '"+author+"', '"+price+"', '"+date+"', '"+photo+"', '"+contact+"', '"+remarks+"', '"+condition+"', '"+department+"', '"+ISBN+"', '"+username+"', '"+userId+"')";
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