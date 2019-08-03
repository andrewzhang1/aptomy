package John_JTFB;

class Machine{
	private String name;
	private int code;
	// 1. Constructor is a special method which is run every time you create an instance of your class;
	// 2. Constructor can also take parameters using same name with different parameters;
	public Machine(){
		this(" Andrew: One cnstructor calls another constructor ", 0);
		System.out.println("1st Constructor running!");

		// Constructor calls another constructor:
		name = "Arnie";

	}

	public Machine(String name){
		this(name, 0);
		System.out.println("Second constructor running.");
		this.name = name; // This means the above "private String name", set by a local variable.
		System.out.println(name);
	}

	// Constructor can also take parameters:
	public Machine(String name, int code){
		this.name = name;
		this.code = code;
		System.out.println("3rd constructor running:" + name + " " +code);
	}

}

public class JT_18_Constructor_Machine {

	public static void main(String[] args) {

		Machine machine1 = new Machine();
		new Machine(); // creating an object of a constructor can do this by invoking he constructor
		Machine machine2 = new Machine("Andrew");
		Machine machine3 = new Machine("Jason", 20);

	}

}


/*
3rd constructor running: Andrew: One cnstructor calls another constructor  0
1st Constructor running!
3rd constructor running: Andrew: One cnstructor calls another constructor  0
1st Constructor running!
3rd constructor running:Andrew 0
Second constructor running.
Andrew
3rd constructor running:Jason 20
*/
