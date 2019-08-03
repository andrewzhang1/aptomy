package CACC.week2;

public class Variable {
    static int fooo;
    static float f1;
    static boolean isOut;

    public static void main(String[] args) {
        int foo = 42;
        double d1 = 3.14, d2 = 2 * 3.14;
        boolean isFun = true;
        System.out.println("### declare and initialization");
        System.out.println("foo: " + foo);
        System.out.println("d1: " + d1 + " d2: " + d2);
        System.out.println("isFun: " + isFun);

        int foo1;
        double d3, d4;
        boolean isFun1;
        //System.out.println("foo1: " + foo1); // exception
        //System.out.println("d1: " + d3 + " d2: " + d4); // exception
        //System.out.println("isFun1: " + isFun1); // exception

        foo1 = 125;
        d3 = 3e3;
        d4 = 3e-3;
        System.out.println("### declare and set value");
        System.out.println("foo1: " + foo1);
        System.out.println("d1: " + d3 + " d2: " + d4);


        System.out.println("### default value");
        System.out.println("fooo: " + fooo);
        System.out.println("f1: " + f1);
        System.out.println("isOut: " + isOut);
    }
}
