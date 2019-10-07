package CACC_2018.week17;

import java.util.Date;
import java.util.Random;

public class CoreJava {
    static Random random = new Random();
    static long COUNT = 50_000;

    public static void learnEqual() {
        ClassA a1 = new ClassA(10);
        ClassA a2 = new ClassA(10);
        ClassA a3 = new ClassA(10,20);
        System.out.println(a1 == a2);
        System.out.println(a1.equals(a2));
        System.out.println(a1.equals(a3));
    }

    public static void learnStringBuilder() {
        Date start1 = new Date();
        useString();
        Date end1 = new Date();
        System.out.println("use String takes: " + (end1.getTime() - start1.getTime()) + " millisecond");

        Date start2 = new Date();
        useStringBuilder();
        Date end2 = new Date();
        System.out.println("use String builder takes: " + (end2.getTime() - start2.getTime())  + " millisecond");

    }

    public static String getRandomInteger() {
        return String.valueOf(random.nextInt());
    }
    public static void useString() {
        String rv = "";
        for (long l=0; l < COUNT; l++) {
            rv += getRandomInteger();
        }
        System.out.println(rv.length());
    }
    public static void useStringBuilder() {
        StringBuilder sb = new StringBuilder();
        for (long l=0; l < COUNT; l++) {
            sb.append(getRandomInteger());
        }
        System.out.println(sb.toString().length());
    }

    public static void main(String[] args) {
        // equal method
        learnEqual();

        // use of string builder
        learnStringBuilder();

        // Scanner


        // Wrapper
        // primitive int, long, char, float, double etc...
        Integer i1 = 1;
        int i2 = i1;
        int i3 = 2;
        Integer i4 = i3;

        // Class
        CoreJava cj = new CoreJava();
        Class clazz = cj.getClass();
        System.out.println(clazz);

    }
}
