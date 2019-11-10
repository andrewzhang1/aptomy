package CACC_2019.week8_Method;

public class App4_Exception1 {
	public static void main(String[] args) {
		float a = 5;
		//int b = 2;
		int b = 0;
		try {
			System.out.println( a / b);
		}
		catch (ArithmeticException w ){
			System.out.println("I caught the exeption!");
		}
	    System.out.println("After the calcuation. Exited!");
/*

		try{
			System.out.println(a / b);
		}
		catch (ArithmeticException e ){
			System.out.println("I caught the exeption!");
		}

		System.out.println("After the calcuation. Exited!");


*/

	}

}
