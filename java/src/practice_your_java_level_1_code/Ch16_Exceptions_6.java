package practice_your_java_level_1_code;

//import jdk.nashorn.internal.runtime.arrays.ArrayIndex;

public class Ch16_Exceptions_6 {
    public static void main(String[] args) {

        try {
            String s = null;

        } catch (NullPointerException e) {
            System.out.println("I caught the exeption: " + e);
        }

    }
}

//I caught the exeption: java.lang.NullPointerException
