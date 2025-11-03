<%@ page language="java" contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*,java.util.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>

<jsp:useBean id='objFolderConfig' scope='session' class='hitstd.group.tool.upload.FolderConfig' />
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // 🔸 改成由 MultipartRequest 取得表單參數（不是 request）
    MultipartRequest theMultipartRequest = new MultipartRequest(request, objFolderConfig.FilePath(), 10 * 1024 * 1024);

    // 🔸 用 MultipartRequest 取得 bookId
    String bookId = theMultipartRequest.getParameter("bookId");

    Enumeration theEnumeration = theMultipartRequest.getFileNames();

    while (theEnumeration.hasMoreElements()) {
        String fieldName = (String) theEnumeration.nextElement();
        String fileName = theMultipartRequest.getFilesystemName(fieldName);
        String contentType = theMultipartRequest.getContentType(fieldName);
        File theFile = theMultipartRequest.getFile(fieldName);

        out.println("檔案名稱: " + fileName + "<br>");
        out.println("檔案型態: " + contentType + "<br>");
        out.println("檔案路徑: " + theFile.getAbsolutePath() + "<br>");

        // 🔸 資料庫操作區塊
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        Statement smt = con.createStatement();

        // 🔸 更新書籍圖片的 SQL
        smt.executeUpdate("UPDATE book SET photo = '" + objFolderConfig.WebsiteRelativeFilePath() + fileName +
                          "' WHERE bookId = '" + bookId + "'");

        // 🔸 可選：上傳後導回書籍詳細頁或首頁
        response.sendRedirect("bookDetail.jsp?bookId=" + bookId);

        con.close();
    }
%>