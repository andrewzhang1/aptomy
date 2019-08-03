package practice_your_java_level_1_code;

public class Ch8_Loops_14_Enchanced {

	public static void main(String[] args) {
		int[] intArry01 = {18, 25, 4, 66, 8};
		int index = 0;
		for (int item : intArry01){
			System.out.printf("intArray01[%d] = %d\n" , index, item);
			index++;
		}
 	}
}

/* without index:
18
25
4
66
8
*/

/*
After adding index:
intArray01[0] = 18
intArray01[1] = 25
intArray01[2] = 4
intArray01[3] = 66
intArray01[4] = 8*/
