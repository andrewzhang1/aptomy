package practice_your_java_level_1_code;

public class Ch19_Char_primitive_char_WrapperClass_11 {
    public static void main(String[] args) {

        System.out.println("Item 11:");
        char[] charArry01 = {'?', '1', '2', '3', '4', '5', '6', '7', '8',
                '9', '0', 'A', 'a' };
        for (int i = 0; i < charArry01.length; i++) {
            System.out.println(charArry01[i] + " is equivalent to " + (int) charArry01[i]);
        }
    }

}

/*

Item 11:
? is equivalent to 63
1 is equivalent to 49
2 is equivalent to 50
3 is equivalent to 51
4 is equivalent to 52
5 is equivalent to 53
6 is equivalent to 54
7 is equivalent to 55
8 is equivalent to 56
9 is equivalent to 57
0 is equivalent to 48
A is equivalent to 65
a is equivalent to 97
*/
