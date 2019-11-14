/*
 * myDate.getDate(start, end)로 start ~ end 의 날짜 목록을 반환
 * ex) myDate.getDate("2019-01-01", "2019-01-03") = "2019-01-01<br>2019-01-02<br>2019-01-03<br>"
 */
package myPackage;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

public class myDate { 
	// 시작일과 종료일이 주어졌을 때 그 사이의 날짜 목록을 하나의 문자열에 담아 반환
	public static String getDate(String start, String end) throws ParseException {
		final String DATE_PATTERN = "yyyy-MM-dd";
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
		Date startDate = sdf.parse(start);
		Date endDate = sdf.parse(end);
		ArrayList<String> cdates = new ArrayList<String>();
		Date currentDate = startDate;
		// 종료일이 될 때까지 날짜를 추가
		while (currentDate.compareTo(endDate) <= 0) {
		    cdates.add(sdf.format(currentDate));
		    Calendar c = Calendar.getInstance();
		    c.setTime(currentDate);
		    c.add(Calendar.DAY_OF_MONTH, 1);
		    currentDate = c.getTime();
		}
		String dates ="";
		// 빈 문자열로 초기화한 dates 에 날짜+<br>를 하나씩 더함
		// <br>은 사용할 때 구분을 위함
		/*for (String date : cdates) {
		    dates += date + "<br>";
		}*/
		for (int i=0; i<cdates.size(); i++) {
		    dates += cdates.get(i) + "<br>";
		}
		return dates;
	}
}

