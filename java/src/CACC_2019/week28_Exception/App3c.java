package CACC_2019.week28_Exception;
/*
Script Name: App3c.java
 Note:  1. Let's see a alternative way to handle the exception:
        Use "try ... catch" block
        2. What about we do have a test-a.txt file already?
        3. We add a empty file "test-a.txt" under your project folder,
           re-run the programe, then we won't see any error.
*/
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

public class App3c {
    public static void main(String[] args)  {
        // handling exceptions
        File file = new File("test.txt");
        try {
            FileReader fr = new FileReader(file);
        } catch (FileNotFoundException e) {
            // This is a default way:
            e.printStackTrace();
        }
    }
}
/* The printout:
Now we don't have error!
*/
