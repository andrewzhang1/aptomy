
public class Cis36AFall2014AndrewZhangLab1Ex1 {

	/**
	 * Author: Andrew Zhang Date: Aug. 26, 2014
	 */
	public static void main(String[] args) {
		
		// JT_25_Public_Private_Protected.Test adding tasks
		int agz =16;
		
		System.out.println("CIS 36A Java Programming");
		System.out.println("Laney College");
		System.out.println("Andrew Zhang");
		System.out.println("");
		System.out.println("Assignment Information --");
		System.out.println("  Assignment Number: Lab 01,");
		System.out
				.println("                     Coding Assignment -- Exercise #1");
		System.out.println("  Written by:        Andrew Zhang");
		System.out.println("  Submitted Date:    Sept. 2,  2014");
		System.out
				.println("**********************************************************");
		System.out.println("");

		// Combing two steps into one: declaring an array and define the array:
		int[] array1 = { -15, 450, 6, -9, 9 };
		//After moved and sorted array should look like: -15 -9 9 450 6

		// Display the first array on the one line:
		System.out.print("The Original Input Array1[] is: ");
		displayArrayOneLine(array1);
	//	System.out.println();
		
		int[] array2 = { 100, -15, 450, 6, -91, 9 };
		//After moved and sorted array should look like: -91 15 9 450 100 6
		

		System.out.println();

		// Call the method to move the odd numbers before the even:
		// moveAndSortInt(array1);

		// Code to find the even number in the array
		System.out.println();

		// Call the method for to move the odd number to the top:
		System.out.println("Calling moveAndSortInt() --");	
		
		array1 = moveAndSortInt(array1);

		/**********
		moveAndSortInt(array1);
		****/
	
		System.out.println("Updated sorted Arry1[] is: ");
		displayArrayOneLine(array1);
		
		System.out.println();		
		
		System.out.println();	
		
		System.out.print("The Original Input Array2[] is: ");
		System.out.println();	
		displayArrayOneLine(array2);
		System.out.println();

		System.out.println("Calling moveAndSortInt() --");
		
		System.out.println();
		 array2 = moveAndSortInt(array2);
		//moveAndSortInt(array2);
		

		System.out.println("Updated ssorted Arry2[] is: ");
		displayArrayOneLine(array2);

	}

	// Method to display the array in one line:
	public static void displayArrayOneLine(int[] ary) {
		for (int i = 0; i < ary.length; i++) {
			System.out.print(ary[i]);
			if (i != ary.length - 1)
				System.out.print(", ");
		}
	}

	// Method to move and sort the array:
	public static int[] moveAndSortInt(int[] ary) {
		/*
		 * Logic: 
		 * First, move odd up and even down; 
		 * Secondary, sort odd numbers ascending and even numbers descending.
		 */
		int i = 0;
		int j = ary.length -1 ;
		int temp = 0;

		// Add another for loop to move on for the search
		for (i = 0; i < j; i++) {
			if (ary[i] % 2 == 0) {
				// swap the ary[j] with ary[i] if ary[j] is an odd: 
				while (ary[j] % 2 == 0) {
					j--;
				}

				// Compare only until i < j; otherwise, it will repeat the process.
				if (i < j) {
					temp = ary[i];
					ary[i] = ary[j];
					ary[j] = temp;
				}
				System.out.println();
			}
		}
		
		// Find the index of the last odd number to separate from the even number
		int indexOfOdd = -1;
		for(int z = 0; z < ary.length; z++){
			if( ary[z] % 2!= 0 )
				indexOfOdd++;
			System.out.print(ary[z]+ ", ");
		}
		System.out.println("*********** Temp result (odd before even)");
		
	//Ascends the odds
		if( indexOfOdd> -1 )
		for (int m = 0; m <= indexOfOdd-1; m++) {
			// Find the minimum in the list[i..list.length-1]
			double currentMin = ary[m];
			int currentMinIndex = m;

			for (int n = m + 1; n <= indexOfOdd; n++) {
				if (currentMin > ary[n]) {
					currentMin = ary[n];
					currentMinIndex = n;
				}
			}
			// Swap list[i] with list[currentMinIndex] if necessary
			if (currentMinIndex != m) {
				ary[currentMinIndex] = ary[m];
				ary[m] = (int) currentMin;
			}
		} 	
		
	//Descends the even
		if(indexOfOdd < ary.length-1)
		for (int m = indexOfOdd+1; m < ary.length - 1; m++) {
			// Find the maximum in the list[i..list.length-1]
			double currentMax = ary[m];
			int currentMaxIndex = m;

			for (int n = m + 1; n < ary.length; n++) {
				if (currentMax < ary[n]) {
					currentMax = ary[n];
					currentMaxIndex = n;
				}
			}
			// Swap list[i] with list[currentMaxIndex] if necessary
			if (currentMaxIndex != m) {
				ary[currentMaxIndex] = ary[m];
				ary[m] = (int) currentMax;
			}
		} 	
		
		 int[] myArray = ary;
		 return myArray;


	}

}
