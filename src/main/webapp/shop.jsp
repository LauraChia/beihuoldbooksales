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
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        main {
            flex: 1; /* 🔹 讓主內容區塊撐開剩餘空間 */
        }

        .form-container {
            background-color: #fff;
            padding: 30px 40px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 120px auto 60px;
        }

        label { display: inline-block; width: 100px; margin-bottom: 10px; }
        input, textarea, select { width: calc(100% - 120px); margin-left: 5px; margin-bottom: 10px; padding: 5px; }
        .required { color: red; font-weight: bold; }

        footer, .container-fluid.bg-dark {
            margin-top: auto;
            width: 100%;
        }
    </style>
</head>

<body>
    <%@ include file="menu.jsp"%> 

    <main>
        <div class="form-container">
            <h3>📚 上架書籍</h3>
            <form action="shop_DBInsertInto.jsp" method="post" name="form" enctype="multipart/form-data">
                <label>書名：</label>
                <input type="text" name="titleBook" required><span class="required">*</span><br>

                <label>作者：</label>
                <input type="text" name="author" required><span class="required">*</span><br>

                <label>價格：</label>
                <input type="number" name="price" required><span class="required">*</span><br>

                <label>出版日期：</label>
                <input type="date" name="date" required><span class="required">*</span><br>

                <label>書籍照片：</label>
                <input type="file" name="photo" accept="image/*"><br>

                <label>聯絡方式：</label>
                <input type="text" name="contact" required><span class="required">*</span><br>

                <label>有無筆記：</label>
                <select name="remarks">
                    <option value="有">有</option>
                    <option value="無">無</option>
                </select><br>

                <label>書籍狀況：</label>
                <select name="condition" id="condition" onchange="toggleOtherCondition()" style="width: calc(50% - 65px); margin-right: 5px;">
                    <option value="全新">全新</option>
                    <option value="二手">二手</option>
                    <option value="三手以上">三手以上</option>
                    <option value="舊">舊</option>
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

                <div style="text-align:center; margin-top:15px;">
				    <input type="submit" class="btn btn-primary" value="送出">
				    <input type="reset" class="btn btn-secondary" value="修改">
				</div>
            </form>
        </div>
    </main>

    <!-- Footer Start -->
    <div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
        <div class="container py-5">
            <div class="row g-5">
                <div class="col-md-6 col-lg-3">
                    <h5 class="text-white mb-4">專題資訊</h5>
                    <p class="mb-2">題目：北護二手書拍賣系統</p>
                    <p class="mb-2">系所：健康事業管理系</p>
                </div>
                <div class="col-md-6 col-lg-3">
                    <h5 class="text-white mb-4">快速連結</h5>
                    <a class="btn btn-link" href="#">首頁</a>
                    <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
                </div>
            </div>
        </div>
        <div class="container-fluid text-center border-top border-secondary py-3">
            <p class="mb-0">&copy; 2025 二手書拍賣網. All Rights Reserved.</p>
        </div>
    </div>
    <!-- Footer End -->

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>