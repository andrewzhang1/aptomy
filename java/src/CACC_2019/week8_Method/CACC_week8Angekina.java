package CACC_2019.week8_Method;
/*Angelina Chen:
    A formal parameter is the variables defined in the method header.
    An actual parameter is the value passed to the parameter when the method is invoked.
    The return value type is the data type of the value the method returns.
    Note: This is the first program.*/

import java.util.Scanner;

public class CACC_week8Angekina {
    public static void main(String[] args) {
        System.out.println("Please print one number.");
        Scanner x = new Scanner(System.in);
        Long n1 = x.nextLong();
        System.out.println("Please print another number.");
        Long n2 = x.nextLong();
        Long n3 = Math.max(n1,n2);
        System.out.println("The larger number is " + n3);
    }

}
