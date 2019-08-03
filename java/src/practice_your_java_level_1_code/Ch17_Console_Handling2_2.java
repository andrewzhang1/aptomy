package practice_your_java_level_1_code;

import java.io.Console;

public class Ch17_Console_Handling2_2 {
    public static void main(String[] args) {

        Console consoleObject = System.console();
        if(consoleObject != null) {
            System.out.print("Please enter your first name: ");
            String firstName = consoleObject.readLine();
            System.out.print("Please enter your last name: ");
            String lastName = consoleObject.readLine();
            System.out.printf("\nYour name is %s %s", firstName, lastName);
        }
        else
            System.out.println("A console obeject was not obatained successfully.");

    }
}
