package CACC.week6;

import java.util.Calendar;
import java.util.Date;

public class Shoe {
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

    public static void main(String[] args) {
        Shoe shoe = new Shoe();
        shoe.buyDate = new Date();
        shoe.brand = "Nike";
        shoe.price = 100.99;
        shoe.size = 9;
        shoe.type = "running";

        shoe.run();
        System.out.println(shoe.getUsability());

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -48);
        shoe.buyDate = cal.getTime();
        System.out.println(shoe.getUsability());

    }
}
