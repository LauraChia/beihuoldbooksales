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
    // 🔹 設定上傳目錄和大小限制 (20MB)
    String uploadPath = objFolderConfig.FilePath();
    int maxSize = 20 * 1024 * 1024;
    
    // 檢查並建立上傳目錄
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        boolean created = uploadDir.mkdirs();
        out.println("<!-- 建立目錄: " + uploadPath + " (成功: " + created + ") -->");
    }

    // 🔹 MultipartRequest 支援中文和多檔案
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    // 🔹 取得表單資料
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
    String extiryDate = multi.getParameter("extiryDate");
    String teacher = multi.getParameter("teacher");
    String course = multi.getParameter("course");
    String ISBN = multi.getParameter("ISBN");
    String userId = multi.getParameter("userId");
    String quantity = multi.getParameter("quantity");

    // 🔹 如果選擇「其他」, 使用自訂書況
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
            String extension = "";
            int dotIndex = originalFileName.lastIndexOf(".");
            if (dotIndex > 0) extension = originalFileName.substring(dotIndex);

            // 生成唯一檔名
            String safeFileName = UUID.randomUUID().toString() + extension;

            File oldFile = new File(uploadPath + File.separator + originalFileName);
            File newFile = new File(uploadPath + File.separator + safeFileName);

            if (oldFile.exists() && oldFile.renameTo(newFile)) {
                // ⭐ 關鍵修改：只儲存檔名，不包含完整路徑
                // 因為 index.jsp 和 bookDetail.jsp 會自動加上 "assets/images/member/" 前綴
                uploadedFiles.add(safeFileName);
                out.println("<!-- 上傳成功: " + safeFileName + " -->");
            } else {
                out.println("<!-- 檔案重新命名失敗: " + originalFileName + " -->");
            }
        }
    }

    // 🔹 將圖片路徑用逗號連接
    String photosPaths = String.join(",", uploadedFiles);
    out.println("<!-- 最終圖片路徑: " + photosPaths + " -->");

    // 🔹 資料庫連線
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

    // 🔹 先檢查資料表有哪些欄位
    DatabaseMetaData metaData = con.getMetaData();
    ResultSet columns = metaData.getColumns(null, null, "book", null);
    List<String> availableColumns = new ArrayList<>();
    while (columns.next()) {
        availableColumns.add(columns.getString("COLUMN_NAME").toLowerCase());
    }
    columns.close();

    out.println("<!-- 資料表欄位: " + availableColumns + " -->");

    // 🔹 根據實際存在的欄位建立 SQL
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
    
    if (availableColumns.contains("extiryDate")) {
        sqlBuilder.append(", extiryDate");
        valuesBuilder.append(", ?");
        paramValues.add(extiryDate != null ? extiryDate : "");
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

    // 🔹 執行 SQL
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
    <p><strong>已上傳圖片：</strong><%= uploadedFiles.size() %> 張</p>
    <p><strong>圖片檔名：</strong><%= photosPaths %></p>
    <p style="color:#666; margin-top:15px;">等待管理員審核中...</p>
</div>

<script>
    setTimeout(function() {
        alert("✅ 書籍已成功上架！\n已上傳 <%= uploadedFiles.size() %> 張圖片\n等待管理員審核中...");
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
    
    out.println("<h4>請檢查以下項目</h4>");
    out.println("<ul>");
    out.println("<li>✓ WEB-INF/lib 是否有 cos.jar 和 ucanaccess 相關 jar 檔</li>");
    out.println("<li>✓ 資料庫檔案路徑: " + objDBConfig.FilePath() + "</li>");
    out.println("<li>✓ 上傳目錄路徑: " + objFolderConfig.FilePath() + "</li>");
    out.println("<li>✓ 上傳目錄是否有寫入權限</li>");
    out.println("<li>✓ 檔案大小是否超過 20MB</li>");
    out.println("<li>✓ 資料庫 book 資料表是否存在</li>");
    out.println("</ul>");
    
    out.println("<br><a href='shop.jsp' style='display:inline-block; padding:10px 20px; background:#007bff; color:#fff; text-decoration:none; border-radius:4px;'>返回上架頁面</a>");
}
%>
</body>
</html>