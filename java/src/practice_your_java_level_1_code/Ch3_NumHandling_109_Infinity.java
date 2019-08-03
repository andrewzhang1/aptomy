package practice_your_java_level_1_code;//Constanc & built-in Math op and methhods


public class Ch3_NumHandling_109_Infinity{

	public static void main(String[] args) {

//		int a = 50;
//		int b = 0;
//		System.out.printf("%d/%d=%f", a,b, (a/b));


// 109 Impotant:

//		float b=0, c=-1, d=1;
//		float a =0;
//
//		System.out.printf("%f/%f = %f\n", a, b, a/b);
//		System.out.printf("%f/%f = %f\n", c, a, c/a);
//		System.out.printf("%f/%f = %f\n", d, a, d/a);

/* output:
0.000000/0.000000 = NaN
-1.000000/0.000000 = -Infinity
1.000000/0.000000 = Infinity
*/

		/*
0.000000/0.000000 = NaN
-1.000000/0.000000 = -Infinity
1.000000/0.000000 = Infinity
*/

// 110


		float a = Float.POSITIVE_INFINITY;
		float b = Float.NEGATIVE_INFINITY;

		System.out.printf("%f + %f = %f\n", b, a, b + a);
		System.out.printf("%f / %f = %f\n", b, a, b / a);

		//111 Complex num
		double x_var1 = 5;
		double y_ar_1 = 10;

		double r = Math.hypot(x_var1, y_ar_1);
		double theta = Math.atan2(x_var1, y_ar_1);
		System.out.printf("The complex number in polar form is  (%f, %f)\n", r, theta);

		// The complex number in polar form is  (11.180340, 0.463648)

		//112 Increment
//		int i = 23;
//		int j = i++;
//		System.out.print("i is now: " + i);
//		System.out.print("\nj is now: " + j);
//
//		i is now: 24
//		j is now: 23



/*	int i = 23;
		int j = ++i;
		System.out.print("i is now: " + i);
		System.out.print("\nj is now: " + j);

		i is now: 24
		j is now: 24*/

//118
		/*int i = 5, j = 27;
		int result = i++ + --j;

		System.out.println("Result = " +  result);
		System.out.println("i = " +  i);
		System.out.println("j = " +  j);

		Result = 31
		i = 6
		j = 26
*/

		int i = 5, j = 27;
		int result = i-- - --j;

		System.out.println("Result = " +  result);
		System.out.println("i = " +  i);
		System.out.println("j = " +  j);

/*
		Result = -21
		i = 4
		j = 26
*/






 	}
}
