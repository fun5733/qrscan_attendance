<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.ArrayList" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>content_list page</title>
<meta charset="utf-8" />
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script type="text/javascript">
function setCID(id) {
	callAjax(id);
}
function callAjax(value){	
	$.ajax({
		type: "post",
		async: false,
		url : "./view_list.jsp",
		data: {
			//content_id : $("#button").val(),
			content_id : value,
		},
		success: whenSuccess,
		error: whenError
	});
}
function whenSuccess(resdata){
	$("#ajaxReturn").html(resdata);
	System.out.println(resdata);
}
function whenError(){
	alert("Error");
}
</script>
</head>
<body>
<h2>일정 리스트</h2>
<%
	ArrayList<String> dates = new ArrayList<String>();
	Connection con = null;
	PreparedStatement stmt = null;
	String loginID = "";
	String idList ="";
	loginID = request.getParameter("loginID");
	String date ="";
%>
	<form action="new_content.jsp" method="post">
		<input name="loginID" value="<%=loginID%>" type="hidden">
		<input type="submit" value="새 일정 추가">
	</form>
	<form action="login.jsp">
		<input type="submit" value="로그인 화면으로">
	</form>
	<table border="1" id="tab">
	<tr>
		<td>일정명</td>
		<!-- <td>일정 번호</td> -->
		<td>시작일</td>
		<td>종료일</td>
		<td>주최자</td>
		<td>명단</td>
		<td>QR코드</td>
		<td>타입</td>
	</tr>
<%
	try {
		Class.forName("org.sqlite.JDBC");
		// con = DriverManager.getConnection("jdbc:sqlite:C:/Users/tmpl/workspace/JSPDB/WebContent/test.db");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_list";
		if(!loginID.equals("1105421")) {
			sql += " where CONTENT_LOGINID='"+loginID+"'";
			out.println("사번 : " + loginID + " 님의 일정 리스트");	
		}
		else out.println("관리자용");
		stmt = con.prepareStatement(sql);
		ResultSet rs = stmt.executeQuery();
		int id = 0;
		String cid="";
		while(rs.next()) {
			date ="";
			cid = rs.getString("CONTENT_ID");
%>
		<tr>
			<td><%=rs.getString("CONTENT_NAME") %></td> 
			<%-- <td><%=rs.getString("CONTENT_ID") %></td> --%>
			<td><%=rs.getString("CONTENT_DATE_START") %></td>
			<td><%=rs.getString("CONTENT_DATE_END") %></td>
			<td><%=rs.getString("CONTENT_HOST") %></td>
			<td><a href="javascript:setCID(<%=cid%>)">보기</a></td>
			<td>
				<form action="view.jsp" method="post">
					<input name="content_id" value="<%=rs.getString("CONTENT_ID") %>" type="hidden">
					<input type="submit" value="보기">
				</form>
			</td>
			<td><%=rs.getString("CONTENT_TYPE") %></td>
		</tr>			
<%	
			id++;
			date = rs.getString("CONTENT_DATE");
			int index_temp=-1;
			while(true) {
				index_temp = rs.getString("CONTENT_DATE").indexOf("<br>", index_temp+1);
				if(index_temp == -1) break;
				idList += rs.getString("CONTENT_ID") + " ";
			}	
			dates.add(date);
		}
	}
	catch(SQLException se) {
		System.out.println("SQL Exception: " + se.getMessage());
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
</table>
<div id="ajaxReturn"></div>
</body>
</html>