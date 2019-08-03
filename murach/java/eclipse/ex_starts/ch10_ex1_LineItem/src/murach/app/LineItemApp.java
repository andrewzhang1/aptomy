package murach.app;

import murach.business.*;
import murach.database.ProductDB;
import murach.presentation.Console;

public class LineItemApp {

    public static void main(String args[]) {
        // display a welcome message
        System.out.println("Welcome to the Line Item Calculator");
        System.out.println();

        // perform 1 or more calculations
        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {
            // get the input from the user
            String productCode = Console.getString("Enter product code: ");
            int quantity = Console.getInt("Enter quantity:     ", 0, 1000);

            // use the ProductDB class to get the Product object
            Product product = ProductDB.getProduct(productCode);

            // create the LineItem object
            LineItem lineItem = new LineItem();
            lineItem.setProduct(product);
            lineItem.setQuantity(quantity);

            // display the output
            System.out.println();
            System.out.println("LINE ITEM");
            System.out.println("Code:        " + product.getCode());
            System.out.println("Description: " + product.getDescription());
            System.out.println("Price:       " + product.getPriceFormatted());
            System.out.println("Quantity:    " + lineItem.getQuantity());
            System.out.println("Total:       "
                    + lineItem.getTotalFormatted() + "\n");

            // see if the user wants to continue
            choice = Console.getString("Continue? (y/n): ");
            System.out.println();
        }
    }
}