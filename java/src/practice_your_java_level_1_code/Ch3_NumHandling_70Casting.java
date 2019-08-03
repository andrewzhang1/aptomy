package practice_your_java_level_1_code;

public class Ch3_NumHandling_70Casting {

	public static void main(String[] args) {
		short i = 300;
		short j = 400;

		//70
		short result1 = (short)(i + j);
		System.out.println("result1 = " + result1);


		//71 Wrong output for result2:
		short  result2 = (short)(i * j);
		System.out.println("result2 = " + result2);

		//72
		int  result3 = i * j;
		System.out.println("result3 = " + result3);
 	}

}

/*
result1 = 700
result2 = -11072
result3 = 120000*/
