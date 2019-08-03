package John_JTFB;

class Thing{

	public final static int LUCK_NUMBER = 7;


	public String name;
	public static String description;  // Static variable belongs to the class, not the object!

	public static int count = 0;

	public int id;

	public Thing(){
		id = count;
		count++;
	}

	// static method vs instance method:
	public void showName(){
		System.out.println("Obeject id " + id + ", " + description + ": " + name); //instance method can access static variable! ? However, name is
										              // not static ?
	}

	public static void showInfo(){
		System.out.println("Hello"); // Static method can access static variable
		System.out.println(description);
		//System.out.println(name); // Error:(13, 36) java: non-static variable name cannot be referenced from a static context

	}

}


public class JT_19_Static_Final {

	public static void main(String[] args) {

		Thing.description = "I'm a thing.";


		System.out.println("Before creating objects, count is " + Thing.count);


		Thing thing1 = new Thing();
		Thing thing2 = new Thing();

		thing1.name = "Bob";
		thing2.name = "Sue";

		System.out.println(thing1.name);
		System.out.println(thing2.name);

		System.out.println("After creating objects, count is " + Thing.count);

	//	System.out.println(Thing.description);
		Thing.showInfo();

		thing1.showName();
		thing2.showName();

		System.out.println(Math.PI);

		// Math.PI = 3.3; unchangable!
		System.out.println(Thing.LUCK_NUMBER);

	}

}

