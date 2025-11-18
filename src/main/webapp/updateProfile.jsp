<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userId = (String) session.getAttribute("userId");
    
    // ✅ 修改1: 改為接收正確的參數名稱 (name, contact, password)
    String name = request.getParameter("name");
    String department = request.getParameter("department");
    String password = request.getParameter("password");

    // ✅ 修改2: 加入 contact 的 null 檢查
    if (name == null) name = "";
    if (department == null) department = "";
    if (password == null) password = "";

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ✅ 修改3: SQL 改為更新 name, contact, password (移除不存在的 email 欄位)
        String sql = "UPDATE users SET name = ?, contact = ?, department = ?, password = ? WHERE userId = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(3, department);
        ps.setString(4, password);
        ps.setString(5, userId);
        
        // ✅ 修改4: 加入執行結果檢查
        int rowsAffected = ps.executeUpdate();
        
        if (rowsAffected > 0) {
            // 更新成功
            response.sendRedirect("profile.jsp");
        } else {
            // 沒有資料被更新 (userId 可能不存在)
            out.println("<script>alert('更新失敗：找不到使用者資料'); history.back();</script>");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // ✅ 修改5: 提供更詳細的錯誤訊息
        out.println("<script>alert('更新失敗：" + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>