package CACC.week3;

import java.util.Random;
import java.util.Scanner;

public class GuessNumber {
    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);
        Random random = new Random();
        System.out.println("Type in an integer as range");
        int range = scanner.nextInt();

//        int number;

        for ( int i=0; i < 50; i++) {
            int number = random.nextInt(range);
            System.out.println(number);
        }

        int number = random.nextInt(range);

        int guess;
        do {
            System.out.println("Guess an integer ");
            guess = scanner.nextInt();
            if (guess == number) {
                System.out.println("you got it right!");
            } else if (guess > number) {
                System.out.println("you got it too big!");
            } else {
                System.out.println("you got it too small!");
            }

        } while(guess != number);

    }
}
