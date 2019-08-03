package practice_your_java_level_1_code;

public class Ch10_booleanWrapperClass {

	public static void main(String[] args) {
		Boolean a = new Boolean(true);
		Boolean b = new Boolean(false);

		System.out.println(Boolean.logicalAnd(a,b));
		System.out.println(Boolean.logicalOr(a,b));
		System.out.println(Boolean.logicalXor(a,b));
	}
}
/*
false
true
true
*/
