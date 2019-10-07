package CACC_2018.week2;

public class Primitive {
    public static void main(String[] args) {
        byte b = 10;
        System.out.println("byte is: " + b);
        b = 127;
        System.out.println("byte is: " + b);
        b = -128;
        System.out.println("byte is: " + b);

        int i = 1;
        System.out.println("integer is: " + i);
        System.out.println("integer in binary format is: " + Integer.toBinaryString(i));
        Integer intObj = 1;
        System.out.println("primitive integer is same as wrapper integer? " + (i == intObj));

        i = 2;
        System.out.println("integer is: " + i);
        System.out.println("integer in binary format is: " + integerPadding(i));

        i = 100;
        System.out.println("integer is: " + i);
        System.out.println("integer in binary format is: " + integerPadding(i));
        i = -100;
        System.out.println("integer is: " + i);
        System.out.println("integer in binary format is: " + integerPadding(i));

        System.out.println("max integer: " + Integer.MAX_VALUE);
        System.out.println("max integer in binary format is: " + integerPadding(Integer.MAX_VALUE));
        // 1111111111111111111111111111111
        System.out.println("min integer: " + Integer.MIN_VALUE);
        System.out.println("min integer in binary format is: " + integerPadding(Integer.MIN_VALUE));
        System.out.println("min integer plus one in binary format is: " + integerPadding(Integer.MIN_VALUE + 1));

        short s = 1;
        System.out.println("short is: " + s);

        System.out.println("max short: " + Short.MAX_VALUE);
        System.out.println("max short in binary format is: " + shortPadding(Short.MAX_VALUE));
        // 1111111111111111111111111111111
        System.out.println("min short: " + Short.MIN_VALUE);
        System.out.println("min short in binary format is: " + shortPadding(Short.MIN_VALUE));

    }

    private static String integerPadding(int i) {
        return String.format("%32s",Integer.toBinaryString(i)).replace(" ","0");
    }
    private static String shortPadding(int i) {
        return String.format("%32s",Integer.toBinaryString(i)).replace(" ","0").substring(16);
    }
}
