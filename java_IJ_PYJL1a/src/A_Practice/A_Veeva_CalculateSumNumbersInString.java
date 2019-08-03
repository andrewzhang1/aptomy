package A_Practice;

// Veeva test

public class A_Veeva_CalculateSumNumbersInString {
    public static void main(String[] args) {

        //String a = "jklmn489pjro635ops";
        String a = "jklmn41pjro5ops";

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


