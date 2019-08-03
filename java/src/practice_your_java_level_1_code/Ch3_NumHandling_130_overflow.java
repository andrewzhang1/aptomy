package practice_your_java_level_1_code;//Constanc & built-in Math op and methhods


public class Ch3_NumHandling_130_overflow {

	public static void main(String[] args) {

		int a = Integer.MAX_VALUE;
		int b = Integer.MAX_VALUE;
		int total1 = a + 1;

		//total = Math.addExact(a, b);
		//System.out.println("Total = " + total);
		System.out.println("a = " + a);
		System.out.println("total1 ==> " + total1); //total1 ==> -2147483648

		// Total = -2147483648 (if a + 1)
		// Total = -2147483647 (if a + 2)

// 133
		// Exception in thread "main" java.lang.ArithmeticException: integer overflow:

		/*int total2;
		total2 = Math.addExact(a, b);
		System.out.println("tota2 ==> " + total2);
		*/

		int total3;
		total3 = a + b;

		System.out.println("\ntotal3 ==> " + total3);  // got wrong result for total3 ==> -2

		// 135
		int total135 = ++a;
		System.out.println("\ntota1l35 ==> " + total135);

		int total135a = Math.incrementExact(b);
		System.out.println("\ntota1l35a ==> " + total135a);
		// got ArithmeticException



 	}
}
