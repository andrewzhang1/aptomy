package practice_your_java_level_1_code;

import java.io.IOException;

public class Ch18_Console_Handling3_3 {
    public static void main(String[] args) {
        System.out.printf("Number of args=%d\n", args.length);
        for (int i = 0; i < args.length; i++)
            System.out.printf("Argument[%d] = %s\n", i, args[i]);
        }

    }

/*
/mnt/AGZ1/GD_AGZ1117/AGZ_Home/Workspace_Java_IJ_PYJL1/out/production/PYJL1
(azhang@vmlxU2)\>java Ch18_Console_Handling3_3 one two three four five
Number of args=5
Argument[0] = one
Argument[1] = two
Argument[2] = three
Argument[3] = four
Argument[4] = five
*/
