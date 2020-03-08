package CACC_2019.week6_Loop;

public class Loop2 {
    public static void main(String[] args) {
        int item = 1;
        int sum = 0;
        do {
                sum += item;
                item -= 0.1;
                System.out.println(sum);
        } while (item != 0);

        System.out.println("Done Loop2");
    }

}
