<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<html lang="zh">

<head>
    <meta charset="utf-8">
    <title>二手書交易網</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet">
    
    <!-- Stylesheets -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    
    <style>
        /* 未讀徽章樣式 */
        .message-badge {
            position: relative;
            display: inline-block;
        }
        .badge-notification {
            position: absolute;
            top: -8px;
            right: -10px;
            background-color: #dc3545;
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: bold;
            min-width: 18px;
            text-align: center;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }
    </style>
</head>

<body>

    <!-- Navbar start -->
    <div class="container-fluid fixed-top">
        <!-- 保留圓弧設計的區塊 -->
        <div class="container topbar bg-primary rounded-pill d-none d-lg-block text-white py-2">
            <small>
                <i class="fas fa-map-marker-alt me-2"></i>
                <a href="https://www.ntunhs.edu.tw/?Lang=zh-tw" class="text-white">國立台北護理健康大學</a>
            </small>
        </div>
        
        <nav class="navbar navbar-expand-lg bg-white">
            <div class="container">
                <!-- 網站標題 -->
                <a href="index.jsp" class="navbar-brand">
                    <h1 class="text-primary display-6">二手書交易網</h1>
                </a>

                <!-- 漢堡選單按鈕 -->
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse">
                    <span class="fa fa-bars text-primary"></span>
                </button>

                <!-- 導覽列 -->
                <%
	                // 在需要使用的地方直接取得
	                String currentPage = request.getRequestURI();
	                int unreadCount = 0;
	                String loggedInUserId = (String) session.getAttribute("userId");
	                
	                if (loggedInUserId != null && !loggedInUserId.trim().isEmpty()) {
	                    Connection menuCon = null;
	                    PreparedStatement menuPstmt = null;
	                    ResultSet menuRs = null;
	                    
	                    try {
	                        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	                        // 直接從 session 取得
	                        hitstd.group.tool.database.DBConfig dbConfig = 
	                            (hitstd.group.tool.database.DBConfig) session.getAttribute("objDBConfig");
	                        menuCon = DriverManager.getConnection("jdbc:ucanaccess://"+dbConfig.FilePath()+";");
                            
                            String sql = "SELECT COUNT(*) as cnt FROM messages WHERE sellerId = ? AND isRead = No";
                            menuPstmt = menuCon.prepareStatement(sql);
                            menuPstmt.setString(1, loggedInUserId);
                            menuRs = menuPstmt.executeQuery();
                            
                            if (menuRs.next()) {
                                unreadCount = menuRs.getInt("cnt");
                            }
                        } catch (Exception e) {
                            System.out.println("查詢未讀訊息錯誤: " + e.getMessage());
                        } finally {
                            try {
                                if (menuRs != null) menuRs.close();
                                if (menuPstmt != null) menuPstmt.close();
                                if (menuCon != null) menuCon.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                %>
                    
                <%-- 登入/登出邏輯 --%>
                <div class="navbar-nav mx-auto">
                    <a href="shop.jsp" class="nav-link <%= currentPage.endsWith("shop.jsp") ? "nav-active" : "" %>">我要賣書</a>
                    
                    <% if (session.getAttribute("username") != null) { %>
                        <!-- 我的訊息 (帶未讀徽章) -->
                        <a href="myMessages.jsp" class="nav-link message-badge <%= currentPage.endsWith("myMessages.jsp") ? "nav-active" : "" %>">
                            <i class="fas fa-envelope"></i> 我的訊息
                            <% if (unreadCount > 0) { %>
                                <span class="badge-notification"><%= unreadCount %></span>
                            <% } %>
                        </a>
                        <a href="myFavorites.jsp" class="nav-link">我的收藏</a>
                        <a href="profile.jsp" class="nav-link <%= currentPage.endsWith("profile.jsp") ? "nav-active" : "" %>">個人資料</a>
                        <a href="logout.jsp" class="nav-link">登出</a>
                    <% } else { %>
                        <a href="login.jsp" class="nav-link <%= currentPage.endsWith("login.jsp") ? "nav-active" : "" %>">登入</a>
                    <% } %>
                </div>

                <!-- 搜尋和用戶圖示 -->
                <div class="d-flex align-items-center">
                    <button class="btn btn-md-square border border-secondary me-3" data-bs-toggle="modal" data-bs-target="#searchModal">
                        <i class="fas fa-search text-primary"></i>
                    </button>
                    <a href="login.jsp" class="text-primary">
                        <i class="fas fa-user fa-2x"></i>
                    </a>
                </div>
            </div>
        </nav>
    </div>
    <!-- Navbar End -->

    <!-- 搜尋 Modal Start -->
    <div class="modal fade" id="searchModal" tabindex="-1">
        <div class="modal-dialog modal-fullscreen">
            <div class="modal-content rounded-0">
                <div class="modal-header">
                    <h5 class="modal-title">搜尋書籍</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body d-flex align-items-center">
                    <form action="search.jsp" method="get" class="input-group w-75 mx-auto">
                        <!-- 下拉式搜尋分類 -->
                        <select name="type" class="form-select p-3" style="max-width: 180px;">
                            <option value="titleBook">書名</option>
                            <option value="author">作者</option>
                            <option value="department">系所</option>
                            <option value="teacher">授課老師</option>
                            <option value="course">使用課程</option>
                        </select>

                        <!-- 搜尋文字 -->
                        <input type="search" name="query" class="form-control p-3" placeholder="請輸入關鍵字">
                        
                        <!-- 送出按鈕 -->
                        <button type="submit" class="btn btn-primary p-3">
                            <i class="fa fa-search"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- 搜尋 Modal End -->
    
    <!-- 使用者名稱顯示 -->
    <div class="container mt-4">
        <% if (session.getAttribute("name") != null) { %>
        <p class="text-end text-primary">歡迎, <strong><%= session.getAttribute("name") %></strong></p>
        <% } %>
    </div>

    <!-- JavaScript Libraries -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>