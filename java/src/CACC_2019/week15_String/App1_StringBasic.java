package CACC_2019.week15_String;
/*
String build sample 1

String is immutable, this sample shows an inefficient way to
build a string
 */
public class App1_StringBasic {

    public static void main(String[] args) {

        String info = "";

        info += "My name is Bob.";
        info += " ";
        info += "I am a builder. ";

        info += "I am 20 yrs old.";
        System.out.printf(info);
    }
}
/*
Outout:
My name is Bob. I am a builder.
*/