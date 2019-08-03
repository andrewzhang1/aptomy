import java.util.Scanner;
import java.text.NumberFormat;
import java.math.BigDecimal;
import java.math.RoundingMode;

public class InvoiceApp {

    public static void main(String[] args) {
        final BigDecimal SALES_TAX_PCT = new BigDecimal(".05");

        @SuppressWarnings("resource")
		Scanner sc = new Scanner(System.in);
        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {
            System.out.print("Enter subtotal:   ");
            String subtotalString = sc.next();

            BigDecimal subtotal = new BigDecimal(subtotalString);
            BigDecimal discountPercent;
            if (subtotal.doubleValue() >= 100) {
                discountPercent = new BigDecimal(".1");
            } else {
                discountPercent = new BigDecimal("0.0");
            }

            // calculate the results
            BigDecimal discountAmount = subtotal.multiply(discountPercent)
                    .setScale(2, RoundingMode.HALF_UP);
            BigDecimal totalBeforeTax = subtotal.subtract(discountAmount);
            BigDecimal salesTax = SALES_TAX_PCT.multiply(totalBeforeTax)
                    .setScale(2, RoundingMode.HALF_UP);
            BigDecimal total = totalBeforeTax.add(salesTax);

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