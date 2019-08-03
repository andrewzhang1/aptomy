package practice_your_java_level_1_code;

import java.util.Random;

public class Ch20_Random_Num_2 {
    public static void main(String[] args) {
        Random randomGenerator = new Random();
        int nextRandomValue;
        for (int count = 0; count < 10; count++) {
            nextRandomValue = randomGenerator.nextInt();
            System.out.println(nextRandomValue);
        }
    }

}
/*
1st fime:
1388851681
-1118967288
-9013907
306639128
-1607588314
574642742
382255674
2016606518
955662990
-11754829*/

/* 2nd time:
-1510002260
899220486
-1022346235
2142106972
1857432932
-1980508459
-50882629
866426362
-1535357329
34016619*/
