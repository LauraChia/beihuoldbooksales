<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userId = (String) session.getAttribute("userId");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    // ✅ 避免存入 null
    if (name == null) name = "";
    if (email == null) email = "";
    if (password == null) password = "";

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "UPDATE users SET name = ?, email = ?, password = ? WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, userId);
        ps.executeUpdate();

        response.sendRedirect("profile.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('更新失敗，請稍後再試'); history.back();</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
