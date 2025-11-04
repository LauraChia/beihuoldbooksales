<%@page contentType="text/html; charset=UTF-8"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<jsp:useBean id='objFolderConfig' scope='session' class='hitstd.group.tool.upload.FolderConfig' />

<html>
<body>
<%
try {
    // 🔹 MultipartRequest 支援中文
    MultipartRequest multi = new MultipartRequest(request, objFolderConfig.FilePath(), 10*1024*1024, "UTF-8");

    // 🔹 取得資料
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

    // 🔹 取得上傳檔案並改成安全檔名
    String originalFileName = multi.getFilesystemName("photo");
    String safeFileName = null;
    if(originalFileName != null && !originalFileName.isEmpty()) {
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        safeFileName = UUID.randomUUID().toString() + extension;

        File oldFile = new File(objFolderConfig.FilePath() + "/" + originalFileName);
        File newFile = new File(objFolderConfig.FilePath() + "/" + safeFileName);
        oldFile.renameTo(newFile); // 🔹 中文檔名改成安全英文檔名
    }

    // 🔹 資料庫連線
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    Statement smt = con.createStatement();

    // 🔹 SQL 插入（含圖片欄位）
    String sql = "INSERT INTO book(titleBook, author, price, [date], contact, remarks, [condition], department, ISBN, userId, photo, createdAt) " +
                 "VALUES('" + titleBook + "', '" + author + "', '" + price + "', '" + date + "', '" + contact + "', '" + remarks + "', '" + condition + "', '" + department + "', '" + ISBN + "', '" + userId + "', '" + (safeFileName != null ? objFolderConfig.WebsiteRelativeFilePath() + safeFileName : "") + "', NOW())";

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