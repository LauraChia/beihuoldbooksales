<%@page contentType="text/html; charset=UTF-8"%> 
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
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
Connection con = null;
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

    // ========== 取得書籍基本資料 (books 表) ==========
    String title = multi.getParameter("title");
    String author = multi.getParameter("author");
    String publishDate = multi.getParameter("publishDate");
    String edition = multi.getParameter("edition");
    String ISBN = multi.getParameter("ISBN");

    // ========== 取得上架詳情資料 (bookListings 表) ==========
    String sellerId = multi.getParameter("sellerId");
    String price = multi.getParameter("price");
    String quantity = multi.getParameter("quantity");
    String condition = multi.getParameter("condition");
    String remarks = multi.getParameter("remarks"); // 有無筆記
    String listedAt = multi.getParameter("listedAt"); // 上架日期（來自隱藏欄位）
    String expiryDateRaw = multi.getParameter("expiryDate");

    // ========== 處理下架日期時間格式 ==========
    String expiryDate = expiryDateRaw;
    if (expiryDateRaw != null && !expiryDateRaw.trim().isEmpty()) {
        try {
            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date date = inputFormat.parse(expiryDateRaw);
            expiryDate = outputFormat.format(date);
            out.println("<!-- 轉換下架時間: " + expiryDateRaw + " -> " + expiryDate + " -->");
        } catch (ParseException pe) {
            out.println("<!-- 日期轉換失敗，使用原始值: " + expiryDateRaw + " -->");
        }
    }

    // ========== 取得課程資料 (courses 表) ==========
    String courseName = multi.getParameter("courseName");
    String teacher = multi.getParameter("teacher");
    String department = multi.getParameter("department");

    

    out.println("<!-- 接收到的資料 -->");
    out.println("<!-- 書名: " + title + " -->");
    out.println("<!-- 作者: " + author + " -->");
    out.println("<!-- 出版日期: " + publishDate + " -->");
    out.println("<!-- 上架日期: " + listedAt + " -->");
    out.println("<!-- 下架日期時間: " + expiryDate + " -->");
    out.println("<!-- 書籍狀況: " + condition + " -->");
    out.println("<!-- 有無筆記: " + remarks + " -->");

    // ========== 處理多個上傳的圖片檔案 ==========
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

    // ========== 資料庫連線 ==========
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    con.setAutoCommit(false); // 開啟交易

    int bookId = -1;
    int courseId = -1;

    // ========== 1. 檢查或新增書籍 (books 表) ==========
    String checkBookSQL = "SELECT bookId FROM books WHERE title = ? AND author = ?";
    PreparedStatement checkBookStmt = con.prepareStatement(checkBookSQL);
    checkBookStmt.setString(1, title);
    checkBookStmt.setString(2, author);
    ResultSet bookRs = checkBookStmt.executeQuery();

    if (bookRs.next()) {
        // 書籍已存在，取得 bookId
        bookId = bookRs.getInt("bookId");
        out.println("<!-- ✅ 書籍已存在，bookId: " + bookId + " -->");
    } else {
        // 新增書籍
        String insertBookSQL = "INSERT INTO books(title, author, ISBN, edition, createdAt) VALUES(?, ?, ?, ?, ?)";
        PreparedStatement insertBookStmt = con.prepareStatement(insertBookSQL, Statement.RETURN_GENERATED_KEYS);
        insertBookStmt.setString(1, title);
        insertBookStmt.setString(2, author);
        insertBookStmt.setString(3, ISBN != null && !ISBN.trim().isEmpty() ? ISBN : null);
        insertBookStmt.setString(4, edition != null && !edition.trim().isEmpty() ? edition : null);
        insertBookStmt.setString(5, publishDate);
        
        insertBookStmt.executeUpdate();
        
        ResultSet generatedKeys = insertBookStmt.getGeneratedKeys();
        if (generatedKeys.next()) {
            bookId = generatedKeys.getInt(1);
            out.println("<!-- ✅ 新增書籍成功，bookId: " + bookId + " -->");
        }
        generatedKeys.close();
        insertBookStmt.close();
    }
    bookRs.close();
    checkBookStmt.close();

    // ========== 2. 檢查或新增課程 (courses 表) ==========
    String checkCourseSQL = "SELECT courseId FROM courses WHERE courseName = ? AND teacher = ? AND department = ?";
    PreparedStatement checkCourseStmt = con.prepareStatement(checkCourseSQL);
    checkCourseStmt.setString(1, courseName);
    checkCourseStmt.setString(2, teacher);
    checkCourseStmt.setString(3, department);
    ResultSet courseRs = checkCourseStmt.executeQuery();

    if (courseRs.next()) {
        // 課程已存在
        courseId = courseRs.getInt("courseId");
        out.println("<!-- ✅ 課程已存在，courseId: " + courseId + " -->");
    } else {
        // 新增課程
        String insertCourseSQL = "INSERT INTO courses(courseName, teacher, department) VALUES(?, ?, ?)";
        PreparedStatement insertCourseStmt = con.prepareStatement(insertCourseSQL, Statement.RETURN_GENERATED_KEYS);
        insertCourseStmt.setString(1, courseName);
        insertCourseStmt.setString(2, teacher);
        insertCourseStmt.setString(3, department);
        
        insertCourseStmt.executeUpdate();
        
        ResultSet courseKeys = insertCourseStmt.getGeneratedKeys();
        if (courseKeys.next()) {
            courseId = courseKeys.getInt(1);
            out.println("<!-- ✅ 新增課程成功，courseId: " + courseId + " -->");
        }
        courseKeys.close();
        insertCourseStmt.close();
    }
    courseRs.close();
    checkCourseStmt.close();

    // ========== 3. 新增書籍上架詳情 (bookListings 表) ==========
    String insertListingSQL = "INSERT INTO bookListings(bookId, sellerId, price, quantity, [condition], photo, remarks, Approved, isDelisted, listedAt, expiryDate) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    PreparedStatement insertListingStmt = con.prepareStatement(insertListingSQL, Statement.RETURN_GENERATED_KEYS);
    insertListingStmt.setInt(1, bookId);
    insertListingStmt.setString(2, sellerId);
    insertListingStmt.setString(3, price);
    insertListingStmt.setString(4, quantity != null ? quantity : "1");
    insertListingStmt.setString(5, condition);
    insertListingStmt.setString(6, photosPaths);
    insertListingStmt.setString(7, remarks);
    insertListingStmt.setString(8, "待審核");
    insertListingStmt.setBoolean(9, false); // isDelisted: false = 未下架
    insertListingStmt.setString(10, listedAt);
    
    // 使用 Timestamp 儲存下架日期時間
    if (expiryDate != null && !expiryDate.trim().isEmpty()) {
        insertListingStmt.setTimestamp(11, Timestamp.valueOf(expiryDate));
    } else {
        insertListingStmt.setNull(11, Types.TIMESTAMP);
    }

    int listingRows = insertListingStmt.executeUpdate();
    
    ResultSet listingKeys = insertListingStmt.getGeneratedKeys();
    int listingId = -1;
    if (listingKeys.next()) {
        listingId = listingKeys.getInt(1);
        out.println("<!-- ✅ 新增上架詳情成功，listingId: " + listingId + " -->");
    }
    listingKeys.close();
    insertListingStmt.close();

    // ========== 4. 建立書籍與課程的關聯 (book_course_relations 表) ==========
    String checkRelationSQL = "SELECT relationId FROM book_course_relations WHERE bookId = ? AND courseId = ?";
    PreparedStatement checkRelationStmt = con.prepareStatement(checkRelationSQL);
    checkRelationStmt.setInt(1, bookId);
    checkRelationStmt.setInt(2, courseId);
    ResultSet relationRs = checkRelationStmt.executeQuery();

    if (!relationRs.next()) {
        // 不存在關聯，新增
        String insertRelationSQL = "INSERT INTO book_course_relations(bookId, courseId) VALUES(?, ?)";
        PreparedStatement insertRelationStmt = con.prepareStatement(insertRelationSQL);
        insertRelationStmt.setInt(1, bookId);
        insertRelationStmt.setInt(2, courseId);
        insertRelationStmt.executeUpdate();
        insertRelationStmt.close();
        out.println("<!-- ✅ 新增書籍-課程關聯成功 -->");
    } else {
        out.println("<!-- ✅ 書籍-課程關聯已存在 -->");
    }
    relationRs.close();
    checkRelationStmt.close();

    // ========== 提交交易 ==========
    con.commit();
    out.println("<!-- ✅ 所有資料已成功寫入資料庫 -->");
    
    // 格式化顯示日期時間
    String displayExpiryDate = expiryDate;
    try {
        SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        java.util.Date date = dbFormat.parse(expiryDate);
        displayExpiryDate = displayFormat.format(date);
    } catch (Exception e) {
        // 如果解析失敗，使用原始值
    }
%>
<div class="success-box">
    <h3 style="color:green;">✅ 上傳成功！</h3>
    <p><strong>書名：</strong><%= title %></p>
    <p><strong>作者：</strong><%= author %></p>
    <p><strong>價格：</strong>NT$<%= price %></p>
    <p><strong>課程：</strong><%= courseName %></p>
    <p><strong>授課教師：</strong><%= teacher %></p>
    <p><strong>系所：</strong><%= department %></p>
    <p><strong>書籍狀況：</strong><%= condition %></p>
    <p><strong>有無筆記：</strong><%= remarks %></p>
    <p><strong>上架日期：</strong><%= listedAt %></p>
    <p><strong>下架日期時間：</strong><%= displayExpiryDate %></p>
    <p><strong>已上傳圖片：</strong><%= uploadedFiles.size() %> 張</p>
    <p style="color:#666; margin-top:15px;">等待管理員審核中...</p>
</div>

<script>
    setTimeout(function() {
        alert("✅ 書籍已成功上架！\n書名：<%= title %>\n課程：<%= courseName %>\n書籍狀況：<%= condition %>\n有無筆記：<%= remarks %>\n上架日期：<%= listedAt %>\n下架日期時間：<%= displayExpiryDate %>\n已上傳 <%= uploadedFiles.size() %> 張圖片\n等待管理員審核中...");
        window.location.href = "index.jsp";
    }, 1000);
</script>
<%
} catch (Exception e) {
    // 發生錯誤時回滾交易
    if (con != null) {
        try {
            con.rollback();
            out.println("<!-- ❌ 交易已回滾 -->");
        } catch (SQLException se) {
            out.println("<!-- ❌ 回滾失敗: " + se.getMessage() + " -->");
        }
    }
    
    out.println("<div class='error-box'>");
    out.println("<h3 style='color:red;'>❌ 上傳失敗</h3>");
    out.println("<p><strong>錯誤訊息：</strong>" + e.getMessage() + "</p>");
    out.println("</div>");
    
    out.println("<h4>詳細錯誤資訊</h4>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    
    out.println("<br><a href='shop.jsp' style='display:inline-block; padding:10px 20px; background:#007bff; color:#fff; text-decoration:none; border-radius:4px;'>返回上架頁面</a>");
} finally {
    // 關閉資料庫連線
    if (con != null) {
        try {
            con.setAutoCommit(true);
            con.close();
        } catch (SQLException se) {
            out.println("<!-- 關閉連線錯誤: " + se.getMessage() + " -->");
        }
    }
}
%>
</body>
</html>