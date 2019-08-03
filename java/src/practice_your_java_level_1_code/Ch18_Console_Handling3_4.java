package practice_your_java_level_1_code;

public class Ch18_Console_Handling3_4 {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Please pass exactly 2 arguments.");
            System.exit(0);
        }
        System.out.printf("%s, %s", args[1], args[0]);
    }
}


/*
/mnt/AGZ1/GD_AGZ1117/AGZ_Home/Workspace_Java_IJ_PYJL1/out/production/PYJL1
(azhang@vmlxU2)\>java Ch18_Console_Handling3_4 Andrew
Please pass exactly 2 arguments.

/mnt/AGZ1/GD_AGZ1117/AGZ_Home/Workspace_Java_IJ_PYJL1/out/production/PYJL1
(azhang@vmlxU2)\>java Ch18_Console_Handling3_4 Andrew Zhang Jason
Please pass exactly 2 arguments.

/mnt/AGZ1/GD_AGZ1117/AGZ_Home/Workspace_Java_IJ_PYJL1/out/production/PYJL1
(azhang@vmlxU2)\>java Ch18_Console_Handling3_4 Andrew Zhang
Zhang, Andrew
*/
