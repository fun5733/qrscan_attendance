<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Add page</title>
<%
	String id = request.getParameter("txtID");
	String name = request.getParameter("txtNAME");
	int cid = 0;
	cid = Integer.parseInt(request.getParameter("cid"));
	String cloginid = request.getParameter("cloginid");
	String cdatestart = request.getParameter("cdatestart");
	String cdateend = request.getParameter("cdateend");
	Connection con = null;
	PreparedStatement stmt = null;
	
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
	Calendar cal = Calendar.getInstance();
	java.util.Date startDate = df.parse(cdatestart);
	java.util.Date endDate = df.parse(cdateend);
	long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
	Integer days = (int)(long)diff + 1;
	cal.setTime(startDate);
	
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "insert into content_member_list values(?,?,?,?,?)";
		while(true) {	
			stmt = con.prepareStatement(sql);
			stmt.setInt(1, cid);
			stmt.setString(2, df.format(cal.getTime()));
			stmt.setString(3, id);
			stmt.setString(4, name);
			stmt.setString(5, "X");
			stmt.executeUpdate();
			
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}
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
	// 작업이 끝난 후 다시 일정 리스트 페이지 표시-> 깜박거림 후 삭제되어있음
	//response.sendRedirect("content_list.jsp?loginID=" + cloginid);
%>