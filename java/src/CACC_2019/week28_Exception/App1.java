package CACC_2019.week28_Exception;

// Script Name: App1.java
// Note:  The program is failed to run due to the file not existed!

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.File;

public class App1 {
    public static void main(String[] args) throws FileNotFoundException {
        // handling exceptions
        File file = new File("test-a.txt");
        FileReader fr = new FileReader(file);
    }
}

/*
Error:(13, 25) java: unreported exception java.io.FileNotFoundException;
 must be caught or declared to be thrown
 */
