<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<html lang="zh">

<head>
    <meta charset="utf-8">
    <title>搜尋結果</title>
    <meta content="width=device-width,initial-scale=1.0" name="viewport">
    <meta content="" name="keywords">
    <meta content="" name="description">

    <!-- Google Web Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet">

    <!-- Icon Font Stylesheet -->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Libraries Stylesheet -->
    <link href="lib/lightbox/css/lightbox.min.css" rel="stylesheet">
    <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">

    <!-- Customized Bootstrap Stylesheet -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Template Stylesheet -->
    <link href="css/style.css" rel="stylesheet">
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
        }

        th, td {
            padding: 15px;
            text-align: left;
        }
    </style>
</head>

<body>
    <%@ include file="menu.jsp" %>
    <br><br><br><br><br>
    <%
        // 初始化資料庫連線
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        Statement smt = con.createStatement();

        // 取得搜尋關鍵字
        String keyword = request.getParameter("query");
        String sql = "SELECT * FROM book";
        if (keyword != null && !keyword.trim().isEmpty()) {
            // 如果有輸入搜尋關鍵字，則進行條件查詢
            sql = "SELECT * FROM book WHERE titleBook LIKE '%" + keyword + "%'";
        }
        ResultSet rs = smt.executeQuery(sql);
    %>

    <div class="container">
        <h1 class="text-center">搜尋結果</h1>

        <%
        boolean hasResults = false;
        while (rs.next()) {
            hasResults = true;
            String bookId = rs.getString("bookId");
            String fullDate = rs.getString("date");
            String formattedDate = fullDate != null ? fullDate.split(" ")[0] : "";
            String photoPath = rs.getString("photo");
            String remarks = rs.getString("remarks");
        %>
            <table style="width:100%; border:1px solid black; border-collapse: collapse;">
                <tr>
                    <th>書名</th>
                    <th>作者</th>
                    <th>價格</th>
                    <th>出版日期</th>
                    <th>圖片</th>
                    <th>聯絡方式</th>
                    <th>備註</th>
                </tr>
                <tr>
                    <td><%= rs.getString("titleBook") %></td>
                    <td><%= rs.getString("author") %></td>
                    <td><%= rs.getString("price") %></td>
                    <td><%= formattedDate %></td>
                    <td>
                        <% if (photoPath != null && !photoPath.isEmpty()) { %>
                            <img src="<%= photoPath %>" alt="書籍圖片" style="width:100px; height:auto;">
                        <% } else { %>
                            無圖片
                        <% } %>
                    </td>
                    <td><%= rs.getString("contact") %></td>
                    <td>
                        <% if (remarks != null && !remarks.isEmpty()) { %>
                            <%= remarks %>
                        <% } %>
                    </td>
                </tr>
            </table>
        <% } %>

        <% if (!hasResults) { %>
            <div class="alert alert-warning" role="alert">
                未找到相關書籍，請試試其他關鍵字。
            </div>
        <% } %>

        <a href="index.jsp" class="btn btn-primary mt-4">返回首頁</a>
    </div>

    <%
        con.close();
    %>

    <!-- Back to Top -->
    <a href="#" class="btn btn-primary border-3 border-primary rounded-circle back-to-top"><i class="fa fa-arrow-up"></i></a>

    <!-- JavaScript Libraries -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="lib/easing/easing.min.js"></script>
    <script src="lib/waypoints/waypoints.min.js"></script>
    <script src="lib/lightbox/js/lightbox.min.js"></script>
    <script src="lib/owlcarousel/owl.carousel.min.js"></script>

    <!-- Template Javascript -->
    <script src="js/main.js"></script>
</body>
</html>
