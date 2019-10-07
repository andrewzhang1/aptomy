package CACC_2017.week7;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.TreeSet;

public class ClassDemo_07_03_List {

	public static void main(String[] args) {
		ArrayList lst01 = new ArrayList();
		
		for(int i=0;i<50;i++){
			lst01.add(Math.random());
		}
		
		System.out.println("The size of the ArrayList created is - "+lst01.size());
		System.out.println("The first element is - "+lst01.get(0));
		System.out.println("The last element is - "+lst01.get(lst01.size()-1));
//
//		System.out.println("Now let's see what's in there:");
//		Iterator lstIterator = lst01.iterator();
//		int counter = 0;
//		while(lstIterator.hasNext()){
//			System.out.println("The "+counter+"th element is - "+lstIterator.next());
//			counter ++;
//		}
//
//		for(int j=0;j<lst01.size();j++)
//			System.out.println("The "+j+"th element is - "+lst01.get(j));
//
//		System.out.println("That's all!");
	}
}
