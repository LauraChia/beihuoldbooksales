<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>資料庫檢查工具</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.6.1/mermaid.min.js"></script>
    <style>
        body { 
            font-family: 'Microsoft JhengHei', Arial, sans-serif; 
            padding: 20px; 
            background-color: #f5f5f5;
        }
        .container { 
            max-width: 1400px; 
            margin: 0 auto; 
            background: white; 
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { 
            color: #333; 
            border-bottom: 3px solid #4CAF50; 
            padding-bottom: 10px;
        }
        /* 目錄樣式 */
        #toc {
            background: #f9f9f9;
            border: 2px solid #4CAF50;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        #toc h2 {
            margin-top: 0;
            color: #4CAF50;
        }
        #toc ul {
            list-style: none;
            padding-left: 0;
        }
        #toc li {
            margin: 8px 0;
        }
        #toc a {
            color: #333;
            text-decoration: none;
            padding: 5px 10px;
            display: block;
            border-radius: 4px;
            transition: all 0.3s;
        }
        #toc a:hover {
            background: #4CAF50;
            color: white;
        }
        
        /* ER 圖樣式 */
        .er-diagram {
            background: white;
            border: 2px solid #2196F3;
            border-radius: 8px;
            padding: 20px;
            margin: 30px 0;
        }
        .er-diagram h2 {
            color: #2196F3;
        }
        
        /* 表格樣式 */
        .table-section {
            margin: 40px 0;
            scroll-margin-top: 20px;
        }
        table { 
            border-collapse: collapse; 
            margin: 20px 0; 
            width: 100%;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 12px; 
            text-align: left; 
        }
        th { 
            background-color: #4CAF50; 
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        
        .error { color: red; font-weight: bold; }
        .success { color: green; }
        .info { 
            background: #e3f2fd; 
            padding: 10px; 
            border-left: 4px solid #2196F3;
            margin: 10px 0;
        }
        
        .table-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 8px 8px 0 0;
            margin-top: 20px;
        }
        
        .relations {
            background: #fff3cd;
            border: 1px solid #ffc107;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        
        .back-to-top {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background: #4CAF50;
            color: white;
            padding: 10px 15px;
            border-radius: 50px;
            text-decoration: none;
            box-shadow: 0 2px 5px rgba(0,0,0,0.3);
        }
        .back-to-top:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 資料庫檢查工具</h1>
        
        <%
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
            DatabaseMetaData metaData = con.getMetaData();
            
            // 收集所有表格資訊
            List<String> tableNames = new ArrayList<>();
            Map<String, List<String[]>> foreignKeys = new HashMap<>();
            
            ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"});
            while (tables.next()) {
                String tableName = tables.getString("TABLE_NAME");
                if (!tableName.startsWith("MSys")) { // 排除系統表
                    tableNames.add(tableName);
                    
                    // 獲取外鍵關係
                    ResultSet fks = metaData.getImportedKeys(null, null, tableName);
                    List<String[]> fkList = new ArrayList<>();
                    while (fks.next()) {
                        String pkTable = fks.getString("PKTABLE_NAME");
                        String pkColumn = fks.getString("PKCOLUMN_NAME");
                        String fkColumn = fks.getString("FKCOLUMN_NAME");
                        fkList.add(new String[]{pkTable, pkColumn, fkColumn});
                    }
                    if (!fkList.isEmpty()) {
                        foreignKeys.put(tableName, fkList);
                    }
                    fks.close();
                }
            }
            tables.close();
            
            out.println("<h2 class='success'>✓ 資料庫連接成功</h2>");
            out.println("<div class='info'>共找到 <strong>" + tableNames.size() + "</strong> 個資料表</div>");
            
            // 生成目錄
            out.println("<div id='toc'>");
            out.println("<h2>📑 快速導覽</h2>");
            out.println("<ul>");
            out.println("<li><a href='#er-diagram'>🔗 資料表關聯圖</a></li>");
            for (String tableName : tableNames) {
                out.println("<li><a href='#table-" + tableName + "'>📋 " + tableName + "</a></li>");
            }
            out.println("</ul>");
            out.println("</div>");
            
            // 生成 ER 圖
            out.println("<div id='er-diagram' class='er-diagram'>");
            out.println("<h2>🔗 資料表關聯圖 (ER Diagram)</h2>");
            
            if (!foreignKeys.isEmpty()) {
                out.println("<pre class='mermaid'>");
                out.println("erDiagram");
                
                for (Map.Entry<String, List<String[]>> entry : foreignKeys.entrySet()) {
                    String fkTable = entry.getKey();
                    for (String[] fk : entry.getValue()) {
                        String pkTable = fk[0];
                        String pkColumn = fk[1];
                        String fkColumn = fk[2];
                        // 格式: PKTABLE ||--o{ FKTABLE : "FK關係"
                        out.println("    " + pkTable + " ||--o{ " + fkTable + " : \"" + pkColumn + " -> " + fkColumn + "\"");
                    }
                }
                out.println("</pre>");
            } else {
                out.println("<p class='info'>此資料庫沒有定義外鍵關係，或使用的資料庫類型不支援外鍵資訊讀取。</p>");
            }
            out.println("</div>");
            
            // 顯示每個表格的詳細資訊
            for (String tableName : tableNames) {
                out.println("<div id='table-" + tableName + "' class='table-section'>");
                out.println("<div class='table-header'>");
                out.println("<h2>📋 表格: " + tableName + "</h2>");
                out.println("</div>");
                
                // 顯示外鍵關係
                if (foreignKeys.containsKey(tableName)) {
                    out.println("<div class='relations'>");
                    out.println("<strong>🔗 外鍵關係：</strong><br>");
                    for (String[] fk : foreignKeys.get(tableName)) {
                        out.println("→ 參考 <strong>" + fk[0] + "</strong>." + fk[1] + " (本表欄位: " + fk[2] + ")<br>");
                    }
                    out.println("</div>");
                }
                
                // 顯示欄位結構
                ResultSet columns = metaData.getColumns(null, null, tableName, "%");
                out.println("<h3>欄位結構</h3>");
                out.println("<table>");
                out.println("<tr><th>欄位名稱</th><th>資料類型</th><th>大小</th><th>可為空</th><th>預設值</th></tr>");
                
                while (columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    int columnSize = columns.getInt("COLUMN_SIZE");
                    String nullable = columns.getString("IS_NULLABLE");
                    String defaultValue = columns.getString("COLUMN_DEF");
                    
                    out.println("<tr>");
                    out.println("<td><strong>" + columnName + "</strong></td>");
                    out.println("<td>" + columnType + "</td>");
                    out.println("<td>" + columnSize + "</td>");
                    out.println("<td>" + nullable + "</td>");
                    out.println("<td>" + (defaultValue != null ? defaultValue : "-") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
                columns.close();
                
                // 顯示資料內容
                try {
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM [" + tableName + "]");
                    ResultSetMetaData rsmd = rs.getMetaData();
                    int columnCount = rsmd.getColumnCount();
                    
                    out.println("<h3>資料內容</h3>");
                    out.println("<table>");
                    out.println("<tr>");
                    for (int i = 1; i <= columnCount; i++) {
                        out.println("<th>" + rsmd.getColumnName(i) + "</th>");
                    }
                    out.println("</tr>");
                    
                    int rowCount = 0;
                    while (rs.next() && rowCount < 100) { // 限制顯示100筆
                        out.println("<tr>");
                        for (int i = 1; i <= columnCount; i++) {
                            String value = rs.getString(i);
                            out.println("<td>" + (value != null ? value : "<em>NULL</em>") + "</td>");
                        }
                        out.println("</tr>");
                        rowCount++;
                    }
                    out.println("</table>");
                    out.println("<p class='info'>共 " + rowCount + " 筆資料" + (rowCount >= 100 ? " (僅顯示前100筆)" : "") + "</p>");
                    rs.close();
                    stmt.close();
                } catch (Exception e) {
                    out.println("<p class='error'>無法讀取資料: " + e.getMessage() + "</p>");
                }
                
                out.println("</div>");
                out.println("<hr>");
            }
            
            con.close();
            
        } catch (Exception e) {
            out.println("<h2 class='error'>✗ 發生錯誤</h2>");
            out.println("<p class='error'>" + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        }
        %>
        
    </div>
    
    <a href="#" class="back-to-top">↑ 回到頂部</a>
    
    <script>
        mermaid.initialize({ startOnLoad: true, theme: 'default' });
    </script>
</body>
</html>