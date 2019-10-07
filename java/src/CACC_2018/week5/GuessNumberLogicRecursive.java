package CACC_2018.week5;

import java.util.Random;
import java.util.Scanner;

public class GuessNumberLogicRecursive {
    public static void guess(int curMin, int curMax, int target, int t) {
        int guess = (curMin + curMax)/2;

        if (guess == target) {
            System.out.println("Got it correct in " + t + " try");
        } else if (guess < target) {
            System.out.println("Guess number " + guess + " is too small, " + t + " try");
            guess(guess + 1, curMax, target, t+1);
        } else {
            System.out.println("Guess number " + guess + " is too large, " + t + " try");
            guess(curMin, guess - 1, target, t+1);
        }

    }

    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);
        Random random = new Random();
        System.out.println("Type in an integer as range");
        int range = scanner.nextInt();

        int target = random.nextInt(range);
        System.out.println("target is " + target);
        guess(0, range-1, target, 1);

    }
}
