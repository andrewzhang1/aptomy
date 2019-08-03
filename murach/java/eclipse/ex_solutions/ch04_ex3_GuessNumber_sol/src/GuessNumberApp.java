import java.util.Scanner;

public class GuessNumberApp {
    
    public static void main(String[] args) {
        final int LIMIT = 10;

        System.out.println("Guess the number!");
        System.out.println("I'm thinking of a number from 1 to " + LIMIT);
        System.out.println();

        // get a random number between 1 and the limit
        double d = Math.random() * LIMIT; // d is >= 0.0 and < limit
        int number = (int) d;             // convert double to int
        number++;                         // int is >= 1 and <= limit

        @SuppressWarnings("resource")
        Scanner sc = new Scanner(System.in);            
        int count = 0;
        int guess = 0;
        while (guess != number) {
            System.out.print("Your guess: ");
            guess = sc.nextInt();
            
            if (guess < 1 || guess > LIMIT) {
                System.out.println("Invalid guess. Try again.");
                count--;
            } else if (guess < number) {
                System.out.println("Too low.");
            } else if (guess > number) {
                System.out.println("Too high.");
            }
            
            count++;
        }
        System.out.println("You guessed it in " + 
                                   count + " tries.\n");
        System.out.println("Bye!");
    }   
}