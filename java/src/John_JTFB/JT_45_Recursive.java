package John_JTFB;

/**
 * Created by Andrew on 7/10/2017.
 */
public class JT_45_Recursive {
    public static void main(String[] args){

        // Print out factorials:
        // 4! = 4*3*2*1
     System.out.println(factorial(23));
     //  calculate(4);
    }

    private static int factorial (int value){
        //System.out.println(value);


        if(value == 1){
            return 1 ;
        }


       // calculate(value -1 );
       return factorial(value -1) * value;

    }

}
