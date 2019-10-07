package CACC_2019.week7;

import java.util.Scanner;

public class App4_CompareString {
    public static void main(String[] args) {

        // Please play around the different char:

        //char ch = 'B';
        //char ch = 'k';
        char ch = '8';

        if (ch >= 'A' && ch <= 'Z')
            System.out.println(ch + " is an uppercase letter");
        else if (ch >= 'a' && ch <= 'z')
            System.out.println(ch + " is a lowercase letter");
        else if (ch >= '0' && ch <= '9')
            System.out.println(ch + " is a numeric character");

    }
}
