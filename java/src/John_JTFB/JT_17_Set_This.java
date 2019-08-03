package John_JTFB;

class Frog{
	private String name; // This "name" is the "instance name"
	private int age;

	/*public void setName(String newName){
		name = newName;  // This "name"  is the "local variable name";
						// local variable mask the kind of instance variable if hey have the same name
		// but if I want to acturally refer to instance variable, we can start to use pre-fix: this
	}
*/
	public void setName(String name){
		this.name = name;	// This "this.name" means the name of the instance name belongs to the obeject or the class;
					// the right "= name" ==> seeting this .name which is up here equal to "String name)
	}
/*
	public void setAge(int newAge){
		age = newAge;
	}
*/

	public void setAge(int age){
		this.age = age;
	}

	public String getName(){
		return name;
	}

	public int getAge(){
		return age; // we use "this.age" here, but needed, as it's obvious!
	}

	public void setInfo(String name, int age){
		this.setName(name); // Here, this is optional!
		this.setAge(age);
	}
}

public class JT_17_Set_This {

	public static void main(String[] args) {

		Frog frog1 = new Frog();

		//frog1.name = "Andrew";
		//frog1.age = 55;

		frog1.setName("Sherry");
		frog1.setAge(19);

		System.out.println(frog1.getName());
		System.out.println(frog1.getAge());
		//System.out.println(frog);
	}
}
