import java.io.*;

public class CustomTesterApp {

    public static void main(String[] args) {
        method1();
    }

    public static void method1() {
        method2();
    }

    public static void method2() {
        try {
            method3();
        } catch (TestException e) {
            System.out.println("A test exception occurred.");
            System.out.println("Cause: " + e.getCause().toString());
        }
    }

    public static void method3() throws TestException {
        try {
            throw new IOException("An I/O exception occurred.");
        } catch (IOException e) {
            throw new TestException(e);
        }
    }
}
