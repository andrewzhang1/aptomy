package CACC_2019.week29_FileHandling;

/*
Script Name: App1.java
Note: 1. Create a file name "text.txt" under your project folder
      2. Create a File object
      3. This program finally just read one line successfully
 */
import java.io.*;

public class App1 {
    public static void main(String[] args) {

        File file = new File("test.txt");
        try {
            FileReader fr = new FileReader(file);
            BufferedReader br = new BufferedReader(fr);

            String  line;
            line = br.readLine();
            System.out.println(line);

   } catch (FileNotFoundException e) {
            //e.printStackTrace();
            System.out.println("File not found " + file.toString());
        } catch (IOException e) {
           // e.printStackTrace();
            System.out.println("Unable to read file: " + file.toString());
        }
   }
}
/*
Print out:
first line
*/
