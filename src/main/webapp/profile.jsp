<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // ✅ 修正：統一使用 "userId"
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userAccessId = (String) session.getAttribute("userId");
    String username = "";
    String name = "";
    String contact = "";
    String department = "";
    String lastLogin = "";
    String lastLogout = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "SELECT username, name, contact, department, lastLogin, lastLogout FROM users WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, userAccessId);
        rs = ps.executeQuery();

        if (rs.next()) {
            username = rs.getString("username");
            name = rs.getString("name");
            contact = rs.getString("contact");
            department = rs.getString("department");
            
            // ✅ 修正：正確取得 lastLogin 和 lastLogout
            Timestamp loginTimestamp = rs.getTimestamp("lastLogin");
            Timestamp logoutTimestamp = rs.getTimestamp("lastLogout");
            
            // 格式化時間顯示
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            lastLogin = (loginTimestamp != null) ? sdf.format(loginTimestamp) : "尚未登入";
            lastLogout = (logoutTimestamp != null) ? sdf.format(logoutTimestamp) : "尚未登出";

            // ✅ 避免 null 顯示
            if (username == null) username = "";
            if (name == null) name = "";
            if (contact == null) contact = "";
            if (department == null) department = "";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>個人資料 - 北護二手書交易網</title>
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
        
        .info-group { 
            margin-bottom: 20px; 
            display: flex; 
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .info-group:last-child {
            border-bottom: none;
        }
        
        .info-label { 
            display: inline-block; 
            width: 140px; 
            font-weight: 500; 
            color: #555;
            flex-shrink: 0;
        }
        
        .info-value {
            flex: 1;
            color: #333;
            font-size: 15px;
        }
        
        .info-value.empty {
            color: #999;
            font-style: italic;
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
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 187, 106, 0.4);
            text-decoration: none;
        }
        
        .profile-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: white;
            font-size: 36px;
        }
        
        .user-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e8f5e9;
        }
        
        .user-header h3 {
            border: none;
            margin: 10px 0 5px;
            padding: 0;
        }
        
        .user-header .username {
            color: #999;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp" %>
    
    <div class="page-header">
        <div class="container">
            <h1><i class="fas fa-user"></i> 個人資料</h1>
        </div>
    </div>
    
    <div class="form-container">
        <div class="info-alert">
            <strong><i class="fas fa-info-circle"></i> 資料說明</strong><br>
            以下是您的個人資料，如需修改請點擊下方的「編輯資料」按鈕。
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-id-card"></i> 帳號：</div>
            <div class="info-value"><%= username %></div>
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-user-circle"></i> 暱稱：</div>
            <div class="info-value <%= name.isEmpty() ? "empty" : "" %>">
                <%= name.isEmpty() ? "尚未設定" : name %>
            </div>
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-envelope"></i> 聯絡方式：</div>
            <div class="info-value <%= contact.isEmpty() ? "empty" : "" %>">
                <%= contact.isEmpty() ? "尚未設定" : contact %>
            </div>
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-graduation-cap"></i> 就讀系所：</div>
            <div class="info-value <%= department.isEmpty() ? "empty" : "" %>">
                <%= department.isEmpty() ? "尚未設定" : department %>
            </div>
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-sign-in-alt"></i> 上次登入：</div>
            <div class="info-value"><%= lastLogin %></div>
        </div>

        <div class="info-group">
            <div class="info-label"><i class="fas fa-sign-out-alt"></i> 上次登出：</div>
            <div class="info-value"><%= lastLogout %></div>
        </div>

        <div class="btn-container">
            <a href="editProfile.jsp" class="btn-primary">
                <i class="fas fa-edit"></i> 編輯資料
            </a>
        </div>
    </div>

    <%@ include file="footer.jsp"%>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>