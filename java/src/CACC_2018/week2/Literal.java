package CACC_2018.week2;

public class Literal {
    public static void main(String[] args) {
        int i1 = 1230;
        System.out.println("i1: " + i1);
        // decimal (base 10)

        int i2 = 01230;
        System.out.println("i2: " + i2);
        // octal (base 8)

        int i3 = 0x1230;
        System.out.println("i3: " + i3);
        // hexadecimal (base 16)
        int i4 = 0x2F0;
        System.out.println("i4: " + i4);

        byte b = 42;
        int i = 43;
        int result = b * i; // b is promoted to int

        //b = i; // Compile-time error, explicit cast needed byte
        b = (byte) i; // OK

        byte one = 0b00000001;
        byte two = 0b00000010;
        byte sixteen = (byte)0b00010000;
        long ones = 0b11111111111111111111111111111111111111111111111L;
        System.out.println(one + " " + two + " " + sixteen + " " + ones);

        //long l1 = 123458858838; // compile error!
        long l2 = 123458883233L;

        Object obj = 10.0;
        System.out.println(obj.getClass());
        obj = 10;
        System.out.println(obj.getClass());
        obj = 10000011020304L;
        System.out.println(obj.getClass());

        char a = 'a';
        System.out.println(a);

        System.out.println( "Hello, World..." );
        String s = "I am the walrus...";
        String t = "John said: \"I am the walrus...\"";
        String quote = "Four score and " + "seven years ago,";
        String more = quote + " our" + " fathers" +  " brought...";
    }
}
