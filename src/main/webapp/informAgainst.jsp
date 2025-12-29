<%@page contentType="text/html" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='hitstd.group.tool.database.DBConfig' />

<%
    String reportLoggedInUserId = (String) session.getAttribute("userId");
    if (reportLoggedInUserId == null || reportLoggedInUserId.trim().isEmpty()) {
        response.sendRedirect("login.jsp?redirect=" + request.getRequestURI());
        return;
    }

    String bookId = request.getParameter("bookId");
    String message = "";
    String messageType = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String reason = request.getParameter("reason");
        if (reason != null && !reason.trim().isEmpty() && bookId != null && !bookId.trim().isEmpty()) {
            try {
                Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
                Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
                String sql = "INSERT INTO reports (userId, bookId, reason) VALUES (?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, reportLoggedInUserId);
                ps.setString(2, bookId);
                ps.setString(3, reason);
                ps.executeUpdate();
                ps.close();
                con.close();

                response.sendRedirect("report.jsp?bookId=" + bookId + "&success=1");
                return;
            } catch(Exception e) {
                message = "舉報失敗：" + e.getMessage();
                messageType = "error";
            }
        } else {
            message = "請填寫舉報原因";
            messageType = "error";
        }
    }

    if ("1".equals(request.getParameter("success"))) {
        message = "舉報成功，管理員將會處理此書籍";
        messageType = "success";
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>舉報書籍 - 北護二手書交易網</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="https://use.fontawesome.com/releases/v5.15.4/css/all.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: "Microsoft JhengHei", sans-serif;
        }
        
        /* 頁面標題 - 使用淺綠色 */
        .report-header {
            background: #81c784;
            color: white;
            padding: 40px;
            text-align: center;
            margin: 150px auto 50px;
            box-shadow: 0 10px 15px rgba(102, 187, 106, 0.3);
        }
        
        .report-header h1 {
            font-size: 2em;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .report-header p {
            margin: 0;
            opacity: 0.95;
        }
        
        .container-custom {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 20px 60px;
        }
        
        .report-form {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            font-weight: 700;
            color: #333;
            margin-bottom: 10px;
            display: block;
            font-size: 1.05em;
        }
        
        .form-label .required {
            color: #e57373;
            margin-left: 3px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s;
            font-family: inherit;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #81c784;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 150px;
            line-height: 1.6;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 35px;
            justify-content: center;
        }
        
        /* 提交按鈕 - 使用淺綠色 */
        .btn-submit {
            background: linear-gradient(135deg, #81c784 0%, #66bb6a 100%);
            color: white;
            padding: 14px 50px;
            border: none;
            border-radius: 25px;
            font-weight: 700;
            font-size: 1.1em;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-submit:hover {
            background: linear-gradient(135deg, #66bb6a 0%, #4caf50 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(129, 199, 132, 0.4);
        }
        
        .btn-cancel {
            background: white;
            color: #666;
            padding: 14px 50px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-weight: 600;
            font-size: 1.1em;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-cancel:hover {
            border-color: #999;
            color: #333;
            text-decoration: none;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ef9a9a;
        }
        
        .alert-success {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
        }
        
        .char-count {
            text-align: right;
            color: #999;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        .form-hint {
            color: #999;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        .warning-box {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 25px;
            color: #856404;
        }
        
        .warning-box i {
            margin-right: 8px;
        }
        
        @media (max-width: 768px) {
            .report-form {
                padding: 25px;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn-submit,
            .btn-cancel {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="menu.jsp"%>
    
    <div class="report-header">
        <h1><i class="fas fa-flag"></i> 舉報書籍</h1>
        <p>幫助我們維護良好的交易環境</p>
    </div>
    
    <div class="container-custom">
        <form method="post" class="report-form" id="reportForm">
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <i class="fas fa-<%= messageType.equals("error") ? "exclamation-circle" : "check-circle" %>"></i> 
                    <%= message %>
                </div>
            <% } %>
            
            <div class="warning-box">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>舉報須知：</strong>請確實說明舉報原因，我們會仔細審核每一則舉報。惡意舉報可能會影響您的帳號使用權限。
            </div>
            
            <div class="form-group">
                <label class="form-label" for="bookId">書籍編號</label>
                <input type="text" 
                       id="bookId" 
                       name="bookId" 
                       class="form-control" 
                       value="<%= bookId != null ? bookId : "" %>"
                       readonly
                       style="background-color: #f5f5f5;">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="reason">舉報原因 <span class="required">*</span></label>
                <textarea id="reason" 
                          name="reason" 
                          class="form-control" 
                          placeholder="請詳細說明舉報原因，例如：書籍資訊不實、圖片與實物不符、價格異常、涉嫌詐騙等..." 
                          maxlength="500"
                          required></textarea>
                <div class="char-count">
                    <span id="reasonCount">0</span> / 500 字
                </div>
                <p class="form-hint">
                    <i class="fas fa-info-circle"></i> 請提供具體的舉報理由，以便管理員快速處理
                </p>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> 送出舉報
                </button>
                <a href="index.jsp" class="btn-cancel">
                    <i class="fas fa-times"></i> 取消
                </a>
            </div>
        </form>
    </div>
    
<%@ include file="footer.jsp"%>
    
    <script>
        // 字數統計
        const reasonInput = document.getElementById('reason');
        const reasonCount = document.getElementById('reasonCount');
        
        reasonInput.addEventListener('input', function() {
            reasonCount.textContent = this.value.length;
        });
        
        // 表單驗證
        document.getElementById('reportForm').addEventListener('submit', function(e) {
            const reason = reasonInput.value.trim();
            if (reason.length < 10) {
                e.preventDefault();
                alert('請至少輸入 10 個字的舉報原因');
                return false;
            }
        });
    </script>
</body>
</html>