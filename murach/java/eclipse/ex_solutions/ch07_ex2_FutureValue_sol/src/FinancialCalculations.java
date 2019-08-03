public class FinancialCalculations {
    public static double calculateFutureValue(double monthlyInvestment,
            double monthlyInterestRate, int months) {
        double futureValue = 0;
        for (int i = 1; i <= months; i++) {
            futureValue
                    = (futureValue + monthlyInvestment)
                    * (1 + monthlyInterestRate);
        }
        return futureValue;
    }    
}
