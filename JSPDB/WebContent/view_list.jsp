<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- 
	해당 일정 테이블의 출석 명단을 확인 가능
 --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>View page</title>
<script>
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var tb = document.getElementById("tb");
	
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		if(selectedHTML == "전체") {
			tb.rows[i].style = "display:visible";
		}
		else if(temp != selectedHTML) {
			tb.rows[i].style = "display:none";
		}
		else {
			tb.rows[i].style = "display:visible";
		}
	}

}
</script>
</head>
<body>
<%@ page import = "java.sql.*" %>
<%
	String content_id = request.getParameter("content_id");
	String date="", content_name="";
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_qr = null;
	try {
		Class.forName("org.sqlite.JDBC");
		// con = DriverManager.getConnection("jdbc:sqlite:C:/Users/tmpl/workspace/JSPDB/WebContent/test.db");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_member_list where CONTENT_ID = '"+content_id+"'";
		String sql_qr = "select * from content_list where CONTENT_ID='"+content_id+"' ";
		stmt = con.prepareStatement(sql);
		stmt_qr = con.prepareStatement(sql_qr);
		ResultSet rs = stmt.executeQuery();
		ResultSet rs_qr = stmt_qr.executeQuery();
		if(rs_qr.next()) {
			date = rs_qr.getString("CONTENT_DATE");
			content_name = rs_qr.getString("CONTENT_NAME");
		}
%>
<select id="id-codes" name="codes" onchange="change()">
		<option>전체</option>	
<%
	String[] arr = date.split("<br>");
	String codePath = request.getContextPath() + "/qrcode/images/" + content_id;
		
	for(int i=0; i<arr.length; i++) {
%>
		<option><%=arr[i] %></option>			
<%
	}
		
%>		
</select>
<table border="1" id="tb">
	<tr>
		<td>사번</td>
		<td>이름</td>
		<td>날짜</td>
		<td>출석</td>
	</tr>
<%
		while(rs.next()) {
%>
	<tr>
		<td><%=rs.getString("MEMBER_ID") %></td> 
		<td><%=rs.getString("MEMBER_NAME") %></td>
		<td><%=rs.getString("CONTENT_DATE") %>
		<td><%=rs.getString("ATTEND") %></td>
	</tr>			
<%	
		}
%>
</table>
<%
	}
	
	catch(SQLException se) {
		System.out.println("SQL Exception: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception: " + e.getMessage());
	}
	finally {
		try {
			if(con!=null) con.close();
			if(stmt!=null) stmt.close();
		}
		catch(SQLException se) {
			System.out.println("Exception");
		}
	}
%>
</body>
</html>