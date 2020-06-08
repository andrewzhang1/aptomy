package CACC_2019.week28_Exception;
/*
Script Name: App3e.java
 Note:  1. Let's see a alternative way to handle the exception:
        Use "try ... catch" block
        2. What about we do have a test-a.txt file already?
        3. Add code inside the printStackTrace()... So you can
        handle the exception anyway you like!
        4. Add more code at the "try" block
*/
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

public class App3e {
    public static void main(String[] args)  {
        // handling exceptions
        File file = new File("test-abc.txt");
        try {
            FileReader fr = new FileReader(file);

            // This will not be executed if an exception is thrown...
            System.out.println("Continuing...");
        } catch (FileNotFoundException e) {
            // This is a default way, but we can add code by myself:
            //e.printStackTrace();
            System.out.println("File not found: " + file.toString() );
        }
        // Continue..
        System.out.println("Finished." );
    }
}
/* The printout:
File not found: test-a.txt
*/
