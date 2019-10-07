package CACC_2019.Week2;

import java.util.Scanner;


/**
 * Program Name: CP101_Assignment1_PrintName.java
 * Written By:   Andrew Zhang
 * Date:         2010/08/25
 */

// An example of how to use keyboard as an input
public class PrintName {

	public static void main(String[] args) {

		Scanner input = new Scanner(System.in);

		System.out.println("Please type in your first Name:");
		String string1 = input.nextLine();

		System.out.println("Please type in your last name:");
		String string2 = input.nextLine();

		System.out.println("\nYou Full Name is: "+ string1 + " " + string1);

		System.out.println("\nPlease type in your grade, School Name, and City you're from (for example: 8th grade, Hart Middle school, Pleasnton");
		String string3 = input.nextLine();

		System.out.println("\nMy grade, schoole name, and city are: " + string3);

	}
}

/* Output:

Please type in your first Name:
Andrew
Please type in your last name:
Zhang

You Full Name is: Andrew Andrew

Please type in your grade, School Name, and City you're from (for example: 8th grade, Hart Middle school, Pleasnton
4th, DFD elelem, Fremont

My grade, schoole name, and city are: 4th, DFD elelem, Fremont

Process finished with exit code 0


 */