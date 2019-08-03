package John_JTFB;

public class JT_3_String {
    	public static void main(String[] args) {
		int myInt = 7;

		String text = "Hello";
		String blank = " ";
		String name = "bob";

		String greeting = text + blank + name;

		System.out.println(greeting);

		System.out.println("My integer is : " + myInt);

		int ageA = 52;
		int ageJ = 18;
		String nameA = "Andrew";
		String nameJ = "Jason";

		System.out.println("Andrew's age + Jason's Age");
		System.out.println(ageA + ageJ);
		System.out.println(ageA + ageJ + nameA + nameJ);

		System.out.println("Andrew's age + Jason's Age - Second Way:");
		System.out.println(nameA + nameJ + ageA + ageJ);
		System.out.println(nameA + nameJ + (ageA + ageJ));

	}

}
