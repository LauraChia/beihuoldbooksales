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

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>處理更新中 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            font-family: "Microsoft JhengHei", sans-serif;
            background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .processing-container {
            max-width: 800px;
            width: 100%;
            background: white;
            border-radius: 16px;
            box-shadow: 0 8px 32px rgba(102, 187, 106, 0.2);
            overflow: hidden;
            animation: slideIn 0.5s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .processing-header {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .processing-header h2 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }

        .processing-body {
            padding: 40px;
        }

        /* Loading 動畫 */
        .loading-section {
            text-align: center;
            padding: 40px 20px;
        }

        .spinner {
            width: 60px;
            height: 60px;
            border: 4px solid #e8f5e9;
            border-top: 4px solid #66bb6a;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-text {
            color: #66bb6a;
            font-size: 18px;
            font-weight: 500;
            margin-bottom: 10px;
        }

        .loading-hint {
            color: #999;
            font-size: 14px;
        }

        /* 成功訊息樣式 */
        .success-section {
            display: none;
        }

        .success-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            animation: scaleIn 0.5s ease-out;
        }

        @keyframes scaleIn {
            from {
                opacity: 0;
                transform: scale(0.5);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        .success-icon i {
            font-size: 40px;
            color: white;
        }

        .success-title {
            color: #2e7d32;
            font-size: 24px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 30px;
        }

        .info-grid {
		    display: flex;
		    flex-direction: column;
		    gap: 15px;
		    margin-bottom: 30px;
		}


        .info-card {
            background: white;
	    	border-radius: 8px;
		    padding: 15px 20px;
		    border-left: 4px solid #66bb6a;
		    transition: all 0.3s;
		    display: flex;
		    align-items: center;
		    gap: 15px;
        }

        .info-card:hover {
            background: #e8f5e9;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 187, 106, 0.15);
        }

        .info-label {
            color: #666;
		    font-size: 14px;
		    display: flex;
		    align-items: center;
		    gap: 6px;
		    min-width: 120px;
		    font-weight: 500;
        }

        .info-label i {
            color: #66bb6a;
            font-size: 14px;
        }

        .info-value {
            color: #333;
	    	font-size: 15px;
		    font-weight: 400;
		    word-break: break-word;
		    flex: 1;
        }

        .photo-preview {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            gap: 12px;
            margin-top: 20px;
        }

        .photo-item {
            position: relative;
            width: 100%;
            padding-bottom: 100%;
            border-radius: 8px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
            transition: all 0.3s;
        }

        .photo-item:hover {
            border-color: #66bb6a;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(102, 187, 106, 0.3);
        }

        .photo-item img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .notice-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 20px;
            border-radius: 8px;
            margin: 30px 0;
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.9; }
        }

        .notice-box .notice-title {
            color: #1565c0;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .notice-box .notice-content {
            color: #1976d2;
            font-size: 14px;
            line-height: 1.6;
        }

        /* 錯誤訊息樣式 */
        .error-section {
            display: none;
        }

        .error-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #ef5350 0%, #e53935 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            animation: shake 0.5s ease-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        .error-icon i {
            font-size: 40px;
            color: white;
        }

        .error-title {
            color: #c62828;
            font-size: 24px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 20px;
        }

        .error-message {
            background: #ffebee;
            border: 1px solid #ef9a9a;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .error-message-title {
            color: #c62828;
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .error-message-content {
            color: #d32f2f;
            font-size: 14px;
            line-height: 1.6;
        }

        .error-details {
            background: #f5f5f5;
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            max-height: 300px;
            overflow-y: auto;
        }

        .error-details pre {
            margin: 0;
            font-size: 12px;
            color: #666;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        /* 按鈕樣式 */
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 14px 32px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 187, 106, 0.4);
        }

        .btn-secondary {
            background: white;
            color: #666;
            border: 2px solid #e0e0e0;
        }

        .btn-secondary:hover {
            background: #f5f5f5;
            border-color: #bdbdbd;
        }

        .btn-danger {
            background: white;
            color: #e53935;
            border: 2px solid #ef5350;
        }

        .btn-danger:hover {
            background: #ffebee;
            border-color: #e53935;
        }

        /* 進度條 */
        .progress-bar {
            width: 100%;
            height: 4px;
            background: #e0e0e0;
            border-radius: 2px;
            overflow: hidden;
            margin: 20px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #81c784 0%, #66bb6a 100%);
            animation: progress 2s ease-out;
        }

        @keyframes progress {
            from { width: 0%; }
            to { width: 100%; }
        }
    </style>
</head>
<body>

<div class="processing-container">
    <div class="processing-header">
        <h2>
            <i class="fas fa-sync-alt fa-spin"></i>
            處理更新中
        </h2>
    </div>
    
    <div class="processing-body">
        <!-- Loading 狀態 -->
        <div class="loading-section" id="loadingSection">
            <div class="spinner"></div>
            <div class="loading-text">正在處理您的更新...</div>
            <div class="loading-hint">請稍候，不要關閉此頁面</div>
            <div class="progress-bar">
                <div class="progress-fill"></div>
            </div>
        </div>

        <!-- 成功狀態 -->
        <div class="success-section" id="successSection">
            <div class="success-icon">
                <i class="fas fa-check"></i>
            </div>
            <div class="success-title">✨ 更新成功！</div>
            
            <div id="successContent"></div>
            
            <div class="notice-box">
                <div class="notice-title">
                    <i class="fas fa-info-circle"></i>
                    重要提醒
                </div>
                <div class="notice-content">
                    📢 您的書籍已重新上架並送出審核申請<br>
                    ⏰ 管理員將在 1-2 個工作天內完成審核<br>
                    📧 審核結果將透過系統通知您
                </div>
            </div>

            <div class="action-buttons">
                <a href="bookDetail.jsp?listingId=<%= request.getParameter("listingId") %>" class="btn btn-primary">
                    <i class="fas fa-eye"></i> 查看書籍詳情
                </a>
                <a href="myListings.jsp" class="btn btn-secondary">
                    <i class="fas fa-list"></i> 返回我的刊登
                </a>
            </div>
        </div>

        <!-- 錯誤狀態 -->
        <div class="error-section" id="errorSection">
            <div class="error-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="error-title">❌ 更新失敗</div>
            
            <div class="error-message">
                <div class="error-message-title">
                    <i class="fas fa-times-circle"></i>
                    錯誤訊息
                </div>
                <div class="error-message-content" id="errorMessage"></div>
            </div>

            <div class="action-buttons">
                <button onclick="history.back()" class="btn btn-danger">
                    <i class="fas fa-arrow-left"></i> 返回編輯頁面
                </button>
                <a href="myListings.jsp" class="btn btn-secondary">
                    <i class="fas fa-home"></i> 返回首頁
                </a>
            </div>

            <div class="error-details" id="errorDetails" style="display:none;">
                <pre id="errorDetailsContent"></pre>
            </div>
        </div>
    </div>
</div>

<%
Connection con = null;
boolean success = false;
String errorMsg = "";
String errorDetails = "";

// 收集資料用於顯示
Map<String, String> updateData = new HashMap<>();

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
    String remarks = multi.getParameter("remarks");
    String contact = multi.getParameter("contact");
    String expiryDateRaw = multi.getParameter("expiryDate");
    
    // 課程資料
    String courseName = multi.getParameter("courseName");
    String teacher = multi.getParameter("teacher");
    String department = multi.getParameter("department");
    
    // 現有圖片
    String existingPhotos = multi.getParameter("existingPhotos");

    // 儲存資料以便顯示
    updateData.put("title", title);
    updateData.put("author", author);
    updateData.put("price", price);
    updateData.put("publishDate", publishDate);
    updateData.put("edition", edition != null ? edition : "無");
    updateData.put("ISBN", ISBN != null ? ISBN : "無");
    updateData.put("quantity", quantity);
    updateData.put("condition", condition);
    updateData.put("remarks", remarks);
    updateData.put("contact", contact);
    updateData.put("courseName", courseName);
    updateData.put("teacher", teacher);
    updateData.put("department", department);

    // ========== 處理下架日期時間格式 ==========
    String expiryDate = expiryDateRaw;
    if (expiryDateRaw != null && !expiryDateRaw.trim().isEmpty()) {
        try {
            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy年MM月dd日 HH:mm");
            java.util.Date date = inputFormat.parse(expiryDateRaw);
            expiryDate = outputFormat.format(date);
            updateData.put("expiryDate", displayFormat.format(date));
        } catch (ParseException pe) {
            updateData.put("expiryDate", expiryDateRaw);
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
            }
        }
    }
    
    // 檢查圖片數量
    if (allPhotos.isEmpty()) {
        throw new Exception("至少需要一張圖片！");
    }
    if (allPhotos.size() > 6) {
        throw new Exception("圖片總數不能超過 6 張！目前有 " + allPhotos.size() + " 張");
    }
    
    String photosPaths = String.join(",", allPhotos);
    updateData.put("photoCount", String.valueOf(allPhotos.size()));
    updateData.put("photos", photosPaths);

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
        }
        courseKeys.close();
        insertCourseStmt.close();
    }
    courseRs.close();
    checkCourseStmt.close();

    // ========== 3. 更新 bookListings 表 ==========
    String updateListingSQL = "UPDATE bookListings SET price=?, quantity=?, [condition]=?, photo=?, remarks=?, expiryDate=?, Approved=?, isDelisted=?, listedAt=?, relistingCount=relistingCount+1 WHERE listingId=?";

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

    updateListingStmt.setString(paramIndex++, "待審核");
    updateListingStmt.setBoolean(paramIndex++, false);
    updateListingStmt.setString(paramIndex++, new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
    updateListingStmt.setInt(paramIndex++, Integer.parseInt(listingId));
    updateListingStmt.executeUpdate();
    updateListingStmt.close();

    // ========== 4. 更新 book_course_relations 表 ==========
    String deleteRelationSQL = "DELETE FROM book_course_relations WHERE bookId = ?";
    PreparedStatement deleteRelationStmt = con.prepareStatement(deleteRelationSQL);
    deleteRelationStmt.setInt(1, Integer.parseInt(bookId));
    deleteRelationStmt.executeUpdate();
    deleteRelationStmt.close();
    
    String insertRelationSQL = "INSERT INTO book_course_relations(bookId, courseId) VALUES(?, ?)";
    PreparedStatement insertRelationStmt = con.prepareStatement(insertRelationSQL);
    insertRelationStmt.setInt(1, Integer.parseInt(bookId));
    insertRelationStmt.setInt(2, courseId);
    insertRelationStmt.executeUpdate();
    insertRelationStmt.close();

    // ========== 提交交易 ==========
    con.commit();
    success = true;

} catch (Exception e) {
    if (con != null) {
        try {
            con.rollback();
        } catch (SQLException se) {
            // 忽略回滾錯誤
        }
    }
    
    success = false;
    errorMsg = e.getMessage();
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    errorDetails = sw.toString();
    
} finally {
    if (con != null) {
        try {
            con.setAutoCommit(true);
            con.close();
        } catch (SQLException se) {
            // 忽略關閉錯誤
        }
    }
}

// 輸出 JavaScript 來更新頁面
if (success) {
%>
<script>
    setTimeout(function() {
        // 隱藏 loading
        document.getElementById('loadingSection').style.display = 'none';
        
        // 顯示成功區塊
        const successSection = document.getElementById('successSection');
        successSection.style.display = 'block';
        
        // 建立成功內容
        const successContent = `
            <div class="info-grid">
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-book"></i> 書名</div>
                    <div class="info-value"><%= updateData.get("title") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-user-edit"></i> 作者</div>
                    <div class="info-value"><%= updateData.get("author") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-dollar-sign"></i> 價格</div>
                    <div class="info-value">NT$ <%= updateData.get("price") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-calendar-alt"></i> 出版日期</div>
                    <div class="info-value"><%= updateData.get("publishDate") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-graduation-cap"></i> 課程</div>
                    <div class="info-value"><%= updateData.get("courseName") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-chalkboard-teacher"></i> 授課教師</div>
                    <div class="info-value"><%= updateData.get("teacher") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-university"></i> 系所</div>
                    <div class="info-value"><%= updateData.get("department") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-star"></i> 書籍狀況</div>
                    <div class="info-value"><%= updateData.get("condition") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-clock"></i> 下架時間</div>
                    <div class="info-value"><%= updateData.get("expiryDate") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-box"></i> 數量</div>
                    <div class="info-value"><%= updateData.get("quantity") %> 本</div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-images"></i> 圖片</div>
                    <div class="info-value"><%= updateData.get("photoCount") %> 張</div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-phone"></i> 聯絡方式</div>
                    <div class="info-value"><%= updateData.get("contact") %></div>
                </div>
                <div class="info-card">
                    <div class="info-label"><i class="fas fa-edit"></i> 筆記</div>
                    <div class="info-value"><%= updateData.get("remarks") %></div>
                </div>
            </div>
            
            <% if (updateData.get("photos") != null && !updateData.get("photos").isEmpty()) { 
                String[] photoArray = updateData.get("photos").split(",");
            %>
            <div style="margin-top: 30px;">
                <div style="color: #666; font-size: 14px; margin-bottom: 15px; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-images" style="color: #66bb6a;"></i>
                    <strong>書籍照片預覽</strong>
                </div>
                <div class="photo-preview">
                    <% for (String photo : photoArray) { 
                        String displayPath = photo.trim();
                        if (!displayPath.startsWith("assets/")) {
                            displayPath = "assets/images/member/" + displayPath;
                        }
                    %>
                    <div class="photo-item">
                        <img src="<%= displayPath %>" alt="書籍照片" onerror="this.src='assets/images/about.png'">
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        `;
        
        document.getElementById('successContent').innerHTML = successContent;
    }, 1500);
</script>
<%
} else {
%>
<script>
    setTimeout(function() {
        // 隱藏 loading
        document.getElementById('loadingSection').style.display = 'none';
        
        // 顯示錯誤區塊
        const errorSection = document.getElementById('errorSection');
        errorSection.style.display = 'block';
        
        // 設定錯誤訊息
        document.getElementById('errorMessage').textContent = '<%= errorMsg.replace("'", "\\'").replace("\n", " ") %>';
        
        <% if (errorDetails != null && !errorDetails.isEmpty()) { %>
        // 顯示詳細錯誤（可選）
        const errorDetailsDiv = document.getElementById('errorDetails');
        const errorDetailsContent = document.getElementById('errorDetailsContent');
        errorDetailsContent.textContent = '<%= errorDetails.replace("'", "\\'").replace("\n", "\\n") %>';
        
        // 添加顯示/隱藏詳細資訊的按鈕
        const toggleBtn = document.createElement('button');
        toggleBtn.className = 'btn btn-secondary';
        toggleBtn.innerHTML = '<i class="fas fa-info-circle"></i> 顯示技術細節';
        toggleBtn.style.marginTop = '15px';
        toggleBtn.onclick = function() {
            if (errorDetailsDiv.style.display === 'none') {
                errorDetailsDiv.style.display = 'block';
                toggleBtn.innerHTML = '<i class="fas fa-eye-slash"></i> 隱藏技術細節';
            } else {
                errorDetailsDiv.style.display = 'none';
                toggleBtn.innerHTML = '<i class="fas fa-info-circle"></i> 顯示技術細節';
            }
        };
        
        document.querySelector('.error-message').appendChild(toggleBtn);
        <% } %>
    }, 1000);
</script>
<%
}
%>

</body>
</html>