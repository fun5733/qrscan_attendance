<!-- 
	new_content.jsp로부터 새로운 일정의 정보를 전달받아, 이를 토대로 새로운 일정을 DB(content_list 테이블)에 넣음
	새로운 일정이 만들어지면 이에 해당하는 QR코드를 생성
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.File" %>
<%@ page import = "java.awt.image.BufferedImage, javax.imageio.ImageIO" %>
<%@ page import = "com.google.zxing.qrcode.QRCodeWriter, com.google.zxing.common.BitMatrix, com.google.zxing.BarcodeFormat, com.google.zxing.client.j2se.MatrixToImageWriter" %>
<%@ page import = "myPackage.myDate"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Make new content page</title>
<style>  
	* { font-size:30px; }
	table { border-collapse:collapse; }  
	th, td { border:1px solid gray; }
	input { border:1px solid black; }
</style>
<script language="javascript">
// 셀렉트 박스에서 어떤 날짜를 선택하느냐에 따라 표시되는 QR코드 바뀜
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedValue = selectBox.options[selectBox.selectedIndex].value;
	var img = "<img src=" + selectedValue + ">";
	document.getElementById("img_out").innerHTML = img;
}
// 명단에 인원 추가
function addItem() {
      var lo_table = document.getElementById("TblAttach");
      var row_index = lo_table.rows.length;      // 테이블(TR) row 개수
      newTr = lo_table.insertRow(row_index);
      newTr.idName = "newTr" + row_index;
 
      newTd=newTr.insertCell(0);
      newTd.innerHTML= "사번";
 
      newTd=newTr.insertCell(1);
      newTd.innerHTML= "<input type=text name=subject maxlength=7>";
      
      newTd=newTr.insertCell(2);
      newTd.innerHTML= "이름";
      
      newTd=newTr.insertCell(3);
      newTd.innerHTML= "<input type=text name=subject>";
}
//명단에 인원 삭제
function delItem(){
      var lo_table = document.getElementById("TblAttach");
      var row_index = lo_table.rows.length-1;      // 테이블(TR) row 개수
 
      if(row_index > 0) lo_table.deleteRow(row_index);    
}
function validateForm() {
	var inputs = document.getElementsByName('subject');
	var id_pattern = /^\d{7}$/;
	if(inputs.length === 0) {
		alert("최소한 한 개 이상의 행을 입력해주세요.");
		return false;
	}
	for(var i=0; i<inputs.length; i++) {	
		if(inputs[i].value === '') {
			alert("빈 칸을 채워주세요.");
			return false;
		}
		else if(i % 2 == 0 && !id_pattern.test(inputs[i].value)){
			alert("사번은 7자리 숫자입니다.");
			return false;
		}
		for(var j=0; j<i; j++) {
			if(inputs[i].value == inputs[j].value && i % 2 == 0) {
				alert("사번이 중복되는 데이터가 있습니다." );
				return false;
			}
		}	
	}
	return true;
}
</script>
</head>
<body>
<% 
	String cname="", chost="", ctype="", cloginid="", cdatestart="", cdateend="";
	int cid = 0;
	cid = Integer.parseInt(request.getParameter("txtCID"));
	String cP = request.getContextPath() + "/qrcode/images/";
	cname = request.getParameter("txtCNAME");
	chost = request.getParameter("txtCHOST");
	ctype = request.getParameter("txtCTYPE");
	cloginid = request.getParameter("txtCLOGINID");
	String dates = "";
	cdatestart = request.getParameter("txtCDATE_START");
	cdateend = request.getParameter("txtCDATE_END");

	// 시작일과 종료일 사이의 날짜 목록 생성	
	dates = myDate.getDate(cdatestart, cdateend);
	String[] cdates = dates.split("<br>");
	
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");

		String sql = "insert into content_list values(?,?,?,?,?,?,?)";
		stmt = con.prepareStatement(sql);
		stmt.setString(1, cname);
		stmt.setInt(2, cid);
		stmt.setString(3, cdatestart);
		stmt.setString(4, cdateend);
		stmt.setString(5, chost);
		stmt.setString(6, ctype);
		stmt.setString(7, cloginid);
		stmt.executeUpdate();
		
		// 자유 참가일 경우
		if(ctype.equals("free")) {
			out.println("" + cname + " 일정 추가 완료");	 
%>
			<form action="content_list.jsp" method="post">
				<input name="loginID" value="<%= cloginid %>" type="hidden">
				<input type="submit" value="돌아가기">
			</form>
<%
		}
		// 신청 참가일 경우
		else {		
%>	
			<div id="user_list_input_div">
				<form name="myForm" action="insert_user_list.jsp" method="post" onsubmit="return validateForm()">
					<table border=0 cellpadding=0 cellspacing=0 id="TblAttach">
						<tr>
			            	<td>신청자 명단</td>
			            	<td width="100" align=center>   
								<input type="button" value="추가" onclick="addItem();">  
			                  	<input type="button" value="삭제" onclick="delItem();">  
			            	</td>
						</tr>
			      	</table>
			      	<input name="cid" value="<%= cid %>" type="hidden">
			      	<input name="cloginid" value="<%= cloginid %>" type="hidden">
			      	<input name="cdates" value="<%= dates %>" type="hidden">      	
			      	<input type="submit" value="명단 등록">
		      	</form>
			</div> 
<%
		}
		
		long key1 = 1759, key2 = 29, key3 = 19700101;	// 암호키

		String url = "http://192.168.211.233:8080/JSPDB/attendance.jsp?param=";
		File path = new File(application.getRealPath("/") + "qrcode/images/");
		String savedFileName = ""+cid;
		// QR코드 png파일의 경로를 저장할 변수
		String[] codePaths = new String [cdates.length];
		String codePath = "";
		
		if(!path.exists()) path.mkdirs();
		QRCodeWriter writer = new QRCodeWriter();
		
		// QR코드 생성 
		for(int i=0; i<cdates.length; i++) {
			savedFileName = (cid + cdates[i]).toString();	// png 파일명(=날짜와 content_id 조합)
			String temp = cdates[i].toString().replace("-",""); // 2019-11-08 --> 20191108
			// val = 우변의 식을 통해 생성되는 암호값
			long val = ((Long.parseLong(temp) + key3) * key1 + cid) * key2;
			
			// QR코드 생성 후 파일로 저장
			BitMatrix qrCode = writer.encode(url + val, BarcodeFormat.QR_CODE, 500, 500);
			BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(qrCode);
			ImageIO.write(qrImage, "PNG", new File(path, savedFileName + ".png"));
			
			// 화면에 qr코드 출력
			codePath = request.getContextPath() + "/qrcode/images/" + savedFileName + ".png";
			codePaths[i] = codePath;
			i++;
		}
%>
	<select id="id-codes" name="codes" onchange="change()">
<%
		for(int i=0; i<cdates.length; i++) {
%>
			<option value="<%=codePaths[i] %>"><%=cdates[i] %></option>			
<%
		}
%>		
	</select>
	<!-- QR코드 출력 부분 -->
	<p id="img_out"><img src="<%=codePaths[0]%>"></p>
<%
	}
	catch(SQLException se) {
		System.out.println("SQL Exception: " + se.getMessage());
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>	
</body>
</html>