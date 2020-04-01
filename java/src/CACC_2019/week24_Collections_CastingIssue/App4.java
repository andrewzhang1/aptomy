package CACC_2019.week24_Collections_CastingIssue;

import java.util.ArrayList;

public class App4 {
    public static void main(String[] args) {
        ArrayList numbers = new ArrayList();
        numbers.add(new Integer(1));
        numbers.add(new Integer(2));
        numbers.add("John");
        numbers.add("Jack");
        for (int i = 0; i < numbers.size(); i++) {
            String number = (String) numbers.get(i);
            System.out.println(number);
        }
    }
}
