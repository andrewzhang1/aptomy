package murach.business;

import java.text.NumberFormat;

/**
 * The <code>Product</code> class represents a product and is used by the
 * <code>LineItem</code> class.
 * @author Joel Murach
 * @version 1.0.0
*/
public class Product {

    private String code;
    private String description;
    private double price;

    /**
     * Creates a <code>Product</code> with default values.
     */
    public Product() {
        code = "";
        description = "";
        price = 0;
    }

    /**
     * Sets the product's code.
     * @param code a <code>String</code> for the product's code
     */
    public void setCode(String code) {
        this.code = code;
    }

    /**
     * Gets the product's code.
     * @return a <code>String</code> for the product's code
     */
    public String getCode() {
        return code;
    }

    /**
     * Sets the product's description.
     * @param description a <code>String</code> for the product's description
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Gets the product's description.
     * @return a <code>String</code> for the product's description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the product's price.
     * @param price a <code>double</code> value for the product's price
     */
    public void setPrice(double price) {
        this.price = price;
    }

    /**
     * Gets a <code>double</code> value for the product's price.
     * @return a <code>double</code> value that represents the product's price
     */
    public double getPrice() {
        return price;
    }

    /**
     * Gets a <code>String</code> for the product's price with 
     * standard currency formatting
     * @return a <code>String</code> for the product's price with
     *         standard currency formatting applied ($1,000.00).
     */
    public String getPriceFormatted() {
        NumberFormat currency = NumberFormat.getCurrencyInstance();
        return currency.format(price);
    }
}