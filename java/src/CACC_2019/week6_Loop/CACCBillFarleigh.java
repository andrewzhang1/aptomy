package CACC_2019.week6_Loop;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;


//

// date:

public class CACCBillFarleigh {    public static void main(String[] args) {
        int item = 0;
        int sum = 0;
        while (item <= 50) {
            sum += item;
            item += 2;
            //sum #1
        }
        System.out.println(sum);
        sum = 0;
        item = 0;
        do {
            sum += item;
            item += 2;
            // sum #2
        } while (item <= 50);
        System.out.println(Math.sin(sum));
        sum = 0;
        for (item = 0; item <= 50; item += 2) {
            sum += item;
            System.out.println(sum);
        }
        System.out.println(sum);
        System.out.println("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrree");
        System.out.println("number of sides in polygon: ");
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
            final int you = Integer.parseInt(reader.readLine());
            System.out.println((you*180)-360);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
