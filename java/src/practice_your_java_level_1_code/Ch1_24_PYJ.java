package practice_your_java_level_1_code;

public class Ch1_24_PYJ {

	static void greet(){
		System.out.println("Hello, how are you!");
		System.out.println("We will also combine the practice for ch1_25:");
	}
	
	static int addIntegers(int a, int b){
		return (a + b);
	}
	public static void main(String[] args) {
		greet();
		int result = addIntegers (2, 3);
		System.out.println(result);
	}

}
