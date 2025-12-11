<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>檢查資料庫欄位</title>
    <style>
        body { font-family: monospace; padding: 20px; }
        table { border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>資料庫欄位檢查工具</h1>
    
    <%
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
        
        // 獲取資料庫元數據
        DatabaseMetaData metaData = con.getMetaData();
        
        // 獲取所有表格
        ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"});
        
        out.println("<h2 class='success'>✓ 資料庫連接成功</h2>");
        out.println("<h3>資料庫中的所有表格：</h3>");
        
        while (tables.next()) {
            String tableName = tables.getString("TABLE_NAME");
            out.println("<hr>");
            out.println("<h3>表格: " + tableName + "</h3>");
            
            // 獲取該表格的所有欄位
            ResultSet columns = metaData.getColumns(null, null, tableName, "%");
            
            out.println("<table>");
            out.println("<tr><th>欄位名稱</th><th>資料類型</th><th>大小</th><th>可為空</th></tr>");
            
            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String columnType = columns.getString("TYPE_NAME");
                int columnSize = columns.getInt("COLUMN_SIZE");
                String nullable = columns.getString("IS_NULLABLE");
                
                out.println("<tr>");
                out.println("<td><strong>" + columnName + "</strong></td>");
                out.println("<td>" + columnType + "</td>");
                out.println("<td>" + columnSize + "</td>");
                out.println("<td>" + nullable + "</td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
            columns.close();
            
            // 顯示所有資料
            try {
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM " + tableName);
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                
                out.println("<h4>所有資料：</h4>");
                out.println("<table>");
                out.println("<tr>");
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<th>" + rsmd.getColumnName(i) + "</th>");
                }
                out.println("</tr>");
                
                int rowCount = 0;
                while (rs.next()) {
                    out.println("<tr>");
                    for (int i = 1; i <= columnCount; i++) {
                        out.println("<td>" + (rs.getString(i) != null ? rs.getString(i) : "NULL") + "</td>");
                    }
                    out.println("</tr>");
                    rowCount++;
                }
                
                out.println("</table>");
                out.println("<p>共 " + rowCount + " 筆資料</p>");
                rs.close();
                stmt.close();
            } catch (Exception e) {
                out.println("<p class='error'>無法讀取資料: " + e.getMessage() + "</p>");
            }
        }
        
        tables.close();
        con.close();
        
    } catch (Exception e) {
        out.println("<h2 class='error'>✗ 錯誤</h2>");
        out.println("<p class='error'>" + e.getMessage() + "</p>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    }
    %>
    
</body>
</html>