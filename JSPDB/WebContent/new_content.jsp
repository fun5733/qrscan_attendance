<!-- 
	새로운 일정을 등록하는 버튼을 누르면 오게 되는 페이지
	새로운 일정의 정보를 입력받아서 make_new_content.jsp로 전달
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>new content page</title>
<link rel="stylesheet" href="css/style.css">
<style>
	div { zoom : 1.1;}
</style>
<% String loginID = request.getParameter("loginID"); %>
<script>
// 시작일이 과거인지 판별
function check_fast() {
	var now = new Date().toISOString().substring(0, 10);
	var date = document.forms["myForm"]["txtCDATE_START"].value;
	var fast = document.getElementById("fast");
	if(date.length >= 8) {
		// 과거라면 입력창 옆에 공간에 과거라는 것을 텍스트로 표시
		if(now > date) fast.innerHTML = "과거";
		else fast.innerHTML = "";
	}
}
function check_time() {
	var time = document.forms["myForm"]["txtCTIME_START"].value;
	var hour = time.substring(0, 2);
	var min = time.substring(3, 5);
	var time_notice = document.getElementById("time_notice");
	hour -= 2;
	if(hour < 0) {
		hour = 0;
		min = 0;
	}
	if(hour < 10) hour = "0" + hour;
	if(time.length >= 4) { 
		document.getElementById("time_notice").innerHTML = hour + ":" + min + "때부터 출석 가능";	
	}
}
function validateForm() {
	var cid = document.forms["myForm"]["txtCID"].value;
	var cname = document.forms["myForm"]["txtCNAME"].value;
	var chost = document.forms["myForm"]["txtCHOST"].value;
	var cdatestart = document.forms["myForm"]["txtCDATE_START"].value;
	var cdateend = document.forms["myForm"]["txtCDATE_END"].value;
	var ctimestart = document.forms["myForm"]["txtCTIME_START"].value;
	var ctimeend = document.forms["myForm"]["txtCTIME_END"].value;
	if(cname == "" || cid == ""  || chost == "" || cdatestart == "" || ctimestart == "" || ctimeend == "") {
		alert("빈 칸을 채워주세요.");
		return false;
	}
	else if(cdateend == "") {
		document.forms["myForm"]["txtCDATE_END"].value = cdatestart;
	}
	else if(cdateend < cdatestart) {
		alert("종료일이 시작일보다 빠르게 입력되어있습니다.");
		document.forms["myForm"]["txtCDATE_END"].value = "";
		return false;
	}
	if(ctimeend < ctimestart) {
		alert("종료시간이 시작시간보다 빠르게 입력되어있습니다.");
		document.forms["myForm"]["txtCTIME_END"].value = "";
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
		// content_id를 자동생성 -> 현재 DB 내의 가장 큰 content_id + 1값
		while(rs.next()) {
			if(cid < rs.getInt("CONTENT_ID")) cid = rs.getInt("CONTENT_ID");
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
<div class="center">
<span class="top" ></span>
<div class="content" >
<form name="myForm" action="make_new_content.jsp" method="post" onsubmit="return validateForm()">
	<span class="input">일정명</span> 	<input type="text" class="newData" name="txtCNAME" onclick="check_fast()" onkeypress="check_fast()"><span class="input"></span><br>
	<input type=hidden name="txtCID" value="<%=cid%>">					
	<span class="input">시작일</span>  <input type="date" class="newData" name="txtCDATE_START" onblur="check_fast()"><span class="input" id="fast"></span><br>
	<span class="input">종료일</span>  <input type="date" class="newData" name="txtCDATE_END" ><span class="input"></span><br>
	<span class="input">시작시간</span>  	<input type="time" class="newDataTime" name="txtCTIME_START" onblur="check_time()"><span class="input"></span><br>
	<span class="input">종료시간</span>	<input type="time" class="newDataTime" name="txtCTIME_END" ><span class="input"></span><br>
	<span class="input">주최자</span> 	<input type="text" class="newData" name="txtCHOST" ><span class="input"></span><br>
	<span class="input">타입</span>  	<input type="radio" name="txtCTYPE" value="free" checked="checked">자유참가
		 							<input type="radio" name="txtCTYPE" value="apply">신청참가
	<input type="hidden" name="txtCLOGINID" value="<%=loginID %>"><span class="input"></span><br>
	<input type="submit" value="추가">
</form>
</div>	
<p id="time_notice"></p>
</div>
</body>
</html>