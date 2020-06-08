package CACC_2019.week28_Exception;

// Script Name: App2.java
// Note:  The program is failed to run due to the file not existed!
// This App1.java added “throws FileNotFoundException” by the IDE, you won’t need to type yourself.

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.File;


public class App2 {
    public static void main(String[] args) throws FileNotFoundException {
        // handling exceptions
        File file = new File("test-a.txt");
        FileReader fr = new FileReader(file);
    }
}

/*
Exception in thread "main" java.io.FileNotFoundException: test-a.txt (The system cannot find the file specified)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileReader.<init>(FileReader.java:72)
	at CACC_2019.week28_Exception.App2.main(App2.java:15)

  */
