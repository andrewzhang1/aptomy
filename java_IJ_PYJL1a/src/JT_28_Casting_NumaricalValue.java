public class JT_28_Casting_NumaricalValue {
    public static void main(String[] args) {

        byte byteValue = 20;
        short shortValue = 55;
        int intValue = 888;
        long longValue = 23355;

        float floatValue = 6623.2f;
        float floatValue2 = (float) 33434.233;
        double doubleValue = 32.4;

        System.out.println(Byte.MAX_VALUE);

        intValue = (int)longValue;
        System.out.println(intValue);

        doubleValue = intValue;
        System.out.println(doubleValue);

        intValue = (int)floatValue;
        System.out.println(intValue);

        byteValue = (byte)127999999;
        System.out.println(byteValue);

    }
}


