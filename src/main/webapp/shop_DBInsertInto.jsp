<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*,java.util.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<jsp:useBean id='objFolderConfig' scope='session' class='hitstd.group.tool.upload.FolderConfig' />

<html>
<body>
<%
try {
    // ★修改開始：使用 MultipartRequest 處理 multipart/form-data 表單
    MultipartRequest multi = new MultipartRequest(request, objFolderConfig.FilePath(), 10*1024*1024, "UTF-8");

    String titleBook = multi.getParameter("titleBook");
    String author = multi.getParameter("author");
    String price = multi.getParameter("price");
    String date = multi.getParameter("date");
    String contact = multi.getParameter("contact");
    String remarks = multi.getParameter("remarks");
    String condition = multi.getParameter("condition");
    String department = multi.getParameter("department");
    String ISBN = multi.getParameter("ISBN");
    String userId = multi.getParameter("userId");

    // ★抓檔案，存到 photo 欄位，不改名字
    String photo = multi.getFilesystemName("photo");
    if (photo == null) photo = "";  // 避免 null 錯誤
    // ★修改結束

    // 資料庫連線與寫入
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    Statement smt = con.createStatement();

    // ★使用原本 photo 欄位名稱
    String sql = "INSERT INTO book(titleBook, author, price, [date], photo, contact, remarks, condition, department, ISBN, userId) "
               + "VALUES('" + titleBook + "', '" + author + "', '" + price + "', '" + date + "', '" + photo + "', '" + contact + "', '"
               + remarks + "', '" + condition + "', '" + department + "', '" + ISBN + "', '" + userId + "')";

    smt.executeUpdate(sql);
    con.close();
%>
<script>
alert("資料已成功送出！");
window.location.href = "index.jsp";
</script>
<%
} catch (Exception e) {
    // ★修改開始：印出例外詳細資訊方便除錯
    out.println("<h3 style='color:red;'>資料送出失敗，請稍後再試。</h3>");
    out.println("<pre>");
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    out.println(sw.toString());
    out.println("</pre>");
    // ★修改結束
}
%>
</body>
</html>