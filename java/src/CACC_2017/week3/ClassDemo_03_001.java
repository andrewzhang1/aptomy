package CACC_2017.week3;

public class ClassDemo_03_001 {

	public static void main(String[] args) {
		double score = 80;
		
		if(score>=90){
			System.out.println("Excellent");
		}else{
			if(score>=80){
				// 80 <= score < 90 
				System.out.println("Great");
			}else{
				if(score>=70){
					// 70 <= score < 80 
					System.out.println("Good");
				}else{
					// Score < 70
					System.out.println("Keep working");
				}
			}
		}
	}

}
