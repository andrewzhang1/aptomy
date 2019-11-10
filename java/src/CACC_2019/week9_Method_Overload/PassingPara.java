package CACC_2019.week9_Method_Overload;

class PassingPara {
    public static void main(String[] args) {

        System.out.println("Passing Parameters\n");
       // nPrintln( 5, "Welcome to java");
//
    }

    public static void nPrintln(String message, int n) {
        for (int i = 0; i < n; i++)
            System.out.println(message);

    }
}
