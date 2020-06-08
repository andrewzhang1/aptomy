package CACC_2019.week29_FileHandling;
/*
Script Name: App3a.java
Note: 1. Create a file name "text.txt" under your project folder
      2. Create a File object
      3. This program finally just read one line successfully
      4. Added a while to read until the last line
      5. Added a close method
      6. Added a "finally" block, which is a even better way
 */

import java.io.*;
public class App3b {
    public static void main(String[] args) {

        File file = new File("test.txt");

        BufferedReader br = null;
        try {
            FileReader fr = new FileReader(file);

            br = new BufferedReader(fr);
            /*Question: Where do we close the buffer?
             If not closed, it will cause memory leak if you have
            a large file */
            String line;
            //line = br.readLine();
            while ((line = br.readLine()) != null) {
                System.out.println(line);
            }

        } catch (FileNotFoundException exe) {
            //e.printStackTrace();
            System.out.println("File not found " + file.toString());
        } catch (IOException e) {
            // e.printStackTrace();
            System.out.println("Unable to read file: " + file.toString());
        } finally {
            try {
                br.close();
            } catch (IOException e) {
                System.out.println("Unable to read file: " + file.toString());
            } catch (NullPointerException ex) {
                // File was probably never opend!
            }
        }

    }
}
/*
Print out:
first line
second line
third line

*/
