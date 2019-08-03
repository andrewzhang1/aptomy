package John_JTFB.JT_HandlingExceptions;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

public class App2 {
        public static void main(String[] args) {

            File file = new File("test.txt");
            try {
                FileReader fr = new FileReader(file);

                // This will not executed if the exception is thrown...

                System.out.println("Continue....");
            } catch (FileNotFoundException e) {
             //   e.printStackTrace();

                System.out.println("File not found: " + file);
                // I can do this:


				e.printStackTrace();
            }

        }
}
