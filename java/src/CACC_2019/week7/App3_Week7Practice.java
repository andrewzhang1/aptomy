package CACC_2019.week7;

public class App3_Week7Practice {
    public static void main(String[] args) {

        // 1: characters
        char ch = 'c';
        //System.out.println(++ch);
        System.out.println(ch += 1);

        char letter1 = '\u0041';
        System.out.println("letter 1 is: " + letter1);
        char letter2 = 'A';
        System.out.println("letter 2 is: " + letter2);

        // 2. Unicode:
        // char letter3 = '\u0022';
        char letter3 = '\u005D';
        System.out.println("letter 3 is: " + letter3);


        // 3. Casting between char and Numeric Types
        int i = 'a'; // Same as int i = (int)'a’;
        System.out.println("i is: " + i);

        // Same as int i = (int)'a’;
        int i1 = (int) 'a';
        System.out.println("i1 is: " + i1);


        char c = 97; // Same as char c = (char)97;
        System.out.println("c is: " + c);

        char c1 = (char) 97;
        System.out.println("c1 is: " + c1);

        // 4. StringLength

        String mesg = "Welcome to Java ";
        System.out.println("The length of " + mesg + " is "
                + mesg.length());


    }
}
