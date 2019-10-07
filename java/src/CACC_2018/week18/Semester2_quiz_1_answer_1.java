package CACC_2018.week18;

import java.util.ArrayList;
import java.util.List;

// you may choose a different class name
public class Semester2_quiz_1_answer_1 {
    int a; // what visibility?

    // TODO: define variables with different access modifiers
    private int b;
    protected int c;
    public int d;

    // TODO: define variables with different non-access modifiers
    static int e;
    final int f = 0;
    volatile int g;     // you may not have learnt this

    // TODO: define a list using Generic type, initialize it
    private List<String> myList = new ArrayList<>();    // Java 5 Generic; Java 7 Diamond operator

    // TODO: write a method fib(n), which calculates up to "n" number of Fibonacci numbers. For example, fib(3) gives output 0,1,1
    // Hint: you can choose any looping technique
    private int fib(int n) {
        int a = 0;
        int b = 1;
        int temp = -1;
        if (n <= 1) {
            System.out.println(a);
            return a;
        } else {
            StringBuffer sb = new StringBuffer();
            sb.append(a + "," + b);
            for (int i=3; i<=n; i++) {
                temp = a;
                a = b;
                b += temp;
                sb.append("," + b);
            }
            System.out.println(sb.toString());
            return b;
        }
    }

    // TODO: write "main" method for this class to call fib(n)
    public static void main(String[] args) {
        Semester2_quiz_1_answer_1 test = new Semester2_quiz_1_answer_1();
        test.fib(10);
    }
}