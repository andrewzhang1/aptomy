import java.text.NumberFormat;
import java.util.Scanner;

public class FutureValueApp {

	public static void main(String[] args) {
        System.out.println("Welcome to the Future Value Calculator");
        System.out.println();

        // get a Scanner object to scan for user input
		@SuppressWarnings("resource")
		Scanner sc = new Scanner(System.in);

        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {

            // get input from user
            System.out.print("Enter monthly investment:   ");
            double monthlyInvestment = sc.nextDouble();

            System.out.print("Enter yearly interest rate: ");
            double interestRate = sc.nextDouble();

            System.out.print("Enter number of years:      ");
            int years = sc.nextInt();

            // convert all input values to months
            double monthlyInterestRate = interestRate / 12 / 100;
            int months = years * 12;
            
            // call method to calculate future value
            double futureValue = calculateFutureValue(
                    monthlyInvestment, monthlyInterestRate, months);

            // format and display the result
            NumberFormat currency = NumberFormat.getCurrencyInstance();
            System.out.println("Future value:               "
                    + currency.format(futureValue) + "\n");

            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            System.out.println();
        }
    }

    private static double calculateFutureValue(double monthlyInvestment,
            double monthlyInterestRate, int months) {
        double futureValue = 0;
        for (int i = 1; i <= months; i++) {
            futureValue = (futureValue + monthlyInvestment)
                    * (1 + monthlyInterestRate);
        }
        return futureValue;
    }
}