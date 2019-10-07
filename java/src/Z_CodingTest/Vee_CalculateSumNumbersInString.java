package Z_CodingTest;

// Veeva test

public class Vee_CalculateSumNumbersInString {
    public static void main(String[] args) {

        //String a = "jklmn489pjro635ops";
        String a = "jklmn41pj8ro5ops";

        int sum = 0;
        String num = "";

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


