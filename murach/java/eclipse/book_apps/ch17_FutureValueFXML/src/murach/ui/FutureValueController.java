package murach.ui;

import java.text.NumberFormat;
import javafx.fxml.FXML;
import javafx.scene.control.TextField;

import murach.business.FinancialCalculations;

public class FutureValueController {
    @FXML private TextField investmentField;
    @FXML private TextField interestRateField;
    @FXML private TextField yearsField;
    @FXML private TextField futureValueField;
    
    @FXML 
    private void calculateButtonClicked() {
        double investment = Double.parseDouble(investmentField.getText());
        double rate = Double.parseDouble(interestRateField.getText());
        int years = Integer.parseInt(yearsField.getText());
        double futureValue = FinancialCalculations.calculateFutureValue(
                investment, rate, years);

        NumberFormat currency = NumberFormat.getCurrencyInstance();
        futureValueField.setText(currency.format(futureValue));            
    }
    
    @FXML 
    private void exitButtonClicked() {
        System.exit(0);   // 0 indicates a normal exit
    }    
}