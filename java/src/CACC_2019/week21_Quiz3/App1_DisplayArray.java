package CACC_2019.week21_Quiz3;

/*
App1_DisplayArray.java

* */

public class App1_DisplayArray {
	public static void main(String[] args) {

		System.out.println("CACC Week21 Quiz Q2");
		System.out.println("Andrew Zhang");
		System.out.println("");
		System.out.println("Date:    2/16/2020");
		System.out
				.println("**********************************************************");
		System.out.println("");

		// Combing two steps into one: declaring an array and define the array:
		int[] array1 = { -15, 450, 6, -9, 9 };
		System.out.print("The Original Input Array1[] is: ");

		displayArrayOneLine(array1);
		System.out.println("\nThe length of the Array is: " + array1.length);
	}

	// Method to display the array in one line:
	public static void displayArrayOneLine(int[] ary) {
		for (int i = 0; i < ary.length; i++) {
			System.out.print(ary[i]);
			if (i != ary.length -1)
				System.out.print(" ");
		}
	}
}
