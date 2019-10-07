package CACC_2019.Week4;

// Enter your Name, age, School and city interactively from your console

import java.util.Scanner;

public class ComputeArea2 {
    /**
     * Main method
     */
    public static void main(String[] args) {

        //Reading Numbers from the Keyboard

        System.out.print("Enter a double value: ");
        Scanner input = new Scanner(System.in);
        double d = input.nextDouble();

        System.out.println("You inputed:" + d);

        // Name
        Scanner input_name = new Scanner(System.in);
        System.out.print("Enter your name: ");
        String name = input_name.nextLine();

        System.out.println("Name is: " + name);

        // Your School
        Scanner inputSchool = new Scanner(System.in);
        System.out.print("Enter your school name: ");
        String schoolName = input_name.nextLine();

        System.out.println("My Name is: " + schoolName);

    }
}


/*
Enter a double value: 76
You inputed:76.0
Enter your name: ANdrew
Name is: ANdrew
Enter your school name: FootHill High
Name is: FootHill High


 */