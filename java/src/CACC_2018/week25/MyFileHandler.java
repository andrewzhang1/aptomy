package CACC_2018.week25;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;

public class MyFileHandler {

    //static final String PATH = "C:\\Dev\\IntelliJProjects\\CACC_Java101\\resource";
    static final String PATH = "C:\\AGZ1\\aptomy";



    public static void main(String[] args) {
        //FileSystems.getDefault().getRootDirectories().forEach(s -> log(s.toString()));
        Path path = FileSystems.getDefault().getPath(PATH,
                "MyFile_1.txt");
        BufferedReader br = null;
        try {
            br = Files.newBufferedReader(path, StandardCharsets.UTF_8);
            String line =  null;
            while ((line = br.readLine()) != null) {
                log(line);
            }
        } catch (FileNotFoundException fnfe) {
            fnfe.printStackTrace();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }finally {
            try {
                if (br != null) br.close();
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }

        try (BufferedReader br_2 = Files.newBufferedReader(path)) {
            String line = null;
            while ((line = br_2.readLine()) != null) {
                log(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }

    private static void log(String str) {
        System.out.println(str);
    }

}
