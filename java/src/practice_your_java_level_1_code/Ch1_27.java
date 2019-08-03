package practice_your_java_level_1_code;
// About varargs:

public class Ch1_27 {
	static long addIntegers(int... intArray){
		if (intArray.length == 0) return (0);
		long total = 0;
		for (int i = 0; i < intArray.length; i++)
			total += intArray[i];
			return (total);
		
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		long result1 = 0, result2 = 0, result3 = 0, result4 = 0;
		result1 = addIntegers(1,2,3,4,5,6,7,8,9,10);
		result2 = addIntegers(55, 76, 88,13);
		result3 = addIntegers(3,7);

		int[] intArray01 = {1, 5, 15, 5};
		result4 = addIntegers(intArray01);
		System.out.println(result4);
        System.out.printf("is %s" , result1);
	}
}
