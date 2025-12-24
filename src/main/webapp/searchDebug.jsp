<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<html>
<head>
    <meta charset="utf-8">
    <title>搜尋除錯頁面</title>
    <style>
        body { 
            font-family: "Microsoft JhengHei", monospace; 
            padding: 20px; 
            background: #f5f5f5;
        }
        .section { 
            background: white; 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .section h2 { 
            color: #333; 
            border-bottom: 2px solid #d9534f;
            padding-bottom: 10px;
        }
        .sql-box { 
            background: #f8f9fa; 
            padding: 15px; 
            border-left: 4px solid #007bff;
            margin: 10px 0;
            overflow-x: auto;
        }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin: 10px 0;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 8px; 
            text-align: left; 
        }
        th { 
            background-color: #007bff; 
            color: white; 
        }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .param { 
            background: #e7f3ff; 
            padding: 10px; 
            margin: 10px 0;
            border-radius: 4px;
        }
        pre {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <h1>🔍 搜尋功能除錯頁面</h1>

<%
    String type = request.getParameter("type");
    String query = request.getParameter("query");
    
    Connection con = null;
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
%>

<!-- 第1步：顯示接收到的參數 -->
<div class="section">
    <h2>步驟 1️⃣：接收到的參數</h2>
    <div class="param">
        <strong>搜尋類型 (type):</strong> <%= type != null ? type : "<span class='error'>NULL</span>" %><br>
        <strong>搜尋關鍵字 (query):</strong> <%= query != null ? query : "<span class='error'>NULL</span>" %><br>
        <strong>參數是否有效:</strong> 
        <% if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) { %>
            <span class="success">✓ 有效</span>
        <% } else { %>
            <span class="error">✗ 無效（參數為空）</span>
        <% } %>
    </div>
</div>

<!-- 第2步：檢查資料庫連線 -->
<div class="section">
    <h2>步驟 2️⃣：資料庫連線狀態</h2>
    <% if(con != null && !con.isClosed()) { %>
        <p class="success">✓ 資料庫連線成功</p>
        <p>資料庫路徑: <%= objDBConfig.FilePath() %></p>
    <% } else { %>
        <p class="error">✗ 資料庫連線失敗</p>
    <% } %>
</div>

<!-- 第3步：檢查各資料表的資料 -->
<div class="section">
    <h2>步驟 3️⃣：檢查資料表內容</h2>
    
    <h3>📚 books 表</h3>
    <%
        Statement smt1 = con.createStatement();
        ResultSet rs1 = smt1.executeQuery("SELECT COUNT(*) as cnt FROM books");
        rs1.next();
        int bookCount = rs1.getInt("cnt");
    %>
    <p>總書籍數: <strong><%= bookCount %></strong></p>
    
    <% if(bookCount > 0) { %>
        <p>前5筆資料:</p>
        <table>
            <tr><th>bookId</th><th>title</th><th>author</th></tr>
            <%
                ResultSet rs1a = smt1.executeQuery("SELECT TOP 5 bookId, title, author FROM books");
                while(rs1a.next()) {
            %>
            <tr>
                <td><%= rs1a.getString("bookId") %></td>
                <td><%= rs1a.getString("title") %></td>
                <td><%= rs1a.getString("author") %></td>
            </tr>
            <% } %>
        </table>
    <% } %>
    
    <h3>📋 bookListings 表</h3>
    <%
        Statement smt2 = con.createStatement();
        ResultSet rs2 = smt2.executeQuery("SELECT COUNT(*) as cnt FROM bookListings");
        rs2.next();
        int listingCount = rs2.getInt("cnt");
    %>
    <p>總刊登數: <strong><%= listingCount %></strong></p>
    
    <%
        ResultSet rs2a = smt2.executeQuery(
            "SELECT COUNT(*) as cnt FROM bookListings WHERE isDelisted = false AND Approved = 'approved'"
        );
        rs2a.next();
        int approvedCount = rs2a.getInt("cnt");
    %>
    <p>已核准且未下架: <strong class="<%= approvedCount > 0 ? "success" : "error" %>"><%= approvedCount %></strong></p>
    
    <% if(approvedCount > 0) { %>
        <p>前5筆已核准的資料:</p>
        <table>
            <tr><th>bookId</th><th>price</th><th>Approved</th><th>isDelisted</th></tr>
            <%
                ResultSet rs2b = smt2.executeQuery(
                    "SELECT TOP 5 bookId, price, Approved, isDelisted FROM bookListings WHERE isDelisted = false AND Approved = 'approved'"
                );
                while(rs2b.next()) {
            %>
            <tr>
                <td><%= rs2b.getString("bookId") %></td>
                <td><%= rs2b.getString("price") %></td>
                <td><%= rs2b.getString("Approved") %></td>
                <td><%= rs2b.getBoolean("isDelisted") %></td>
            </tr>
            <% } %>
        </table>
    <% } else { %>
        <p class="warning">⚠️ 沒有已核准且未下架的書籍！這就是為什麼搜尋不到結果。</p>
        <p>檢查所有 bookListings 的狀態:</p>
        <table>
            <tr><th>bookId</th><th>Approved</th><th>isDelisted</th></tr>
            <%
                ResultSet rs2c = smt2.executeQuery("SELECT TOP 10 bookId, Approved, isDelisted FROM bookListings");
                while(rs2c.next()) {
            %>
            <tr>
                <td><%= rs2c.getString("bookId") %></td>
                <td><%= rs2c.getString("Approved") %></td>
                <td><%= rs2c.getBoolean("isDelisted") %></td>
            </tr>
            <% } %>
        </table>
    <% } %>
</div>

<!-- 第4步：測試基本 JOIN 查詢 -->
<div class="section">
    <h2>步驟 4️⃣：測試 books 和 bookListings 的 JOIN</h2>
    
    <div class="sql-box">
        <pre>SELECT b.bookId, b.title, b.author, bl.price, bl.Approved, bl.isDelisted
FROM books b 
INNER JOIN bookListings bl ON b.bookId = bl.bookId 
WHERE bl.isDelisted = false AND bl.Approved = 'approved'</pre>
    </div>
    
    <%
        Statement smt3 = con.createStatement();
        ResultSet rs3 = smt3.executeQuery(
            "SELECT COUNT(*) as cnt FROM books b " +
            "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
            "WHERE bl.isDelisted = false AND bl.Approved = 'approved'"
        );
        rs3.next();
        int joinCount = rs3.getInt("cnt");
    %>
    
    <p>JOIN 後的結果數: <strong class="<%= joinCount > 0 ? "success" : "error" %>"><%= joinCount %></strong></p>
    
    <% if(joinCount > 0) { %>
        <p>前5筆資料:</p>
        <table>
            <tr><th>bookId</th><th>title</th><th>author</th><th>price</th></tr>
            <%
                ResultSet rs3a = smt3.executeQuery(
                    "SELECT TOP 5 b.bookId, b.title, b.author, bl.price " +
                    "FROM books b " +
                    "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
                    "WHERE bl.isDelisted = false AND bl.Approved = 'approved'"
                );
                while(rs3a.next()) {
            %>
            <tr>
                <td><%= rs3a.getString("bookId") %></td>
                <td><%= rs3a.getString("title") %></td>
                <td><%= rs3a.getString("author") %></td>
                <td><%= rs3a.getString("price") %></td>
            </tr>
            <% } %>
        </table>
    <% } %>
</div>

<!-- 第5步：測試你的搜尋條件 -->
<% if(query != null && !query.trim().isEmpty() && type != null && !type.trim().isEmpty()) { %>
<div class="section">
    <h2>步驟 5️⃣：測試搜尋條件</h2>
    
    <%
        String testSql = "";
        String whereClause = "";
        
        if("title".equals(type)) {
            whereClause = "b.title LIKE '%" + query + "%'";
            testSql = "SELECT b.bookId, b.title, b.author, bl.price " +
                     "FROM books b " +
                     "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
                     "WHERE bl.isDelisted = false AND bl.Approved = 'approved' AND " + whereClause;
        } else if("author".equals(type)) {
            whereClause = "b.author LIKE '%" + query + "%'";
            testSql = "SELECT b.bookId, b.title, b.author, bl.price " +
                     "FROM books b " +
                     "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
                     "WHERE bl.isDelisted = false AND bl.Approved = 'approved' AND " + whereClause;
        }
    %>
    
    <p><strong>搜尋條件:</strong> <%= whereClause %></p>
    
    <div class="sql-box">
        <pre><%= testSql %></pre>
    </div>
    
    <%
        if(!testSql.isEmpty()) {
            Statement smt4 = con.createStatement();
            ResultSet rs4 = smt4.executeQuery(testSql);
            
            int searchCount = 0;
    %>
    
    <h3>搜尋結果:</h3>
    <table>
        <tr><th>bookId</th><th>title</th><th>author</th><th>price</th></tr>
        <%
            while(rs4.next()) {
                searchCount++;
        %>
        <tr>
            <td><%= rs4.getString("bookId") %></td>
            <td><%= rs4.getString("title") %></td>
            <td><%= rs4.getString("author") %></td>
            <td><%= rs4.getString("price") %></td>
        </tr>
        <% } %>
    </table>
    
    <% if(searchCount == 0) { %>
        <p class="error">❌ 搜尋不到結果！</p>
        
        <h3>🔍 進一步診斷：</h3>
        
        <!-- 檢查是否有符合的書籍但未核准 -->
        <%
            String diagSql = "";
            if("title".equals(type)) {
                diagSql = "SELECT b.bookId, b.title, bl.Approved, bl.isDelisted " +
                         "FROM books b " +
                         "LEFT JOIN bookListings bl ON b.bookId = bl.bookId " +
                         "WHERE b.title LIKE '%" + query + "%'";
            } else if("author".equals(type)) {
                diagSql = "SELECT b.bookId, b.title, b.author, bl.Approved, bl.isDelisted " +
                         "FROM books b " +
                         "LEFT JOIN bookListings bl ON b.bookId = bl.bookId " +
                         "WHERE b.author LIKE '%" + query + "%'";
            }
            
            if(!diagSql.isEmpty()) {
                ResultSet rs5 = smt4.executeQuery(diagSql);
                boolean foundAny = false;
        %>
        
        <p>檢查所有符合關鍵字的書籍（不管狀態）:</p>
        <table>
            <tr><th>bookId</th><th>title</th><% if("author".equals(type)) { %><th>author</th><% } %><th>Approved</th><th>isDelisted</th><th>問題</th></tr>
            <%
                while(rs5.next()) {
                    foundAny = true;
                    String approved = rs5.getString("Approved");
                    boolean delisted = rs5.getBoolean("isDelisted");
                    String issue = "";
                    
                    if(approved == null) {
                        issue = "沒有 listing 資料";
                    } else if(!"approved".equals(approved)) {
                        issue = "狀態不是 approved (是: " + approved + ")";
                    } else if(delisted) {
                        issue = "已下架";
                    } else {
                        issue = "正常（應該要顯示）";
                    }
            %>
            <tr>
                <td><%= rs5.getString("bookId") %></td>
                <td><%= rs5.getString("title") %></td>
                <% if("author".equals(type)) { %><td><%= rs5.getString("author") %></td><% } %>
                <td><%= approved %></td>
                <td><%= delisted %></td>
                <td class="<%= issue.contains("正常") ? "success" : "warning" %>"><%= issue %></td>
            </tr>
            <% } %>
        </table>
        
        <% if(!foundAny) { %>
            <p class="error">❌ 資料庫中完全沒有符合「<%= query %>」的書籍資料！</p>
            <p>建議：</p>
            <ul>
                <li>檢查資料庫中的書名/作者拼寫是否正確</li>
                <li>確認是否有輸入該書籍到資料庫</li>
                <li>檢查是否有多餘的空格或特殊字元</li>
            </ul>
        <% } %>
        
        <% } %>
    <% } else { %>
        <p class="success">✓ 找到 <%= searchCount %> 筆結果</p>
    <% } %>
    
    <% } %>
</div>
<% } %>

<!-- 第6步：提供測試連結 -->
<div class="section">
    <h2>步驟 6️⃣：快速測試</h2>
    <p>使用以下連結測試搜尋功能：</p>
    <ul>
        <li><a href="searchDebug.jsp?type=title&query=測試" target="_blank">搜尋書名：測試</a></li>
        <li><a href="searchDebug.jsp?type=author&query=王" target="_blank">搜尋作者：王</a></li>
        <% 
            // 取得第一本書的資料來產生測試連結
            if(joinCount > 0) {
                Statement smtTest = con.createStatement();
                ResultSet rsTest = smtTest.executeQuery(
                    "SELECT TOP 1 b.title, b.author FROM books b " +
                    "INNER JOIN bookListings bl ON b.bookId = bl.bookId " +
                    "WHERE bl.isDelisted = false AND bl.Approved = 'approved'"
                );
                if(rsTest.next()) {
                    String testTitle = rsTest.getString("title");
                    String testAuthor = rsTest.getString("author");
        %>
        <li><a href="searchDebug.jsp?type=title&query=<%= java.net.URLEncoder.encode(testTitle.substring(0, Math.min(2, testTitle.length())), "UTF-8") %>" target="_blank">搜尋實際書名前幾個字：<%= testTitle.substring(0, Math.min(3, testTitle.length())) %></a></li>
        <li><a href="searchDebug.jsp?type=author&query=<%= java.net.URLEncoder.encode(testAuthor, "UTF-8") %>" target="_blank">搜尋實際作者：<%= testAuthor %></a></li>
        <% 
                }
            }
        %>
    </ul>
</div>

<%
        con.close();
    } catch(Exception e) {
%>
        <div class="section">
            <h2 class="error">❌ 發生錯誤</h2>
            <pre><%= e.toString() %></pre>
            <pre><%= e.getMessage() %></pre>
            <%
                java.io.StringWriter sw = new java.io.StringWriter();
                e.printStackTrace(new java.io.PrintWriter(sw));
            %>
            <pre><%= sw.toString() %></pre>
        </div>
<%
    } finally {
        if(con != null && !con.isClosed()) {
            con.close();
        }
    }
%>

</body>
