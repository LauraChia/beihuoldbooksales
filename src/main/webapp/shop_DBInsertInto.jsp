<%@page contentType="text/html; charset=UTF-8"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<jsp:useBean id='objDBConfig' scope='application' class='hitstd.group.tool.database.DBConfig' />
<jsp:useBean id='objFolderConfig' scope='session' class='hitstd.group.tool.upload.FolderConfig' />

<html>
<body>
<%
try {
    // 🔹 設定上傳目錄和大小限制 (20MB)
    String uploadPath = objFolderConfig.FilePath();
    int maxSize = 20 * 1024 * 1024; // 20MB
    
    // 🔹 MultipartRequest 支援中文和多檔案
    MultipartRequest multi = new MultipartRequest(
        request, 
        uploadPath, 
        maxSize, 
        "UTF-8", 
        new DefaultFileRenamePolicy()
    );

    // 🔹 取得表單資料
    String titleBook = multi.getParameter("titleBook");
    String author = multi.getParameter("author");
    String price = multi.getParameter("price");
    String date = multi.getParameter("date");
    String contact = multi.getParameter("contact");
    String remarks = multi.getParameter("remarks");
    String condition = multi.getParameter("condition");
    String otherCondition = multi.getParameter("otherCondition");
    String department = multi.getParameter("department");
    String ISBN = multi.getParameter("ISBN");
    String userId = multi.getParameter("userId");
    
    // 🔹 如果選擇「其他」,使用自訂書況
    if ("其他".equals(condition) && otherCondition != null && !otherCondition.trim().isEmpty()) {
        condition = otherCondition;
    }

    // 🔹 處理多個上傳的圖片檔案
    List<String> uploadedFiles = new ArrayList<>();
    Enumeration files = multi.getFileNames();
    
    while (files.hasMoreElements()) {
        String fieldName = (String) files.nextElement();
        String originalFileName = multi.getFilesystemName(fieldName);
        
        if (originalFileName != null && !originalFileName.isEmpty()) {
            // 取得副檔名
            String extension = "";
            int dotIndex = originalFileName.lastIndexOf(".");
            if (dotIndex > 0) {
                extension = originalFileName.substring(dotIndex);
            }
            
            // 生成唯一檔名 (UUID + 副檔名)
            String safeFileName = UUID.randomUUID().toString() + extension;
            
            // 重新命名檔案
            File oldFile = new File(uploadPath + File.separator + originalFileName);
            File newFile = new File(uploadPath + File.separator + safeFileName);
            
            if (oldFile.exists() && oldFile.renameTo(newFile)) {
                // 儲存相對路徑
                uploadedFiles.add(objFolderConfig.WebsiteRelativeFilePath() + safeFileName);
            }
        }
    }
    
    // 🔹 將所有圖片路徑用逗號連接
    String photosPaths = String.join(",", uploadedFiles);

    // 🔹 資料庫連線
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    
    // 🔹 使用 PreparedStatement 防止 SQL Injection
    String sql = "INSERT INTO book(titleBook, author, price, [date], contact, remarks, [condition], department, ISBN, userId, photo, createdAt, isApproved) " +
                 "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), '待審核')";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setString(1, titleBook);
    pstmt.setString(2, author);
    pstmt.setString(3, price);
    pstmt.setString(4, date);
    pstmt.setString(5, contact);
    pstmt.setString(6, remarks);
    pstmt.setString(7, condition);
    pstmt.setString(8, department);
    pstmt.setString(9, ISBN != null ? ISBN : "");
    pstmt.setString(10, userId);
    pstmt.setString(11, photosPaths); // 所有圖片路徑,逗號分隔
    
    pstmt.executeUpdate();
    pstmt.close();
    con.close();
%>
<script>
    alert("✅ 書籍已成功上架！\n已上傳 <%= uploadedFiles.size() %> 張圖片\n等待管理員審核中...");
    window.location.href = "index.jsp";
</script>
<%
} catch (Exception e) {
    out.println("<h3 style='color:red;'>❌ 上傳失敗</h3>");
    out.println("<p>錯誤訊息：" + e.getMessage() + "</p>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    out.println("<br><a href='shop.jsp'>返回上架頁面</a>");
}
%>
</body>
</html>