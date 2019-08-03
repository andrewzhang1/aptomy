package practice_your_java_level_1_code;//Constanc & built-in Math op and methhods


class Math1
{
	public static final double PI = 3.1415926;
	public static final double E = 2.71;
}

public class Ch3_NumHandling_73_Constants {

	public static void main(String[] args) {
		//73-74
		System.out.println(Math.PI);
		System.out.println(Math1.PI);
		System.out.println(Math.E);
		System.out.println(Math1.E);


/* /From Built-in Math constance
3.141592653589793
2.718281828459045
*/

	//81 Built-in
		int rem1 = 50 % 22;
		short rem2 = (short)(50 % 22);
		short rem3 = (short)(50 / 22);
		float rem4 = (float)(50 / 22);
		float rem5 = (float)(50 / 22);
		//How do I get 2.2727?

		int a = 50;
		int b = 22;
		float result_devided = (float) a / (float)b;

		System.out.println("The remainder is: " +  rem1);
		System.out.println("The remainder is: " +  rem2);
		System.out.println("The rem3 is: " +  rem3);
		System.out.println("The Rem4 is: " +  rem4);
		System.out.println("The Rem5 is: " +  rem5);

		System.out.println("result_devided is " + result_devided);
		//or:

		//85
		float x = 121.0f;
		double result;

		result = Math.pow (x, (1.0/5.0));
		System.out.println("The 5th root of " + x + " is " + result);

	// 87 Prinint out the cosine of 180 degree:
		double degrees =180;
		double radians = Math.toRadians(degrees);
		double cosine = Math.cos(radians);
		System.out.printf("The cosine of %f degree = %f\n", degrees, cosine);


// 107 Impotant:

/*
		int A =5;
		int B = 10;
		System.out.printf("%d/%d=%f", A,B, (A/B));

*/

	}
}
