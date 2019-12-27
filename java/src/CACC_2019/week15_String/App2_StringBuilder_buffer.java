package CACC_2019.week15_String;
/*
String build sample 2:
String builder, a more efficient way to build a string
String buffer: same as string build.
==> Remember: String builder is more memory efficient than Stringbuffer
 */
public class App2_StringBuilder_buffer {

    public static void main(String[] args) {

        StringBuilder sb = new StringBuilder();
        //StringBuffer sb = new StringBuffer();
        //sb.append(90);
        sb.append("My name is Andrew");
        sb.append(" ");
        sb.append("I'm a lion tamer");

        System.out.println(sb.toString());

        // Above is called "method chaining" for the append.
        // Here we have a shorcut, because append method returns a reference
        StringBuilder s = new StringBuilder();
        s.append("My name is Ben.")
                .append(" ")
                .append("I'm a skydiver.")
        .append("I'm from Pleasanton")
        ;

        System.out.printf(s.toString());
    }
}
/* Output:
My name is Andrew I'ma a lion tamer
My name is Ben. I'm a skydiver.
 */
