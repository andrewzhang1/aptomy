package Z_CodingTest;

// Veeva test

public class Veeva_CalculateSumNumbersInString {
    public static void main(String[] args) {

        //String a = "jklmn489pjro635ops";
        String a = "jklmn4pj8roops";

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


