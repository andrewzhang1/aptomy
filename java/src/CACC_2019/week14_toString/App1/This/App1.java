package CACC_2019.week14_toString.App1.This;

class Frog{
    public String toString() {
        return "Hello";
    }
}
public class App1 {
    public static void main(String[] args) {
        Frog frog1 = new Frog();
        System.out.println(frog1);
        Object obj1 = new Object();
        System.out.println(obj1.toString());
        System.out.println(obj1.getClass());

    }
}
