package CACC_2019.week6_Loop;

public class Loop {
    public static void main(String[] args) {
        double item = 1;
        double sum = 0;
        while (item != 0) { // No guarantee item will be 0
            sum += item;
            item -= 0.1;
        }
        System.out.println(sum);
        System.out.println("Done");
    }

}
