<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<html>
<head><title>登出</title></head>
<body>
<%
if(session.getAttribute("userId") != null) {
    session.removeAttribute("userId");
    session.removeAttribute("username");
}
response.sendRedirect("index.jsp");
%>
</body>
</html>

