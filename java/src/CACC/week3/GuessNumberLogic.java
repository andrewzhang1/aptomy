package CACC.week3;

import java.util.Random;
import java.util.Scanner;

public class GuessNumberLogic {
    public static void guess(int number, int range) {
        int count = 1;
        // your code here
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
