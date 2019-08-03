package practice_your_java_level_1_code;

public class Ch3_NumHandling_142_Binary {

	public static void main(String[] args) {
		int var_binary = 0b00001110;
		System.out.println(var_binary);

		int var01 = 0b1000011;
		int var02 = 0b1111101;
		int var03 = var01 + var02;
		System.out.println(var03);

/*
14
192
*/

//144
        int var_hexdicimal = 0xFFF0;
		System.out.println(var_hexdicimal);

		int var_hexdicimal1 = 0b1000011;
		int var_hexdicimal2 = 0b1111101;
		int var_hexdicimal3 = var_hexdicimal1 + var_hexdicimal2;
		System.out.println(var_hexdicimal3);

		//146: Random

		double random01 = Math.random()*10;
		System.out.println(random01);

// A random integer from 1 to 10
		int random02 = (int)Math.ceil(Math.random()*10);
		System.out.println(random02);

 	}

}


