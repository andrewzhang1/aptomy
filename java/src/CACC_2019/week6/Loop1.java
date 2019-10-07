package CACC_2019.week6;

public class Loop1 {
    public static void main(String[] args) {
        int item = 10;
        int sum = 0;
        while (item != 0) {
            sum += item;
            item -= 1;
        }
        System.out.println(sum);
        System.out.println("Done Loop1");
    }
}
