package CACC_2019.week28_Exception;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
/*
Script Name: App4.java
Note:  1. Add a new static method openFile()
*/

public class App4 {
    public static void main(String[] args) throws FileNotFoundException {
        // handling exceptions
//        File file = new File("test-a.txt");
//        FileReader fr = new FileReader(file);
        openFile();


    }

    public static void openFile() throws FileNotFoundException {
        File file = new File("test-a.txt");
        FileReader fr = new FileReader(file);
    }
}
