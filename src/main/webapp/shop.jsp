<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<%
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        out.println("<script>alert('請先登入才能上架書籍！'); window.location.href='login.jsp';</script>");
        return;
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>上架書籍 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { 
            background-color: #f8f9fa; 
            font-family: "Microsoft JhengHei", sans-serif; 
        }
        .form-container { 
            background:#fff; 
            padding:30px; 
            border-radius:8px; 
            max-width:900px; 
            margin:120px auto; 
            box-shadow:0 2px 8px rgba(0,0,0,0.08); 
        }
        .form-group {
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
        }
        label { 
            display:inline-block; 
            width:120px; 
            margin-bottom:10px; 
            vertical-align:top;
            font-weight: 500;
            padding-top: 6px;
        }
        input:not([type="file"]):not([type="submit"]):not([type="reset"]), 
        select, 
        textarea { 
            flex: 1;
            padding: 8px 12px; 
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        /* 圖片上傳區域樣式 */
        .upload-section {
            display: flex;
            flex-direction: column;
            gap: 15px;
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
        .upload-icon {
            font-size: 48px;
            color: #d9534f;
            margin-bottom: 10px;
        }
        .upload-text {
            color: #666;
            margin-bottom: 5px;
        }
        .upload-hint {
            color: #999;
            font-size: 13px;
        }
        
        /* 圖片預覽區域 */
        .image-preview-container { 
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        .preview-item { 
            position: relative; 
            width: 100%;
            padding-bottom: 100%; /* 1:1 比例 */
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
            background: rgba(220, 53, 69, 0.9); 
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
        }
        #photoInput {
            display: none;
        }
        .btn-container {
            text-align: center;
            margin-top: 30px;
            display: flex;
            gap: 15px;
            justify-content: center;
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp" %>

    <div class="form-container">
        <h3 style="margin-bottom: 30px;">📚 上架書籍</h3>
        
        <form action="shop_DBInsertInto.jsp" method="post" enctype="multipart/form-data" id="uploadForm">
            <div class="form-group">
                <label>書名：</label>
                <input type="text" name="titleBook" required>
            </div>

            <div class="form-group">
                <label>作者：</label>
                <input type="text" name="author" required>
            </div>

            <div class="form-group">
                <label>價格：</label>
                <input type="number" name="price" min="0" required>
            </div>

            <div class="form-group">
                <label>出版日期：</label>
                <input type="date" name="date" required>
            </div>

            <div class="form-group" style="flex-direction: column; align-items: stretch;">
                <label style="width: 100%;">書籍照片：</label>
                <div class="upload-section">
                    <div class="upload-area" id="uploadArea" onclick="document.getElementById('photoInput').click()">
                        <div class="upload-icon">📷</div>
                        <div class="upload-text">點擊或拖曳圖片到此處上傳</div>
                        <div class="upload-hint">支援 JPG、PNG、GIF 格式，最多上傳 6 張圖片</div>
                    </div>
                    <input type="file" name="photo" id="photoInput" accept="image/*" multiple>
                    <div class="image-preview-container" id="previewContainer"></div>
                    <div class="upload-limit">已選擇 <span id="imageCount">0</span> / 6 張圖片</div>
                </div>
            </div>

            <div class="form-group">
                <label>聯絡方式：</label>
                <input type="text" name="contact" placeholder="例如：Line ID、Email、手機號碼" required>
            </div>

            <div class="form-group">
                <label>有無筆記：</label>
                <select name="remarks">
                    <option value="有">有</option>
                    <option value="無">無</option>
                </select>
            </div>

            <div class="form-group">
                <label>書籍狀況：</label>
                <div style="flex: 1; display: flex; gap: 10px;">
                    <select name="condition" id="condition" onchange="toggleOtherCondition()" style="flex: 1;">
                        <option value="全新">全新</option>
                        <option value="二手">二手</option>
                        <option value="三手以上">三手以上</option>
                        <option value="其他">其他</option>
                    </select>
                    <input type="text" id="otherConditionInput" name="otherCondition"
                           placeholder="請輸入書況說明"
                           style="display:none; flex: 1;" />
                </div>
            </div>

            <div class="form-group">
                <label>系所：</label>
                <div style="flex: 1; display: flex; gap: 10px;">
                    <select id="college" onchange="updateDepartment()" style="flex: 1;">
                        <option value="">請選擇學院</option>
                        <option value="護理學院">護理學院</option>
                        <option value="健康科技學院">健康科技學院</option>
                        <option value="人類發展與健康學院">人類發展與健康學院</option>
                        <option value="智慧健康照護跨領域學院">智慧健康照護跨領域學院</option>
                        <option value="通識教育中心">通識教育中心</option>
                    </select>
                    <select id="department" name="department" style="flex: 1;">
                        <option value="">請先選擇學院</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label>ISBN：</label>
                <input type="text" name="ISBN" placeholder="選填">
            </div>

            <input type="hidden" name="username" value="<%= username %>">
            <input type="hidden" name="userId" value="<%= userId %>">

            <div class="btn-container">
                <button type="submit" class="btn btn-primary btn-lg" style="min-width: 150px;">送出上架</button>
                <button type="reset" class="btn btn-secondary btn-lg" id="resetBtn" style="min-width: 150px;">清除重填</button>
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

        function toggleOtherCondition() {
            const conditionSelect = document.getElementById("condition");
            const otherInput = document.getElementById("otherConditionInput");
            if (conditionSelect.value === "其他") {
                otherInput.style.display = "inline-block";
                otherInput.required = true;
            } else {
                otherInput.style.display = "none";
                otherInput.required = false;
                otherInput.value = "";
            }
        }

        // 圖片上傳處理
        const photoInput = document.getElementById('photoInput');
        const previewContainer = document.getElementById('previewContainer');
        const uploadArea = document.getElementById('uploadArea');
        const imageCountSpan = document.getElementById('imageCount');
        const MAX_IMAGES = 6;
        let selectedFiles = [];

        // 更新預覽
        function updatePreview() {
            previewContainer.innerHTML = '';
            imageCountSpan.textContent = selectedFiles.length;

         // 為每個文件創建預覽
            selectedFiles.forEach((file, index) => {
                // 創建預覽元素容器
                const div = document.createElement('div');
                div.className = 'preview-item';
                
                // 先添加佔位內容
                div.innerHTML = `
                    <img src="" alt="載入中..." style="display:none;">
                    <button type="button" class="remove-btn" onclick="removeImage(${index})">×</button>
                `;
                
                // 立即添加到容器中
                previewContainer.appendChild(div);
                
                // 讀取圖片
                const reader = new FileReader();
                const img = div.querySelector('img');
                
                reader.onload = function(e) {
                    img.src = e.target.result;
                    img.style.display = 'block';
                };
                
                reader.onerror = function() {
                    console.error('讀取圖片失敗:', file.name);
                    img.alt = '載入失敗';
                };
                
                reader.readAsDataURL(file);
            });
        }

        // 移除圖片
        function removeImage(index) {
            selectedFiles.splice(index, 1);
            updateFileInput();
            updatePreview();
        }

        // 更新 file input
        function updateFileInput() {
            const dt = new DataTransfer();
            selectedFiles.forEach(file => dt.items.add(file));
            photoInput.files = dt.files;
        }

        // 檔案選擇事件
        photoInput.addEventListener('change', function() {
            const newFiles = Array.from(this.files);
            
            newFiles.forEach(file => {
                if (!file.type.startsWith('image/')) {
                    alert('請選擇圖片檔案！');
                    return;
                }
                if (selectedFiles.length >= MAX_IMAGES) {
                    alert(`最多只能上傳 ${MAX_IMAGES} 張圖片！`);
                    return;
                }
                selectedFiles.push(file);
            });

            updateFileInput();
            updatePreview();
        });

        // 拖曳上傳
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            
            const files = Array.from(e.dataTransfer.files);
            files.forEach(file => {
                if (file.type.startsWith('image/') && selectedFiles.length < MAX_IMAGES) {
                    selectedFiles.push(file);
                }
            });
            
            updateFileInput();
            updatePreview();
        });

        // 表單重置
        document.getElementById('resetBtn').addEventListener('click', function() {
            setTimeout(() => {
                selectedFiles = [];
                previewContainer.innerHTML = '';
                imageCountSpan.textContent = '0';
            }, 10);
        });

        // 表單提交驗證
        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            if (selectedFiles.length === 0) {
                if (!confirm('您尚未上傳任何圖片，確定要繼續嗎？')) {
                    e.preventDefault();
                }
            }
        });
    </script>
    <!-- Footer Start -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目：北護二手書拍賣系統</p>
                <p class="mb-2">系所：健康事業管理系</p>
                <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8" target="_blank" rel="noopener noreferrer">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025年 國北護二手書拍賣網. @All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->
</body>
</html>