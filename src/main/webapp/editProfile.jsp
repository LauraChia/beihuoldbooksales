<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userId = (String) session.getAttribute("userId");
    String username = "";
    String name = "";
    String department = "";
    String password = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "SELECT username, name, department, password FROM users WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, userId);
        rs = ps.executeQuery();

        if (rs.next()) {
            username = rs.getString("username");
            name = rs.getString("name");
            department = rs.getString("department");
            password = rs.getString("password");
        }

        // ✅ 避免顯示 null
        if (name == null) name = "";
        if (department == null) department = "";
        if (password == null) password = "";
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }

    // 判斷現有的聯絡方式是預設選項還是自訂的
    String contactType = "";
    String customContact = "";
    
    
    // 根據系所判斷所屬學院
    String selectedCollege = "";
    if (!department.isEmpty()) {
        if (department.contains("護理系所") || department.contains("護理助產及婦女健康系所") || 
            department.contains("醫護教育暨數位學習系所") || department.contains("高齡健康照護系所")) {
            selectedCollege = "護理學院";
        } else if (department.contains("資訊管理系所") || department.contains("健康事業管理系所") || 
                   department.contains("長期照護系所") || department.contains("休閒產業與健康促進系所") || 
                   department.contains("語言治療與聽力學系所")) {
            selectedCollege = "健康科技學院";
        } else if (department.contains("嬰幼兒保育系所") || department.contains("運動保健系所") || 
                   department.contains("生死與健康心理諮商系所")) {
            selectedCollege = "人類發展與健康學院";
        } else if (department.contains("人工智慧與健康大數據系所")) {
            selectedCollege = "智慧健康照護跨領域學院";
        } else if (department.contains("英文") || department.contains("國文") || department.contains("其他")) {
            selectedCollege = "通識教育中心";
        }
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>編輯個人資料 - 北護二手書拍賣網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <%@ include file="menu.jsp" %>

    <div class="container mt-5 pt-5">
        <div class="card p-4 shadow-sm">
            <h4 class="mb-4">編輯個人資料</h4>

            <form method="post" action="updateProfile.jsp">
                <div class="mb-3">
                    <label class="form-label">帳號</label>
                    <input type="text" class="form-control" value="<%= username %>" readonly>
                </div>

                <div class="mb-3">
                    <label class="form-label">暱稱 <span class="text-danger">*</span></label>
                    <input type="text" name="name" class="form-control" value="<%= name %>">
                </div>

                <div class="mb-3">
                    <label class="form-label">聯絡方式 <span class="text-danger">*</span></label>
                    <select name="contactType" id="contactType" class="form-select" onchange="toggleCustomContact()">
                        <option value="">請選擇</option>
                        <option value="LINE" <%= contactType.equals("LINE") ? "selected" : "" %>>LINE</option>
                        <option value="IG" <%= contactType.equals("IG") ? "selected" : "" %>>IG</option>
                        <option value="FB" <%= contactType.equals("FB") ? "selected" : "" %>>FB</option>
                        <option value="其他" <%= contactType.equals("其他") ? "selected" : "" %>>其他</option>
                    </select>
                </div>

                <div class="mb-3" id="customContactDiv" style="display: <%= contactType.equals("其他") ? "block" : "none" %>;">
                    <label class="form-label">請輸入聯絡方式 <span class="text-danger">*</span></label>
                    <input type="text" name="customContact" id="customContact" class="form-control" 
                           placeholder="例如:電話、Email等" value="<%= customContact %>">
                </div>

                <!-- 隱藏欄位,用來傳送最終的 contact 值 -->
                <input type="hidden" name="contact" id="finalContact">
                

                <div class="mb-3">
                    <label for="college" class="form-label">就讀系所 <span class="text-danger">*</span></label>
                    <div class="department-row">
                        <select class="form-select" id="college" onchange="updateDepartment()" required>
                            <option value="">請選擇學院</option>
                            <option value="護理學院" <%= selectedCollege.equals("護理學院") ? "selected" : "" %>>護理學院</option>
                            <option value="健康科技學院" <%= selectedCollege.equals("健康科技學院") ? "selected" : "" %>>健康科技學院</option>
                            <option value="人類發展與健康學院" <%= selectedCollege.equals("人類發展與健康學院") ? "selected" : "" %>>人類發展與健康學院</option>
                            <option value="智慧健康照護跨領域學院" <%= selectedCollege.equals("智慧健康照護跨領域學院") ? "selected" : "" %>>智慧健康照護跨領域學院</option>
                        </select>
                        <select class="form-select" id="department" name="department" required>
                            <option value="">請先選擇學院</option>
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label">密碼 <span class="text-danger">*</span></label>
                    <input type="password" name="password" class="form-control" value="<%= password %>">
                </div>

                <button type="submit" class="btn btn-success" onclick="return prepareSubmit()">儲存變更</button>
                <a href="profile.jsp" class="btn btn-secondary ms-2">返回</a>
            </form>
        </div>
    </div>

<!-- Footer Start -->
<div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">專題資訊</h5>
                <p class="mb-2">題目:北護二手書拍賣系統</p>
                <p class="mb-2">系所:健康事業管理系</p>
            </div>
            <div class="col-md-6 col-lg-3">
                <h5 class="text-white mb-4">快速連結</h5>
                <a class="btn btn-link" href="index.jsp">首頁</a>
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
<script>
    // 系所選項資料
    const departmentOptions = {
        "護理學院": ["護理系所", "護理助產及婦女健康系所", "醫護教育暨數位學習系所", "高齡健康照護系所"],
        "健康科技學院": ["資訊管理系所", "健康事業管理系所", "長期照護系所", "休閒產業與健康促進系所", "語言治療與聽力學系所"],
        "人類發展與健康學院": ["嬰幼兒保育系所", "運動保健系所", "生死與健康心理諮商系所"],
        "智慧健康照護跨領域學院": ["人工智慧與健康大數據系所"],
        "通識教育中心": ["英文", "國文", "其他"]
    };

    // 儲存原本的系所值
    const originalDepartment = "<%= department %>";
    const selectedCollege = "<%= selectedCollege %>";

    // 頁面載入時初始化系所選單
    window.addEventListener('DOMContentLoaded', function() {
        if (selectedCollege) {
            updateDepartment();
            // 設定原本的系所選項
            if (originalDepartment) {
                document.getElementById("department").value = originalDepartment;
            }
        }
    });

    // 更新系所選單
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

    // 切換是否顯示自訂聯絡方式輸入框
    function toggleCustomContact() {
        var contactType = document.getElementById('contactType').value;
        var customDiv = document.getElementById('customContactDiv');
        
        if (contactType === '其他') {
            customDiv.style.display = 'block';
        } else {
            customDiv.style.display = 'none';
            document.getElementById('customContact').value = '';
        }
    }

    // 提交前準備最終的 contact 值
    function prepareSubmit() {
        var contactType = document.getElementById('contactType').value;
        var finalContact = document.getElementById('finalContact');
        
        if (contactType === '其他') {
            var customContact = document.getElementById('customContact').value.trim();
            if (customContact === '') {
                alert('請輸入自訂的聯絡方式');
                return false;
            }
            finalContact.value = customContact;
        } else {
            finalContact.value = contactType;
        }
        
        return true;
    }
</script>
</body>
</html>