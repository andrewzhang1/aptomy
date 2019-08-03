//package testFraction01;

public class FractionUtility {
    
    
    public boolean ifExists(FractionNastassiaP fr1, FractionNastassiaP fr2) {
        if (fr1.getDenom() == 0 && fr2.getDenom() == 0 ) {
           return false;
       }
        return true;
    }
        
    public static void printMessage() {
        System.out.println("\nYou didn't enter any fractions yet."
                    + " Please,choose option 1 and enter your fractions");
    }
    
    public static FractionNastassiaP init(FractionNastassiaP fr) {
        int n = 0;
        int d = 0;
        fr.setNum(n);
        fr.setDenom(d);
        return fr;
    }
    
    public static FractionNastassiaP addFraction(FractionNastassiaP fr1,
            FractionNastassiaP fr2) {
        int n;
        int d;
        String strOp = " + ";
        FractionNastassiaP fr3 = null;
        
        n = fr1.getNum() * fr2.getDenom() + fr1.getDenom() * fr2.getNum();
        d = fr1.getDenom() * fr2.getDenom();
        fr3 = new FractionNastassiaP(fr3, n, d);
        printResult(fr1, fr2, fr3, strOp);
        fr3 = new FractionNastassiaP(fr3, n, d);
        fr3.FractionFormat(fr3, n, d);
        return fr3;
    }
    
    public static FractionNastassiaP subFraction(FractionNastassiaP fr1,
            FractionNastassiaP fr2) {
        int n;
        int d;
        String strOp = " - ";
        FractionNastassiaP fr3 = null;
        n = fr1.getNum() * fr2.getDenom() - fr1.getDenom() * fr2.getNum();
        d = fr1.getDenom() * fr2.getDenom();
        fr3 = new FractionNastassiaP(fr3, n, d);
        printResult(fr1, fr2, fr3, strOp);
        fr3 = new FractionNastassiaP(fr3, n, d);
        fr3.FractionFormat(fr3, n, d);
        return fr3;
    }
    
    public static FractionNastassiaP mulFraction(FractionNastassiaP fr1,
            FractionNastassiaP fr2) {
        int n;
        int d;
        String strOp = " * ";
        FractionNastassiaP fr3 = null;
        n = fr1.getNum() * fr2.getNum();
        d = fr1.getDenom() * fr2.getDenom();
        fr3 = new FractionNastassiaP(fr3, n, d);
        printResult(fr1, fr2, fr3, strOp);
        fr3.FractionFormat(fr3, n, d);
        return fr3;
    }
    
    public boolean checkDenom(FractionNastassiaP fr1, FractionNastassiaP fr2) {
        int d;
        if (fr1.getDenom() * fr2.getNum() == 0) {
            System.out.println("Chosen mathematical operation impossible."
                    + " 0 denominator. Please, update Fraction 2");
            return true;
        }
        return false;
    }
    
    public static FractionNastassiaP divFraction(FractionNastassiaP fr1,
            FractionNastassiaP fr2) {
        int n;
        int d;
        String strOp = " : ";
        FractionNastassiaP fr3 = null;
        n = fr1.getNum() * fr2.getDenom();
        d = fr1.getDenom() * fr2.getNum();
        fr3 = new FractionNastassiaP(fr3, n, d);
        printResult(fr1, fr2, fr3, strOp);
        fr3.FractionFormat(fr3, n, d);
        return fr3;
    }
    
    public static void printResult(FractionNastassiaP fr1,
            FractionNastassiaP fr2, FractionNastassiaP fr3, String op) {
        System.out.print("\n" + fr1.getNum() + " / " + fr1.getDenom() + op
                + fr2.getNum() + " / " + fr2.getDenom() 
                + " = " + fr3.getNum() + "/" + fr3.getDenom());
    }
    
    
    public static void print(FractionNastassiaP fr1,FractionNastassiaP fr2) {
        System.out.println("Fraction 1: " + fr1.getNum() 
                + " / " + fr1.getDenom());
        System.out.println("Fraction 2: " + fr2.getNum() 
                + " / " + fr2.getDenom());
    }
}
