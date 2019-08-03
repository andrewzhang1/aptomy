import java.util.Scanner;

public class AgeCalculatorApp {

    public static void main(String[] args) {
        System.out.println("Welcome to the Age Calculator\n");
        
        // Get the current date

        // Get input from the the user
        @SuppressWarnings("resource")
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter your date of birth (YYYY-MM-DD): ");
        String dateOfBirthString = sc.nextLine();
        System.out.println();
        
        // Get and validate user's date of birth
        
        // If user's date of birth is valid
            // Format and print user's date of birth
            System.out.println("Your date of birth is ");

            // Format and print the current date
            System.out.println("The current date is ");

            // Calculate and print the user's age
            System.out.println("Your age is ");
    }
}