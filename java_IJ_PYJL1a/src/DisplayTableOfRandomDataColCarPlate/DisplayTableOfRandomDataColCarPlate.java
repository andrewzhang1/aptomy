package DisplayTableOfRandomDataColCarPlate;

import java.util.Scanner;

public class DisplayTableOfRandomDataColCarPlate {

    	public static void main(String[] args) {
		System.out.println("Welcome to the Squares and Cubes table");
		System.out.println("");

		Scanner sc = new Scanner(System.in);

		double num = Math.random();


		String choice = "y";
		while (choice.equalsIgnoreCase("y")) {
			//Get some input from the user:

			System.out.print("Enter an integer:   ");
			int integer1 = sc.nextInt();
			System.out.println();

		//	string CarPlateID = 'f';

			// define the table and append the header rows
			String	table = "";
			table += "ID_Num Random1 Random2 Random3 Random4 Random5\n";

			for (int i = 1; i <= integer1; i++ ){
				double  Random1  = Math.random() * 100;
				double  Random2  = Math.random() * 100;
				double  Random3  = Math.random() * 100;
                double  Random4  = Math.random() * 100;
				double  Random5  = Math.random() * 100;


				table += "ID" + i + " " + Random1 + " " + Random2 + " " + Random3 + " " + Random4 +  " " + Random5 + " " + "\n";

			}

			// Display the table
			System.out.println(table);

			// See if the user wants to do again:
			System.out.println();
            System.out.print("Continue? (y/n): " );
            choice = sc.next();
            System.out.println();
		}
	}

}
