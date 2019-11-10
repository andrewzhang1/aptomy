package CACC_2019.week8_Method;
/*Angelina Chen:
  This is the second piece of code.(Exception)*/

public class CACC_week8a_Angelina {
    public static void main(String[] args) {
        float z = 10;
        //int y = 5;
        int y = 0;
        try {
            System.out.println(z / y);
        } catch (ArithmeticException w) {
            System.out.println("Exception caught.");
        }
        System.out.println("Calculation finished.");
    }

}