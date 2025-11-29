<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    // 修改變數名稱，避免與 menu.jsp 中的變數衝突
    String currentUserId = (String) session.getAttribute("userId");
    String currentUserName = (String) session.getAttribute("name");
    
    if (currentUserId == null || currentUserId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=writeReview.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    if ("POST".equals(request.getMethod())) {
        String reviewType = request.getParameter("reviewType");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String ratingStr = request.getParameter("rating");
        String isAnonymousStr = request.getParameter("isAnonymous");
        
        if (reviewType != null && title != null && content != null && ratingStr != null) {
            try {
                int rating = Integer.parseInt(ratingStr);
                boolean isAnonymous = "on".equals(isAnonymousStr);
                
                Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
                Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
                
                // 修正 SQL 語句：使用 name 而非 userName，並加入 createdAt 和 likeCount
                String sql = "INSERT INTO reviews (userId, name, reviewType, title, content, rating, isAnonymous, createAt, likeCount) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, Now(), 0)";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setString(1, currentUserId);
                pstmt.setString(2, currentUserName);
                pstmt.setString(3, reviewType);
                pstmt.setString(4, title);
                pstmt.setString(5, content);
                pstmt.setInt(6, rating);
                pstmt.setBoolean(7, isAnonymous);
                
                int result = pstmt.executeUpdate();
                pstmt.close();
                con.close();
                
                if (result > 0) {
                    response.sendRedirect("reviews.jsp");
                    return;
                } else {
                    message = "發表失敗，請稍後再試";
                    messageType = "error";
                }
            } catch (Exception e) {
                message = "系統錯誤：" + e.getMessage();
                messageType = "error";
            }
        } else {
            message = "請填寫所有必填欄位";
            messageType = "error";
        }
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>發表心得 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        /* 頁面標題 - 改用淺綠色 */
        .write-header {
            background: #81c784;
            color: white;
            padding: 40px 20px;
            text-align: center;
            margin-bottom: 40px;
            box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
        }
        
        .write-header h1 {
            font-size: 2em;
            margin-bottom: 120px;
            font-weight: 600;
        }
        
        .container-custom {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 20px 60px;
        }
        
        .write-form {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            font-weight: 700;
            color: #333;
            margin-bottom: 10px;
            display: block;
            font-size: 1.05em;
        }
        
        .form-label .required {
            color: #e57373;
            margin-left: 3px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s;
            font-family: inherit;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #81c784;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 150px;
            line-height: 1.6;
        }
        
        .type-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .type-option {
            position: relative;
        }
        
        .type-option input[type="radio"] {
            position: absolute;
            opacity: 0;
        }
        
        /* 類型選擇按鈕 - 改用淺綠色 */
        .type-option label {
            display: block;
            padding: 20px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
        }
        
        .type-option label:hover {
            border-color: #81c784;
            background: #f1f8f4;
        }
        
        .type-option input[type="radio"]:checked + label {
            border-color: #81c784;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
        }
        
        .type-icon {
            font-size: 2em;
            display: block;
            margin-bottom: 8px;
        }
        
        .rating-stars {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 10px;
        }
        
        .rating-stars input[type="radio"] {
            display: none;
        }
        
        .rating-stars label {
            font-size: 2.5em;
            cursor: pointer;
            color: #ddd;
            transition: color 0.2s;
        }
        
        .rating-stars label:hover,
        .rating-stars label:hover ~ label {
            color: #ffc107;
        }
        
        .rating-stars input[type="radio"]:checked ~ label {
            color: #ffc107;
        }
        
        /* 匿名選項 - 改用淺綠色 */
        .checkbox-wrapper {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px;
            background: #f1f8f4;
            border-radius: 8px;
            border: 1px solid #e8f5e9;
        }
        
        .checkbox-wrapper input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
            accent-color: #66bb6a;
        }
        
        .checkbox-wrapper label {
            cursor: pointer;
            margin: 0;
            color: #555;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 35px;
            justify-content: center;
        }
        
        /* 提交按鈕 - 改用淺綠色 */
        .btn-submit {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 14px 50px;
            border: none;
            border-radius: 25px;
            font-weight: 700;
            font-size: 1.1em;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-submit:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .btn-cancel {
            background: white;
            color: #666;
            padding: 14px 50px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-weight: 600;
            font-size: 1.1em;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-cancel:hover {
            border-color: #999;
            color: #333;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
        }
        
        .alert-error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ef9a9a;
        }
        
        .char-count {
            text-align: right;
            color: #999;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        .form-hint {
            color: #999;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        @media (max-width: 768px) {
            .write-form {
                padding: 25px;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn-submit,
            .btn-cancel {
                width: 100%;
            }
            
            .rating-stars label {
                font-size: 2em;
            }
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp"%>
    
    <div class="write-header">
        <h1><i class="fas fa-pen"></i> 發表使用心得</h1>
        <p>分享你的真實體驗，幫助其他使用者</p>
    </div>
    
    <div class="container-custom">
        <form method="post" class="write-form" id="reviewForm">
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <i class="fas fa-exclamation-circle"></i> <%= message %>
                </div>
            <% } %>
            
            <div class="form-group">
                <label class="form-label">心得類型 <span class="required">*</span></label>
                <div class="type-options">
                    <div class="type-option">
                        <input type="radio" name="reviewType" id="type1" value="購書心得" required>
                        <label for="type1">
                            <span class="type-icon">📚</span>
                            購書心得
                        </label>
                    </div>
                    <div class="type-option">
                        <input type="radio" name="reviewType" id="type2" value="賣書經驗" required>
                        <label for="type2">
                            <span class="type-icon">💰</span>
                            賣書經驗
                        </label>
                    </div>
                    <div class="type-option">
                        <input type="radio" name="reviewType" id="type3" value="使用建議" required>
                        <label for="type3">
                            <span class="type-icon">💡</span>
                            使用建議
                        </label>
                    </div>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="title">心得標題 <span class="required">*</span></label>
                <input type="text" 
                       id="title" 
                       name="title" 
                       class="form-control" 
                       placeholder="用一句話概括你的心得" 
                       maxlength="100"
                       required>
                <div class="char-count">
                    <span id="titleCount">0</span> / 100 字
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="content">詳細內容 <span class="required">*</span></label>
                <textarea id="content" 
                          name="content" 
                          class="form-control" 
                          placeholder="分享你的使用經驗、遇到的問題或建議..." 
                          maxlength="1000"
                          required></textarea>
                <div class="char-count">
                    <span id="contentCount">0</span> / 1000 字
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">整體評分 <span class="required">*</span></label>
                <div class="rating-stars">
                    <input type="radio" name="rating" id="star5" value="5" required>
                    <label for="star5">★</label>
                    <input type="radio" name="rating" id="star4" value="4">
                    <label for="star4">★</label>
                    <input type="radio" name="rating" id="star3" value="3">
                    <label for="star3">★</label>
                    <input type="radio" name="rating" id="star2" value="2">
                    <label for="star2">★</label>
                    <input type="radio" name="rating" id="star1" value="1">
                    <label for="star1">★</label>
                </div>
                <p class="form-hint" style="text-align: center; margin-top: 10px;">
                    點擊星星評分（1星最低，5星最高）
                </p>
            </div>
            
            <div class="form-group">
                <div class="checkbox-wrapper">
                    <input type="checkbox" id="isAnonymous" name="isAnonymous">
                    <label for="isAnonymous"><i class="fas fa-user-secret"></i> 匿名發表（不顯示我的姓名）</label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn-submit"><i class="fas fa-check"></i> 發表心得</button>
                <a href="reviews.jsp" class="btn-cancel"><i class="fas fa-times"></i> 取消</a>
            </div>
        </form>
    </div>
    
    <!-- Footer -->
    <div class="container-fluid bg-dark text-white-50 footer pt-5 mt-5">
        <div class="container py-5">
            <div class="row g-5">
                <div class="col-md-6 col-lg-3">
                    <h5 class="text-white mb-4">專題資訊</h5>
                    <p class="mb-2">題目：國北護二手書交易網</p>
                    <p class="mb-2">系所：健康事業管理系</p>
                    <p class="mb-2">專題組員：黃郁心、賈子瑩、許宇翔、闕紫彤</p>
                </div>
                <div class="col-md-6 col-lg-3">
                    <h5 class="text-white mb-4">快速連結</h5>
                    <a class="btn btn-link" href="index.jsp">首頁</a>
                    <a class="btn btn-link" href="reviews.jsp">使用心得分享</a>
                </div>
            </div>
        </div>
        <div class="container-fluid text-center border-top border-secondary py-3">
            <p class="mb-0">&copy; 2025年 國北護二手書交易網. All Rights Reserved.</p>
        </div>
    </div>
    
    <script>
        // 字數統計
        const titleInput = document.getElementById('title');
        const contentInput = document.getElementById('content');
        const titleCount = document.getElementById('titleCount');
        const contentCount = document.getElementById('contentCount');
        
        titleInput.addEventListener('input', function() {
            titleCount.textContent = this.value.length;
        });
        
        contentInput.addEventListener('input', function() {
            contentCount.textContent = this.value.length;
        });
        
        // 星星評分反向顯示
        const ratingStars = document.querySelectorAll('.rating-stars label');
        ratingStars.forEach(star => {
            star.addEventListener('mouseenter', function() {
                const value = this.previousElementSibling.value;
                highlightStars(value);
            });
        });
        
        document.querySelector('.rating-stars').addEventListener('mouseleave', function() {
            const checked = document.querySelector('.rating-stars input:checked');
            if (checked) {
                highlightStars(checked.value);
            } else {
                clearStars();
            }
        });
        
        function highlightStars(value) {
            const stars = document.querySelectorAll('.rating-stars label');
            stars.forEach((star, index) => {
                if (5 - index <= value) {
                    star.style.color = '#ffc107';
                } else {
                    star.style.color = '#ddd';
                }
            });
        }
        
        function clearStars() {
            const stars = document.querySelectorAll('.rating-stars label');
            stars.forEach(star => {
                star.style.color = '#ddd';
            });
        }
        
        // 表單驗證
        document.getElementById('reviewForm').addEventListener('submit', function(e) {
            const rating = document.querySelector('input[name="rating"]:checked');
            if (!rating) {
                e.preventDefault();
                alert('請選擇評分');
                return false;
            }
        });
    </script>
</body>
</html>