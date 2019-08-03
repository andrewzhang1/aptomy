package practice_your_java_level_1_code;

import java.util.*;
import java.io.IOException;

public class Ch17_Console_Handling2_17 {
    public static void main(String[] args) {
        char c;
        System.out.println("Enter a single character");
        try{
            c = (char)System.in.read();
            System.out.println("The character read was: " + c);
        }
        catch (IOException e){
            System.out.println("Couldn't read from the keyboar successfully!");
        }

    }
}
