package John_JTFB;

public class JT_20_StringBuild_Buffer {

	public static void main(String[] args) {

		String info = "";

		info += "My name is Bob";
		info += " ";
		info += "I'm an builder,";

		System.out.println(info);

		// To get around the above unefficient way to build string, we use class "Stringbuilder" to be more efficient!

		StringBuilder sb = new StringBuilder("");
		sb.append("My name is Sue.");
		sb.append(" ");
		sb.append("I'm a lion tamer.");

		System.out.println(sb.toString());

		StringBuilder s = new StringBuilder();

		s.append("My name is Andrew.")
				.append(" ")
				.append("I'm a sky diver.");

		System.out.println(s.toString());

		// String buffer, a thread saving version of stringBuilder

		// Formating:
		System.out.println("Here is some text. \tThat was a tab.");
		System.out.println("More text.");
		System.out.printf("Total cost %d quantity is %d\n", 5, 120); // d means number?
		System.out.printf("Total cost %10d quantity is %10d\n", 5, 120); // d means number, give 10 char space!

		System.out.println("\n1. see the different:\n");
		for(int i=8; i<11; i++) {
			System.out.printf("%d: some text here\n", i);
		}

		System.out.println("\n2. see the different:\n");
		for(int i=8; i<11; i++){
			System.out.printf("%2d: some text here\n", i);
		}

		System.out.println("\n3. see the different:\n");
		for(int i=8; i<11; i++){
			System.out.printf("%-2d: some text here\n", i);
		}

		System.out.println("\n4. Another useful: %s:");
		System.out.println("\nsee the different:\n");
		for(int i=8; i<11; i++){
			System.out.printf("%-2d: %s\n", i, "here is some text here");
		}

		System.out.println("\n5. Most Useful: Print out floating point:");
		System.out.printf("Total value: %f\n", 5.6);
		//Total value: 5.600000

		System.out.printf("Total value: %.2f\n", 5.3996);
		//Total value: 5.60

		System.out.printf("Total value: %6.1f\n", 235.3996); // Total 6 space

		System.out.printf("Total value: %-6.1f\n", 235.3996); // Total 6 space

	}
}

/*
My name is Bob I'm an builder,
My name is Sue. I'm a lion tamer.
My name is Andrew. I'm a sky diver.
Here is some text. 	That was a tab.
More text.
Total cost 5 quantity is 120
Total cost          5 quantity is        120

1. see the different:

8: some text here
9: some text here
10: some text here

2. see the different:

 8: some text here
 9: some text here
10: some text here

3. see the different:

8 : some text here
9 : some text here
10: some text here

4. Another useful: %s:

see the different:

8 : here is some text here
9 : here is some text here
10: here is some text here

5. Most Useful: Print out floating point:
Total value: 5.600000
Total value: 5.40
Total value:  235.4
Total value: 235.4
*/
