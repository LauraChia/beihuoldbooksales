<%@page contentType="text/html; charset=UTF-8"%> 
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.Date"%>
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
        uploadDir.mkdirs();
    }

    // 處理 multipart 表單
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    // ========== 取得表單資料 ==========
    String listingId = multi.getParameter("listingId");
    String bookId = multi.getParameter("bookId");
    String sellerId = multi.getParameter("sellerId");
    String isRelist = multi.getParameter("isRelist");
    
    // 書籍資料
    String title = multi.getParameter("title");
    String author = multi.getParameter("author");
    String publishDate = multi.getParameter("publishDate");
    String edition = multi.getParameter("edition");
    String ISBN = multi.getParameter("ISBN");
    
    // 上架資料
    String price = multi.getParameter("price");
    String quantity = multi.getParameter("quantity");
    String condition = multi.getParameter("condition");
    String remarks = multi.getParameter("remarks"); // 有無筆記
    String contact = multi.getParameter("contact");
    String expiryDateRaw = multi.getParameter("expiryDate");
    
    // 課程資料
    String courseName = multi.getParameter("courseName");
    String teacher = multi.getParameter("teacher");
    String department = multi.getParameter("department");
    
    // 現有圖片
    String existingPhotos = multi.getParameter("existingPhotos");

    out.println("<!-- 接收到的資料 -->");
    out.println("<!-- listingId: " + listingId + " -->");
    out.println("<!-- bookId: " + bookId + " -->");
    out.println("<!-- isRelist: " + isRelist + " -->");
    out.println("<!-- existingPhotos: " + existingPhotos + " -->");

    // ========== 處理下架日期時間格式 ==========
    String expiryDate = expiryDateRaw;
    if (expiryDateRaw != null && !expiryDateRaw.trim().isEmpty()) {
        try {
            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date date = inputFormat.parse(expiryDateRaw);
            expiryDate = outputFormat.format(date);
        } catch (ParseException pe) {
            out.println("<!-- 日期轉換失敗，使用原始值 -->");
        }
    }

    // ========== 處理圖片上傳 ==========
    List<String> allPhotos = new ArrayList<>();
    
    // 保留現有圖片
    if (existingPhotos != null && !existingPhotos.trim().isEmpty()) {
        String[] existingArray = existingPhotos.split(",");
        for (String photo : existingArray) {
            String trimmed = photo.trim();
            if (!trimmed.isEmpty()) {
                allPhotos.add(trimmed);
            }
        }
    }
    
    // 處理新上傳的圖片
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
                allPhotos.add(safeFileName);
                out.println("<!-- 新上傳圖片: " + safeFileName + " -->");
            }
        }
    }
    
    // 檢查圖片數量
    if (allPhotos.isEmpty()) {
        throw new Exception("至少需要一張圖片！");
    }
    if (allPhotos.size() > 6) {
        throw new Exception("圖片總數不能超過 6 張！");
    }
    
    String photosPaths = String.join(",", allPhotos);
    out.println("<!-- 最終圖片: " + photosPaths + " -->");

    // 組合備註
    StringBuilder fullRemarks = new StringBuilder();
    if (contact != null && !contact.trim().isEmpty()) {
        fullRemarks.append("聯絡方式: ").append(contact);
    }
    if (remarks != null && !remarks.trim().isEmpty()) {
        if (fullRemarks.length() > 0) fullRemarks.append(" | ");
        fullRemarks.append("筆記: ").append(remarks);
    }

    // ========== 資料庫連線 ==========
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    con.setAutoCommit(false);

    // ========== 1. 更新 books 表 ==========
    String updateBookSQL = "UPDATE books SET title=?, author=?, ISBN=?, edition=?, createdAt=? WHERE bookId=?";
    PreparedStatement updateBookStmt = con.prepareStatement(updateBookSQL);
    updateBookStmt.setString(1, title);
    updateBookStmt.setString(2, author);
    updateBookStmt.setString(3, ISBN != null && !ISBN.trim().isEmpty() ? ISBN : null);
    updateBookStmt.setString(4, edition != null && !edition.trim().isEmpty() ? edition : null);
    updateBookStmt.setString(5, publishDate);
    updateBookStmt.setInt(6, Integer.parseInt(bookId));
    updateBookStmt.executeUpdate();
    updateBookStmt.close();
    out.println("<!-- ✅ 更新書籍資料成功 -->");

    // ========== 2. 更新或取得 courses 表 ==========
    int courseId = -1;
    String checkCourseSQL = "SELECT courseId FROM courses WHERE courseName = ? AND teacher = ? AND department = ?";
    PreparedStatement checkCourseStmt = con.prepareStatement(checkCourseSQL);
    checkCourseStmt.setString(1, courseName);
    checkCourseStmt.setString(2, teacher);
    checkCourseStmt.setString(3, department);
    ResultSet courseRs = checkCourseStmt.executeQuery();

    if (courseRs.next()) {
        courseId = courseRs.getInt("courseId");
        out.println("<!-- ✅ 課程已存在，courseId: " + courseId + " -->");
    } else {
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

    // ========== 3. 更新 bookListings 表 ==========
    String updateListingSQL = "UPDATE bookListings SET price=?, quantity=?, [condition]=?, photo=?, remarks=?, expiryDate=?";
    
    // 如果是重新上架，更新審核狀態和下架狀態
    if ("true".equals(isRelist)) {
        updateListingSQL += ", Approved=?, isDelisted=?, listedAt=?";
    }
    
    updateListingSQL += " WHERE listingId=?";
    
    PreparedStatement updateListingStmt = con.prepareStatement(updateListingSQL);
    int paramIndex = 1;
    updateListingStmt.setString(paramIndex++, price);
    updateListingStmt.setString(paramIndex++, quantity != null ? quantity : "1");
    updateListingStmt.setString(paramIndex++, condition);
    updateListingStmt.setString(paramIndex++, photosPaths);
    updateListingStmt.setString(paramIndex++, fullRemarks.toString());
    
    if (expiryDate != null && !expiryDate.trim().isEmpty()) {
        updateListingStmt.setTimestamp(paramIndex++, Timestamp.valueOf(expiryDate));
    } else {
        updateListingStmt.setNull(paramIndex++, Types.TIMESTAMP);
    }
    
    // 如果是重新上架，設定審核狀態
    if ("true".equals(isRelist)) {
        updateListingStmt.setString(paramIndex++, "待審核"); // Approved
        updateListingStmt.setBoolean(paramIndex++, false); // isDelisted = false
        updateListingStmt.setString(paramIndex++, new SimpleDateFormat("yyyy-MM-dd").format(new Date())); // listedAt 更新為今天
    }
    
    updateListingStmt.setInt(paramIndex++, Integer.parseInt(listingId));
    updateListingStmt.executeUpdate();
    updateListingStmt.close();
    out.println("<!-- ✅ 更新上架資料成功 -->");

    // ========== 4. 更新 book_course_relations 表 ==========
    // 先刪除舊的關聯
    String deleteRelationSQL = "DELETE FROM book_course_relations WHERE bookId = ?";
    PreparedStatement deleteRelationStmt = con.prepareStatement(deleteRelationSQL);
    deleteRelationStmt.setInt(1, Integer.parseInt(bookId));
    deleteRelationStmt.executeUpdate();
    deleteRelationStmt.close();
    
    // 新增新的關聯
    String insertRelationSQL = "INSERT INTO book_course_relations(bookId, courseId) VALUES(?, ?)";
    PreparedStatement insertRelationStmt = con.prepareStatement(insertRelationSQL);
    insertRelationStmt.setInt(1, Integer.parseInt(bookId));
    insertRelationStmt.setInt(2, courseId);
    insertRelationStmt.executeUpdate();
    insertRelationStmt.close();
    out.println("<!-- ✅ 更新書籍-課程關聯成功 -->");

    // ========== 提交交易 ==========
    con.commit();
    out.println("<!-- ✅ 所有資料已成功更新 -->");
    
    // 格式化顯示日期時間
    String displayExpiryDate = expiryDate;
    try {
        SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        java.util.Date date = dbFormat.parse(expiryDate);
        displayExpiryDate = displayFormat.format(date);
    } catch (Exception e) {
        // 使用原始值
    }
%>
<div class="success-box">
    <h3 style="color:green;">✅ 更新成功！</h3>
    <p><strong>書名：</strong><%= title %></p>
    <p><strong>作者：</strong><%= author %></p>
    <p><strong>價格：</strong>NT$<%= price %></p>
    <p><strong>課程：</strong><%= courseName %></p>
    <p><strong>授課教師：</strong><%= teacher %></p>
    <p><strong>系所：</strong><%= department %></p>
    <p><strong>書籍狀況：</strong><%= condition %></p>
    <p><strong>下架日期時間：</strong><%= displayExpiryDate %></p>
    <p><strong>圖片總數：</strong><%= allPhotos.size() %> 張</p>
    <% if ("true".equals(isRelist)) { %>
    <p style="color:#2196f3; margin-top:15px; font-weight:bold;">📢 書籍已重新上架，等待管理員審核中...</p>
    <% } %>
</div>

<script>
    setTimeout(function() {
        <% if ("true".equals(isRelist)) { %>
        alert("✅ 書籍已成功更新並重新上架！\n書名：<%= title %>\n課程：<%= courseName %>\n等待管理員審核中...");
        <% } else { %>
        alert("✅ 書籍資料已成功更新！\n書名：<%= title %>\n課程：<%= courseName %>");
        <% } %>
        window.location.href = "listingDetail.jsp?listingId=<%= listingId %>";
    }, 1000);
</script>
<%
} catch (Exception e) {
    if (con != null) {
        try {
            con.rollback();
            out.println("<!-- ❌ 交易已回滾 -->");
        } catch (SQLException se) {
            out.println("<!-- ❌ 回滾失敗: " + se.getMessage() + " -->");
        }
    }
    
    out.println("<div class='error-box'>");
    out.println("<h3 style='color:red;'>❌ 更新失敗</h3>");
    out.println("<p><strong>錯誤訊息：</strong>" + e.getMessage() + "</p>");
    out.println("</div>");
    
    out.println("<h4>詳細錯誤資訊</h4>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    
    out.println("<br><a href='javascript:history.back()' style='display:inline-block; padding:10px 20px; background:#007bff; color:#fff; text-decoration:none; border-radius:4px;'>返回編輯頁面</a>");
} finally {
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