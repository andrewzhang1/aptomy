package practice_your_java_level_1_code;

public class Ch6_Condition_8 {

	public static void main(String[] args) {

		int x =4;
		//int y = 18;
		int z1 = 80;
		int z2 = 96;

		if ( (x > 5) || (z1 ==0) ^ (z2 == 9)) //(^ XOR: only one condiftion can be true)
		{
			System.out.print("got some result\n");
		}


		//String customerLevel = "gold";
		//String customerLevel = "gold";
		String customerLevel = "bronze";
		//String customerLevel = "wrong";
		customerLevel = customerLevel.toLowerCase();

		System.out.println("Your benefits are: ");
		switch (customerLevel){
			case "gold":
				System.out.println("\t include dinner for 1");
			case "silver":
				System.out.println("\t include breakfast");
			case "bronze":
				System.out.println("\t free parking");
			default:
				System.out.println("\t room");

		}
 	}
}

/*
got some resultYour benefits are:
	 include breakfast
	 free parking
	 room
*/
