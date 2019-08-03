package practice_your_java_level_1_code;

public class Ch19_Char_primitive_char_WrapperClass_8 {
    public static void main(String[] args) {
//8
        char char01 = (char)100;

        System.out.println(char01);
//output: d

        System.out.println("Item 10:");
        char char02 = 'A';
        int num = char02;
        System.out.println(num);
//output: 65

        //10
        System.out.println("Item 11:");
        for(int j =65; j <=15; j++){
            System.out.println(j + " is " + (char)j);

/*
        System.out.println("Item 11:");
            char[] charArry01 = {'?', '1', '2', '3', '4', '5', '6', '7', '8',
                                    '9', '0', 'A', 'a'};
            for(int i = 0; i < charArry01.length; i++ ){
                System.out.println(charArry01[i] + " is equivalent to " + (int)charArry01[i]);
            }
*/


        }

    }

}


/*
d
Item 10:
65
Item 11:
*/

