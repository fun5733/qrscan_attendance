<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>    
<%-- 
	새로운 일정을 추가하기 위한 정보를 입력받음
 --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>new content page</title>
<style>
	span {
		display : inline-block;
		width : 80px;
	}
</style>
<%
	String loginID = request.getParameter("loginID");
%>
<script>
function check_kako() {
	var now = new Date().toISOString().substring(0, 10);
}
function validateForm() {
	var cid = document.forms["myForm"]["txtCID"].value;
	var cname = document.forms["myForm"]["txtCNAME"].value;
	var chost = document.forms["myForm"]["txtCHOST"].value;
	var cdatestart = document.forms["myForm"]["txtCDATE_START"].value;
	var cdateend = document.forms["myForm"]["txtCDATE_END"].value;
	if(cname == "" || cid == ""  || chost == "" || cdatestart == "") {
		alert("빈 칸을 채워주세요");
		return false;
	}
	else if(cdateend == "") {
		document.forms["myForm"]["txtCDATE_END"].value = cdatestart;
	}
	else if(cdateend < cdatestart) {
		alert("종료일이 시작일보다 빠르게 입력되어있습니다");
		document.forms["myForm"]["txtCDATE_END"].value = "";
		return false;
	}
	return true;
}
</script>
</head>
<body>
<%
	Connection con = null;
	PreparedStatement stmt = null;
	int cid = 0;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_list";
		stmt = con.prepareStatement(sql);
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			if(cid < rs.getInt("CONTENT_ID")) 
				cid = rs.getInt("CONTENT_ID");
		}
		cid++;
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
<form name="myForm" action="make_new_content.jsp" method="post" onsubmit="return validateForm()">
	<span>일정명</span> 	<input type="text" name="txtCNAME"><br>
	<input type=hidden name="txtCID" value="<%=cid%>">					
	<span>시작일</span>  <input type="date" name="txtCDATE_START"><br>
	<span>종료일</span>  <input type="date" name="txtCDATE_END"><br>
	<span>주최자</span> 	<input type="text" name="txtCHOST"><br>
	<span>타입</span>  	<input type="radio" name="txtCTYPE" value="free" checked="checked">자유참가
		 				<input type="radio" name="txtCTYPE" value="apply">신청참가
	<input type="hidden" name="txtCLOGINID" value="<%=loginID %>">
	<br><input type="submit" value="추가">
</form>	
</body>
</html>