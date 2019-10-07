package CACC_2018.week5;

import java.util.Random;
import java.util.Scanner;

public class GuessNumberLogic {
    public static void guess(int number, int range) {
        int count = 1;
        int curMax = range - 1, curMin = 0;
        int guess = (curMax + curMin) / 2;
        while (guess != number) {
            System.out.println("Guess " + count++ + ": " + guess);
            if (guess < number) {
                curMin = guess;
            } else {
                curMax = guess;
            }
            guess = (curMin + curMax) / 2;
        }
        System.out.println("Guess correctly in attempt " + count + " number is: " + number);
    }

    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);
        Random random = new Random();
        System.out.println("Type in an integer as range");
        int range = scanner.nextInt();

        int number = random.nextInt(range);

        guess(number, range);

    }
}
