package CACC_2019.week8_Method;

public class Test {
    public static void main(String[] args) {

        double a = 3;
        double b = 2;
        try {
            System.out.println(a/b );
        }
        catch (ArithmeticException w){
            System.out.println("I caught the error");
        }

    }
}
