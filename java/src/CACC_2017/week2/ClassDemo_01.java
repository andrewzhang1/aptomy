package CACC_2017.week2;

import java.util.Scanner;

// An example of how to use keyboard as an input
public class ClassDemo_01 {

	public static void main(String[] args) {
		Scanner input = new Scanner(System.in);

		System.out.println("Please type in your 1st number:");
		String string1 = input.nextLine();

		System.out.println("Please type in your 2nd number:");
		String string2 = input.nextLine();
		
		input.close();
		
		double number1 = Double.parseDouble(string1);
		double number2 = Double.parseDouble(string2);

		System.out.println("The summation of the 2 numbers is: "+ (number1 + number2));
	}
}
