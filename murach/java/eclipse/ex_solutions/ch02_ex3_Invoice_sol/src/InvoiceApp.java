import java.util.Scanner;

public class InvoiceApp {

    public static void main(String[] args) {
        // welcome the user to the program
        System.out.println("Welcome to the Invoice Total Calculator");
        System.out.println();  // print a blank line

        // create a Scanner object named sc
        @SuppressWarnings("resource")
        Scanner sc = new Scanner(System.in);
        
        // initialize variables for use in calculating averages
        double invoiceTotal = 0.0;
        double discountTotal = 0.0;
        int invoiceCount = 0;

        // perform invoice calculations until choice is "n" or "N"
        String choice = "y";
        while (!choice.equalsIgnoreCase("n")) {
            // get the invoice subtotal from the user
            System.out.print("Enter subtotal:   ");
            double subtotal = sc.nextDouble();

            // calculate the discount amount and total
            double discountPercent;
            if (subtotal >= 500) {
                discountPercent = .25;
            } else if (subtotal >= 200) {
                discountPercent = .2;
            } else if (subtotal >= 100) {
                discountPercent = .1;
            } else {
                discountPercent = 0.0;
            }
            double discountAmount = subtotal * discountPercent;
            double total = subtotal - discountAmount;
            
            // accumulate the invoice count and invoice total
            invoiceTotal = invoiceTotal + total;
            discountTotal = discountTotal + discountAmount;
            invoiceCount = invoiceCount + 1;       

            // display the discount percent, discount amount, and total
            String message = "Discount percent: " + discountPercent + "\n"
                           + "Discount amount:  " + discountAmount + "\n"
                           + "Invoice total:    " + total + "\n";            
            System.out.println(message);
            
            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            System.out.println();
        }
        
        // calculate and display invoice count, average invoice, and average discount
        String message = "Number of invoices: " + invoiceCount + "\n"
                       + "Average invoice:    " + invoiceTotal / invoiceCount + "\n"
                       + "Average discount:   " + discountTotal / invoiceCount + "\n";
        System.out.println(message);
    }
}