package practice_your_java_level_1_code;

import java.time.LocalDateTime;

public class Ch15_Date_Time_Foundation_1 {
	public static void main(String[] args) {
		LocalDateTime currentDataTime = LocalDateTime.now();

		System.out.println("The current data & time is " + currentDataTime);

		System.out.println("\nItem 2:");
		System.out.println("Year           = " + currentDataTime.getDayOfYear());
		System.out.println("Month          = " + currentDataTime.getMonth());
		System.out.println("Month          = " + currentDataTime.getMonthValue());
		System.out.println("DayofMonth     = " + currentDataTime.getDayOfMonth());
		System.out.println("DayofWeek      = " + currentDataTime.getDayOfWeek());
		System.out.println("Hour           = " + currentDataTime.getHour());
		System.out.println("Hour           = " + currentDataTime.getHour());
		System.out.println("Miniutes       = " + currentDataTime.getMinute());
		System.out.println("Nono-seconds   = " + currentDataTime.getNano());

	}
}

/*
The current data & time is 2017-06-11T16:18:56.318

Item 2:
Year           = 162
Month          = JUNE
Month          = 6
DayofMonth     = 11
DayofWeek      = SUNDAY
Hour           = 16
Hour           = 16
Miniutes       = 18
Nono-seconds   = 318000000*/
