<!-- 
	content_list.jsp에서 클릭된 일정의 출석 명단을 생성,
	ajax를 통해 content_list의 특정 div에서 이를 표시
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<%@ page import = "myPackage.myDate" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>View page</title>
<link rel="stylesheet" href="css/style.css">
<script>
//셀렉트 박스 선택값이 바뀔 때 출석 명단을 해당 날짜의 것으로 교체해서 표시
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var tb = document.getElementById("tb");
	var count = tb.rows.length-1;	// 몇 명 출석인지 카운트
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		if(selectedHTML == "전체") {
			tb.rows[i].style = "display:visible";
			if(tb.rows[i].cells[3].innerHTML == "X") count--;
		}
		else if(temp != selectedHTML) {
			tb.rows[i].style = "display:none";
			count--;
		}
		else {
			tb.rows[i].style = "display:visible";
			if(tb.rows[i].cells[3].innerHTML == "X") count--;
		}
	}
	document.getElementById("count").innerHTML = count + "명 출석";
}
</script>
</head>
<body>
<%
	String content_id = request.getParameter("content_id");
	String date="", content_name="", cdatestart="", cdateend="";
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_qr = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_member_list where CONTENT_ID = '"+content_id+"'";
		String sql_qr = "select * from content_list where CONTENT_ID='"+content_id+"' ";
		stmt = con.prepareStatement(sql);
		stmt_qr = con.prepareStatement(sql_qr);
		ResultSet rs = stmt.executeQuery();
		ResultSet rs_qr = stmt_qr.executeQuery();
		if(rs_qr.next()) {
			//date = myDate.getDate(rs_qr.getString("CONTENT_DATE_START"), rs_qr.getString("CONTENT_DATE_END"));
			cdatestart = rs_qr.getString("CONTENT_DATE_START");
			cdateend = rs_qr.getString("CONTENT_DATE_END");
			content_name = rs_qr.getString("CONTENT_NAME");
		}
%>
<div class="select">
<select id="id-codes" name="codes" onchange="change()">
		<option>전체</option>	
<%-- <%
	String[] arr = date.split("<br>");
		
	for(int i=0; i<arr.length; i++) {
%>
		<option><%=arr[i] %></option>			
<%
	}
%>	 --%>
<%
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
	Calendar cal = Calendar.getInstance();
	java.util.Date startDate = df.parse(cdatestart);
	java.util.Date endDate = df.parse(cdateend);
	long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
	Integer days = (int)(long)diff + 1;
	cal.setTime(startDate);
	
	while(true) {	
%>
		<option><%=df.format(cal.getTime()) %></option>
<%	
		if(df.format(cal.getTime()).equals(cdateend)) break;
		cal.add(Calendar.DATE, 1); // 날짜 1 증가
	}
%>	
</select>
</div>
<table border="1" id="tb">
	<tr>
		<td>사번</td>
		<td>이름</td>
		<td>날짜</td>
		<td>출석</td>
	</tr>
<%
		int count = 0;
		while(rs.next()) {
%>
	<tr>
		<td><%=rs.getString("MEMBER_ID") %></td> 
		<td><%=rs.getString("MEMBER_NAME") %></td>
		<td><%=rs.getString("CONTENT_DATE") %>
		<td><%=rs.getString("ATTEND") %></td>
	</tr>			
<%	
			if(!rs.getString("ATTEND").equals("X")) {
				count++;
			}
		}
%>
</table>
<!-- 몇 명 출석했는지를 표시 -->
<p id="count"><%=count %>명 출석</p>
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