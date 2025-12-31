<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // 檢查是否登入
    String currentUserId = (String) session.getAttribute("userId");
    if (currentUserId == null || currentUserId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=myListings.jsp");
        return;
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>書籍詳情 - 我的上架</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        /* 頁面標題 - 淺綠色 */
        .page-header {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 40px;
            box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
        }
        
        .page-header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 600;
        }
        
        .page-header .breadcrumb {
            background: transparent;
            padding: 0;
            margin: 10px 0 0 0;
            font-size: 14px;
        }
        
        .page-header .breadcrumb a {
            color: white;
            opacity: 0.9;
            text-decoration: none;
        }
        
        .page-header .breadcrumb a:hover {
            opacity: 1;
            text-decoration: underline;
        }
        
        .page-header .breadcrumb-item.active {
            color: white;
            opacity: 0.7;
        }
        
        .page-header .breadcrumb-item + .breadcrumb-item::before {
            color: white;
            opacity: 0.7;
        }
        
        .back-button {
            background-color: white;
            border: 2px solid #81c784;
            color: #66bb6a;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
        }
        
        .back-button:hover {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            transform: translateX(-5px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .book-detail {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            gap: 40px;
            padding: 0 40px 40px;
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .image-gallery {
            position: relative;
            width: 400px;
            flex-shrink: 0;
        }
        
        .image-container {
            position: relative;
            width: 100%;
            height: 500px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.12);
            background-color: #f0f0f0;
        }
        
        .book-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }
        
        .book-image.active {
            display: block;
        }
        
        .image-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background-color: rgba(129, 199, 132, 0.9);
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            z-index: 10;
        }
        
        .image-nav:hover {
            background-color: #66bb6a;
            transform: translateY(-50%) scale(1.1);
        }
        
        .image-nav.prev {
            left: 10px;
        }
        
        .image-nav.next {
            right: 10px;
        }
        
        .thumbnail-container {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            overflow-x: auto;
            padding: 5px 0;
        }
        
        .thumbnail {
            width: 80px;
            height: 100px;
            border-radius: 8px;
            object-fit: cover;
            cursor: pointer;
            border: 3px solid transparent;
            transition: all 0.3s;
            flex-shrink: 0;
        }
        
        .thumbnail:hover {
            transform: scale(1.05);
            border-color: #c8e6c9;
        }
        
        .thumbnail.active {
            border-color: #66bb6a;
            box-shadow: 0 2px 8px rgba(102, 187, 106, 0.4);
        }
        
        .image-counter {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background-color: rgba(102, 187, 106, 0.9);
            color: white;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            z-index: 10;
        }
        
        .status-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            z-index: 10;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        .status-approved {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
        }
        
        .status-pending {
            background: linear-gradient(135deg, #ffb74d 0%, #ffa726 100%);
            color: white;
        }
        
        .status-rejected {
            background: linear-gradient(135deg, #e57373 0%, #ef5350 100%);
            color: white;
        }
        
        .status-delisted {
            background: linear-gradient(135deg, #bdbdbd 0%, #9e9e9e 100%);
            color: white;
        }
        
        .detail-info {
            flex: 1;
            max-width: 700px;
        }
        
        .detail-header {
            margin-bottom: 20px;
        }
        
        .detail-header h2 {
            font-weight: bold;
            margin: 0 0 10px 0;
            color: #333;
            font-size: 28px;
        }
        
        .price {
            font-size: 32px;
            color: #e53935;
            font-weight: bold;
            margin: 15px 0;
        }
        
        .info-section {
            background-color: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid #e0e0e0;
        }
        
        .info-section h3 {
            font-size: 18px;
            font-weight: bold;
            color: #66bb6a;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid #c8e6c9;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .info-item {
            margin: 14px 0;
            color: #555;
            line-height: 1.8;
            display: flex;
            align-items: flex-start;
        }
        
        .info-item strong {
            color: #333;
            min-width: 140px;
            display: inline-block;
            font-weight: 600;
        }
        
        .info-item .value {
            flex: 1;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 14px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-edit {
            background: linear-gradient(135deg, #42a5f5 0%, #2196f3 100%);
            color: white;
        }
        
        .btn-edit:hover {
            background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(33, 150, 243, 0.4);
        }
        
        .btn-delete {
            background: linear-gradient(135deg, #ef5350 0%, #e53935 100%);
            color: white;
        }
        
        .btn-delete:hover {
            background: linear-gradient(135deg, #e53935 0%, #d32f2f 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.4);
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
        }
        
        .btn-secondary:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .alert {
            padding: 18px 25px;
            margin: 0 40px 30px;
            max-width: 1400px;
            margin-left: auto;
            margin-right: auto;
            border-radius: 10px;
            animation: slideIn 0.3s;
            border-left: 4px solid;
        }
        
        .alert-warning {
            background-color: #fff8e1;
            border-color: #ffb74d;
            color: #f57c00;
        }
        
        .alert-info {
            background-color: #e3f2fd;
            border-color: #42a5f5;
            color: #1976d2;
        }
        
        .alert strong {
            font-size: 16px;
            display: block;
            margin-bottom: 5px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .stat-box {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 18px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(129, 199, 132, 0.3);
        }
        
        .stat-box .label {
            font-size: 13px;
            opacity: 0.9;
            margin-bottom: 8px;
        }
        
        .stat-box .value {
            font-size: 26px;
            font-weight: bold;
        }
        
        .no-image {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            font-size: 16px;
        }
        
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        @media (max-width: 1024px) {
            .book-detail {
                flex-direction: column;
                padding: 0 20px 40px;
            }
            
            .image-gallery {
                width: 100%;
                max-width: 500px;
                margin: 0 auto;
            }
            
            .detail-info {
                width: 100%;
                max-width: 100%;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .alert {
                margin: 0 20px 30px;
            }
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp"%>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-book-open"></i> 書籍詳情</h1>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="index.jsp">首頁</a></li>
                <li class="breadcrumb-item"><a href="myListings.jsp">我的上架</a></li>
                <li class="breadcrumb-item active">書籍詳情</li>
            </ol>
        </nav>
    </div>
</div>

<%
    String listingId = request.getParameter("listingId");
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    String sql = "SELECT " +
                 "bl.listingId, bl.bookId, bl.sellerId, bl.price, bl.quantity, " +
                 "bl.condition, bl.photo, bl.remarks, bl.Approved, bl.listedAt, bl.expiryDate, bl.isDelisted, " +
                 "b.title, b.author, b.ISBN, b.edition, b.createdAt AS publishDate, " +
                 "c.courseName, c.teacher, c.department " +
                 "FROM bookListings bl " +
                 "INNER JOIN books b ON bl.bookId = b.bookId " +
                 "LEFT JOIN book_course_relations bcr ON b.bookId = bcr.bookId " +
                 "LEFT JOIN courses c ON bcr.courseId = c.courseId " +
                 "WHERE bl.listingId = " + listingId + " AND bl.sellerId = '" + currentUserId + "'";
    
    Statement smt = con.createStatement();
    ResultSet rs = smt.executeQuery(sql);
    
    if (rs.next()) {
        String bookId = rs.getString("bookId");
        String sellerId = rs.getString("sellerId");
        
        // 驗證是否為本人的書籍
        if (!currentUserId.equals(sellerId)) {
            response.sendRedirect("myListings.jsp");
            return;
        }
        
        // 分割圖片路徑
        String photoStr = rs.getString("photo");
        List<String> photoList = new ArrayList<>();
        
        if (photoStr != null && !photoStr.trim().isEmpty()) {
            String[] photoArray = photoStr.split(",");
            for (String photo : photoArray) {
                String trimmedPhoto = photo.trim();
                if (!trimmedPhoto.startsWith("assets/")) {
                    trimmedPhoto = "assets/images/member/" + trimmedPhoto;
                }
                photoList.add(trimmedPhoto);
            }
        }
        
        if (photoList.isEmpty()) {
            photoList.add("assets/images/about.png");
        }
        
        int totalImages = photoList.size();
        
        // 處理審核狀態
        String approvalStatus = rs.getString("Approved");
        Boolean isDelisted = rs.getBoolean("isDelisted");
        String statusText = "待審核";
        String statusClass = "status-pending";
        
        if (isDelisted != null && isDelisted) {
            statusText = "已下架";
            statusClass = "status-delisted";
        } else if ("TRUE".equalsIgnoreCase(approvalStatus)) {
            statusText = "已審核";
            statusClass = "status-approved";
        } else if ("FALSE".equalsIgnoreCase(approvalStatus)) {
            statusText = "未通過";
            statusClass = "status-rejected";
        }
        
     	// 取得有無筆記資訊
        String remarks = rs.getString("remarks");
        String hasNotes = (remarks != null && !remarks.trim().isEmpty()) ? remarks : "未提供";
        
        // 設定預設值（不執行查詢）
        int favoriteCount = 0;
        int messageCount = 0;
%>

<% if (isDelisted != null && isDelisted) { %>
<div class="alert alert-warning">
    <strong>⚠️ 此書籍已下架</strong><br>
    此書籍已從平台下架，買家無法看到此商品。
</div>
<% } else if ("FALSE".equalsIgnoreCase(approvalStatus)) { %>
<div class="alert alert-warning">
    <strong>⚠️ 審核未通過</strong><br>
    此書籍未通過審核，買家無法看到此商品。請檢查上架內容是否符合規範，或聯繫管理員了解詳情。
</div>
<% } else if (!"TRUE".equalsIgnoreCase(approvalStatus)) { %>
<div class="alert alert-info">
    <strong>ℹ️ 等待審核中</strong><br>
    您的書籍正在等待管理員審核。
</div>
<% } %>

<div style="max-width: 1400px; margin: 0 auto; padding: 0 40px;">
    <button class="back-button" onclick="window.location.href='myListings.jsp'">
        <i class="fas fa-arrow-left"></i> 返回我的上架
    </button>
</div>

<div class="book-detail">
    <div class="image-gallery">
        <div class="image-container">
            <div class="status-badge <%= statusClass %>"><%= statusText %></div>
            
            <% if (photoList.isEmpty()) { %>
                <div class="no-image">無圖片</div>
            <% } else { %>
                <% for (int i = 0; i < photoList.size(); i++) { %>
                    <img src="<%= photoList.get(i) %>" 
                         alt="書籍圖片<%= (i+1) %>" 
                         class="book-image <%= (i == 0) ? "active" : "" %>"
                         onerror="this.src='assets/images/about.png'">
                <% } %>
                
                <% if (totalImages > 1) { %>
                    <button class="image-nav prev" onclick="changeImage(-1)">
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <button class="image-nav next" onclick="changeImage(1)">
                        <i class="fas fa-chevron-right"></i>
                    </button>
                    <div class="image-counter">
                        <span id="current-image">1</span> / <%= totalImages %>
                    </div>
                <% } %>
            <% } %>
        </div>
        
        <% if (totalImages > 1) { %>
        <div class="thumbnail-container">
            <% for (int i = 0; i < photoList.size(); i++) { %>
                <img src="<%= photoList.get(i) %>" 
                     alt="縮圖<%= (i+1) %>" 
                     class="thumbnail <%= (i == 0) ? "active" : "" %>"
                     onclick="showImage(<%= i %>)"
                     onerror="this.src='assets/images/about.png'">
            <% } %>
        </div>
        <% } %>
    </div>
    
    <div class="detail-info">
        <div class="detail-header">
            <h2><%= rs.getString("title") %></h2>
        </div>

        <div class="price">NT$<%= (int) Float.parseFloat(rs.getString("price")) %></div>
        
        <!-- 基本資訊 -->
        <div class="info-section">
            <h3><i class="fas fa-book"></i> 基本資訊</h3>
            <div class="info-item">
                <strong>作者：</strong>
                <span class="value"><%= rs.getString("author") != null ? rs.getString("author") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>出版日期：</strong>
                <span class="value"><%= rs.getString("publishDate") != null ? rs.getString("publishDate").split(" ")[0] : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>書籍版本：</strong>
                <span class="value"><%= rs.getString("edition") != null && !rs.getString("edition").trim().isEmpty() ? rs.getString("edition") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>ISBN：</strong>
                <span class="value"><%= rs.getString("ISBN") != null && !rs.getString("ISBN").trim().isEmpty() ? rs.getString("ISBN") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>書籍狀況：</strong>
                <span class="value"><%= rs.getString("condition") %></span>
            </div>
            <div class="info-item">
                <strong>有無筆記：</strong>
                <span class="value"><%= hasNotes.isEmpty() ? "未提供" : hasNotes %></span>
            </div>
            <div class="info-item">
                <strong>剩餘數量：</strong>
                <span class="value"><%= rs.getString("quantity") %> 本</span>
            </div>
        </div>
        
        <!-- 課程資訊 -->
        <div class="info-section">
            <h3><i class="fas fa-graduation-cap"></i> 課程資訊</h3>
            <div class="info-item">
                <strong>使用系所：</strong>
                <span class="value"><%= rs.getString("department") != null ? rs.getString("department") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>使用課程：</strong>
                <span class="value"><%= rs.getString("courseName") != null ? rs.getString("courseName") : "未提供" %></span>
            </div>
            <div class="info-item">
                <strong>授課老師：</strong>
                <span class="value"><%= rs.getString("teacher") != null ? rs.getString("teacher") : "未提供" %></span>
            </div>
        </div>
        
        <!-- 上架資訊 -->
        <div class="info-section">
    		<h3><i class="fas fa-info-circle"></i> 上架資訊</h3>  		
            <div class="info-item">
                <strong>上架日期：</strong>
                <span class="value"><%= rs.getString("listedAt").split(" ")[0] %></span>
            </div>
            <%
                String expiryDateStr = rs.getString("expiryDate");
                String displayExpiryDate = expiryDateStr;
                
                if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
                    try {
                        SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                        java.util.Date date = dbFormat.parse(expiryDateStr);
                        displayExpiryDate = displayFormat.format(date);
                    } catch (Exception e) {
                        displayExpiryDate = expiryDateStr;
                    }
                }
            %>
            <div class="info-item">
                <strong>下架日期時間：</strong>
                <span class="value"><%= displayExpiryDate %></span>
            </div>
            <div class="info-item">
                <strong>審核狀態：</strong>
                <span class="value <%= statusClass.replace("status-", "") %>"><%= statusText %></span>
            </div>
        </div>

        <!-- 操作按鈕 -->
		<div class="action-buttons">
		    <% if (isDelisted != null && isDelisted) { %>
		        <!-- 已下架：顯示編輯並重新上架按鈕 -->
		        <button class="btn-action btn-secondary" onclick="editAndRelist()">
		            <i class="fas fa-edit"></i> 編輯並重新上架
		        </button>
		    <% } else { %>
		        <!-- 未下架：只顯示下架按鈕 -->
		        <button class="btn-action btn-delete" onclick="deleteListing()">
		            <i class="fas fa-trash"></i> 下架書籍
		        </button>
		    <% } %>
		    <button class="btn-action btn-secondary" onclick="viewMessages()">
		        <i class="fas fa-comments"></i> 查看訊息 <% if (messageCount > 0) { %>(<%= messageCount %>)<% } %>
		    </button>
		</div>
    </div>
</div>

<script>
    const listingId = '<%= listingId %>';
    const bookTitle = '<%= rs.getString("title") %>';
    
    let currentImageIndex = 0;
    const images = document.querySelectorAll('.book-image');
    const thumbnails = document.querySelectorAll('.thumbnail');
    const totalImages = images.length;
    
    function showImage(index) {
        images.forEach(img => img.classList.remove('active'));
        thumbnails.forEach(thumb => thumb.classList.remove('active'));
        
        currentImageIndex = index;
        images[currentImageIndex].classList.add('active');
        if (thumbnails.length > 0) {
            thumbnails[currentImageIndex].classList.add('active');
        }
        
        const counter = document.getElementById('current-image');
        if (counter) {
            counter.textContent = currentImageIndex + 1;
        }
    }
    
    function changeImage(direction) {
        let newIndex = currentImageIndex + direction;
        
        if (newIndex >= totalImages) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = totalImages - 1;
        }
        
        showImage(newIndex);
    }
    
    document.addEventListener('keydown', function(e) {
        if (totalImages > 1) {
            if (e.key === 'ArrowLeft') {
                changeImage(-1);
            } else if (e.key === 'ArrowRight') {
                changeImage(1);
            }
        }
    });
    
    function editAndRelist() {
        if (confirm('確定要編輯並重新上架「' + bookTitle + '」嗎？\n\n您將被導向編輯頁面，編輯完成後書籍將自動重新上架並等待審核。')) {
            // 帶上 relist 參數，表示這是重新上架的編輯
            window.location.href = 'editListing.jsp?listingId=' + listingId + '&relist=true';
        }
    }
    
    function deleteListing() {
        if (confirm('確定要下架「' + bookTitle + '」嗎？\n\n下架後買家將無法看到此書籍。')) {
            fetch('delistBook.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'listingId=' + listingId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('✅書籍已成功下架');
                    window.location.reload();
                } else {
                    alert('❌ 下架失敗: ' + (data.message || '未知錯誤'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('❌ 系統錯誤');
            });
        }
    }
    
    function viewMessages() {
        window.location.href = 'myMessages.jsp?listingId=' + listingId;
    }
</script>

<%
    }
    con.close();
%>

<%@ include file="footer.jsp"%>

</body>
</html>