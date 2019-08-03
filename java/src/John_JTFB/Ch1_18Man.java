package John_JTFB;

class Ch1_18Man {
	public static String gender="Male";
	public static String firstName;
	public String lastName;
	
	public static void main(String[] args){
		Ch1_18Man man01 = new Ch1_18Man();
		man01.firstName = "Andrew";
		man01.lastName = "Zhang";
		System.out.println(man01.firstName);
		System.out.println(man01.lastName);

		//This can directly access
		System.out.println("\n### Direct call from the class: ###");
		System.out.println(Ch1_18Man.gender);

		System.out.println(Ch1_18Man.firstName);
		System.out.println(man01.lastName);
		System.out.println(man01.gender);

	}

}

/* output:
Andrew
Male
Male
 */

