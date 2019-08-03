package practice_your_java_level_1_code;

import java.time.LocalDateTime;

public class Ch16_Exceptions_2 {
	public static void main(String[] args) {
		float a = 5;
		int b = 10;

		try{
			System.out.println(a / b);
		}
		catch (ArithmeticException e ){
			System.out.println("I caught the exeption!");
		}

		System.out.println("After the calcuation");




	}
}
