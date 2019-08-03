package practice_your_java_level_1_code;//package practiceYourJava;

class Ch1_18Man {
	public static String gender="Male";
	public String firstName;
	public String lastName;
	
	public static void main(String[] args){
		Ch1_18Man man01 = new Ch1_18Man();
		man01.firstName = "Andrew";
		man01.lastName = "Zhang";
		System.out.println(man01.firstName);
		System.out.println(man01.lastName);

		//This can directly access
		System.out.println(Ch1_18Man.gender);
		
		System.out.println(man01.lastName);
		System.out.println(man01.gender);

	}

}

/* output:
Andrew
Male
Male
 */

