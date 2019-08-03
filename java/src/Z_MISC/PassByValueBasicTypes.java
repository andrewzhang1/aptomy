package Z_MISC;

/**
 * Created by Andrew on 7/3/2017.
 */


public class PassByValueBasicTypes {
	private static void swapBasic(int x, int y) {
		// What is x and y
        // x = 10, y = 20
		int t = x;
		x = y;
		y = t;
		// What is x and y
        // x = 20, y = 10
	}

	private static void PassByValueBasicTypes() {
		int a = 10;
		int b = 20;
		// What is x and y
		swapBasic(a, b);
		// What is x and y
        // a = 10, b = 20


	}

    private static void swap1(Integer x, Integer y) {
        //What is x and y
        Integer t = new Integer(x);
        x = y;
        y = t;
        //What is x and y
    }
    private static void passByValueObjectTypes() {
        Integer x =new Integer(10) ;
        Integer y =new Integer(20) ;
        //What is x and y
        swap1(x, y);
        //What is x and y
        System.out.println(x + " " + y);
    }

	public static void main(String[] args) {

	    passByValueObjectTypes();
	}
}
