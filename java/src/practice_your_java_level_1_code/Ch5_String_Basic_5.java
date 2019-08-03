package practice_your_java_level_1_code;

public class Ch5_String_Basic_5 {

	public static void main(String[] args) {

		String fisrtName = "Andrew";
		int stringLength = 0;
		System.out.println("The string length of Andrew is: " + fisrtName.length());
		System.out.println("The string length of 'Andrew Zhang' is: " + "Andrew Zhang".length());

		System.out.println(fisrtName.toUpperCase());

		//11
		String s1 = null;
		String s2 = "";
		System.out.println(s1);
		System.out.println(s2);
		//System.out.println(s1.length()); //Exception in thread "main" java.lang.NullPointerException
		System.out.println(s2.length());

		//15-3
		String rhymeLine = "Mary has a little lamb";
		System.out.printf("The position of the letter \'i\' is %d\n", rhymeLine.indexOf('i'));

		//20 replace
		String r = "Mary had a little lamb, \nlittle lamb";
		String newr = r.replace("little", "big");
		System.out.printf("The newr is: \n%s\n", newr);

 	}

}
/*

The string length of Andrew is: 6
The string length of 'Andrew Zhang' is: 12
ANDREW
null

0
*/

/*
//20
The newr is:
Mary had a big lamb, Ch5_String_Basic_5
big lamb
*/


