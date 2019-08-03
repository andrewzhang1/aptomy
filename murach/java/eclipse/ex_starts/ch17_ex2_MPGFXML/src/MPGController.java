import java.text.NumberFormat;
import javafx.fxml.FXML;
import javafx.scene.control.TextField;

public class MPGController {
    
    @FXML private TextField milesField;
    @FXML private TextField gallonsField;
    @FXML private TextField mpgField;
        
    @FXML
    private void calculateButtonClicked() {
        double miles = Double.parseDouble(milesField.getText());
        double gallons = Double.parseDouble(gallonsField.getText());
        double mpg = miles / gallons;
                
        NumberFormat num = NumberFormat.getNumberInstance();
        mpgField.setText( num.format(mpg) );
    }
    
}
