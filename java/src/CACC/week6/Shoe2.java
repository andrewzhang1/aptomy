package CACC.week6;

import java.util.Calendar;
import java.util.Date;

public class Shoe2 {
    static final long TOTAL_USE_TIME = 2L * 365 * 24 * 60 * 60 * 1000;
    float size;
    String brand;
    String type;
    double price;
    Date buyDate;

    public void run() {
        System.out.println("running");
    }

    public double getUsability() {
        double rv = (TOTAL_USE_TIME -(new Date().getTime() - buyDate.getTime())) * 1.0 / TOTAL_USE_TIME;
        if (rv > 0)
            return rv;
        return 0.0;
    }

    public Shoe2(float size, String brand, String type, double price, Date buyDate) {
        this.size = size;
        this.brand = brand;
        this.type = type;
        this.price = price;
        this.buyDate = buyDate;
    }

    public static void main(String[] args) {
        // Shoe2 shoe = new Shoe2(); -- will cause error!
        Shoe2 shoe = new Shoe2(9.5F, "Nike", "running", 89.99, new Date());

        shoe.run();
        System.out.println(shoe.getUsability());

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -48);
        shoe.buyDate = cal.getTime();
        System.out.println(shoe.getUsability());

    }
}
