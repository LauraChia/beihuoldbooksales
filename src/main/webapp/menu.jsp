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
        /* 使用者下拉選單樣式 */
        .user-dropdown {
            position: relative;
        }
        
        .user-icon-wrapper {
            position: relative;
            cursor: pointer;
            padding: 8px;
            border-radius: 50%;
            transition: background-color 0.3s;
        }
        
        .user-icon-wrapper:hover {
            background-color: rgba(25, 135, 84, 0.1);
        }
        
        /* 未讀訊息提示點 */
        .notification-dot {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 12px;
            height: 12px;
            background-color: #dc3545;
            border-radius: 50%;
            border: 2px solid white;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.8; }
        }
        
        /* 下拉選單容器 */
        .user-dropdown-menu {
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            min-width: 280px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s ease;
            z-index: 1000;
        }
        
        .user-dropdown-menu.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        /* 下拉選單箭頭 */
        .user-dropdown-menu::before {
            content: '';
            position: absolute;
            top: -8px;
            right: 20px;
            width: 0;
            height: 0;
            border-left: 8px solid transparent;
            border-right: 8px solid transparent;
            border-bottom: 8px solid white;
        }
        
        /* 使用者資訊區塊 */
        .user-info-section {
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
            background: linear-gradient(135deg, #198754 0%, #157347 100%);
            border-radius: 12px 12px 0 0;
            color: white;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #198754;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .user-name {
            font-size: 18px;
            font-weight: 600;
            margin: 0;
        }
        
        .user-email {
            font-size: 13px;
            opacity: 0.9;
            margin: 5px 0 0 0;
        }
        
        /* 選單項目 */
        .dropdown-menu-items {
            padding: 8px 0;
        }
        
        .dropdown-item-custom {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: #333;
            text-decoration: none;
            transition: background-color 0.2s;
            position: relative;
        }
        
        .dropdown-item-custom:hover {
            background-color: #f8f9fa;
            color: #198754;
        }
        
        .dropdown-item-custom i {
            width: 24px;
            margin-right: 12px;
            font-size: 16px;
            color: #666;
        }
        
        .dropdown-item-custom:hover i {
            color: #198754;
        }
        
        .dropdown-item-text {
            flex: 1;
        }
        
        /* 未讀徽章（選單內） */
        .menu-badge {
            background-color: #dc3545;
            color: white;
            border-radius: 10px;
            padding: 2px 8px;
            font-size: 11px;
            font-weight: bold;
            margin-left: auto;
        }
        
        /* 分隔線 */
        .dropdown-divider-custom {
            height: 1px;
            background-color: #e9ecef;
            margin: 8px 0;
        }
        
        /* 登出按鈕特殊樣式 */
        .dropdown-item-logout {
            color: #dc3545;
        }
        
        .dropdown-item-logout:hover {
            background-color: #fff5f5;
            color: #dc3545;
        }
        
        .dropdown-item-logout i {
            color: #dc3545;
        }
        
        /* 未登入狀態的登入按鈕 */
        .login-button {
            display: inline-flex;
            align-items: center;
            padding: 8px 20px;
            background: linear-gradient(135deg, #198754 0%, #157347 100%);
            color: white;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(25, 135, 84, 0.3);
        }
        
        .login-button:hover {
            background: linear-gradient(135deg, #157347 0%, #0d5132 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(25, 135, 84, 0.4);
        }
        
        .login-button i {
            margin-right: 8px;
        }
        
        /* 響應式設計 */
        @media (max-width: 991px) {
            .user-dropdown-menu {
                right: -10px;
            }
        }
        
        /* 簡化後的導覽列樣式 */
        .navbar-nav .nav-link {
            padding: 8px 16px !important;
            margin: 0 4px;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .navbar-nav .nav-link:hover {
            background-color: rgba(25, 135, 84, 0.1);
            color: #198754 !important;
        }
        
        .navbar-nav .nav-link.nav-active {
            background-color: #198754;
            color: white !important;
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
                    // 取得當前頁面和使用者資訊
                    String currentPage = request.getRequestURI();
                    int unreadCount = 0;
                    int unreadNotificationCount = 0;
                    String loggedInUserId = (String) session.getAttribute("userId");
                    String userName = (String) session.getAttribute("name");
                    String userAccount = (String) session.getAttribute("username");
                    
                    // 查詢未讀訊息數量和未讀通知數量
                    if (loggedInUserId != null && !loggedInUserId.trim().isEmpty()) {
                        Connection menuCon = null;
                        PreparedStatement menuPstmt = null;
                        PreparedStatement notifPstmt = null;
                        ResultSet menuRs = null;
                        ResultSet notifRs = null;
                        
                        try {
                            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
                            hitstd.group.tool.database.DBConfig dbConfig = 
                                (hitstd.group.tool.database.DBConfig) session.getAttribute("objDBConfig");
                            menuCon = DriverManager.getConnection("jdbc:ucanaccess://"+dbConfig.FilePath()+";");
                            
                            // 查詢未讀訊息
                            String sql = "SELECT COUNT(*) as cnt FROM messages WHERE sellerId = ? AND isRead = No";
                            menuPstmt = menuCon.prepareStatement(sql);
                            menuPstmt.setString(1, loggedInUserId);
                            menuRs = menuPstmt.executeQuery();
                            
                            if (menuRs.next()) {
                                unreadCount = menuRs.getInt("cnt");
                            }
                            
                            // 查詢未讀系統通知
                            String notifSql = "SELECT COUNT(*) as cnt FROM notifications WHERE userId = ? AND isRead = false";
                            notifPstmt = menuCon.prepareStatement(notifSql);
                            notifPstmt.setString(1, loggedInUserId);
                            notifRs = notifPstmt.executeQuery();
                            
                            if (notifRs.next()) {
                                unreadNotificationCount = notifRs.getInt("cnt");
                            }
                        } catch (Exception e) {
                            System.out.println("查詢未讀訊息/通知錯誤: " + e.getMessage());
                        } finally {
                            try {
                                if (menuRs != null) menuRs.close();
                                if (notifRs != null) notifRs.close();
                                if (menuPstmt != null) menuPstmt.close();
                                if (notifPstmt != null) notifPstmt.close();
                                if (menuCon != null) menuCon.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                %>
                    
                <%-- 簡化後的導覽列選項（只保留主要功能） --%>
                <div class="collapse navbar-collapse" id="navbarCollapse">
                    <div class="navbar-nav mx-auto">
                        <a href="index.jsp" class="nav-link <%= currentPage.endsWith("index.jsp") ? "nav-active" : "" %>">
                            <i class="fas fa-home"></i> 首頁
                        </a>
                        <a href="shop.jsp" class="nav-link <%= currentPage.endsWith("shop.jsp") ? "nav-active" : "" %>">
                            <i class="fas fa-book"></i> 我要賣書
                        </a>
                        <a href="reviews.jsp" class="nav-link <%= currentPage.endsWith("reviews.jsp") ? "nav-active" : "" %>">
                           <i class="fas fa-comments"></i> 使用心得分享
                       </a>
                    </div>

                    <!-- 右側功能區 -->
                    <div class="d-flex align-items-center">
                        <!-- 搜尋按鈕 -->
                        <button class="btn btn-md-square border border-secondary me-3" data-bs-toggle="modal" data-bs-target="#searchModal">
                            <i class="fas fa-search text-primary"></i>
                        </button>
                        
                        <% if (userName != null) { %>
                            <!-- 通知鈴鐺圖標 -->
                            <div class="position-relative me-3">
                                <a href="sellerNotifications.jsp" class="btn btn-md-square border border-secondary position-relative">
                                    <i class="fas fa-bell text-primary"></i>
                                    <% if (unreadNotificationCount > 0) { %>
                                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 10px;">
                                            <%= unreadNotificationCount > 99 ? "99+" : unreadNotificationCount %>
                                        </span>
                                    <% } %>
                                </a>
                            </div>
                            
                            <!-- 已登入：顯示使用者下拉選單 -->
                            <div class="user-dropdown">
                                <div class="user-icon-wrapper" id="userDropdownToggle">
                                    <i class="fas fa-user-circle fa-2x text-primary"></i>
                                    <% if (unreadCount > 0) { %>
                                        <span class="notification-dot"></span>
                                    <% } %>
                                </div>
                                
                                <div class="user-dropdown-menu" id="userDropdownMenu">
                                    <!-- 使用者資訊區塊 -->
                                    <div class="user-info-section">
                                        <div class="user-avatar">
                                            <%= userName.substring(0, 1) %>
                                        </div>
                                        <p class="user-name"><%= userName %></p>
                                        <p class="user-email">@<%= userAccount %></p>
                                    </div>
                                    
                                    <!-- 選單項目 -->
                                    <div class="dropdown-menu-items">
                                        <a href="profile.jsp" class="dropdown-item-custom">
                                            <i class="fas fa-user"></i>
                                            <span class="dropdown-item-text">個人資料</span>
                                        </a>
                                        
                                        <a href="myMessages.jsp" class="dropdown-item-custom">
                                            <i class="fas fa-envelope"></i>
                                            <span class="dropdown-item-text">我的訊息</span>
                                            <% if (unreadCount > 0) { %>
                                                <span class="menu-badge"><%= unreadCount %></span>
                                            <% } %>
                                        </a>
                                        
                                        <a href="sellerNotifications.jsp" class="dropdown-item-custom">
                                            <i class="fas fa-bell"></i>
                                            <span class="dropdown-item-text">系統通知</span>
                                            <% if (unreadNotificationCount > 0) { %>
                                                <span class="menu-badge"><%= unreadNotificationCount %></span>
                                            <% } %>
                                        </a>
                                        
                                        <a href="myFavorites.jsp" class="dropdown-item-custom">
                                            <i class="fas fa-heart"></i>
                                            <span class="dropdown-item-text">我的收藏</span>
                                        </a>
                                        
                                       <a href="myListings.jsp" class="dropdown-item-custom">
                                           <i class="fas fa-store"></i>
                                            <span class="dropdown-item-text">我的上架</span>
                                        </a>
                                        
                                        <div class="dropdown-divider-custom"></div>
                                        
                                        <a href="logout.jsp" class="dropdown-item-custom dropdown-item-logout">
                                            <i class="fas fa-sign-out-alt"></i>
                                            <span class="dropdown-item-text">登出</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        <% } else { %>
                            <!-- 未登入：顯示登入按鈕 -->
                            <a href="login.jsp" class="login-button">
                                <i class="fas fa-sign-in-alt"></i>
                                登入 / 註冊
                            </a>
                        <% } %>
                    </div>
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
                        <select name="type" class="form-select p-3" style="max-width: 180px;">
                            <option value="title">書名</option>
                            <option value="author">作者</option>
                            <option value="department">系所</option>
                            <option value="teacher">授課老師</option>
                            <option value="course">使用課程</option>
                        </select>
                        <input type="search" name="query" class="form-control p-3" placeholder="請輸入關鍵字">
                        <button type="submit" class="btn btn-primary p-3">
                            <i class="fa fa-search"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- 搜尋 Modal End -->

    <!-- JavaScript Libraries -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- 使用者下拉選單互動 -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const dropdownToggle = document.getElementById('userDropdownToggle');
            const dropdownMenu = document.getElementById('userDropdownMenu');
            
            if (dropdownToggle && dropdownMenu) {
                // 點擊使用者圖示切換選單
                dropdownToggle.addEventListener('click', function(e) {
                    e.stopPropagation();
                    dropdownMenu.classList.toggle('show');
                });
                
                // 點擊頁面其他地方關閉選單
                document.addEventListener('click', function(e) {
                    if (!dropdownMenu.contains(e.target) && !dropdownToggle.contains(e.target)) {
                        dropdownMenu.classList.remove('show');
                    }
                });
                
                // 防止點擊選單內部時關閉
                dropdownMenu.addEventListener('click', function(e) {
                    e.stopPropagation();
                });
            }
        });
    </script>

</body>
</html>