package CACC_2017.week3;

import java.util.Scanner;

public class HW03_01 {

	public static void main(String[] args) {
		Scanner input = new Scanner(System.in);
		System.out.println("Please type in your 1st number:");
		String numStr = input.nextLine();
		int num = Integer.parseInt(numStr);
		for(int i=0;i<num;i++){
			int result = 1;
			for(int j=0;j<=i;j++){
				result = result * (j+1);
			}
			System.out.println(""+(i+1)+"! = "+result);
		}
	}

}
