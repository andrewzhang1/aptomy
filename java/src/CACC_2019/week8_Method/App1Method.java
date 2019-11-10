package CACC_2019.week8_Method;

public class App1Method {
    public static void main(String[] args) {

        System.out.println("HI, I will show which is the larger one");
        int i = 5;
        int j = 2;
        int k = max(i, j);
        System.out.println("max is: " + k);
    }

    public static int max(int num1, int num2){
        int result;

        if (num1 > num2)
            result = num1;
        else
            result = num2;
        return  result;
    }
}
