<!-- 
	content_list.jsp에서 클릭된 일정의 QR코드를 보여주는 페이지
	날짜별로 다른 QR코드를 출력
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
<script>
// 셀렉트 박스 선택값이 바뀔 때 qr코드를 해당 날짜의 것으로 교체해서 표시
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedValue = selectBox.options[selectBox.selectedIndex].value;
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var tb = document.getElementById("tb");
	// 선택된 option의 value값(=QR코드 png 파일의 경로)으로 img 태그 내용 기입
	var img = "<img src=" + selectedValue + ">";
	document.getElementById("img_out").innerHTML = img;
	
	// 셀렉트 박스 선택값과 같은 값을 가져야 display:visible로 보이게 됨
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		if(temp != selectedHTML) {
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
			cdatestart = rs_qr.getString("CONTENT_DATE_START");
			cdateend = rs_qr.getString("CONTENT_DATE_END");
			content_name = rs_qr.getString("CONTENT_NAME");
		}
		// 시작일~종료일 기간의 날짜 목록 생성
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = Calendar.getInstance();
		java.util.Date startDate = df.parse(cdatestart);
		java.util.Date endDate = df.parse(cdateend);
		long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
		Integer days = (int)(long)diff + 1;
		cal.setTime(startDate);
		String codePath = request.getContextPath() + "/qrcode/images/" + content_id;
%>
	<select id="id-codes" name="codes" onchange="change()">
<%
		while(true) {	
%>
			<option value="<%=codePath + df.format(cal.getTime()) + ".png" %>"><%=df.format(cal.getTime()) %></option>			
<%
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}
		
%>		
	</select>
	<p><%=content_name %> 일정 QR코드</p>
	<!-- QR코드 표시 부분 (default로 시작일의 QR코드를 표시) -->
	<p id="img_out"><img src="<%=codePath + cdatestart + ".png" %>"></p>
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