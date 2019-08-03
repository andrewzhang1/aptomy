//  https://study.com/academy/lesson/static-vs-non-static-methods-in-java.html
package Z_MISC;

public class Calc {
    int product(int x, int y) {
        return x * y;
    }

    static int product2(int x, int y){
        return x * y;
    }

    private static void swapValue(int a, int b){
        int temp = a;
        a = b;

    }


    public static void main(String[] args) {
        Calc calc1 = new Calc();
        int ans1 = calc1.product(4,3);
        System.out.println(ans1);

        float ans2 = Calc.product2(8, 9);
        System.out.println(ans2);
        System.out.println("Hi");


    String str="sdfvsdf68fsdfsf8999fsdf09";
    String numberOnly= str.replaceAll("[^0-9]", "");
    System.out.println(str);


   String s="abc123def45gh6ij78";
   for(int i=0;i<s.length();i++) {
    char c=s.charAt(i);
    char d=s.charAt(i);
     if ('a' <= c && c <= 'z')
         System.out.println("String:-"+c);
     else  if ('0' <= d && d <= '9')
           System.out.println("number:-"+d);
    }


    String input = "abc123def45gh6ij78";
    input = input.replaceAll("", "");

    String alpha ="";
    String num = "";

    char[] c_arr = input.toCharArray();

    for(char c: c_arr) {
        if(Character.isDigit(c)) {
            alpha = alpha + c;
        }
        else {
            num = num+c;
        }
    }

    System.out.println("Alphabet: "+ alpha);
    System.out.println("num: "+ num);


    }
}