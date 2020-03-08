package CACC_2019.week6_Loop;
/*Angelina Chen: IntelliJ has pointed out errors, but I do not understand them.
Please see if you can find any errors.*/

public class CACCAngelinaWeek6fourth<sum> {

    public static void main(String[] args) {


        int sum = 0;
        int i = 0;

        do {
            sum += i;
            i += 2;
            System.out.println("Sum = " + sum);
        } while (i <= 50);

        System.out.println("Sum = " + sum);
    }
}