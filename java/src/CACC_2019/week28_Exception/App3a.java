package CACC_2019.week28_Exception;

// Script Name: App3a.java
// Note:  Let's see a alternative way to handle the exception

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

public class App3a {
    public static void main(String[] args)  {
        // handling exceptions
        File file = new File("test.txt");
        try {
            FileReader fr = new FileReader(file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}

/*
Error:(13, 24) java: unreported exception java.io.FileNotFoundException; must be caught or declared to be thrown

  */
