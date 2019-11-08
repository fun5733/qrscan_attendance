<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- 
	넘겨받은 출석 명단을 새로 만들어진 테이블에 insert
 --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>insert user list</title>
</head>
<body>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<%
	String[] values = request.getParameterValues("subject");
	String[] cdates = request.getParameterValues("cdates");
	String cloginid = "";
	int cid = 0;
	cid = Integer.parseInt(request.getParameter("cid"));
	cloginid = request.getParameter("cloginid");
	
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		for(int j=0; j<cdates.length; j++) {	
			for(int i=0; i<values.length; i=i+2) {
				String sql = "insert into content_member_list values(?,?,?,?,?)";
				stmt = con.prepareStatement(sql);
				stmt.setInt(1, cid);
				stmt.setString(2, cdates[j]);
				stmt.setString(3, values[i]);
				stmt.setString(4, values[i+1]);
				stmt.setString(5, "X");
				stmt.executeUpdate();
			}
		}
		out.println("일정 추가 완료");		
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
<form action="content_list.jsp" method="post">
	<input name="loginID" value="<%= cloginid %>" type="hidden">
	<input type="submit" value="돌아가기">
</form>
</body>
</html>