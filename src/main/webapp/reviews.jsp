<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String reviewUserId = (String) session.getAttribute("userId");
    String reviewUserName = (String) session.getAttribute("name");
    boolean isLoggedIn = (reviewUserId != null && !reviewUserId.trim().isEmpty());
    
    // 獲取篩選條件
    String filterType = request.getParameter("type");
    String sortBy = request.getParameter("sort");
    if (sortBy == null) sortBy = "latest";
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 修改: 使用 PreparedStatement 防止 SQL 注入
    // 主查詢 SQL
    StringBuilder reviewsSQL = new StringBuilder("SELECT * FROM reviews WHERE 1=1");
    List<String> params = new ArrayList<>();
    
    if (filterType != null && !filterType.equals("all")) {
        reviewsSQL.append(" AND reviewType = ?");
        params.add(filterType);
    }
    
    // 排序 - 修正: createdAt -> createAt
    if ("popular".equals(sortBy)) {
        reviewsSQL.append(" ORDER BY likeCount DESC, createAt DESC");
    } else if ("rating".equals(sortBy)) {
        reviewsSQL.append(" ORDER BY rating DESC, createAt DESC");
    } else {
        reviewsSQL.append(" ORDER BY createAt DESC");
    }
    
    // 修改: 使用 PreparedStatement
    PreparedStatement pstmt = con.prepareStatement(reviewsSQL.toString());
    for (int i = 0; i < params.size(); i++) {
        pstmt.setString(i + 1, params.get(i));
    }
    ResultSet rs = pstmt.executeQuery();
    
    // 如果使用者已登入,獲取他們按讚的心得
    Set<Integer> likedReviews = new HashSet<>();
    if (isLoggedIn) {
        // 按讚查詢 SQL (使用不同的變數名)
        String likeQuerySQL = "SELECT reviewId FROM reviewLikes WHERE userId = ?";
        PreparedStatement likePstmt = con.prepareStatement(likeQuerySQL);
        likePstmt.setString(1, reviewUserId);
        ResultSet likeRs = likePstmt.executeQuery();
        while (likeRs.next()) {
            likedReviews.add(likeRs.getInt("reviewId"));
        }
        likeRs.close();
        likePstmt.close();
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>使用心得分享 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        /* 頁面標題 - 改用淺綠色 */
        .reviews-header {
            background: #81c784;
            color: white;
            padding: 50px 20px 35px;
            text-align: center;
            margin-bottom: 40px;
            box-shadow: 0 4px 15px rgba(102, 187, 106, 0.3);
        }
        
        .reviews-header h1 {
            font-size: 2.5em;
            margin-bottom: 100px;
            font-weight: 600;
        }
        
        .reviews-header p {
            font-size: 1.2em;
            opacity: 0.95;
        }
        
        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            gap: 15px;
            flex-wrap: wrap;
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .filter-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        /* 篩選按鈕 - 改用淺綠色 */
        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #e0e0e0;
            background: white;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 500;
            text-decoration: none;
            color: #666;
            display: inline-block;
        }
        
        .filter-btn:hover {
            border-color: #81c784;
            color: #66bb6a;
            background: #f1f8f4;
        }
        
        .filter-btn.active {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            border-color: transparent;
        }
        
        /* 發表按鈕 - 改用淺綠色 */
        .write-btn {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .write-btn:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
            color: white;
        }
        
        .review-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: all 0.3s;
        }
        
        .review-card:hover {
            box-shadow: 0 4px 15px rgba(0,0,0,0.12);
            transform: translateY(-2px);
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
            gap: 15px;
        }
        
        .review-author-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        /* 作者頭像 - 改用淺綠色 */
        .author-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2em;
            box-shadow: 0 2px 8px rgba(129, 199, 132, 0.3);
        }
        
        .author-details {
            flex: 1;
        }
        
        .author-name {
            font-weight: 700;
            font-size: 1.1em;
            color: #333;
            margin-bottom: 3px;
        }
        
        .review-meta {
            display: flex;
            gap: 12px;
            font-size: 0.9em;
            color: #666;
            align-items: center;
        }
        
        /* 類型徽章 - 調整顏色 */
        .review-type-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.85em;
            font-weight: 600;
        }
        
        .badge-purchase {
            background: #e8f5e9;
            color: #2e7d32;
        }
        
        .badge-sell {
            background: #f1f8e9;
            color: #558b2f;
        }
        
        .badge-suggestion {
            background: #fff9c4;
            color: #f57f17;
        }
        
        .review-rating {
            display: flex;
            gap: 3px;
        }
        
        .star {
            color: #ffc107;
            font-size: 1.1em;
        }
        
        .star.empty {
            color: #ddd;
        }
        
        .review-title {
            font-size: 1.3em;
            font-weight: 700;
            color: #333;
            margin-bottom: 12px;
        }
        
        .review-content {
            color: #555;
            line-height: 1.7;
            margin-bottom: 15px;
            font-size: 1.05em;
        }
        
        .review-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
            border-top: 1px solid #f0f0f0;
        }
        
        /* 按讚按鈕 - 改用淺綠色 */
        .like-btn {
            background: white;
            border: 2px solid #e0e0e0;
            padding: 8px 20px;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .like-btn:hover {
            border-color: #81c784;
            color: #66bb6a;
            background: #f1f8f4;
        }
        
        .like-btn.liked {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            border-color: transparent;
        }
        
        .review-time {
            color: #999;
            font-size: 0.9em;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
        }
        
        .empty-state-icon {
            font-size: 80px;
            color: #c8e6c9;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            color: #66bb6a;
        }
        
        .sort-select {
            padding: 10px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .sort-select:focus {
            outline: none;
            border-color: #81c784;
        }
        
        @media (max-width: 768px) {
            .reviews-header h1 {
                font-size: 1.8em;
            }
            
            .action-bar {
                flex-direction: column;
                align-items: stretch;
            }
            
            .filter-group {
                justify-content: center;
            }
            
            .review-header {
                flex-direction: column;
            }
            
            .review-meta {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp"%>
    
    <div class="reviews-header">
        <h1><i class="fas fa-comments"></i> 使用心得分享</h1>
        <p>分享你的買賣經驗，幫助更多人做出更好的選擇</p>
    </div>
    
    <div class="container-custom">
        <div class="action-bar">
            <div class="filter-group">
                <a href="?type=all&sort=<%= sortBy %>" class="filter-btn <%= (filterType == null || "all".equals(filterType)) ? "active" : "" %>">
                    <i class="fas fa-list"></i> 全部心得
                </a>
                <a href="?type=購書心得&sort=<%= sortBy %>" class="filter-btn <%= "購書心得".equals(filterType) ? "active" : "" %>">
                    <i class="fas fa-book"></i> 購書心得
                </a>
                <a href="?type=賣書經驗&sort=<%= sortBy %>" class="filter-btn <%= "賣書經驗".equals(filterType) ? "active" : "" %>">
                    <i class="fas fa-dollar-sign"></i> 賣書經驗
                </a>
                <a href="?type=使用建議&sort=<%= sortBy %>" class="filter-btn <%= "使用建議".equals(filterType) ? "active" : "" %>">
                    <i class="fas fa-lightbulb"></i> 使用建議
                </a>
            </div>
            
            <div style="display: flex; gap: 10px; align-items: center;">
                <select class="sort-select" onchange="location.href='?type=<%= filterType != null ? filterType : "all" %>&sort=' + this.value">
                    <option value="latest" <%= "latest".equals(sortBy) ? "selected" : "" %>>最新發布</option>
                    <option value="popular" <%= "popular".equals(sortBy) ? "selected" : "" %>>最多按讚</option>
                    <option value="rating" <%= "rating".equals(sortBy) ? "selected" : "" %>>評分最高</option>
                </select>
                
                <% if (isLoggedIn) { %>
                    <a href="writeReview.jsp" class="write-btn"><i class="fas fa-pen"></i> 發表心得</a>
                <% } else { %>
                    <a href="login.jsp?redirect=reviews.jsp" class="write-btn">登入發表</a>
                <% } %>
            </div>
        </div>
        
        <div class="reviews-list">
            <% 
                boolean hasReviews = false;
                while(rs.next()) {
                    hasReviews = true;
                    int reviewId = rs.getInt("reviewId");
                    String userId = rs.getString("userId");
                    String name = rs.getString("name");
                    String reviewType = rs.getString("reviewType");
                    String title = rs.getString("title");
                    String content = rs.getString("content");
                    int rating = rs.getInt("rating");
                    boolean isAnonymous = rs.getBoolean("isAnonymous");
                    String createAt = rs.getString("createAt");
                    int likeCount = rs.getInt("likeCount");
                    boolean isLiked = likedReviews.contains(reviewId);
                    
                    String displayName = isAnonymous ? "匿名使用者" : name;
                    String badgeClass = "";
                    if ("購書心得".equals(reviewType)) {
                        badgeClass = "badge-purchase";
                    } else if ("賣書經驗".equals(reviewType)) {
                        badgeClass = "badge-sell";
                    } else {
                        badgeClass = "badge-suggestion";
                    }
            %>
                <div class="review-card">
                    <div class="review-header">
                        <div class="review-author-info">
                            <div class="author-avatar">
                                <%= displayName.substring(0, 1) %>
                            </div>
                            <div class="author-details">
                                <div class="author-name"><%= displayName %></div>
                                <div class="review-meta">
                                    <span class="review-type-badge <%= badgeClass %>">
                                        <%= reviewType %>
                                    </span>
                                    <div class="review-rating">
                                        <% for (int i = 1; i <= 5; i++) { %>
                                            <span class="star <%= i <= rating ? "" : "empty" %>">★</span>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="review-title"><%= title %></div>
                    <div class="review-content"><%= content.replace("\n", "<br>") %></div>
                    
                    <div class="review-footer">
                        <button class="like-btn <%= isLiked ? "liked" : "" %>" 
                                onclick="toggleLike(<%= reviewId %>, this)"
                                <%= !isLoggedIn ? "disabled title='請先登入'" : "" %>>
                            <span><%= isLiked ? "❤️" : "🤍" %></span>
                            <span class="like-count"><%= likeCount %></span>
                        </button>
                        <span class="review-time">
                            <i class="far fa-clock"></i> <%= createAt != null ? createAt.split(" ")[0] : "" %>
                        </span>
                    </div>
                </div>
            <% 
                }
                
                if (!hasReviews) {
            %>
                <div class="empty-state">
                    <div class="empty-state-icon"><i class="fas fa-inbox"></i></div>
                    <h3>還沒有人分享心得</h3>
                    <p>成為第一個分享使用經驗的人吧！</p>
                    <% if (isLoggedIn) { %>
                        <a href="writeReview.jsp" class="write-btn" style="margin-top: 20px;">立即發表</a>
                    <% } %>
                </div>
            <% 
                }
                rs.close();
                pstmt.close();
                con.close();
            %>
        </div>
    </div>
    
    <br><br>
    
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
        const isLoggedIn = <%= isLoggedIn %>;
        
        function toggleLike(reviewId, button) {
            if (!isLoggedIn) {
                alert('請先登入才能按讚');
                return;
            }
            
            const isLiked = button.classList.contains('liked');
            const action = isLiked ? 'unlike' : 'like';
            
            button.disabled = true;
            
            fetch('toggleReviewLike.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'reviewId=' + reviewId + '&action=' + action
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    button.classList.toggle('liked');
                    const icon = button.querySelector('span:first-child');
                    const count = button.querySelector('.like-count');
                    
                    icon.textContent = button.classList.contains('liked') ? '❤️' : '🤍';
                    count.textContent = data.likeCount;
                } else {
                    alert('操作失敗：' + (data.message || '未知錯誤'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('系統錯誤');
            })
            .finally(() => {
                button.disabled = false;
            });
        }
    </script>
</body>
</html>