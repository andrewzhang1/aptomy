// This is Gore Fee HW. this is the best calculator in the WORLD!//
package CACC_2019.week5;
import java.util.Scanner;
public class CACCGoreFeeWeek5HW {
    public static void main(String[] args) {
        char operator;
        Double number1, number2, result;

        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter operator (either +, -, * or /): ");
        operator = scanner.next().charAt(0);
        System.out.print("Enter number1 and number2 respectively: ");
        number1 = scanner.nextDouble();
        number2 = scanner.nextDouble();

        switch (operator) {
            case '+':
                result = number1 + number2;
                System.out.print(number1 + "+" + number2 + " = " + result);
                break;
            case '-':
                result = number1 - number2;
                System.out.print(number1 + "-" + number2 + " = " + result);
                break;
            case '*':
                result = number1 * number2;
                System.out.print(number1 + "*" + number2 + " = " + result);
                break;
            case '/':
                result = number1 / number2;
                System.out.print(number1 + "/" + number2 + " = " + result);
                break;
            default:
                System.out.println("Invalid operator!");
                break;
        }
    }
}

/*

Enter operator (either +, -, * or /): 4
Enter number1 and number2 respectively: 5
3
Invalid operator!

Process finished with exit code 0

*/