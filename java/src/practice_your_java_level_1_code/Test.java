package practice_your_java_level_1_code;

public class Test {

    public static void main(String[] args) {
        StringBuffer sb01 = new StringBuffer();
            System.out.println("The capacity = " + sb01.capacity());

        StringBuffer sb02 = new StringBuffer(1000);
            System.out.println("The capacity of sb02 = " + sb02.capacity());

    }
}
