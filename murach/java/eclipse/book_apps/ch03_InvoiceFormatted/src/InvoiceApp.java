import java.util.Scanner;
import java.text.NumberFormat;

public class InvoiceApp {

    public static void main(String[] args) {
        final double SALES_TAX_PCT = .05;

        @SuppressWarnings("resource")
		Scanner sc = new Scanner(System.in);
        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {
            System.out.print("Enter subtotal:   ");
            double subtotal = sc.nextDouble();

            double discountPercent;
            if (subtotal >= 100) {
                discountPercent = .1;
            } else {
                discountPercent = 0.0;
            }

            // calculate the results
            // round to 2 decimal places where necessary
            double discountAmount = subtotal * discountPercent;
            discountAmount = (double) Math.round(discountAmount * 100) / 100;
            double totalBeforeTax = subtotal - discountAmount;
            double salesTax = totalBeforeTax * SALES_TAX_PCT;
            salesTax = (double) Math.round(salesTax * 100) / 100;
            double total = totalBeforeTax + salesTax;
            
            // The following code is for debugging only
            /*
            String debugMessage = 
                    "\nUNFORMATTED RESULTS\n"
                    + "Discount percent: " + discountPercent + "\n"
                    + "Discount amount:  " + discountAmount + "\n"
                    + "Total before tax: " + totalBeforeTax + "\n"
                    + "Sales tax:        " + salesTax + "\n"
                    + "Invoice total:    " + total + "\n"
                    + "\nFORMATTED RESULTS";
            System.out.println(debugMessage);
            */

            // format and display the results
            NumberFormat currency = NumberFormat.getCurrencyInstance();
            NumberFormat percent = NumberFormat.getPercentInstance();
            String message = 
                "Discount percent: " + percent.format(discountPercent) + "\n"
              + "Discount amount:  " + currency.format(discountAmount) + "\n"
              + "Total before tax: " + currency.format(totalBeforeTax) + "\n"
              + "Sales tax:        " + currency.format(salesTax) + "\n"
              + "Invoice total:    " + currency.format(total) + "\n";
            System.out.println(message);

            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            System.out.println();
        }
    }
}