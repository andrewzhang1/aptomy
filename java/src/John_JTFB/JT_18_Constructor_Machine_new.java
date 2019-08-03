package John_JTFB;

public class JT_18_Constructor_Machine_new {

	public static void main(String[] args) {

		Machine machine1 = new Machine();
		//new Machine(); // creating an object of a constructor can do this by involking he constructor
		Machine machine2 = new Machine("Andrew");

		Machine machine3 = new Machine("Sherry", 52);

	}

}


/*
Constructor running!
Second constructor running.
Andrew
3rd constructor running:Jason 20*/
