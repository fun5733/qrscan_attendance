<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- 
	새로운 일정을 content_list 테이블에 추가하고
	해당 content_id 를 이름으로 가지는 새로운 테이블을 생성,
	해당 페이지의 URL 정보를 담은 QR코드 생성 
 --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Make new content page</title>
<style>  
	table { border-collapse:collapse; }  
	th, td { border:1px solid gray; }
</style>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.File, java.util.UUID" %>
<%@ page import = "java.awt.image.BufferedImage, javax.imageio.ImageIO" %>
<%@ page import = "com.google.zxing.qrcode.QRCodeWriter, com.google.zxing.common.BitMatrix, com.google.zxing.BarcodeFormat, com.google.zxing.client.j2se.MatrixToImageWriter" %>
<%@ page import = "java.text.ParseException" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.Calendar" %>
<%@ page import = "java.util.Date" %>
<script language="javascript">
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
function delItem(){
      var lo_table = document.getElementById("TblAttach");
      var row_index = lo_table.rows.length-1;      // 테이블(TR) row 개수
 
      if(row_index > 0) lo_table.deleteRow(row_index);    
}
function validateForm() {
	var inputs = document.getElementsByName('subject');
	var id_pattern = /^\d{7}$/;
	if(inputs.length === 0) {
		alert("최소한 한 개 이상의 행을 입력해주세요");
		return false;
	}
	for(var i=0; i<inputs.length; i++) {	
		if(inputs[i].value === '') {
			alert("빈 칸을 채워주세요");
			return false;
		}
		else if(i % 2 == 0 && !id_pattern.test(inputs[i].value)){
			alert("사번은 7자리 숫자입니다 - 잘못 입력된 사번 : " + inputs[i].value);
			return false;
		}
		// 중복처리 - 2중 for문
		for(var j=0; j<i; j++) {
			if(inputs[i].value == inputs[j].value && i % 2 == 0) {
				alert("사번이 중복되는 데이터가 있습니다 - 중복된 데이터 : " + (j/2+1) + "행과 " + (i/2+1) + "행" );
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
	//-------------------------------------------------------------------
	final String DATE_PATTERN = "yyyy-MM-dd";
	String dates ="";
	cdatestart = request.getParameter("txtCDATE_START");
	cdateend = request.getParameter("txtCDATE_END");
	SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
	Date startDate = sdf.parse(cdatestart);
	Date endDate = sdf.parse(cdateend);
	ArrayList<String> cdates = new ArrayList<String>();
	Date currentDate = startDate;
	while (currentDate.compareTo(endDate) <= 0) {
	    cdates.add(sdf.format(currentDate));
	    Calendar c = Calendar.getInstance();
	    c.setTime(currentDate);
	    c.add(Calendar.DAY_OF_MONTH, 1);
	    currentDate = c.getTime();
	}
	for (String date : cdates) {
	    dates += date + "<br>";
	}
	//-------------------------------------------------------------------
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");

		String sql = "insert into content_list values(?,?,?,?,?,?,?,?)";
		stmt = con.prepareStatement(sql);	//여기 문제
		stmt.setString(1, cname);
		stmt.setInt(2, cid);
		stmt.setString(3, cdatestart);
		stmt.setString(4, cdateend);
		stmt.setString(5, chost);
		stmt.setString(6, ctype);
		stmt.setString(7, cloginid);
		stmt.setString(8, dates);
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
<%
					for(String date : cdates) {
%>
			      	<input name="cdates" value="<%= date %>" type="hidden">      	
<%
					}
%>
			      	<input type="submit" value="명단 등록">
		      	</form>
			</div> 
<%
		}
		//qr code 생성
		String url = "http://localhost:8080/JSPDB/attendance.jsp?content_id=" + cid + "&content_date=";
		String url_origin;
		File path = new File(application.getRealPath("/") + "qrcode/images/");
		//String savedFileName = UUID.randomUUID().toString().replace("-", "");	// 영어 소문자와 숫자로만 이루어진 랜덤한 문자열
		String savedFileName = ""+cid;
		String[] codePaths = new String [cdates.size()];
		String codePath = request.getContextPath() + "/qrcode/images/";
		if(!path.exists()) path.mkdirs();
		
		if(cdatestart == cdateend) {
			savedFileName = (cid + cdatestart).toString().replace(":", "-");
			QRCodeWriter writer = new QRCodeWriter();
			BitMatrix qrCode = writer.encode(url + cdatestart, BarcodeFormat.QR_CODE, 500, 500);
			BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(qrCode);
			ImageIO.write(qrImage, "PNG", new File(path, savedFileName + ".png"));
			// 화면에 qr코드 출력
			codePath = request.getContextPath() + "/qrcode/images/" + savedFileName + ".png";
			out.print("<br>해당 페이지 QR코드 ↓<br><img src='"+codePath+"'/>");
		}
		else {
			int i=0;
			for(String date : cdates) {
				savedFileName = (cid + date).toString().replace(":", "-");
				QRCodeWriter writer = new QRCodeWriter();
				BitMatrix qrCode = writer.encode(url + date, BarcodeFormat.QR_CODE, 500, 500);
				BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(qrCode);
				ImageIO.write(qrImage, "PNG", new File(path, savedFileName + ".png"));
				// 화면에 qr코드 출력
				codePath = request.getContextPath() + "/qrcode/images/" + savedFileName + ".png";
				codePaths[i] = codePath;
				i++;
			}
%>
<script>
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedValue = selectBox.options[selectBox.selectedIndex].value;
	var img = "<img src=" + selectedValue + ">";
	document.getElementById("img_out").innerHTML = img;
}
</script>
			<select id="id-codes" name="codes" onchange="change()">
<%
			int j=0;
			for(String date : cdates) {
%>
					<option value="<%=codePaths[j] %>"><%=date %></option>			
<%
				j++;
			}
%>		
			</select>
			<p id="img_out"><img src="<%=codePaths[0]%>"></p>
<%
		}
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