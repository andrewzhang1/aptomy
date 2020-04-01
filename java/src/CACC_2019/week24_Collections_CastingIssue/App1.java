package CACC_2019.week24_Collections_CastingIssue;

// Arrary: If the index < 3, it will have error for a
//Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: 2

public class App1 {
    public static void main(String[] args) {
        String[] names = new String[2];

        System.out.println(names.length);
        names[0] = "jack";
        names[1] = "3";
        names[2] = "john";
        for (int i = 0; i < names.length; i++)
            System.out.println(names[i]);
    }
}

// output:
/*
jack
3
john
null
null
null
*/
