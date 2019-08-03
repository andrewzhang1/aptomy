package murach.presentation;

import java.util.Scanner;

/**
 * The <code>Validator</code> class provides methods that can be used to get
 * input from a console application.
 */
public class Console {

    /**
     * Displays the specified prompt to the console and uses the specified
     * <code>Scanner</code> object to get a <code>String</code> from the user.
     *
     * @param sc     A <code>Scanner</code> object for the console.
     * @param prompt A <code>String</code> prompt to the user.
     * @return       A <code>String</code> entered by the user.
     */
    public static String getString(Scanner sc, String prompt) {
        boolean isValid = false;
        String s = "";
        while (isValid == false) {
            System.out.print(prompt);
            if (sc.hasNext()) {
                s = sc.nextLine(); // read entire line
                isValid = true;
            } else {
                System.out.println("Error! Invalid string value. Try again.");
            }
        }
        return s;
    }

    /**
     * Displays the specified prompt to the console and uses the specified
     * <code>Scanner</code> object to get a <code>double</code> value from the
     * user.
     *
     * @param sc     A <code>Scanner</code> object for the console.
     * @param prompt A <code>String</code> prompt to the user.
     * @return       A <code>double</code> value entered by the user.
     */
    public static double getDouble(Scanner sc, String prompt) {
        boolean isValid = false;
        double d = 0;
        while (isValid == false) {
            System.out.print(prompt);
            if (sc.hasNextDouble()) {
                d = sc.nextDouble();
                isValid = true;
            } else {
                sc.next();     // discard the incorrectly entered double
                System.out.println("Error! Invalid decimal value. Try again.");
            }
            sc.nextLine();  // discard any other data entered on the line
        }
        return d;
    }

    /**
     * Displays the specified prompt to the console and uses the specified
     * <code>Scanner</code> object to get a <code>double</code> value from the
     * user that's within the specified range.
     *
     * @param sc     A <code>Scanner</code> object for the console.
     * @param prompt A <code>String</code> prompt to the user.
     * @param min    The minimum <code>double</code> value.
     * @param max    The maximum <code>double</code> value.
     * @return       A <code>double</code> value entered by the user.
     */
    public static double getDouble(Scanner sc, String prompt,
            double min, double max) {
        double d = 0;
        boolean isValid = false;
        while (isValid == false) {
            d = Console.getDouble(sc, prompt);
            if (d <= min) {
                System.out.println(
                        "Error! Number must be greater than " + min);
            } else if (d >= max) {
                System.out.println(
                        "Error! Number must be less than " + max);
            } else {
                isValid = true;
            }
        }
        return d;
    }

    /**
     * Displays the specified prompt to the console and uses the specified
     * <code>Scanner</code> object to get an <code>int</code> value from the
     * user.
     *
     * @param sc     A <code>Scanner</code> object for the console.
     * @param prompt A <code>String</code> prompt to the user.
     * @return       An <code>int</code> value entered by the user.
     */
    public static int getInt(Scanner sc, String prompt) {
        boolean isValidInt = false;
        int i = 0;
        while (isValidInt == false) {
            System.out.print(prompt);
            if (sc.hasNextInt()) {
                i = sc.nextInt();
                isValidInt = true;
            } else {
                sc.next();  // discard invalid data
                System.out.println("Error! Invalid integer value. Try again.");
            }
            sc.nextLine();  // discard any other data entered on the line
        }
        return i;
    }

    /**
     * Displays the specified prompt to the console and uses the specified
     * <code>Scanner</code> object to get an <code>int</code> value from the
     * user that's within the specified range.
     *
     * @param sc     A <code>Scanner</code> object for the console.
     * @param prompt A <code>String</code> prompt to the user.
     * @param min    The minimum <code>int</code> value.
     * @param max    The maximum <code>int</code> value.
     * @return       An <code>int</code> value entered by the user.
     */
    public static int getInt(Scanner sc, String prompt,
            int min, int max) {
        int i = 0;
        boolean isValid = false;
        while (isValid == false) {
            i = Console.getInt(sc, prompt);
            if (i <= min) {
                System.out.println(
                        "Error! Number must be greater than " + min);
            } else if (i >= max) {
                System.out.println(
                        "Error! Number must be less than " + max);
            } else {
                isValid = true;
            }
        }
        return i;
    }
}