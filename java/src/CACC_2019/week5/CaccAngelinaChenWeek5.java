package CACC_2019.week5;
/* Angelina Chen: The two parts of the program tell you your reward from the city you live in.
 Depending on the amount you earn, you will get a reward.
 In addition, depending on the day you take off, you will get a reward as well.*/
import java.util.Scanner;

public class CaccAngelinaChenWeek5 {
    public static void main(String[] args) {
        System.out.println("Enter your income:");
        Scanner s = new Scanner(System.in);
        long income = s.nextLong();

        if (income > 150000) {
            System.out.println("Reward: free computer.");
        } else{
                System.out.println("Reward: Free phone");
            }

            System.out.println("List the day you don't work: ");

            //String day = s.nextLine();
            //System.out.printf("Day is: " + day);

            Scanner input = new Scanner(System.in);
            String day = input.nextLine();

            switch (day) {
                case "Monday":
                    System.out.println("You receive an extra 500 dollars.");
                    break;
                case "Tuesday":
                    System.out.println("You receive an extra 600 dollars.");
                    break;
                case "Wednesday":
                    System.out.println("You receive an extra 700 dollars.");
                    break;
                case "Thursday":
                    System.out.println("You receive an extra 800 dollars.");
                    break;
                case "Friday":
                    System.out.println("You receive an extra 900 dollars.");
                    break;
                case "Saturday":
                    System.out.println("You receive an extra 1000 dollars.");
                case "Sunday":
                    System.out.println("You receive an extra 1100 dollars.");
                    break;

                    default:
                System.out.println("Invalid Day or type wrong!");
                break;
            }
    }
}

/* I will show you the problem in class.
The code has no bugs, however it terminates at System.out.println("List the day you don't work.");
This is in the middle of all of the code, which is a problem.
*/