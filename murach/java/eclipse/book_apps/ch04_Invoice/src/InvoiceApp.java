import java.text.NumberFormat;
import java.util.Scanner;

public class InvoiceApp {

    public static void main(String[] args) {
        @SuppressWarnings("resource")
		Scanner sc = new Scanner(System.in);
        String choice = "y";

        while (choice.equalsIgnoreCase("y")) {
            // get the input from the user
            System.out.print("Enter customer type (r/c): ");
            String customerType = sc.next();
            System.out.print("Enter subtotal:   ");
            double subtotal = sc.nextDouble();

            // get the discount percent
            double discountPercent = 0;
            switch(customerType) {
                case "r":
                case "R":
                    if (subtotal < 100) {
                        discountPercent = 0.0;
                    } else if (subtotal >= 100 && subtotal < 250) {
                        discountPercent = .1;
                    } else if (subtotal >= 250) {
                        discountPercent = .2;
                    }
                    break;
                case "c":
                case "C":
                    if (subtotal < 250) {
                        discountPercent = .2;
                    } else if (subtotal >= 250) {
                        discountPercent = .3;
                    }
                    break;
                default:
                    discountPercent = .1;
                    break;
            }

            // calculate the discount amount and round to 2 decimals
            double discountAmount = subtotal * discountPercent;
            discountAmount = Math.ceil(discountAmount * 100) / 100;

            // calculate the total
            double total = subtotal - discountAmount;

            // format and display the results
            NumberFormat currency = NumberFormat.getCurrencyInstance();
            NumberFormat percent = NumberFormat.getPercentInstance();
            System.out.println(
                "Discount percent: " + percent.format(discountPercent) + "\n"
              + "Discount amount:  " + currency.format(discountAmount) + "\n"
              + "Total:            " + currency.format(total) + "\n");

            // see if the user wants to continue
            System.out.print("Continue? (y/n): ");
            choice = sc.next();
            System.out.println();
        }
    }
}