<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<html lang="zh">

    <head>
        <meta charset="utf-8">
        <title>二手書拍賣網</title>
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
  padding: 25px;
}
th, td {
  padding-top: 30px;
  padding-bottom: 30px;
  padding-left: 30px;
  padding-right: 30px;
}
        </style>
  <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            min-height: 100vh; /* 使表單在整個視窗垂直居中 */
            flex-direction: column; /* 使元素垂直排列 */
        }

        .form-container {
            margin: 50px auto; /* 上方和下方的間距 */
            padding-top: 100px; /* 往下移動的距離 */
            max-width: 500px; /* 限制表單寬度 */
            background-color: #ffffff;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        label {
            display: inline-block;
            width: 100px; /* 控制標籤固定寬度 */
            margin-bottom: 10px;
        }

        input, textarea {
            width: calc(100% - 120px); /* 控制輸入框的寬度 */
            margin-left: 5px;
            margin-bottom: 5px;
            padding: 5px;
            box-sizing: border-box;
        }

        input[type="submit"], input[type="reset"] {
            width: auto;
            margin: 10px 5px;
            padding: 5px 10px;
        }

        .required {
            color: red;
            font-weight: bold;
        }
      
    </style>       
    </head>

    <body>
    
    <%@ include file="menu.jsp"%> 
    <br><br><br><br><br>
<form action="shop_DBInsertInto.jsp" method="post" style="margin: 0 auto; width: 100%; text-align: left;">

    <label>書名：</label>
    <input type="text" name="bookname" id="bookname" size="20"required><span class="required">*</span><br><br>
    <label>作者：</label>
    <input type="text" name="author" id="author" size="20"required><span class="required">*</span><br><br>
    <label>價格：</label>
    <input type="text" name="price" id="price" size="20"required><span class="required">*</span><br><br>
    <label>出版日期：</label>
    <input type="date" id="date" name="date"required><span class="required">*</span><br><br>
    <label>書籍照片：</label>
    <input type="file" id="bookphoto" name="bookphoto"><br><br>
    <label>聯絡方式：</label>
    <input type="text" name="contact" id="contact" size="30"required><span class="required">*</span><br><br>
    <label>備註：</label>
    <textarea name="memo" id="memo" rows="5" cols="40"></textarea><br><br>
    <input type="submit" value="送出">
    <input type="reset" value="修改">
    <script language="javascript">  
			//點選提交按鈕觸發下面的函式
			function del(){  
				document.form.action="shop_DBUpdate_pic.jsp";
				document.form.enctype="multipart/form-data";
				document.form.submit();
			}  
			</script>    
</form>


	</body>
	
