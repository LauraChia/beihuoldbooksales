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
    <title>上架書籍 - 二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: "Microsoft JhengHei", sans-serif; }
        .form-container { background:#fff; padding:30px; border-radius:8px; max-width:800px; margin:120px auto; box-shadow:0 2px 8px rgba(0,0,0,0.08); }
        label { display:inline-block; width:100px; margin-bottom:10px; vertical-align:top; }
        input, select, textarea { width:calc(100% - 120px); padding:6px; margin-bottom:10px; }
        .image-preview-container { display:flex; flex-wrap:wrap; gap:10px; margin-left:105px; margin-bottom:10px; }
        .preview-item { position:relative; width:120px; height:120px; border:2px solid #ddd; border-radius:5px; overflow:hidden; }
        .preview-item img { width:100%; height:100%; object-fit:cover; display:block; }
        .remove-btn { position:absolute; top:4px; right:4px; background:rgba(255,0,0,0.85); color:#fff; border:none; width:22px; height:22px; border-radius:50%; cursor:pointer; }
    </style>
</head>
<body>
    <%@ include file="menu.jsp" %>

    <div class="form-container">
        <h3>📚 上架書籍</h3>
        <!-- name="photo" 並支援 multiple -->
        <form action="shop_DBInsertInto.jsp" method="post" enctype="multipart/form-data">
            <label>書名：</label>
            <input type="text" name="titleBook" required><br>

            <label>作者：</label>
            <input type="text" name="author" required><br>

            <label>價格：</label>
            <input type="number" name="price" required><br>

            <label>出版日期：</label>
            <input type="date" name="date" required><br>

            <label>書籍照片：</label>
            <input type="file" name="photo" id="photoInput" accept="image/*" multiple>
            <div class="image-preview-container" id="previewContainer"></div>

            <label>聯絡方式：</label>
            <input type="text" name="contact" required><br>

            <label>有無筆記：</label>
            <select name="remarks">
                <option value="有">有</option><option value="無">無</option>
            </select><br>

            <label>書籍狀況：</label>
             <select name="condition" id="condition" onchange="toggleOtherCondition()" style="width: calc(50% - 65px); margin-right: 5px;">
                <option value="全新">全新</option><option 
                <option value="二手">二手</option>
               <option value="三手以上">三手以上</option>  
               value="舊">舊</option>
            
    
 <option value="其他">其他</option>
                </select>
                <input type="text" id="otherConditionInput" name="otherCondition"
                       placeholder="請輸入書況說明"
                       style="display:none; width: calc(50% - 65px); margin-left: 0; padding: 5px;" /><br>
			
			<script>
			function toggleOtherCondition() {
			    const conditionSelect = document.getElementById("condition");
			    const otherInput = document.getElementById("otherConditionInput");
			    if (conditionSelect.value === "其他") {
			        otherInput.style.display = "inline-block";
			    } else {
			        otherInput.style.display = "none";
			        otherInput.value = "";
			    }
			}
			</script>
			
            <label>系所：</label>
            <select id="college" onchange="updateDepartment()" style="width: calc(50% - 65px); margin-right: 5px;">
                    <option value="">請選擇學院</option>
                    <option value="護理學院">護理學院</option>
                    <option value="健康科技學院">健康科技學院</option>
                    <option value="人類發展與健康學院">人類發展與健康學院</option>
                    <option value="智慧健康照護跨領域學院">智慧健康照護跨領域學院</option>
                    <option value="通識教育中心">通識教育中心</option>
                </select>
                <select id="department" name="department" style="width: calc(50% - 65px); margin-left: 0;">
                    <option value="">請先選擇學院</option>
                </select><br>
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
				</script>
				
				<label>ISBN：</label>
				<input type="text" name="ISBN"><br>
            <input type="hidden" name="username" value="<%= username %>">
            <input type="hidden" name="userId" value="<%= userId %>">

            <div style="text-align:center; margin-top:12px;">
                <input type="submit" class="btn btn-primary" value="送出">
                <input type="reset" class="btn btn-secondary" value="清除" id="resetBtn">
            </div>
        </form>
    </div>

    <script>
        const photoInput = document.getElementById('photoInput');
        const previewContainer = document.getElementById('previewContainer');
        photoInput.addEventListener('change', function(){
            previewContainer.innerHTML = '';
            Array.from(this.files).forEach((file, idx) => {
                if (!file.type.startsWith('image/')) return;
                const reader = new FileReader();
                reader.onload = function(e){
                    const div = document.createElement('div');
                    div.className = 'preview-item';
                    div.innerHTML = `<img src="${e.target.result}" alt="preview"><button type="button" class="remove-btn">×</button>`;
                    previewContainer.appendChild(div);
                    // remove-only-from-preview (note: cannot remove file from input.files easily)
                    div.querySelector('.remove-btn').addEventListener('click', function(){
                        div.remove();
                        // Note: cannot remove file from input.files with plain file input in all browsers.
                        // If user removes previews and still wants to prevent upload, they can reset the form then reselect files.
                    });
                };
                reader.readAsDataURL(file);
            });
        });

        // reset preview when form reset
        document.getElementById('resetBtn').addEventListener('click', function(){
            setTimeout(()=> previewContainer.innerHTML = '', 10);
        });
    </script>
</body>
</html>
