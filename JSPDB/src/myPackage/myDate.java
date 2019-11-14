/*
 * myDate.getDate(start, end)�� start ~ end �� ��¥ ����� ��ȯ
 * ex) myDate.getDate("2019-01-01", "2019-01-03") = "2019-01-01<br>2019-01-02<br>2019-01-03<br>"
 */
package myPackage;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

public class myDate { 
	// �����ϰ� �������� �־����� �� �� ������ ��¥ ����� �ϳ��� ���ڿ��� ��� ��ȯ
	public static String getDate(String start, String end) throws ParseException {
		final String DATE_PATTERN = "yyyy-MM-dd";
		SimpleDateFormat sdf = new SimpleDateFormat(DATE_PATTERN);
		Date startDate = sdf.parse(start);
		Date endDate = sdf.parse(end);
		ArrayList<String> cdates = new ArrayList<String>();
		Date currentDate = startDate;
		// �������� �� ������ ��¥�� �߰�
		while (currentDate.compareTo(endDate) <= 0) {
		    cdates.add(sdf.format(currentDate));
		    Calendar c = Calendar.getInstance();
		    c.setTime(currentDate);
		    c.add(Calendar.DAY_OF_MONTH, 1);
		    currentDate = c.getTime();
		}
		String dates ="";
		// �� ���ڿ��� �ʱ�ȭ�� dates �� ��¥+<br>�� �ϳ��� ����
		// <br>�� ����� �� ������ ����
		/*for (String date : cdates) {
		    dates += date + "<br>";
		}*/
		for (int i=0; i<cdates.size(); i++) {
		    dates += cdates.get(i) + "<br>";
		}
		return dates;
	}
}

