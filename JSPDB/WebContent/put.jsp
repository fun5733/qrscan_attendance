<!-- 
	attendance.jsp에서 전달받은 입력값을 DB에 조회
	출석 할 수 있는지 아닌지를 판별해 처리 후 해당 상황의 메시지 출력
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.Date" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>Put page</title>
</head>
<body>
<div class="center">
<span class="content">
<%
	String content_id = "", id = "", name = "", content_date = "";
	content_id = request.getParameter("content_id");
	id = request.getParameter("txtID");
	name = request.getParameter("txtNAME");
	content_date = request.getParameter("content_date");
	// 현재 날짜와 일정 날짜를 비교해 같지 않으면 에러 메시지 출력
	Date now = new Date();
	SimpleDateFormat nowDate = new SimpleDateFormat("yyyy-MM-dd hh:mm");
	if(nowDate.format(now).indexOf(content_date) == -1) {
		out.println("입력하신 정보를 다시 확인해주세요.");
		return;
	}
	
	Connection con = null;
	PreparedStatement stmt_insert = null;
	PreparedStatement stmt_select_content = null;
	PreparedStatement stmt_select_item = null;
	PreparedStatement stmt_update = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql_insert = "insert into content_member_list values(?,?,?,?,?)";
		stmt_insert = con.prepareStatement(sql_insert);
			
		// content_id를 이용해 content_list로부터 일정명, 타입정보를 받아옴
		String sql_select_content = "select * from content_list where CONTENT_ID='"+content_id+"'";	
		stmt_select_content = con.prepareStatement(sql_select_content);
		ResultSet rs_select_content = stmt_select_content.executeQuery();
		String content_name ="", content_type ="";
		if(rs_select_content.next()) {
			content_name = rs_select_content.getString("CONTENT_NAME");
			content_type = rs_select_content.getString("CONTENT_TYPE");
		}
		
		// 자유 형식일 경우
		if(content_type.equals("free")) {
			stmt_insert.setString(1, content_id);
			stmt_insert.setString(2, content_date);
			stmt_insert.setString(3, id);
			stmt_insert.setString(4, name);
			stmt_insert.setString(5, nowDate.format(now));
			stmt_insert.executeUpdate();
		}
		// 신청 형식일 경우
		else {
			String sql_select_item = "select * from content_member_list where CONTENT_ID='"+content_id+"' and CONTENT_DATE='"+content_date+"' and MEMBER_ID='"+id+"' and MEMBER_NAME='"+name+"'";
			stmt_select_item = con.prepareStatement(sql_select_item);
			ResultSet rs_select_item = stmt_select_item.executeQuery();
			// 입력한 정보가 해당 명단에 있을 경우
			if(rs_select_item.next()) {
				// 출석을 아직 하지 않은 상태일 경우
				if(rs_select_item.getString("ATTEND").equals("X")) {
					String sql_update = "update content_member_list set ATTEND='"+nowDate.format(now)+"' where CONTENT_DATE='"+content_date+"' and MEMBER_ID='"+id+"' and MEMBER_NAME='"+name+"' and ATTEND='X'";
					stmt_update = con.prepareStatement(sql_update);
					stmt_update.executeUpdate();
				}
				// 이미 출석이 완료된 상태일 경우
				else {
					out.println(name + "님 이미 출석확인 되었습니다.");
					return;
				}
			}
			// 입력된 정보가 해당 명단에 없거나 일치하지 않을 경우
			else {
				out.println("입력하신 정보를 다시 확인해주세요.");
				return;
			}
		}
		out.println("" + name + " 님 " + content_date + "일 " + content_name + " 일정 출석 완료되었습니다.");		
	}
	catch(SQLException se) {
		if(se.toString().contains("ID")) out.println(name + "님 이미 출석확인 되었습니다.");
		else out.println(se.getMessage());
	}
	catch(Exception e) {
		out.println(e.getMessage());
	}
	finally {
		if(stmt_insert != null) 		try{stmt_insert.close();} catch(SQLException sqle){}
		if(stmt_select_content != null) try{stmt_select_content.close();} catch(SQLException sqle){}
		if(stmt_select_item != null) 	try{stmt_select_item.close();} catch(SQLException sqle){}
		if(stmt_update != null) 		try{stmt_update.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>	
</span>
</div>
</body>
</html>