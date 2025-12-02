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
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: "Microsoft JhengHei", sans-serif; padding: 20px; }
        .error-box { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
        .success-box { background: #d4edda; border-left: 4px solid #28a745; padding: 15px; margin: 20px 0; }
        pre { background: #f5f5f5; padding: 10px; overflow: auto; font-size: 12px; }
    </style>
</head>
<body>
<%
try {
    // 設定上傳目錄和大小限制 (20MB)
    String uploadPath = objFolderConfig.FilePath();
    int maxSize = 20 * 1024 * 1024;
    
    // 檢查並建立上傳目錄
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        boolean created = uploadDir.mkdirs();
        out.println("<!-- 建立目錄: " + uploadPath + " (成功: " + created + ") -->");
    }

    // MultipartRequest 支援中文和多檔案
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    // 取得表單資料
    String titleBook = multi.getParameter("titleBook");
    String author = multi.getParameter("author");
    String price = multi.getParameter("price");
    String date = multi.getParameter("date");
    String edition = multi.getParameter("edition");
    String contact = multi.getParameter("contact");
    String remarks = multi.getParameter("remarks");
    String condition = multi.getParameter("condition");
    String otherCondition = multi.getParameter("otherCondition");
    String college = multi.getParameter("college");
    String department = multi.getParameter("department");
    String createdAt = multi.getParameter("createdAt");
    String expiryDate = multi.getParameter("expiryDate");
    String teacher = multi.getParameter("teacher");
    String course = multi.getParameter("course");
    String ISBN = multi.getParameter("ISBN");
    String userId = multi.getParameter("userId");
    String quantity = multi.getParameter("quantity");

    // 🔍 DEBUG: 印出接收到的日期
    out.println("<!-- 接收到的 createdAt: " + createdAt + " -->");
    out.println("<!-- 接收到的 expiryDate: " + expiryDate + " -->");

    // 如果選擇「其他」, 使用自訂書況
    if ("其他".equals(condition) && otherCondition != null && !otherCondition.trim().isEmpty()) {
        condition = otherCondition;
    }

    // 處理多個上傳的圖片檔案
    List<String> uploadedFiles = new ArrayList<>();
    Enumeration files = multi.getFileNames();

    while (files.hasMoreElements()) {
        String fieldName = (String) files.nextElement();
        String originalFileName = multi.getFilesystemName(fieldName);

        if (originalFileName != null && !originalFileName.isEmpty()) {
            String extension = "";
            int dotIndex = originalFileName.lastIndexOf(".");
            if (dotIndex > 0) extension = originalFileName.substring(dotIndex);

            String safeFileName = UUID.randomUUID().toString() + extension;
            File oldFile = new File(uploadPath + File.separator + originalFileName);
            File newFile = new File(uploadPath + File.separator + safeFileName);

            if (oldFile.exists() && oldFile.renameTo(newFile)) {
                uploadedFiles.add(safeFileName);
                out.println("<!-- 上傳成功: " + safeFileName + " -->");
            }
        }
    }

    String photosPaths = String.join(",", uploadedFiles);
    out.println("<!-- 最終圖片路徑: " + photosPaths + " -->");

    // 資料庫連線
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

    // 先檢查資料表有哪些欄位
    DatabaseMetaData metaData = con.getMetaData();
    ResultSet columns = metaData.getColumns(null, null, "book", null);
    List<String> availableColumns = new ArrayList<>();
    while (columns.next()) {
        availableColumns.add(columns.getString("COLUMN_NAME").toLowerCase());
    }
    columns.close();

    out.println("<!-- 資料表欄位: " + availableColumns + " -->");

    // 根據實際存在的欄位建立 SQL
    StringBuilder sqlBuilder = new StringBuilder("INSERT INTO book(titleBook, author, price, [date]");
    StringBuilder valuesBuilder = new StringBuilder("VALUES(?, ?, ?, ?");
    
    List<String> paramValues = new ArrayList<>();
    paramValues.add(titleBook);
    paramValues.add(author);
    paramValues.add(price);
    paramValues.add(date);
    
    // 動態添加可選欄位
    if (availableColumns.contains("edition") && edition != null && !edition.trim().isEmpty()) {
        sqlBuilder.append(", edition");
        valuesBuilder.append(", ?");
        paramValues.add(edition);
    }
    
    sqlBuilder.append(", contact, remarks, [condition]");
    valuesBuilder.append(", ?, ?, ?");
    paramValues.add(contact);
    paramValues.add(remarks);
    paramValues.add(condition);
    
    if (availableColumns.contains("college")) {
        sqlBuilder.append(", college");
        valuesBuilder.append(", ?");
        paramValues.add(college != null ? college : "");
    }
    
    if (availableColumns.contains("department")) {
        sqlBuilder.append(", department");
        valuesBuilder.append(", ?");
        paramValues.add(department != null ? department : "");
    }
    
    // 🔥 關鍵修正：確保 createdAt 被加入
    if (availableColumns.contains("createdat")) {
        sqlBuilder.append(", createdAt");
        valuesBuilder.append(", ?");
        paramValues.add(createdAt != null && !createdAt.trim().isEmpty() ? createdAt : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()));
        out.println("<!-- ✅ 已加入 createdAt: " + createdAt + " -->");
    }
    
    // 🔥 關鍵修正：確保 expiryDate 被加入
    if (availableColumns.contains("expirydate")) {
        sqlBuilder.append(", expiryDate");
        valuesBuilder.append(", ?");
        paramValues.add(expiryDate != null && !expiryDate.trim().isEmpty() ? expiryDate : "");
        out.println("<!-- ✅ 已加入 expiryDate: " + expiryDate + " -->");
    }
    
    if (availableColumns.contains("teacher")) {
        sqlBuilder.append(", teacher");
        valuesBuilder.append(", ?");
        paramValues.add(teacher != null ? teacher : "");
    }
    
    if (availableColumns.contains("course")) {
        sqlBuilder.append(", course");
        valuesBuilder.append(", ?");
        paramValues.add(course != null ? course : "");
    }
    
    if (availableColumns.contains("isbn")) {
        sqlBuilder.append(", ISBN");
        valuesBuilder.append(", ?");
        paramValues.add(ISBN != null ? ISBN : "");
    }
    
    sqlBuilder.append(", userId");
    valuesBuilder.append(", ?");
    paramValues.add(userId);
    
    if (availableColumns.contains("quantity")) {
        sqlBuilder.append(", quantity");
        valuesBuilder.append(", ?");
        paramValues.add(quantity != null ? quantity : "1");
    }
    
    sqlBuilder.append(", photo");
    valuesBuilder.append(", ?");
    paramValues.add(photosPaths);
    
    if (availableColumns.contains("isapproved")) {
        sqlBuilder.append(", isApproved");
        valuesBuilder.append(", '待審核'");
    }
    
    sqlBuilder.append(") ");
    valuesBuilder.append(")");
    
    String sql = sqlBuilder.toString() + valuesBuilder.toString();
    out.println("<!-- SQL: " + sql + " -->");
    out.println("<!-- 參數數量: " + paramValues.size() + " -->");
    for (int i = 0; i < paramValues.size(); i++) {
        out.println("<!-- 參數[" + i + "]: " + paramValues.get(i) + " -->");
    }

    // 執行 SQL
    PreparedStatement pstmt = con.prepareStatement(sql);
    for (int i = 0; i < paramValues.size(); i++) {
        pstmt.setString(i + 1, paramValues.get(i));
    }

    int rowsAffected = pstmt.executeUpdate();
    out.println("<!-- 影響筆數: " + rowsAffected + " -->");
    
    pstmt.close();
    con.close();
%>
<div class="success-box">
    <h3 style="color:green;">✅ 上傳成功！</h3>
    <p><strong>書名：</strong><%= titleBook %></p>
    <p><strong>作者：</strong><%= author %></p>
    <p><strong>價格：</strong>NT$<%= price %></p>
    <p><strong>上架日期：</strong><%= createdAt %></p>
    <p><strong>下架日期：</strong><%= expiryDate %></p>
    <p><strong>已上傳圖片：</strong><%= uploadedFiles.size() %> 張</p>
    <p style="color:#666; margin-top:15px;">等待管理員審核中...</p>
</div>

<script>
    setTimeout(function() {
        alert("✅ 書籍已成功上架！\n上架日期：<%= createdAt %>\n下架日期：<%= expiryDate %>\n已上傳 <%= uploadedFiles.size() %> 張圖片\n等待管理員審核中...");
        window.location.href = "index.jsp";
    }, 1000);
</script>
<%
} catch (Exception e) {
    out.println("<div class='error-box'>");
    out.println("<h3 style='color:red;'>❌ 上傳失敗</h3>");
    out.println("<p><strong>錯誤訊息：</strong>" + e.getMessage() + "</p>");
    out.println("</div>");
    
    out.println("<h4>詳細錯誤資訊</h4>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    
    out.println("<br><a href='shop.jsp' style='display:inline-block; padding:10px 20px; background:#007bff; color:#fff; text-decoration:none; border-radius:4px;'>返回上架頁面</a>");
}
%>
</body>
</html>