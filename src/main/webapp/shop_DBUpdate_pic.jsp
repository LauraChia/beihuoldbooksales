<%@ page language="java" contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*,java.util.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<jsp:useBean id='objFolderConfig' scope='session' class='hitstd.group.tool.upload.FolderConfig' />
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<%
    // 🔹 確認要更新的書籍 ID
    String bookId = request.getParameter("bookId"); // 或 session.getAttribute("bookId")

    MultipartRequest theMultipartRequest = new MultipartRequest(request,objFolderConfig.FilePath(),10*1024*1024);
    Enumeration theEnumeration = theMultipartRequest.getFileNames();

    if(bookId != null && theEnumeration.hasMoreElements()) {
        String fieldName = (String)theEnumeration.nextElement();
        String fileName = theMultipartRequest.getFilesystemName(fieldName);
        String contentType = theMultipartRequest.getContentType(fieldName);
        File theFile = theMultipartRequest.getFile(fieldName);

        out.println("檔案名稱:"+fileName+"<br>");
        out.println("檔案型態:"+contentType+"<br>");
        out.println("檔案路徑:"+theFile.getAbsolutePath()+"<br>");

        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            Statement smt= con.createStatement();
            smt.executeUpdate("UPDATE book SET pic ='"+objFolderConfig.WebsiteRelativeFilePath()+fileName+ "' WHERE bookId ='"+bookId+"'");
            con.close();

            response.sendRedirect("index.jsp?bookId="+bookId);
        } catch (Exception e) {
            // ★修改：改進錯誤提示（顯示實際錯誤內容）
            out.println("<h3 style='color:red;'>圖片上傳失敗！</h3>");
            out.println("<pre>");

            // ★安全版本：將錯誤訊息轉為字串後輸出
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            out.println(sw.toString());  // ★改這裡，不再直接用 e.printStackTrace(out)

            out.println("</pre>");
        }
    } else {
        out.println("<script>alert('未選擇書籍或檔案！');</script>");
    }
%>