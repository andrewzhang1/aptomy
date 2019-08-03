package practice_your_java_level_1_code;

import java.util.Random;

public class Ch21_StringBuffer_StringBuilder_4 {
    public static void main(String[] args) {
        StringBuffer sb01 = new StringBuffer();
            System.out.println("The capacity = " + sb01.capacity());

        StringBuffer sb02 = new StringBuffer(1000);
            System.out.println("The capacity of sb02 = " + sb02.capacity());

    }
}

