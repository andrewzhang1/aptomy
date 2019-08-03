import java.util.*;
import java.text.*;

public class FutureValueApp {

    public static void main(String[] args) {
        System.out.println("Welcome to the Future Value Calculator\n");

        Scanner sc = new Scanner(System.in);
        String choice = "y";

        while (choice.equalsIgnoreCase("y")) {
            // get the input from the user
            System.out.println("DATA ENTRY");
            double monthlyInvestment = Console.getDouble(sc,
                    "Enter monthly investment: ", 0, 1000);
            double interestRate = Console.getDouble(sc,
                    "Enter yearly interest rate: ", 0, 30);
            int years = Console.getInt(sc,
                    "Enter number of years: ", 0, 100);

            // calculate the future value
            double monthlyInterestRate = interestRate / 12 / 100;
            int months = years * 12;
            double futureValue = FinancialCalculations.calculateFutureValue(
                    monthlyInvestment, monthlyInterestRate, months);

            // get the currency and percent formatters
            NumberFormat c = NumberFormat.getCurrencyInstance();
            NumberFormat p = NumberFormat.getPercentInstance();
            p.setMinimumFractionDigits(1);

            // format the result as a single string
            String results
              = "Monthly investment:   " + c.format(monthlyInvestment) + "\n"
              + "Yearly interest rate: " + p.format(interestRate / 100) + "\n"
              + "Number of years:      " + years + "\n"
              + "Future value:         " + c.format(futureValue) + "\n";

            // print the results
            System.out.println();
            System.out.println("FORMATTED RESULTS");
            System.out.println(results);

            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            sc.nextLine();  // discard any other data entered on the line
            System.out.println();
        }
    }
}