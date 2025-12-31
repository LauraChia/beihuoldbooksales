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
    <title>編輯個人資料 - 二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body { 
            background-color: #f8f9fa; 
            font-family: "Microsoft JhengHei", sans-serif; 
        }
        
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
            background: #fff; 
            padding: 40px; 
            border-radius: 12px; 
            max-width: 900px; 
            margin: 0 auto 40px; 
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
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
            display: inline-block; 
            width: 140px; 
            margin-bottom: 10px; 
            vertical-align: top; 
            font-weight: 500; 
            padding-top: 6px;
            color: #333;
        }
        
        label .required { 
            color: red; 
            margin-left: 2px; 
        }
        
        input:not([type="submit"]):not([type="reset"]):not([type="checkbox"]), select, textarea { 
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
        
        input[readonly] {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }
        
        .department-row {
            display: flex;
            gap: 10px;
            flex: 1;
        }
        
        .department-row select {
            flex: 1;
        }
        
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
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-secondary:hover {
            background: #f5f5f5;
            border-color: #666;
            text-decoration: none;
            color: #666;
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
        
        @media (max-width: 768px) {
            .form-group {
                flex-direction: column;
            }
            
            label {
                width: 100%;
                padding-top: 0;
                margin-bottom: 8px;
            }
            
            .department-row {
                flex-direction: column;
            }
            
            .btn-container {
                flex-direction: column;
            }
            
            .btn-primary, .btn-secondary {
                width: 100%;
            }
        }
    </style>
</head>

<body>
<%@ include file="menu.jsp" %>

<div class="page-header">
    <div class="container">
        <h1><i class="fas fa-user-edit"></i> 編輯個人資料</h1>
    </div>
</div>

<div style="max-width: 900px; margin: 0 auto; padding: 0 20px;">
    <button class="back-button" onclick="window.location.href='profile.jsp'">
        <i class="fas fa-arrow-left"></i> 返回個人資料
    </button>
</div>

<div class="form-container">
    <div class="info-alert">
        <strong><i class="fas fa-info-circle"></i> 編輯說明</strong><br>
        請填寫完整資訊，標有 <span style="color: red;">*</span> 為必填欄位。
    </div>

    <form method="post" action="updateProfile.jsp" id="profileForm">
        <!-- 帳號 (唯讀) -->
        <div class="form-group">
            <label>帳號：</label>
            <input type="text" value="<%= username %>" readonly>
        </div>

        <!-- 暱稱 -->
        <div class="form-group">
            <label>暱稱：<span class="required">*</span></label>
            <input type="text" name="name" value="<%= name %>" required>
        </div>

        <!-- 就讀系所 -->
        <div class="form-group">
            <label>就讀系所：<span class="required">*</span></label>
            <div class="department-row">
                <select id="college" onchange="updateDepartment()" required>
                    <option value="">請選擇學院</option>
                    <option value="護理學院" <%= selectedCollege.equals("護理學院") ? "selected" : "" %>>護理學院</option>
                    <option value="健康科技學院" <%= selectedCollege.equals("健康科技學院") ? "selected" : "" %>>健康科技學院</option>
                    <option value="人類發展與健康學院" <%= selectedCollege.equals("人類發展與健康學院") ? "selected" : "" %>>人類發展與健康學院</option>
                    <option value="智慧健康照護跨領域學院" <%= selectedCollege.equals("智慧健康照護跨領域學院") ? "selected" : "" %>>智慧健康照護跨領域學院</option>
                    <option value="通識教育中心" <%= selectedCollege.equals("通識教育中心") ? "selected" : "" %>>通識教育中心</option>
                </select>
                <select id="department" name="department" required>
                    <option value="">請先選擇學院</option>
                </select>
            </div>
        </div>

        <!-- 密碼 -->
        <div class="form-group">
            <label>密碼：<span class="required">*</span></label>
            <input type="password" name="password" value="<%= password %>" required>
        </div>

        <div class="btn-container">
            <button type="submit" class="btn-primary" onclick="return prepareSubmit()">
                <i class="fas fa-save"></i> 儲存變更
            </button>
            <a href="profile.jsp" class="btn-secondary">
                <i class="fas fa-times"></i> 取消
            </a>
        </div>
    </form>
</div>

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
                if (dept === originalDepartment) {
                    option.selected = true;
                }
                deptSelect.appendChild(option);
            });
        }
    }

    // 切換是否顯示自訂聯絡方式輸入框
    function toggleCustomContact() {
        var contactType = document.getElementById('contactType').value;
        var customDiv = document.getElementById('customContactDiv');
        
        if (contactType === '其他') {
            customDiv.style.display = 'flex';
        } else {
            customDiv.style.display = 'none';
            document.getElementById('customContact').value = '';
        }
    }
</script>

<%@ include file="footer.jsp"%>

</body>
</html>