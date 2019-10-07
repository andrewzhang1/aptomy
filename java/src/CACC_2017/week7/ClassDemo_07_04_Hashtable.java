package CACC_2017.week7;

import java.util.Hashtable;
import java.util.Set;

public class ClassDemo_07_04_Hashtable {

	public static void main(String[] args) {
		Hashtable ht01 = new Hashtable();
		
		for(int i=0;i<50;i++){
			ht01.put("Element_"+i, i*i);
		}
		
		System.out.println("The size of the Hashtable created is - "+ht01.size());
		System.out.println("The value with key=0 - "+ht01.get(0));
		System.out.println("The value of Element_5 is - "+ht01.get("Element_5"));

		Set keys = ht01.keySet();
		for(Object key:keys){
			System.out.println("The value of "+key+" is - "+ht01.get(key));
		}
	}
}
