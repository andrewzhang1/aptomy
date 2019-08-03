package practice_your_java_level_1_code;

public class Ch18_Console_Handling3_5 {
    public static void main(String[] args) {
        long sum = 0;
        int numOfInteger = 0;

        if (args.length == 0) {
            System.out.println("No arguments passed. Exiting.");
            System.exit(0);
        }
        for (int i = 0; i < args.length; i++) {
            long potentialInteger;
            try {
                potentialInteger = Long.parseLong(args[i]);
                sum += potentialInteger;
                numOfInteger++;
            } catch (NumberFormatException e) {
                //Ignore the non-number
            }

        }
        System.out.printf("Totle = %d\n", sum);
        System.out.printf("Number of integer = %d\n", numOfInteger);
        System.out.printf("Number of args    = %d\n", args.length);
    }

}


/*
/mnt/AGZ1/GD_AGZ1117/AGZ_Home/Workspace_Java_IJ_PYJL1/out/production/PYJL1
(azhang@vmlxU2)\>java Ch18_Console_Handling3_5 2 3 4 Andrew 1
Totle = 10
Number of integer = 4
Number of args    = 5*/
