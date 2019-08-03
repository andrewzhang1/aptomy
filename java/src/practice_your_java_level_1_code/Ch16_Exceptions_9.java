package practice_your_java_level_1_code;

public class Ch16_Exceptions_9 {
    public static void main(String[] args) {

        int arrayIndex = 14;
        int[] iArray = new int[5];

        try {
            iArray[arrayIndex] = 1500;
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("I caught the exception!");
        }
        System.out.println("After ther array index acces attemp");
    }
}

/*
I caught the exception!
After ther array index acces attemp
*/
