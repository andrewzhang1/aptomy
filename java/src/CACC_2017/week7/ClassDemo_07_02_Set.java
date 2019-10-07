package CACC_2017.week7;

import java.util.Iterator;
import java.util.TreeSet;

public class ClassDemo_07_02_Set {

	public static void main(String[] args) {
		TreeSet tset01 = new TreeSet();
		
		for(int i=0;i<50;i++){
			tset01.add(Math.random());
		}
		
		System.out.println("The size of the TreeSet created is - "+tset01.size());
//		System.out.println("The first element is - "+tset01.first());
//		System.out.println("The last element is - "+tset01.last());
//
		System.out.println("Now let's see what's in there:");
		Iterator tsetIterator = tset01.iterator();
		int counter = 0;
		while(tsetIterator.hasNext()){
			System.out.println("The "+counter+"th element is - "+tsetIterator.next());
			counter ++;
		}
//		
//		TreeSet tset02 = new TreeSet();
//		String[] books = new String[]{"Star Wars","Harry Potter","Haunted House","Star Wars"};
//		for(int i=0;i<books.length;i++){
//			tset02.add(books[i]);
//		}
//		System.out.println("The size of tset02 is - "+tset02.size());
//		System.out.println("Now let's see what's in there:");
//		Iterator tsetIterator2 = tset02.iterator();
//		while(tsetIterator2.hasNext()){
//			System.out.println(tsetIterator2.next());
//		}
//		System.out.println("That's it?");

		TreeSet tset03 = new TreeSet();
		for(int i=0;i<10;i++){
			tset03.add(Math.random());
		}
		System.out.println("The size of tset02 is - "+tset03.size());
		System.out.println("Now let's see what's in there:");
		Iterator tsetIterator3 = tset03.iterator();
		while(tsetIterator3.hasNext()){
			System.out.println(tsetIterator3.next());
		}
		System.out.println("That's it?");
	}

}
