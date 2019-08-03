package practice_your_java_level_1_code;

public class Ch14_NumH5_26 {
	public static void main(String[] args) {
		int uint01 = Integer.parseUnsignedInt("429470000");
		int uint02 = Integer.parseUnsignedInt("15");
		int result = uint01 + uint02;

		String str01 = Integer.toUnsignedString(result);
		System.out.println("result = " + str01);
	}
}

/*
Did not overflowed?
result = 429470015*/
