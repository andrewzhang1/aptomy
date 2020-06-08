package CACC_2019.week28_Exception;
/*

Script Name: App3b.java
 Note:  Let's see a alternative way to handle the exception:
        Use "try ... catch" block
*/

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

public class App3b {
    public static void main(String[] args)  {
        // handling exceptions
        File file = new File("test-a.txt");
        try {
            FileReader fr = new FileReader(file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}

/* The printout is much similar as the App3a.java:
Exception in thread "main" java.io.FileNotFoundException: test-a.txt (The system cannot find the file specified)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileReader.<init>(FileReader.java:72)
	at CACC_2019.week28_Exception.App2.main(App2.java:15)

  */
