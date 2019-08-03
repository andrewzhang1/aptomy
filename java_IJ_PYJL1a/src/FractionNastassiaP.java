//package testFraction01;

import java.util.Scanner;

public class FractionNastassiaP {
    private int num;
    private int denom;
    Scanner scaner;
    
    public FractionNastassiaP() {
      
    }
    
    public FractionNastassiaP(FractionNastassiaP fr, int n, int d) { 
        num = n;
        denom = d;
    }
    
    public void FractionFormat(FractionNastassiaP fr, int n, int d) { 
        System.out.println("\n... Calling Format(Fraction) ...\n");
        
        int gcd = 0,
                whole = 0,
                remainder,
                num,
                denom,
                numcopy,
                denomcopy;
        
        num = fr.getNum();
        denom = fr.getDenom();
        remainder = num % denom;
        whole = num / denom;
        
        if (remainder == 0) { 
            gcd = denom;
        } else {
        num = remainder;
        }
        
        numcopy = num;
        denomcopy = denom;
        
        while (remainder != 0) {
            num = denom;
            denom = remainder;
            remainder = num % denom;
            gcd = denom;
        }
        if (gcd < 0 ) {
            gcd = -gcd;
        }
        
        if (whole < 0 && numcopy < 0) {
            numcopy = -numcopy;
        }
        System.out.print("\nFormatted fraction is\n ");
        
        if (whole != 0) {
            System.out.print(fr.getNum()/gcd + " / " 
                    + fr.getDenom()/gcd +  " = ");
            System.out.print(whole + " ");
        }
        
        if (numcopy == 0) {
            System.out.println(" = 0");
        }
        
        if (gcd != 0 && denomcopy/gcd !=1 ) {
            System.out.print(numcopy/gcd + " / " + denomcopy/gcd);
            if (numcopy == 0) {
                System.out.print(" = 0");
            }
        }
    }
    
    public void setNum(int n) { //mutator
        System.out.println("Enter numerator:");
        scaner = new Scanner(System.in);
        n = scaner.nextInt();
        num  = n;
    }
    
    public void setDenom(int d) { //mutator
        do {
            System.out.println("Enter denominator (can't be 0):");
            scaner = new Scanner(System.in);
            d = scaner.nextInt();
        } while (d == 0);
        
        denom = d;
        if (d < 0) {
            swapMinus();
        }
    }
    
    public void swapMinus() {
        if (denom < 0) {
            num = -num;
            denom = -denom;
        }
    }
    
    public int getDenom() { // accessor
        return denom;
    }   
    
     public int getNum() { //accessor
         return num;
    }
}
