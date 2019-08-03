

/* A utility to clean data: Delete the first line keep the second and third line;
 then delete the following two line, keep the third line, and repeat
 For exmaple,

 */

import java.io.File;
import java.io.FileWriter;
import java.util.Scanner;

public class DeleteLines {

   public static void main(String args[]) {

//      String input = "/mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/genia/Andrew/GPU_TEST_HOME/result/import.csv";
//      String output = "/mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/genia/Andrew/GPU_TEST_HOME/result/output2.csv";
        String input = "c:/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/genia/Andrew/GPU_TEST_HOME/result/import.csv";
        String output = "c:/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/genia/Andrew/GPU_TEST_HOME/result/output2.csv";

      try {
         Scanner fr = new Scanner(new File(input));
         FileWriter fw = new FileWriter(new File(output));

         int i = 2;

         fr.nextLine();
         fw.write(fr.nextLine() + "\n");

         while (fr.hasNext()) {
            fw.write(fr.nextLine() + "\n");
            fr.nextLine();
            fr.nextLine();
         }

      } catch (Exception e) {
         System.out.println(e.getClass());
      }

   }

}
