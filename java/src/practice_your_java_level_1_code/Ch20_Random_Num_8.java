package practice_your_java_level_1_code;

import java.util.Random;

public class Ch20_Random_Num_8 {
    public static void main(String[] args) {
        double nextRandomValue;
        Random randomGenerator = new Random();
        for (int count = 0; count < 10; count++) {
            nextRandomValue = 1 + randomGenerator.nextGaussian();
            System.out.println(nextRandomValue);
        }
    }
}

/*
0.13389881092600153
1.2982805819019148
-0.3487069820161708
0.8990287373559067
0.5026891051632009
1.1769283171839233
0.4882151306395184
1.9505608856169718
3.185664482436375
0.9544419077535391*/
