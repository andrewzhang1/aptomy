import java.util.ArrayList;
import java.util.Scanner;

public class TestScoreApp {

    public static void main(String[] args) {
        // display operational messages
        System.out.println("Enter test scores that range from 0 to 100.");
        System.out.println("To end the program, enter 999.");
        System.out.println();  // print a blank line

        // initialize variables and create a Scanner object
        @SuppressWarnings("resource")
		Scanner sc = new Scanner(System.in);
        ArrayList<Integer> scores = new ArrayList<>();

        // get test scores from the user and store in array list
        int score = 0;
        while (score <= 100) {
            // get the input from the user
            System.out.print("Enter score: ");
            score = sc.nextInt();

            if (score <= 100) {
                scores.add(score);
            }
        }

        // get the count
        int count = scores.size();
        
        // calculate the total
        int total = 0;
        for (int testScore : scores) {
            total += testScore;
        }
        
        // calculate the average
        double average = (double) total / count;
        
        // display the results
        String message = "\n"
                + "Score count:   " + count + "\n"
                + "Score total:   " + total + "\n"
                + "Score average: " + average + "\n";
        System.out.println(message);
    }
}