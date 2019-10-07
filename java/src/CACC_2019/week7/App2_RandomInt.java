package CACC_2019.week7;
import java.util.Random;

public class App2_RandomInt {
    public static void main(String[] args) {

    //long num = 50_000_000_000L;
	int num = 9;
	double randomDouble = Math.random();
	randomDouble = randomDouble * num + 1;
	int randomInt = (int) randomDouble;
	System.out.println(randomInt);

	// Without casting, the double is still a double
	//System.out.println(randomDouble);
   }
}
