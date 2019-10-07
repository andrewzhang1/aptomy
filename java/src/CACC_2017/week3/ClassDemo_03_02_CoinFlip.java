package CACC_2017.week3;

public class ClassDemo_03_02_CoinFlip {

	public static void main(String[] args) {
        double rdm = Math.random();
        
		if (rdm<0.5)
            System.out.println("Heads");
        else     //Math.random()>=0.5
            System.out.println("Tails");

	}

}
