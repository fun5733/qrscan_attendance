<!-- 
	login.jsp에서 전달받은 사번으로 등록된 일정들을 표시
	각 일정의 출석 명단, QR코드 확인 가능
	리스트에 있는 일정을 삭제하거나 새로운 일정 등록 가능 
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>content_list page</title>
<meta charset="utf-8" />
<link rel="stylesheet" href="css/style.css">
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script type="text/javascript">
// ajax를 이용해 명단 보기가 클릭되면 view_list.jsp에서 갱신된 테이블 내용을 받아 화면에 표시
function setCID(id) {
	callAjax(id);
}
function callAjax(value){	
	$.ajax({
		type: "post",
		async: false,
		url : "./view_list.jsp",
		data: {
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
// 일정 삭제 버튼을 눌렀을 때 물어보는 알림창 표시
function deletePage(cid, cloginid) {
	if(confirm("삭제하시겠습니까?") == true) {
		location.href = "delete.jsp?content_id=" + cid + "&content_loginid=" + cloginid;
	}
}
</script>
</head>
<body>
<%
	Connection con = null;
	PreparedStatement stmt = null;
	String loginID = "";
	loginID = request.getParameter("loginID");
%>
<div class="center">
<div class="select">
<h1>일정 리스트</h1>
<form action="new_content.jsp" method="post">
	<input name="loginID" value="<%=loginID%>" type="hidden">
	<input type="submit" value="새 일정 추가">
</form>
<form action="login.jsp">
	<input type="submit" value="로그인 화면으로">
</form>
</div>
<br>
	<table border="1" id="tab">
	<tr>
		<td>일정명</td>
		<td>시작일</td>
		<td>종료일</td>
		<td>주최자</td>
		<td>명단</td>
		<td>QR코드</td>
		<td>타입</td>
		<td>삭제</td>
	</tr>
<%
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_list";
		// 로그인 아이디가 1105421이면 관리자용으로 접속 -> 모든 일정이 표시됨
		if(!loginID.equals("1105421")) {
			sql += " where CONTENT_LOGINID='"+loginID+"'";
			out.println("사번 : " + loginID + " 님의 일정 리스트");	
		}
		else out.println("관리자용");
		
		stmt = con.prepareStatement(sql);
		ResultSet rs = stmt.executeQuery();
		String cid="";
		// 반복문을 돌면서 일정 리스트 출력
		while(rs.next()) {
			cid = rs.getString("CONTENT_ID");
%>
		<tr>
			<td><%=rs.getString("CONTENT_NAME") %></td> 
			<td><%=rs.getString("CONTENT_DATE_START") %></td>
			<td><%=rs.getString("CONTENT_DATE_END") %></td>
			<td><%=rs.getString("CONTENT_HOST") %></td>
			<td><a href="javascript:setCID(<%=cid%>)">보기</a></td>		<!-- 클릭하면 ajax로 값을 넘겨 화면을 부분적(div id=ajaxReturn)으로 갱신되게 함 -->
			<td>
				<form action="view.jsp" method="post">
					<input name="content_id" value="<%=rs.getString("CONTENT_ID") %>" type="hidden">
					<input type="submit" value="보기">
				</form>
			</td>
			<td><%=rs.getString("CONTENT_TYPE") %></td>
			<td>
				<button type="button" onclick="deletePage(<%=rs.getString("CONTENT_ID") %>, <%=rs.getString("CONTENT_LOGINID") %>)">삭제</button>
			</td>
		</tr>			
<%	
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
<br>
<div id="ajaxReturn"></div> <!-- view_list.jsp에서 갱신된 화면을 표시할 div -->
</div>
</body>
</html>