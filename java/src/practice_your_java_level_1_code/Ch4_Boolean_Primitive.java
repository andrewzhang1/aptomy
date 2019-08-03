package practice_your_java_level_1_code;

public class Ch4_Boolean_Primitive {

	public static void main(String[] args) {

		boolean result;
		int x = 5;
		int y = 7;

		result = x == y;

		System.out.printf("The result of whether %d is equlat to %d = %b\n", x, y, result);

		boolean result9;
		result9 = !(x > y);
		System.out.printf("The result of whether %d is less or quual to %d = %b\n", x, y, result9);
 	}
}


/*
The result of whether 5 is equlat to 7 = false
The result of whether 5 is less or quual to 7 = true
*/

