package CACC_2019.week5;

public class Condition {

	public static void main(String[] args) {

		int x =4;
		//int y = 18;
		int z1 = 90;
		int z2 = 90;

		if ( (x > 5) && (z1 == 0) ^ (z2 == 9)) //(^ XOR: only one condiftion can be true)
		{
			System.out.print("got some result\n");
		}
		else
			System.out.printf("No result match!\n");

/*
		int w = 5 / 2.5;
		System.out.printf("w = " + w);
*/



		String customerLevel = "gold";
		//String customerLevel = "gold";
		//String customerLevel = "bronze";
		//String customerLevel = "wrong";
		customerLevel = customerLevel.toLowerCase();

		System.out.println("\n\nYour benefits are: ");
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
