<%@page contentType="text/html" pageEncoding="utf-8"%>  
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="java.util.Date"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        out.println("<script>alert('請先登入才能編輯書籍！'); window.location.href='login.jsp';</script>");
        return;
    }
    
    String listingId = request.getParameter("listingId");
    String isRelist = request.getParameter("relist"); // 判斷是否為重新上架
    
    if (listingId == null || listingId.trim().isEmpty()) {
        response.sendRedirect("myListings.jsp");
        return;
    }
    
    // 取得今天的日期
    String todayDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title><%= "true".equals(isRelist) ? "編輯並重新上架" : "編輯書籍" %> - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: "Microsoft JhengHei", sans-serif; }
        
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
        
        .form-container { 
            background:#fff; 
            padding:40px; 
            border-radius:12px; 
            max-width:900px; 
            margin:0 auto 40px; 
            box-shadow:0 2px 12px rgba(0,0,0,0.1);
        }
        
        .form-container h3 {
            color: #66bb6a;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #c8e6c9;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
		.info-alert {
		    background: #e8f5e9;
		    border-left: 4px solid #66bb6a;
		    padding: 15px 20px;
		    margin-bottom: 25px;
		    border-radius: 4px;
		    color: #2e7d32;
		}
        
        .warning-alert {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px 20px;
            margin-bottom: 25px;
            border-radius: 4px;
            color: #856404;
        }
        
        .form-group { 
            margin-bottom: 20px; 
            display: flex; 
            align-items: flex-start; 
        }
        
        label { 
            display:inline-block; 
            width:140px; 
            margin-bottom:10px; 
            vertical-align:top; 
            font-weight: 500; 
            padding-top: 6px;
            color: #333;
        }
        
        label .required { color:red; margin-left: 2px; }
        
        input:not([type="file"]):not([type="submit"]):not([type="reset"]):not([type="checkbox"]), select, textarea { 
            flex: 1; 
            padding: 10px 14px; 
            border: 1px solid #ddd; 
            border-radius: 6px; 
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
		 input:focus, select:focus, textarea:focus {
		    outline: none;
		    border-color: #66bb6a;
		    box-shadow: 0 0 0 3px rgba(102, 187, 106, 0.1);
		}

        /* 圖片上傳樣式 */
        .upload-section { display: flex; flex-direction: column; gap: 15px; }
        
        .current-images {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            margin-bottom: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .current-image-item {
            position: relative;
            width: 100%;
            padding-bottom: 100%;
            border: 2px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            background: white;
        }
        
        .current-image-item img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .current-image-item .remove-current {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(244, 67, 54, 0.9);
            color: white;
            border: none;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 16px;
            line-height: 1;
            z-index: 10;
            transition: all 0.3s;
        }
        
        .current-image-item .remove-current:hover {
            background: rgba(211, 47, 47, 1);
            transform: scale(1.1);
        }
        
        .upload-area { 
            border: 2px dashed #d9534f; 
            border-radius: 8px; 
            padding: 30px; 
            text-align: center; 
            background-color: #fef5f5; 
            cursor: pointer; 
            transition: all 0.3s; 
        }
        
        .upload-area:hover { 
            background-color: #ffe6e6; 
            border-color: #c9302c; 
        }
        
        .upload-area.dragover { 
            background-color: #ffe0e0;
            border-color: #c9302c; 
            transform: scale(1.02); 
        }
        
        .upload-icon { font-size: 48px; color: #d9534f; margin-bottom: 10px; }
        .upload-text { color: #666; margin-bottom: 5px; font-weight: 500; }
        .upload-hint { color: #999; font-size: 13px; }
        
        .image-preview-container { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); 
            gap: 15px; 
            margin-top: 15px; 
        }
        
        .preview-item { 
            position: relative; 
            width: 100%; 
            padding-bottom: 100%; 
            border: 2px solid #ddd; 
            border-radius: 8px; 
            overflow: hidden; 
            background-color: #f8f9fa; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
            transition: all 0.3s; 
        }
        
        .preview-item:hover { 
            transform: translateY(-4px); 
            box-shadow: 0 4px 12px rgba(0,0,0,0.15); 
        }
        
        .preview-item img { 
            position: absolute; 
            top: 0; 
            left: 0; 
            width: 100%; 
            height: 100%; 
            object-fit: cover; 
            display: block; 
        }
        
        .remove-btn { 
            position: absolute; 
            top: 8px; 
            right: 8px; 
            background: rgba(244, 67, 54, 0.9); 
            color: #fff; 
            border: none; 
            width: 28px; 
            height: 28px; 
            border-radius: 50%; 
            cursor: pointer; 
            font-size: 18px; 
            line-height: 1; 
            transition: all 0.3s; 
            z-index: 10; 
        }
        
        .remove-btn:hover { 
            background: rgba(200, 35, 51, 1); 
            transform: scale(1.1); 
        }
        
        .upload-limit { 
            text-align: center; 
            color: #666; 
            font-size: 13px; 
            margin-top: 10px; 
            font-weight: 500;
        }
        
        #photoInput { display: none; }
        
        .btn-container { 
            text-align: center; 
            margin-top: 30px; 
            display: flex; 
            gap: 15px; 
            justify-content: center; 
        }
        
        .btn-primary {
		    background: white;
		    border: 2px solid #66bb6a;
		    color: #66bb6a;
		    padding: 14px 40px;
		    border-radius: 8px;
		    font-size: 16px;
		    font-weight: 500;
		    cursor: pointer;
		    transition: all 0.3s;
		}
		
		.btn-primary:hover {
		    background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
		    color: white;
		    transform: translateY(-2px);
		    box-shadow: 0 4px 12px rgba(102, 187, 106, 0.4);
		}
		
		.btn-secondary {
		    background: white;
		    border: 2px solid #999;
		    color: #666;
		    padding: 14px 40px;
		    border-radius: 8px;
		    font-size: 16px;
		    font-weight: 500;
		    cursor: pointer;
		    transition: all 0.3s;
		}
		
		.btn-secondary:hover {
		    background: #f5f5f5;
		    border-color: #666;
		}
        
		 .back-button {
		 	background-color: white;
		    border: 2px solid #81c784;
		    color: #66bb6a;
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
    </style>
</head>
<body>
<%@ include file="menu.jsp" %>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-edit"></i> <%= "true".equals(isRelist) ? "編輯並重新上架" : "編輯書籍資訊" %></h1>
    </div>
</div>

<%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    String sql = "SELECT " +
                 "bl.listingId, bl.bookId, bl.sellerId, bl.price, bl.quantity, " +
                 "bl.condition, bl.photo, bl.remarks, bl.listedAt, bl.expiryDate, bl.isDelisted, " +
                 "b.title, b.author, b.ISBN, b.edition, b.createdAt AS publishDate, " +
                 "c.courseName, c.teacher, c.department " +
                 "FROM bookListings bl " +
                 "INNER JOIN books b ON bl.bookId = b.bookId " +
                 "LEFT JOIN book_course_relations bcr ON b.bookId = bcr.bookId " +
                 "LEFT JOIN courses c ON bcr.courseId = c.courseId " +
                 "WHERE bl.listingId = " + listingId + " AND bl.sellerId = '" + userId + "'";
    
    Statement smt = con.createStatement();
    ResultSet rs = smt.executeQuery(sql);
    
    if (!rs.next()) {
        response.sendRedirect("myListings.jsp");
        return;
    }
    
    // 取得現有資料
    String bookId = rs.getString("bookId");
    String title = rs.getString("title");
    String author = rs.getString("author");
    String price = rs.getString("price");
    String publishDate = rs.getString("publishDate");
    if (publishDate != null && publishDate.contains(" ")) {
        publishDate = publishDate.split(" ")[0];
    }
    String edition = rs.getString("edition");
    String ISBN = rs.getString("ISBN");
    String quantity = rs.getString("quantity");
    String condition = rs.getString("condition");
    String photoStr = rs.getString("photo");
    String remarks = rs.getString("remarks");
    String courseName = rs.getString("courseName");
    String teacher = rs.getString("teacher");
    String department = rs.getString("department");
    String expiryDateStr = rs.getString("expiryDate");
    Boolean isDelisted = rs.getBoolean("isDelisted");
    
    // 解析備註
    String contactInfo = "";
    String hasNotes = "";
    if (remarks != null && !remarks.trim().isEmpty()) {
        String[] remarksParts = remarks.split("\\|");
        for (String part : remarksParts) {
            part = part.trim();
            if (part.startsWith("聯絡方式:")) {
                contactInfo = part.substring("聯絡方式:".length()).trim();
            } else if (part.startsWith("筆記:")) {
                hasNotes = part.substring("筆記:".length()).trim();
            }
        }
    }
    
    // 處理圖片
    List<String> photoList = new ArrayList<>();
    if (photoStr != null && !photoStr.trim().isEmpty()) {
        String[] photoArray = photoStr.split(",");
        for (String photo : photoArray) {
            String trimmedPhoto = photo.trim();
            if (!trimmedPhoto.isEmpty()) {
                photoList.add(trimmedPhoto);
            }
        }
    }
    
    // 格式化下架日期時間為 datetime-local 格式
    String expiryDateLocal = "";
    if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
        try {
            SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat localFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = dbFormat.parse(expiryDateStr);
            expiryDateLocal = localFormat.format(date);
        } catch (Exception e) {
            expiryDateLocal = "";
        }
    }
    
    // 判斷所屬學院
    String selectedCollege = "";
    if (department != null) {
        if (department.contains("護理") || department.contains("助產") || department.contains("醫護") || department.contains("高齡")) {
            selectedCollege = "護理學院";
        } else if (department.contains("資訊") || department.contains("健康事業") || department.contains("長期照護") || 
                   department.contains("休閒") || department.contains("語言治療")) {
            selectedCollege = "健康科技學院";
        } else if (department.contains("嬰幼兒") || department.contains("運動") || department.contains("生死")) {
            selectedCollege = "人類發展與健康學院";
        } else if (department.contains("人工智慧") || department.contains("健康大數據")) {
            selectedCollege = "智慧健康照護跨領域學院";
        } else {
            selectedCollege = "通識教育中心";
        }
    }
    
    con.close();
%>

<div style="max-width: 900px; margin: 0 auto; padding: 0 20px;">
    <button class="back-button" onclick="window.location.href='listingDetail.jsp?listingId=<%= listingId %>'">
        <i class="fas fa-arrow-left"></i> 返回書籍詳情
    </button>
</div>

<div class="form-container">
    <% if ("true".equals(isRelist)) { %>
    <div class="warning-alert">
        <strong><i class="fas fa-info-circle"></i> 重新上架說明</strong><br>
        編輯完成並送出後，此書籍將自動重新上架並等待管理員審核。
    </div>
    <% } else { %>
    <div class="info-alert">
        <strong><i class="fas fa-info-circle"></i> 編輯提示</strong><br>
        修改資料後請記得按下「儲存變更」按鈕。
    </div>
    <% } %>

    <h3><i class="fas fa-book-open"></i> <%= "true".equals(isRelist) ? "編輯並重新上架書籍" : "編輯書籍資訊" %></h3>

    <form action="updateListing.jsp" method="post" enctype="multipart/form-data" id="editForm">
        <input type="hidden" name="listingId" value="<%= listingId %>">
        <input type="hidden" name="bookId" value="<%= bookId %>">
        <input type="hidden" name="sellerId" value="<%= userId %>">
        <input type="hidden" name="isRelist" value="<%= isRelist != null ? isRelist : "false" %>">
        <input type="hidden" name="existingPhotos" id="existingPhotos" value="<%= photoStr != null ? photoStr : "" %>">

        <!-- 書名 -->
        <div class="form-group">
            <label>書名：<span class="required">*</span></label>
            <input type="text" name="title" value="<%= title != null ? title : "" %>" required>
        </div>

        <!-- 作者 -->
        <div class="form-group">
            <label>作者：<span class="required">*</span></label>
            <input type="text" name="author" value="<%= author != null ? author : "" %>" required>
        </div>

        <!-- 價格 -->
        <div class="form-group">
            <label>價格：<span class="required">*</span></label>
            <input type="number" name="price" min="0" value="<%= price != null ? (int)Float.parseFloat(price) : "" %>" required>
        </div>

        <!-- 出版日期 -->
        <div class="form-group">
            <label>出版日期：<span class="required">*</span></label>
            <input type="date" name="publishDate" value="<%= publishDate != null ? publishDate : "" %>" required>
        </div>

        <!-- 書籍版本 -->
        <div class="form-group">
            <label>書籍版本：</label>
            <input type="text" name="edition" value="<%= edition != null ? edition : "" %>" placeholder="選填，例如：第三版">
        </div>

        <!-- ISBN -->
        <div class="form-group">
            <label>ISBN：</label>
            <input type="text" name="ISBN" value="<%= ISBN != null ? ISBN : "" %>" placeholder="選填">
        </div>
        
        <!-- 書籍照片 -->
        <div class="form-group" style="flex-direction: column; align-items: stretch;">
            <label style="width: 100%;">書籍照片：<span class="required">*</span></label>
            <div class="upload-section">
                <!-- 顯示現有圖片 -->
                <% if (!photoList.isEmpty()) { %>
                <div class="current-images" id="currentImagesContainer">
                    <% for (int i = 0; i < photoList.size(); i++) { 
                        String photoPath = photoList.get(i);
                        String displayPath = photoPath;
                        if (!photoPath.startsWith("assets/")) {
                            displayPath = "assets/images/member/" + photoPath;
                        }
                    %>
                    <div class="current-image-item" data-filename="<%= photoPath %>">
                        <img src="<%= displayPath %>" alt="現有圖片<%= (i+1) %>" onerror="this.src='assets/images/about.png'">
                        <button type="button" class="remove-current" onclick="removeCurrentImage(this, '<%= photoPath %>')">×</button>
                    </div>
                    <% } %>
                </div>
                <% } %>
                
                <div class="upload-area" id="uploadArea" onclick="document.getElementById('photoInput').click()">
                    <div class="upload-icon">📷</div>
                    <div class="upload-text">點擊或拖曳圖片到此處上傳新圖片</div>
                    <div class="upload-hint">支援 JPG、PNG、GIF 格式，最多總共 6 張圖片</div>
                    <div class="upload-hint">新上傳的圖片將加入到現有圖片中</div>
                </div>
                <input type="file" name="photo" id="photoInput" accept="image/*" multiple>
                <div class="image-preview-container" id="previewContainer"></div>
                <div class="upload-limit">
                    現有 <span id="existingCount"><%= photoList.size() %></span> 張 + 
                    新增 <span id="newCount">0</span> 張 = 
                    總共 <span id="totalCount"><%= photoList.size() %></span> / 6 張圖片
                </div>
            </div>
        </div>

        <!-- 偏好聯絡方式 -->
        <div class="form-group">
            <label>偏好聯絡方式：<span class="required">*</span></label>
            <input type="text" name="contact" value="<%= contactInfo != null ? contactInfo : "" %>" placeholder="例如：Line、Email、IG、FB" required>
        </div>

        <!-- 使用書籍系所 -->
        <div class="form-group">
            <label>使用書籍系所：<span class="required">*</span></label>
            <div style="flex: 1; display: flex; gap: 10px;">
                <select id="college" name="college" onchange="updateDepartment()" style="flex: 1;" required>
                    <option value="">請選擇學院</option>
                    <option value="護理學院" <%= "護理學院".equals(selectedCollege) ? "selected" : "" %>>護理學院</option>
                    <option value="健康科技學院" <%= "健康科技學院".equals(selectedCollege) ? "selected" : "" %>>健康科技學院</option>
                    <option value="人類發展與健康學院" <%= "人類發展與健康學院".equals(selectedCollege) ? "selected" : "" %>>人類發展與健康學院</option>
                    <option value="智慧健康照護跨領域學院" <%= "智慧健康照護跨領域學院".equals(selectedCollege) ? "selected" : "" %>>智慧健康照護跨領域學院</option>
                    <option value="通識教育中心" <%= "通識教育中心".equals(selectedCollege) ? "selected" : "" %>>通識教育中心</option>
                </select>
                <select id="department" name="department" style="flex: 1;" required>
                    <option value="<%= department != null ? department : "" %>"><%= department != null ? department : "請先選擇學院" %></option>
                </select>
            </div>
        </div>

        <!-- 授課老師 -->
        <div class="form-group">
            <label>授課老師：<span class="required">*</span></label>
            <input type="text" name="teacher" value="<%= teacher != null ? teacher : "" %>" required>
        </div>

        <!-- 使用課程 -->
        <div class="form-group">
            <label>使用課程：<span class="required">*</span></label>
            <input type="text" name="courseName" value="<%= courseName != null ? courseName : "" %>" required>
        </div>

        <!-- 下架日期時間 -->
        <div class="form-group">
            <label>下架日期時間：<span class="required">*</span></label>
            <input type="datetime-local" name="expiryDate" value="<%= expiryDateLocal %>" required>
        </div>
		
        <!-- 書籍狀況 -->
        <div class="form-group">
            <label>書籍狀況：<span class="required">*</span></label>
            <input type="text" name="condition" value="<%= condition != null ? condition : "" %>" placeholder="例如：全新、二手-近全新、二手-良好、二手-有使用痕跡" required>
        </div>

        <!-- 有無筆記 -->
        <div class="form-group">
            <label>有無筆記：<span class="required">*</span></label>
            <select name="remarks" required>
                <option value="">請選擇</option>
                <option value="有" <%= "有".equals(hasNotes) ? "selected" : "" %>>有</option>
                <option value="無" <%= "無".equals(hasNotes) ? "selected" : "" %>>無</option>
            </select>
        </div>

        <!-- 上架本數 -->
        <div class="form-group">
            <label>上架本數：<span class="required">*</span></label>
            <input type="number" name="quantity" value="<%= quantity != null ? quantity : "1" %>" min="1" step="1" required>
        </div>

        <div class="btn-container">
            <button type="submit" class="btn-primary">
                <i class="fas fa-save"></i> <%= "true".equals(isRelist) ? "儲存並重新上架" : "儲存變更" %>
            </button>
            <button type="button" class="btn-secondary" onclick="window.location.href='myListingDetail.jsp?listingId=<%= listingId %>'">
                <i class="fas fa-times"></i> 取消
            </button>
        </div>
    </form>
</div>

<script>
    const departmentOptions = {
        "護理學院": ["護理系所", "護理助產及婦女健康系所", "醫護教育暨數位學習系所", "高齡健康照護系所"],
        "健康科技學院": ["資訊管理系所", "健康事業管理系所", "長期照護系所", "休閒產業與健康促進系所", "語言治療與聽力學系所"],
        "人類發展與健康學院": ["嬰幼兒保育系所", "運動保健系所", "生死與健康心理諮商系所"],
        "智慧健康照護跨領域學院": ["人工智慧與健康大數據系所"],
        "通識教育中心": ["英文", "國文", "其他"]
    };
    
    const currentDepartment = "<%= department != null ? department : "" %>";
    
    function updateDepartment() {
        const college = document.getElementById("college").value;
        const deptSelect = document.getElementById("department");
        deptSelect.innerHTML = "<option value=''>請選擇系所</option>";
        
        if (college && departmentOptions[college]) {
            departmentOptions[college].forEach(dept => {
                const option = document.createElement("option");
                option.value = dept;
                option.textContent = dept;
                if (dept === currentDepartment) {
                    option.selected = true;
                }
                deptSelect.appendChild(option);
            });
        }
    }
    
    // 頁面載入時初始化系所選單
    window.addEventListener('load', function() {
        updateDepartment();
    });

    // 圖片管理
    const photoInput = document.getElementById('photoInput');
    const previewContainer = document.getElementById('previewContainer');
    const uploadArea = document.getElementById('uploadArea');
    const existingCountSpan = document.getElementById('existingCount');
    const newCountSpan = document.getElementById('newCount');
    const totalCountSpan = document.getElementById('totalCount');
    const existingPhotosInput = document.getElementById('existingPhotos');
    const MAX_IMAGES = 6;
    
    let selectedFiles = [];
    let existingPhotos = existingPhotosInput.value.split(',').filter(p => p.trim() !== '');
    
    function updateCounts() {
        const existingCount = existingPhotos.length;
        const newCount = selectedFiles.length;
        const totalCount = existingCount + newCount;
        
        existingCountSpan.textContent = existingCount;
        newCountSpan.textContent = newCount;
        totalCountSpan.textContent = totalCount;
        
        // 更新隱藏欄位
        existingPhotosInput.value = existingPhotos.join(',');
    }
    
    function removeCurrentImage(btn, filename) {
        if (confirm('確定要移除這張圖片嗎？')) {
            const item = btn.closest('.current-image-item');
            item.remove();
            
            // 從 existingPhotos 陣列中移除
            existingPhotos = existingPhotos.filter(p => p !== filename);
            updateCounts();
            
            // 檢查是否還有現有圖片
            const container = document.getElementById('currentImagesContainer');
            if (container && container.children.length === 0) {
                container.remove();
            }
        }
    }
    
    // 將函數設為全域以便 onclick 使用
    window.removeCurrentImage = removeCurrentImage;

    function updatePreview() {
        previewContainer.innerHTML = '';
        selectedFiles.forEach((file, index) => {
            const div = document.createElement('div');
            div.className = 'preview-item';
            div.innerHTML = `<img src="" alt="載入中..." style="display:none;"><button type="button" class="remove-btn" onclick="removeNewImage(${index})">×</button>`;
            previewContainer.appendChild(div);
            
            const reader = new FileReader();
            const img = div.querySelector('img');
            reader.onload = e => { 
                img.src = e.target.result; 
                img.style.display = 'block'; 
            };
            reader.onerror = () => { 
                img.alt = '載入失敗'; 
            };
            reader.readAsDataURL(file);
        });
        updateCounts();
    }

    function removeNewImage(index) {
        selectedFiles.splice(index, 1);
        updateFileInput();
        updatePreview();
    }
    
    window.removeNewImage = removeNewImage;

    function updateFileInput() {
        const dt = new DataTransfer();
        selectedFiles.forEach(file => dt.items.add(file));
        photoInput.files = dt.files;
    }

    photoInput.addEventListener('change', function() {
        const newFiles = Array.from(this.files);
        newFiles.forEach(file => {
            if (!file.type.startsWith('image/')) { 
                alert('請選擇圖片檔案！'); 
                return; 
            }
            const totalImages = existingPhotos.length + selectedFiles.length;
            if (totalImages >= MAX_IMAGES) { 
                alert(`最多只能上傳 ${MAX_IMAGES} 張圖片（包含現有圖片）！`); 
                return; 
            }
            selectedFiles.push(file);
        });
        updateFileInput();
        updatePreview();
    });

    uploadArea.addEventListener('dragover', e => { 
        e.preventDefault(); 
        uploadArea.classList.add('dragover'); 
    });
    
    uploadArea.addEventListener('dragleave', () => { 
        uploadArea.classList.remove('dragover'); 
    });
    
    uploadArea.addEventListener('drop', e => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        Array.from(e.dataTransfer.files).forEach(file => {
            const totalImages = existingPhotos.length + selectedFiles.length;
            if (file.type.startsWith('image/') && totalImages < MAX_IMAGES) {
                selectedFiles.push(file);
            }
        });
        updateFileInput();
        updatePreview();
    });

    document.getElementById('editForm').addEventListener('submit', function(e) {
        const totalImages = existingPhotos.length + selectedFiles.length;
        if (totalImages === 0) {
            e.preventDefault();
            alert('請至少保留或上傳一張圖片！');
            return false;
        }
        if (totalImages > MAX_IMAGES) {
            e.preventDefault();
            alert(`圖片總數不能超過 ${MAX_IMAGES} 張！`);
            return false;
        }
    });
    
    // 初始化計數
    updateCounts();
</script>

</body>
</html>