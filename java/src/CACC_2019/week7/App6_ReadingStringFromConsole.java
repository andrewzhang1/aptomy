package CACC_2019.week7;

import java.util.Scanner;

public class App6_ReadingStringFromConsole {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        System.out.print("Enter a character: ");
        String s = input.nextLine(); //gets entire line
        char ch = s.charAt(0);
        System.out.println("The character entered is " + ch);
    }

}


