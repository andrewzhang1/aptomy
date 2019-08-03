package practice_your_java_level_1_code;

import java.lang.reflect.Array;
import java.util.Arrays;

public class Ch7_Array_33 {

	public static void main(String[] args) {

		int[] intArray01 = {55, 747, 15999, 89, 2333};
		System.out.printf("intArray's contents are now            %s\n", Arrays.toString(intArray01) );
		Arrays.sort(intArray01);
		System.out.printf("intArray's contents after sort are now %s\n", Arrays.toString(intArray01) );

// 34
		Arrays.parallelSort(intArray01);
		System.out.printf("intArray's contents after sort are now %s\n", Arrays.toString(intArray01) );

 	}
}

