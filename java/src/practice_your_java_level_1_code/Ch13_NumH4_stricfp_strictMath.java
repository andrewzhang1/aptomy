package practice_your_java_level_1_code;

import java.math.BigInteger;

public class Ch13_NumH4_stricfp_strictMath {
	public static strictfp void main(String[] args) {
	//public static void main(String[] args) {
		//4
		System.out.println("Item 4:");
		double degree = 75;
		double radians = StrictMath.toRadians(degree);
		double cosine = StrictMath.cos(radians);

		System.out.printf("The cosine of %f degree = %f\n", degree, cosine);

	}
}
