import java.util.Scanner;
import java.text.NumberFormat;

public class FutureValueApp {

    public static void main(String[] args) {
        System.out.println("The Future Value Calculator\n");
        
        @SuppressWarnings("resource")
        Scanner sc = new Scanner(System.in);
        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {
            // get the input from the user
            System.out.print("Enter monthly investment:   ");
            double monthlyInvestment = sc.nextDouble();
            System.out.print("Enter number of years:      ");
            int years = sc.nextInt();
            
            // get currency and percent formatters
            NumberFormat currency = NumberFormat.getCurrencyInstance();
            NumberFormat percent = NumberFormat.getPercentInstance();
            percent.setMinimumFractionDigits(1);
            
            // initialize the table variable
            String table = "";
            
            // create header row and add it to the table
            String headerRow = "Year\t";
            for (double rate = 5.0; rate < 7.0; rate += .5) {
                headerRow += percent.format(rate/100) + "\t\t";
            }
            table += headerRow + "\n";
            
            // loop through the years
            for (int year = 1; year <= years; year++) {
                // add year to the start of the row
                String row = year + "\t";
                
                // loop through each interest rate
                for (double rate = 5.0; rate < 7.0; rate += .5) {
                    // convert yearly values to monthly values
                    int months  = year * 12;
                    double monthlyInterestRate = rate / 12 / 100;
                    
                    // calculate the future value
                    double futureValue = 0.0;
                    for (int i = 1; i <= months; i++) {
                        futureValue = (futureValue + monthlyInvestment) *
                                      (1 + monthlyInterestRate);
                    }
                    // add the calculation to the row
                    row += currency.format(futureValue) + "\t";
                }
                // add row to the table
                table += row + "\n";
            }
            System.out.println();
            System.out.println(table);

            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            System.out.println();
        }
        System.out.println("Bye!");
    }
}