<%@page contentType="text/html" pageEncoding="utf-8"%>  
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>

<%
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        out.println("<script>alert('請先登入才能上架書籍！'); window.location.href='login.jsp';</script>");
        return;
    }
    
    // 取得今天的日期
    String todayDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>上架書籍 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: "Microsoft JhengHei", sans-serif; }
        
        .page-header {
            background: linear-gradient(135deg, #66bb6a 0%, #66bb6a 100%);
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
    </style>
</head>
<body>
<%@ include file="menu.jsp" %>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-upload"></i> 上架書籍</h1>
    </div>
</div>

<div class="form-container">
    <div class="info-alert">
        <strong><i class="fas fa-info-circle"></i> 上架須知</strong><br>
        請詳細填寫書籍資訊，上架後將由管理員審核。審核通過後即可開始販售。
    </div>

    <form action="shop_DBInsertInto.jsp" method="post" enctype="multipart/form-data" id="uploadForm">

        <!-- 書名 -->
        <div class="form-group">
            <label>書名：<span class="required">*</span></label>
            <input type="text" name="title" required>
        </div>

        <!-- 作者 -->
        <div class="form-group">
            <label>作者：<span class="required">*</span></label>
            <input type="text" name="author" required>
        </div>

        <!-- 價格 -->
        <div class="form-group">
            <label>價格：<span class="required">*</span></label>
            <input type="number" name="price" min="0" required>
        </div>

        <!-- 出版日期 -->
        <div class="form-group">
            <label>出版日期：<span class="required">*</span></label>
            <input type="date" name="publishDate" required>
        </div>

        <!-- 書籍版本 -->
        <div class="form-group">
            <label>書籍版本：</label>
            <input type="text" name="edition" placeholder="選填，例如：第三版">
        </div>

        <!-- ISBN -->
        <div class="form-group">
            <label>ISBN：</label>
            <input type="text" name="ISBN" placeholder="選填">
        </div>
        
        <!-- 書籍照片 -->
        <div class="form-group" style="flex-direction: column; align-items: stretch;">
            <label style="width: 100%;">書籍照片：<span class="required">*</span></label>
            <div class="upload-section">
                <div class="upload-area" id="uploadArea" onclick="document.getElementById('photoInput').click()">
                    <div class="upload-icon">📷</div>
                    <div class="upload-text">點擊或拖曳圖片到此處上傳</div>
                    <div class="upload-hint">支援 JPG、PNG、GIF 格式，最多上傳 6 張圖片</div>
                    <div class="upload-hint">請上傳書籍的：正面、反面、側面</div>
                </div>
                <input type="file" name="photo" id="photoInput" accept="image/*" multiple required>
                <div class="image-preview-container" id="previewContainer"></div>
                <div class="upload-limit">已選擇 <span id="imageCount">0</span> / 6 張圖片</div>
            </div>
        </div>

        <!-- 使用書籍系所 -->
        <div class="form-group">
            <label>使用書籍系所：<span class="required">*</span></label>
            <div style="flex: 1; display: flex; gap: 10px;">
                <select id="college" name="college" onchange="updateDepartment()" style="flex: 1;" required>
                    <option value="">請選擇學院</option>
                    <option value="護理學院">護理學院</option>
                    <option value="健康科技學院">健康科技學院</option>
                    <option value="人類發展與健康學院">人類發展與健康學院</option>
                    <option value="智慧健康照護跨領域學院">智慧健康照護跨領域學院</option>
                    <option value="通識教育中心">通識教育中心</option>
                </select>
                <select id="department" name="department" style="flex: 1;" required>
                    <option value="">請先選擇學院</option>
                </select>
            </div>
        </div>

        <!-- 授課老師 -->
        <div class="form-group">
            <label>授課老師：<span class="required">*</span></label>
            <input type="text" name="teacher" required>
        </div>

        <!-- 使用課程 -->
        <div class="form-group">
            <label>使用課程：<span class="required">*</span></label>
            <input type="text" name="courseName" required>
        </div>

        <!-- 上架日期 (隱藏欄位，自動設定為今天) -->
        <input type="hidden" name="listedAt" value="<%= todayDate %>">

        <!-- 下架日期 -->
        <div class="form-group">
		    <label>下架日期：<span class="required">*</span></label>
		    <input type="date" name="expiryDate" required>
		</div>
		
        <!-- 書籍狀況 -->
        <div class="form-group">
            <label>書籍狀況：<span class="required">*</span></label>
            <input type="text" name="condition" placeholder="例如：全新、二手-近全新、二手-良好、二手-有使用痕跡" required>
        </div>

        <!-- 有無筆記 -->
        <div class="form-group">
            <label>有無筆記：<span class="required">*</span></label>
            <select name="remarks" required>
                <option value="">請選擇</option>
                <option value="有">有</option>
                <option value="無">無</option>
            </select>
        </div>

        <!-- 上架本數 -->
        <div class="form-group">
            <label>上架本數：<span class="required">*</span></label>
            <input type="number" name="quantity" value="1" min="1" step="1" required>
        </div>

        <input type="hidden" name="username" value="<%= username %>">
        <input type="hidden" name="sellerId" value="<%= userId %>">

        <div class="btn-container">
            <button type="submit" class="btn-primary">
                <i class="fas fa-check"></i> 送出上架
            </button>
            <button type="reset" class="btn-secondary" id="resetBtn">
                <i class="fas fa-redo"></i> 清除重填
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
    
    function updateDepartment() {
        const college = document.getElementById("college").value;
        const deptSelect = document.getElementById("department");
        deptSelect.innerHTML = "<option value=''>請選擇系所</option>";
        if (college && departmentOptions[college]) {
            departmentOptions[college].forEach(dept => {
                const option = document.createElement("option");
                option.value = dept;
                option.textContent = dept;
                deptSelect.appendChild(option);
            });
        }
    }

    // 多圖片上傳處理
    const photoInput = document.getElementById('photoInput');
    const previewContainer = document.getElementById('previewContainer');
    const uploadArea = document.getElementById('uploadArea');
    const imageCountSpan = document.getElementById('imageCount');
    const MAX_IMAGES = 6;
    let selectedFiles = [];

    function updatePreview() {
        previewContainer.innerHTML = '';
        imageCountSpan.textContent = selectedFiles.length;
        selectedFiles.forEach((file, index) => {
            const div = document.createElement('div');
            div.className = 'preview-item';
            div.innerHTML = `<img src="" alt="載入中..." style="display:none;"><button type="button" class="remove-btn" onclick="removeImage(${index})">×</button>`;
            previewContainer.appendChild(div);
            const reader = new FileReader();
            const img = div.querySelector('img');
            reader.onload = e => { img.src = e.target.result; img.style.display = 'block'; };
            reader.onerror = () => { img.alt = '載入失敗'; };
            reader.readAsDataURL(file);
        });
    }

    function removeImage(index) {
        selectedFiles.splice(index, 1);
        updateFileInput();
        updatePreview();
    }

    function updateFileInput() {
        const dt = new DataTransfer();
        selectedFiles.forEach(file => dt.items.add(file));
        photoInput.files = dt.files;
    }

    photoInput.addEventListener('change', function() {
        const newFiles = Array.from(this.files);
        newFiles.forEach(file => {
            if (!file.type.startsWith('image/')) { alert('請選擇圖片檔案！'); return; }
            if (selectedFiles.length >= MAX_IMAGES) { alert(`最多只能上傳 ${MAX_IMAGES} 張圖片！`); return; }
            selectedFiles.push(file);
        });
        updateFileInput();
        updatePreview();
    });

    uploadArea.addEventListener('dragover', e => { e.preventDefault(); uploadArea.classList.add('dragover'); });
    uploadArea.addEventListener('dragleave', () => { uploadArea.classList.remove('dragover'); });
    uploadArea.addEventListener('drop', e => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        Array.from(e.dataTransfer.files).forEach(file => {
            if (file.type.startsWith('image/') && selectedFiles.length < MAX_IMAGES) selectedFiles.push(file);
        });
        updateFileInput();
        updatePreview();
    });

    document.getElementById('resetBtn').addEventListener('click', function() {
        setTimeout(() => { selectedFiles = []; previewContainer.innerHTML = ''; imageCountSpan.textContent = '0'; }, 10);
    });

    document.getElementById('uploadForm').addEventListener('submit', function(e) {
        if (selectedFiles.length === 0 && !confirm('您尚未上傳任何圖片,確定要繼續嗎?')) e.preventDefault();
    });
</script>

<%@ include file="footer.jsp"%>

</body>
