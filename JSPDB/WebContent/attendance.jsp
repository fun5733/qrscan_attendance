<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>attendance page</title>
<script>
function fn_press(event, type) {
	if(type == "numbers") {
		if(event.keyCode < 48 || event.keyCode > 57) {
			alert("숫자만 입력할 수 있습니다");
			return false;
		}
	}
}
function fn_press_han(obj) {
	if(event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode ==46) {
		alert("한글입력불가");
		return false;
	}
	obj.value = obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '');
}
function check_key() {
	var char_ASCII = event.keyCode; 
	  //숫자
	 if (char_ASCII >= 48 && char_ASCII <= 57 )
	   return 1;
	 //특수기호
	 else if ((char_ASCII>=33 && char_ASCII<=47) || (char_ASCII>=58 && char_ASCII<=64)
	   || (char_ASCII>=91 && char_ASCII<=96) || (char_ASCII>=123 && char_ASCII<=126))
	    return 2;
	 else
	    return 0;
}
function specialKey() {
	if(check_key() == 2) {
		event.returnValue = false;
		alert("특수문자는 입력할 수 없습니다");
		return;
	}
}
function validateForm() {
	var userid = document.forms["myForm"]["txtID"].value;
	var username = document.forms["myForm"]["txtNAME"].value;
	if(username == "" || userid == "") {
		alert("빈 칸을 채워주세요");
		return false;
	}
	else if(userid.length != 7) {
		alert("사번은 7자리 숫자입니다");
		return false;
	}
	return true;
}
</script>
</head>
<body>
<%@ page import="java.sql.*" %>
<%
	String cid = "", cdate = "";
	cid = request.getParameter("content_id");
	cdate = request.getParameter("content_date");
	
	// content_id를 이용해 content_list로부터 일정명, 타입정보를 받아옴 
	String sql = "select * from content_list where CONTENT_ID='"+cid+"'";
	Connection con = null;
	PreparedStatement stmt = null;		
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		stmt = con.prepareStatement(sql);
		ResultSet rs_select_content = stmt.executeQuery();
		String content_name ="", content_type ="";
		if(rs_select_content.next()) {
			content_name = rs_select_content.getString("CONTENT_NAME");
			content_type = rs_select_content.getString("CONTENT_TYPE");
		}
		out.println(content_name + " 일정은 " + content_type + "형식입니다");
	}
	catch(SQLException se) {
		if(se.toString().contains("ID")) out.println("이미 등록된 사번입니다");
		else out.println(se.getMessage());
	}
	catch(Exception e) {
		e.printStackTrace();
		System.out.println("실패");
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>
<form name="myForm" action="put.jsp" method="post" onsubmit="return validateForm()">
	사번  <input type="text" name="txtID" maxlength="7" onkeypress="return fn_press(event, 'numbers');" onkeydown="fn_press_han(this);" style="ime-mode:Disabled"><br>
	이름  <input type="text" name="txtNAME" onkeypress="specialKey()"><br>
	<input name="content_id" value="<%= cid %>" type="hidden">
	<input name="content_date" value="<%= cdate %>" type="hidden">
	<input type="submit" value="등록">
</form>	
</body>
</html>