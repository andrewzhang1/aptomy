package CACC_2019.week5;

import java.util.Scanner;
public class App {
    public static void main(String[] args) {
        int i = (int)3.0;
        int j = (int)3.9;

        System.out.printf("i is now: " + i );
        System.out.printf("\nj is now: " + j);

        Scanner s = new Scanner(System.in);

        System.out.print("\n\nEnter any year:");
        int year = s.nextInt();
        boolean flag = false;
        if(year % 400 == 0)
        {
            flag = true;
        }
        else if (year % 100 == 0)
        {
            flag = false;
        }
        else if(year % 4 == 0)
        {
            flag = true;
        }
        else
        {
            flag = false;
        }
        if(flag)
        {
            System.out.println("Year "+year+" is a Leap Year");
        }
        else
        {
            System.out.println("Year "+year+" is not a Leap Year");
        }
    }


}
