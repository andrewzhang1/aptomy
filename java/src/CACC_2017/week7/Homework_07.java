package CACC_2017.week7;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.TreeSet;

public class Homework_07 {

	public static void main(String[] args) {
		String[] nameInput = {"Cindy","Ester","Andy","Beth","Dave","Jack"
				,"Lizzie","Brian","Megan","Lilli"};
		double[] scoreInput = {98.5,90.5,90.0,87.5,80.5,95.5,97.0,90.0,87.0,87.5};
		
		// Answer part #1
		ArrayList scores = new ArrayList();
		for(double s:scoreInput){
			scores.add(s);
		}
		System.out.println(scores);

		// Answer part #2
		TreeSet tsscores = new TreeSet();
		for(double s:scoreInput){
			tsscores.add(s);
		}
		System.out.println(tsscores);

		// Answer part #3
		Hashtable ht = new Hashtable();
//		ht.put("Cindy", 98.5);
//		ht.put("Ester", 90.5);
//		ht.put("Andy", 90.0);
		for(int i=0;i<scoreInput.length;i++){
			ht.put(nameInput[i], scoreInput[i]);
		}
		System.out.println(ht);
	}

}
