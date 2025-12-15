<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// 檢查是否已登入
String adminUser = (String) session.getAttribute("adminUser");
if (adminUser == null) {
    // 未登入，重導向到登入頁面
    response.sendRedirect("adminLogin.jsp");
    return;
}

// 處理登出
String action = request.getParameter("action");
if ("logout".equals(action)) {
    session.invalidate();
    response.sendRedirect("adminLogin.jsp");
    return;
}

String loginTime = (String) session.getAttribute("loginTime");
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理員後台 - 北護二手書交易網</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft JhengHei', Arial, sans-serif;
            background: #f5f5f5;
        }
        
        .header {
            background: linear-gradient(135deg, #81c408 0%, #81c408 100%);
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 24px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .logout-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid white;
            padding: 8px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .logout-btn:hover {
            background: white;
            color: #667eea;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .welcome-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }
        
        .welcome-card h2 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .welcome-card p {
            color: #666;
            line-height: 1.6;
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .dashboard-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
        }
        
        .dashboard-card .icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        
        .dashboard-card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 18px;
        }
        
        .dashboard-card p {
            color: #666;
            font-size: 14px;
        }
        
        .info-box {
            background: #daf5cc;
            border-left: 4px solid #9ac7c5;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
        
        .info-box p {
            margin: 5px 0;
            font-size: 14px;
            color: 0b8a00;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>📚 北護二手書交易網 - 管理後台</h1>
            <div class="user-info">
                <span>👤 <%= adminUser %></span>
                <a href="?action=logout" class="logout-btn">登出</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome-card">
            <h2>歡迎回來，<%= adminUser %>！</h2>
            <p>這是北護二手書交易網的管理系統。您可以在這裡管理書籍、訂單、會員等功能。</p>
            
            <div class="info-box">
                <p><strong>登入時間：</strong><%= loginTime %></p>
                <p><strong>Session ID：</strong><%= session.getId() %></p>
            </div>
        </div>
        
        <div class="dashboard-grid">
            <a href="manageBooks.jsp" class="dashboard-card">
                <div class="icon">📖</div>
                <h3>書籍審核管理</h3>
                <p>審核書籍的狀態(已審核、未審核、待審核)</p>
            </a>
            
            <a href="manageUsers.jsp" class="dashboard-card">
                <div class="icon">👥</div>
                <h3>使用者管理</h3>
                <p>管理使用者帳號資訊</p>
            </a>
            
            <a href="delistingRecords.jsp" class="dashboard-card">
                <div class="icon">📋</div>
                <h3>下架紀錄查詢</h3>
                <p>查詢書籍下架的歷史紀錄</p>
            </a>
            
            <a href="systemAnnouncement.jsp" class="dashboard-card">
                <div class="icon">📢</div>
                <h3>系統通知</h3>
                <p>管理員公告平台的狀態</p>
            </a>
            
            <a href="statistics.jsp" class="dashboard-card">
                <div class="icon">📊</div>
                <h3>數據統計</h3>
                <p>查看網站使用統計資料</p>
            </a>
            
            <a href="settings.jsp" class="dashboard-card">
                <div class="icon">⚙️</div>
                <h3>系統設定</h3>
                <p>修改網站設定和參數</p>
            </a>
            
            <a href="index.jsp" class="dashboard-card">
                <div class="icon">🏠</div>
                <h3>返回前台</h3>
                <p>查看網站前台頁面</p>
            </a>
            
        </div>
    </div>
</body>
</html>