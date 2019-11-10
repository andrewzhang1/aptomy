package CACC_2019.week7;
// Comments: Hi this is a factorial machine that can correctly go up to 13!. Since computer programming can
// go up to 10 digits, 14 and above is not correct.
public class CACCGoreFeeWeek7Part1
{
    public static void main(String[] args)
    {	final int NUM_FACTS = 100;
        for(int i = 0; i < NUM_FACTS; i++)
            System.out.println( i + "! is " + factorial(i));
    }

    public static int factorial(int n)
    {	int result = 1;
        for(int i = 2; i <= n; i++)
            result *= i;
        return result;
    }
}
