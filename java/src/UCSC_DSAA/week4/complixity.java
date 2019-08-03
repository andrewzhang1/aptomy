package UCSC_DSAA.week4;

/**
 * Created by Andrew on 7/6/2017.
 */

public class complixity {

	private static void P(String s, int n, long k){
		System.out.println(s + " For input " + n + " work done is " + k);
	}

	private static void p1(int n){
		long k = 0;
		int x = 100;
		int y = 89000;
		++k;
		int z = x + y * y + 8000;
		P("p1", n, k);
	}

	private static void p2(int n){
		long k = 0;
		int x = 100;
		int y = 89000;

		++k;
		int z = x + y * y + 8000;

		for (int i = 0; i < n; ++i){
		    ++k;
		    int w = i * x + y;
        }
		P("p2", n, k);
	}

	private static void p3(int n){
		long k = 0;
		int x = 100;
		int y = 89000;

		++k;
		int z = x + y * y + 8000;

		for (int i = 0; i < n; ++i){
		    for(int j=1; j<n; ++j){
		      ++k;
		      int w = (i * x + y)*j;
            }
        }
		P("p3", n, k);
	}

	private static void p4(int n){
		long k = 0;

		for (int i = 0; i < n; ++i){
		    for(int j=1; j<n; ++j){
		      ++k;
		    }
        }
		P("p4", n, k);
	}

    private static void p5(int n){
		long k = 0;
		for (int i = 0; i < n; ++i){
		    for(int j = 0; j < i; ++j){
                for(int z = 0; z < 77; ++z) {
                    ++k;
                }
		    }
        }

		P("p5", n, k);
	}

	private static void test(){
		int n = 100;

		p1(n);
		p2(n);
		p3(n);
		p4(256);
		p5(n);

	}

	public static void main(String[] args){
		System.out.println("Complixity.java");
		test();
		System.out.println("DONE");

	}
}

