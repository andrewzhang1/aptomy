package CACC_2019.week6;

import java.math.*;
import java.util.Random;

public class MathClass {
    public static void main(String[] args) {

        double d9 = Math.sqrt(9);
        System.out.println(Math.pow(3.5, 2.5));  //22.91765149399039
        System.out.println("d9 is: " + d9);  //

        //System.out.println(Math.log10(89));
        System.out.println(Math.ceil(2.1));

        System.out.println(Math.sin(Math.PI / 6));
        //System.out.println(Math.sin(0));
        //System.out.println(Math.cos(0));


        System.out.println(Math.sin(90));
        System.out.println(Math.toRadians(90));
        // You tell me...!
        System.out.println();


        //min, max, and abs
        System.out.println(Math.max(2, 9));

        System.out.println(Math.abs(-9.34343));

        System.out.println(Math.random() * 10);

        // Define an object for Random class
        Random rn = new Random();

        // Find ran
        for (int i = 0; i < 3; i++) {
            int answer = rn.nextInt(10) + 1;
            System.out.println(answer);
        }




        // The following week 7, I will this code to pick a student to come to the while board to write some real code:
        int student = rn.nextInt(10);
        System.out.println("\nStuduent Num Picked is: No. " + student);

    }

}
