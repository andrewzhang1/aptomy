package practice_your_java_level_1_code;

import java.util.Random;

public class Ch20_Random_Num_9 {
    public static void main(String[] args) {
        int upBound = 8;
        int nextRandomValue;
        Random randomGenerator = new Random();
        for (int count = 0; count < 7; count++) {
            nextRandomValue = 1 + randomGenerator.nextInt(upBound);
            System.out.println(nextRandomValue);
        }
    }

}