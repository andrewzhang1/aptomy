package John_JTFB;

public class JT_6_If {
    	public static void main(String[] args) {

		System.out.println("#### 1. if statement:");
		if (5 != 5){
		System.out.println("Yes, it's true!");
		// nothing happens
		}

		if (5 == 5){
			System.out.println("Yes, it's true!");
		}

		System.out.println();

		int myInt = 10;
		if (myInt < 10){
			System.out.println("Yes, it's true");
		}
		else if (myInt > 20){
			System.out.println("No, it's false");
		}
		else{
			System.out.println("none of the above");
		}

		System.out.println();

		System.out.println("#### 2. if statement + while loop");
		int loop = 0;

		while (loop < 5){

			System.out.println("Loop: " + loop);
			loop++;
		}

		System.out.println();

		System.out.println("#### 3. if statement + while loop + using \"break\" ");


		int n = 0;
			while (true){
				System.out.println("looping: " + n);
				n++;
				if ( n == 5){
					break;
				}

				System.out.println("running");


		}


	}
}
