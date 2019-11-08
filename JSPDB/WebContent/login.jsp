<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- 
	사번을 입력해서 주최자의 사번이 같은 일정만 접근할 수 있도록 함		
 --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login page</title>
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
		return;
	}
	obj.value = obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '');
}
function validateForm() {
	var loginid = document.forms["myForm"]["loginID"].value;
	if(loginid == "") {
		alert("빈 칸을 채워주세요");
		return false;
	}
	else if(loginid.length != 7) {
		alert("사번은 7자리 숫자입니다");
		return false;
	}
	return true;
}
</script>
</head>
<body>
	<h2>일정을 추가하시려면 사번을 입력해주세요</h2>
	<form name="myForm" action="content_list.jsp" method="post" onsubmit="return validateForm()">
		사번 <input type="text" name="loginID" maxlength="7" onkeypress="return fn_press(event, 'numbers');" onkeydown="fn_press_han(this);" style="ime-mode:Disabled">
		<input type="submit" value="로그인">
	</form>
</body>
</html>