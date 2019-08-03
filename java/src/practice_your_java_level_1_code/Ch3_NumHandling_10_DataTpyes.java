package practice_your_java_level_1_code;

public class Ch3_NumHandling_10_DataTpyes {

	public static void main(String[] args) {
		System.out.println("\n=== Inger===");
		System.out.println(Integer.MIN_VALUE);
		System.out.println(Integer.MAX_VALUE);
		System.out.printf("Integer.SIZE is %s", Integer.SIZE);
		System.out.println("\nInteger.SIZE is "  + Integer.SIZE);

		System.out.println("\n=== Byte===");

		byte firstByte = -115;
		System.out.println("The value of firstByte is " + firstByte);
		System.out.println(Byte.MIN_VALUE);
		System.out.println(Byte.MAX_VALUE);
		System.out.println(Byte.SIZE);

		System.out.println("\n=== Short ===");

		short fisrtShort = 1000;
		System.out.println("The value of firstShort is " + firstByte);
		System.out.println(Short.MIN_VALUE);
		System.out.println(Short.MAX_VALUE);
		System.out.println(Short.SIZE);

		//long
		long firstLong = 7000000000L;
		//above syntax is ok!
		System.out.println("The value of fistLong is " + firstLong);
		System.out.println("Long.MIN_VALUE is " + Long.MIN_VALUE);
		System.out.println(Long.MAX_VALUE);
		System.out.println(Short.SIZE);

//Floating:
		System.out.println("\n=== Floating===");
		System.out.println("Minimum value = %f\n" + (-1 * Float.MAX_VALUE));
		System.out.println("Maximum value = " + Float.MAX_VALUE);
		System.out.println("Bits cccupied = " + Float.SIZE);

		//chp 3: 34
		System.out.printf("Smallest positive float = %f", Float.MIN_VALUE);

		float fistFloat = 7.9198765424545898989898945455454589894F;
		System.out.println("");
		System.out.println(fistFloat);

		float f1 = 1768000111.77F;
		System.out.printf("f1 = %f\n", f1);

		//39. Double:
		System.out.println("\n=== Double===");
		System.out.println("Minimum value = " + (-1 * Double.MAX_VALUE));
		System.out.println("Maximum value = " + Double.MAX_VALUE);
		System.out.println("Bits ccupied =  " + (-1 * Double.SIZE));

		double d1 = 1768888111.77;
		System.out.printf("d1 = %f\n", d1);
		System.out.println(d1);



	}
	

}
/*

=== Inger===
-2147483648
2147483647
Integer.SIZE is 32
Integer.SIZE is 32

=== Byte===
The value of firstByte is -115
-128
127
8

=== Short ===
The value of firstShort is -115
-32768
32767
16
The value of fistLong is 7000000000
-9223372036854775808
9223372036854775807
16

=== Floating===
Minimum value = %f
-3.4028235E38
Maximum value = 3.4028235E38
Bits cccupied = 32
Smallest positive float = 0.000000
7.9198766
f1 = 1768000128.000000

=== Double===
Minimum value = -1.7976931348623157E308
Maximum value = 1.7976931348623157E308
Bits ccupied =  -64
d1 = 1768888111.770000
1.76888811177E9
*/
