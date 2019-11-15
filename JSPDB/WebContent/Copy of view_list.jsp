<!-- 
	content_list.jsp에서 클릭된 일정의 출석 명단을 생성,
	ajax를 통해 content_list의 특정 div에서 이를 표시
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>View page</title>
<link rel="stylesheet" href="css/style.css">
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script>
$('#addMembe1r').click(function() {
	location.reload();
});
//셀렉트 박스 선택값이 바뀔 때 출석 명단을 해당 날짜의 것으로 교체해서 표시
function change() {
	var selectBox = document.getElementById("id-codes");
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var list = document.getElementById("list");
	var intro = document.getElementById("intro");
	var tb = document.getElementById("tb");
	var count = tb.rows.length-1;	// 몇 명 출석인지 카운트
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		if(selectedHTML == "전체") {
			intro.style = "display:visible";
			list.style = "display:none";
			tb.rows[i].style = "display:visible";
		}
		else if(temp != selectedHTML) {
			list.style = "display:visible";
			intro.style = "display:none";
			tb.rows[i].style = "display:none";
			count--;
		}
		else {
			list.style = "display:visible";
			intro.style = "display:none";
			tb.rows[i].style = "display:visible";
			if(tb.rows[i].cells[3].innerHTML == "X") count--;
		}
	}
	// document.getElementById("count").innerHTML = count + "명 출석";
}
function add() {
	var addForm = document.getElementById("addForm");
	var addButton = document.getElementById("addButton");
	addForm.style = "display:visible";
	addButton.style = "display:none";
}
function cancel() {
	var addForm = document.getElementById("addForm");
	var addButton = document.getElementById("addButton");
	addForm.style = "display:none";
	addButton.style = "display:visible";
	document.forms["addForm"]["txtID"].value = "";
	document.forms["addForm"]["txtNAME"].value = "";
}
function fn_press(event, type) {
	if(type == "numbers") {
		if(event.keyCode < 48 || event.keyCode > 57) {
			alert("숫자만 입력할 수 있습니다");
			return false;
		}
	}
}
function fn_press_han(obj) {
	if(obj.value != obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '')) {
		alert("숫자만 입력할 수 있습니다");
		obj.value = obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '');
		return false;
	}
}
function check_key() {
	var char_ASCII = event.keyCode;
	// 특수문자 확인
	if ((char_ASCII>=33 && char_ASCII<=47) || (char_ASCII>=58 && char_ASCII<=64)
	   || (char_ASCII>=91 && char_ASCII<=96) || (char_ASCII>=123 && char_ASCII<=126))
	    return 1;
	else
	    return 0;
}
function specialKey() {
	if(check_key() == 1) {
		event.returnValue = false;
		alert("특수문자는 입력할 수 없습니다");
		return;
	}
}
function validateForm() {
	var id = document.forms["addForm"]["txtID"].value;
	var name = document.forms["addForm"]["txtNAME"].value;
	var tb = document.getElementById("tb");
	if(name == "" || id == "") {
		alert("빈 칸을 채워주세요.");
		return false;
	}
	else if(id.length != 7) {
		alert("사번은 7자리 숫자입니다");
		return false;
	}
	for(var i=1; i<tb.rows.length; i++) {
		if(tb.rows[i].cells[0].innerHTML == id) {
			alert("중복되는 사원정보가 등록되어있습니다.");
			return false;
		}
	}
	return true;
}
</script>
</head>
<body>
<%
	String content_id = request.getParameter("content_id");
	String date="", content_name="", cdatestart="", cdateend="", cloginid="", ctype="";
	String temp="", all="";
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_qr = null;
	PreparedStatement stmt_view = null;
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
			cloginid = rs_qr.getString("CONTENT_LOGINID");
			ctype = rs_qr.getString("CONTENT_TYPE");
		}
		String sql_view = "select * from content_member_list where CONTENT_DATE = '"+cdatestart+"' and CONTENT_ID = '"+content_id+"'";
		stmt_view = con.prepareStatement(sql_view);
		ResultSet rs_view = stmt_view.executeQuery();
%>
<div class="select">
<select id="id-codes" name="codes" onchange="change()">
		<option>전체</option>	
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
<%
	System.out.println(ctype);
	if(ctype.equals("apply")) {
%>
<button type="button" id="addButton" onclick="add()">추가</button>
<%
	}
%>
<form id="addForm" action="add.jsp" method="post" onsubmit="return validateForm()" style="display:none">
	<button type="button" onclick="cancel()">취소</button>
	사번  <input type="text" class="attendData" name="txtID" maxlength="7" onkeypress="return fn_press(event, 'numbers');" onkeyup="fn_press_han(this);" style="ime-mode:Disabled">
	이름  <input type="text" class="attendData" name="txtNAME" onkeypress="specialKey()">
	<input type="hidden" name="cdatestart" value="<%=cdatestart %>">
	<input type="hidden" name="cdateend" value="<%=cdateend %>">
	<input type="hidden" name="cloginid" value="<%=cloginid %>">
	<input type="hidden" name="cid" value="<%=content_id %>">
	<input type="submit" id="addMember" value="등록">
</form>
</div>
<table border="1" id="tb">

	<tr>
		<th>사번</th>
		<th>이름</th>
		<th>날짜</th>
		<th>출석</th>
	</tr>

	<tbody id="list" style="display:none">
<%
		int count = 0;
		while(rs.next()) {
%>
	<tr>
		<td><%=rs.getString("MEMBER_ID") %></td> 
		<td><%=rs.getString("MEMBER_NAME") %></td>
		<td><%=rs.getString("CONTENT_DATE") %></td>
		<td><%=rs.getString("ATTEND") %></td>
	</tr>			
<%	
			if(!rs.getString("ATTEND").equals("X")) {
				count++;
			}
		}

		while(rs_view.next()) {
			String sql_count 	= "select count(*) from content_member_list where CONTENT_ID = '"+content_id+"' and MEMBER_ID = '"+rs_view.getString("MEMBER_ID")+"' and ATTEND <> 'X'";
			String sql_all 		= "select count(*) from content_member_list where CONTENT_ID = '"+content_id+"' and MEMBER_ID = '"+rs_view.getString("MEMBER_ID")+"'";
			System.out.println(content_id);
			int temp_count = 0;
			int all_count = 0;
			PreparedStatement stmt_count = null;
			stmt_count = con.prepareStatement(sql_count);
			ResultSet rs_count = stmt_count.executeQuery();
			if(rs_count.next()) {
				temp_count = rs_count.getInt(1);
			}
			temp = temp_count+"번";
			PreparedStatement stmt_all = null;
			stmt_all = con.prepareStatement(sql_all);
			ResultSet rs_all = stmt_all.executeQuery();
			if(rs_all.next()) {
				all_count = rs_all.getInt(1);
			}
			all = all_count+"일 중";
%>
	</tbody>
	<tbody id="intro" style="display:visible">
	<tr>
		<td><%=rs_view.getString("MEMBER_ID") %></td> 
		<td><%=rs_view.getString("MEMBER_NAME") %></td>
		<td><%=all%></td>
		<td><%=temp%></td>
	</tr>
<%
		}
%>
	</tbody>
</table>
<!-- 몇 명 출석했는지를 표시 -->
<%-- <p id="count"><%=count %>명 출석</p> --%>
<%
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
</body>
</html>