<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />
<html lang="zh">

    <head>
        <meta charset="utf-8">
        <title>北護二手書拍賣網</title>
        <meta content="width=device-width,Sinitial-scale=1.0" name="viewport">
        <meta content="" name="keywords">
        <meta content="" name="description">

        <!-- Google Web Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600&family=Raleway:wght@600;800&display=swap" rel="stylesheet"> 

        <!-- Icon Font Stylesheet -->
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

        <!-- Libraries Stylesheet -->
        <link href="lib/lightbox/css/lightbox.min.css" rel="stylesheet">
        <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">


        <!-- Customized Bootstrap Stylesheet -->
        <link href="css/bootstrap.min.css" rel="stylesheet">

        <!-- Template Stylesheet -->
        <link href="css/style.css" rel="stylesheet">
        <style>
        table, th ,td{
        border:1px solid black;
        border-collapse:collaspe;
        }
        th, td {
  padding: 15px;
}
th, td {
  padding-top: 10px;
  padding-bottom: 20px;
  padding-left: 30px;
  padding-right: 40px;
}
        </style> 
    </head>

    <body>
    <%@ include file="menu.jsp"%>
    <br><br><br><br><br>
<%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt = con.createStatement();
    String sql = "SELECT * FROM book";              
    ResultSet rs = smt.executeQuery(sql);
    String username = (String)session.getAttribute("accessId");
    boolean isLoggedIn = (username != null && !username.isEmpty());
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
        <th>上架時間</th>
        
    </tr>
<%
    while(rs.next()) {
        String bookId = rs.getString("bookId"); 
        String fullDate = rs.getString("date");
        String formattedDate = fullDate != null ? fullDate.split(" ")[0] : "";
        String photoPath = rs.getString("photo");
        String remarks = rs.getString("remarks");
        String createAt = rs.getString("createdAt");
%>

    <tr style="border:1px solid black;">
        <td><%= rs.getString("titleBook") %></td>
        <td><%= rs.getString("author") %></td>
        <td><%= rs.getString("price") %></td>
        <td><%= formattedDate %></td>
        <!-- 顯示圖片 -->
        <td>
            <% if (photoPath != null && !photoPath.isEmpty()) { %>
                <img src="<%= photoPath %>" alt="書籍圖片" style="width:100px; height:auto;">
            <% } else { %>
                無圖片
            <% } %>
        </td>
        <td><%= rs.getString("contact") %></td>
        <td><%= rs.getString("remarks") %></td>
        <td><%= rs.getString("createdAt") %></td>
    </tr>
<%
    }
    con.close();
%>
</table>
</body>

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
                <a class="btn btn-link" href="index.jsp">首頁</a>
                <a class="btn btn-link" href="https://forms.gle/JP4LyWAVgKSvzzUM8">系統使用回饋表單</a>
            </div>
        </div>
    </div>
    <div class="container-fluid text-center border-top border-secondary py-3">
        <p class="mb-0">&copy; 2025 北護二手書拍賣系統. All Rights Reserved.</p>
    </div>
</div>
<!-- Footer End -->
    </body>  
