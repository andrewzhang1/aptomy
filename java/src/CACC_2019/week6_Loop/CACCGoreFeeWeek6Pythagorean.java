package week6;

import java.util.Scanner;

public class CACCGoreFeeWeek6Pythagorean {

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        double side1, side2, hypotenuse;

        //get the length of the first side
        System.out.print("Enter a value for Side 1: ");
        side1 = input.nextDouble();

        //get the length of the second side
        System.out.print("Enter a value for Side 2: ");
        side2 = input.nextDouble();

        //find the square root of (side1^2 + side2^2)
        hypotenuse = Math.sqrt(Math.pow(side1, 2) + Math.pow(side2, 2));

        System.out.println("The length of the hypotenuse is: " + hypotenuse);

    }
}
