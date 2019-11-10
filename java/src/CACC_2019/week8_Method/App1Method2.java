package CACC_2019.week8_Method;

public class App1Method2 {
    public static void main(String[] args) {

       // System.out.println("HI, I will show which is the larger one");
        int n = 3;

        System.out.println("n is: " + sign(n));
    }

    public static int sign(int n) {
        if (n > 0)
            return 1;
        else if (n == 0)
            return 0;
        else // if  (n < 0)
            return -1;
    }
}
