package CACC_2019.week6;
/*Angelina Chen: This is the while loop for the assignment. */
public class CACCAngelinaWeek6third {
    public static void main(String[] args) {
        int num = 50, i = 0, sum = 0;
        while (i <= num) {
            sum += i;
            i+=3;
        }
        System.out.println("Sum = " + sum);
    }
}