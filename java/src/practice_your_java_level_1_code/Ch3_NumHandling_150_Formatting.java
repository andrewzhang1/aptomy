package practice_your_java_level_1_code;

public class Ch3_NumHandling_150_Formatting {

	public static void main(String[] args) {
		//150:

		int m = 304638;
		System.out.printf("In decimal 	 :%d\n", m);
		System.out.printf("In hexdecimal :%x\n", m);
		System.out.printf("In octal 	 :%o\n", m);

		System.out.printf("In hexdecimal capital :%X\n", m);

		int var01 = 0x1EC05;
		int var02 = 0xF238c;
		int result = var01 + var02;

		System.out.printf("reslt = %X\n", result);

		/*
In decimal 	 :304638
In hexdecimal :4a5fe
In octal 	 :1122776
In hexdecimal :4A5FE
reslt = 110F91
*/


		float f01 = 20.5239f;
		System.out.printf("A) %f\n\n", f01);
		//System.out.print(f01);

		System.out.printf("B) %5.3f\n", f01);
		System.out.printf("C) %1.2f\n", f01);
		System.out.printf("D) %5.1f\n", f01);
		System.out.printf("E) %5.0f\n", f01);
		System.out.printf("F) %5f\n", f01);

		System.out.printf("G) %.4f\n", f01);
		System.out.printf("H) %.3f\n", f01);
		System.out.printf("I) %.2f\n", f01);
		System.out.printf("J) %.1f\n", f01);
		System.out.printf("K) %.0f\n", f01);
		System.out.printf("L) %.15f\n", f01);


/*
A) 20.523899

B) 20.524
C) 20.52
D)  20.5
E)    21
F) 20.523899
G) 20.5239
H) 20.524
I) 20.52
J) 20.5
K) 21
L) 20.523899078369140*/
		float f1=8.91f, f2=-8.9f, f3=327.338f, f4=1768000111.77f;

		System.out.printf("|%f|\n", f1);
		System.out.printf("|%f|\n", f2);
		System.out.printf("|%f|\n", f3);
		System.out.printf("|%f|\n", f4);

/*
|8.910000|
|-8.900000|
|327.338013|
|1768000128.000000|
*/

//Logic and bitwise operators
		int a = 5, b = 2;
		int sum1 = a & b;
		System.out.println(sum1);
// 0?
		int sum2 = a | b;
		System.out.println(sum2);
//7 ?
		int sum3= a ^ b;
		System.out.println(sum3);
		//7?

		int a1 = 26;
		int sum4 = ~a1;
		System.out.println(sum4);
		//-27 ?

		// Left shift:
		int A = 38, B =4;
		int sum5 = A << B;
		System.out.println(sum5);
//608
		System.out.println(A << 4);
		//608
		System.out.println(A*2*2*2*2);
		//608

		// Right shift

		int aa = 38, bb = 2;
		int sum6 = aa >> bb;
		System.out.println(sum6);
//9

	}


}


