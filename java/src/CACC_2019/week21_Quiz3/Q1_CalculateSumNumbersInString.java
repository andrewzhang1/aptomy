package CACC_2019.week21_Quiz3;

// Veeva test

public class Q1_CalculateSumNumbersInString {
    public static void main(String[] args) {

        //String a = "AnyStringWithNumbers"
        String a = "jk4p8sco9ops";

        // Initialization
        int sum = 0;
        String num = "";

        //Character.isDigit((a.length()))


        for (int i = 0; i < a.length(); i++) {
            if (Character.isDigit(a.charAt(i))) {
                num = num + a.charAt(i);
            } else {
                if (!num.equals("")) {
                    sum = sum + Integer.parseInt(num);
                    num = "";
                }
            }
        }

        System.out.println(sum);
    }

}


