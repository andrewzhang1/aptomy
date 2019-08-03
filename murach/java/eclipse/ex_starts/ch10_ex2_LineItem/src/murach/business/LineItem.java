package murach.business;

import java.text.NumberFormat;

/**
 * The <code>LineItem</code> class represents a line item and is used by the
 * <code>Product</code> class.
 */
public class LineItem {

    private Product product;
    private int quantity;
    private double total;

    public LineItem() {
        this.product = null;
        this.quantity = 0;
        this.total = 0;
    }

    public LineItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Product getProduct() {
        return product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotal() {
        total = quantity * product.getPrice();
        return total;
    }

    public String getTotalFormatted() {
        NumberFormat currency = NumberFormat.getCurrencyInstance();
        return currency.format(this.getTotal());
    }
}