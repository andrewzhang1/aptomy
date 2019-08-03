package murach.database;

import murach.business.*;

public class ProductDB {
    public static Product getProduct(String productCode) {
        // In a more realistic application, this code would
        // get the data for the product from a file or database
        // For now, this code just uses if/else statements
        // to return the correct product

        // create the product
        Product product = new Product();
        product.setCode(productCode);

        if (productCode.equalsIgnoreCase("java")) {
            product.setDescription("Murach's Java Programming");
            product.setPrice(57.50);
        }
        else if (productCode.equalsIgnoreCase("jsp")) {
            product.setDescription("Murach's Java Servlets and JSP");
            product.setPrice(57.50);
        }
        else if (productCode.equalsIgnoreCase("mysql")) {
            product.setDescription("Murach's MySQL");
            product.setPrice(54.50);
        }
        else {
            product.setDescription("Unknown");
        }
        return product;
    }
}