import java.text.NumberFormat;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.scene.Scene;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;

public class MPGApplication extends Application {
    private TextField milesField;
    private TextField gallonsField;
    private TextField mpgField;
    
    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Miles Per Gallon Calculator");
                
        GridPane grid = new GridPane();
        grid.setAlignment(Pos.TOP_LEFT);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25)); 
       
        Scene scene = new Scene(grid, 275, 175);
        
        grid.add(new Label("Miles:"), 0, 0);
        milesField = new TextField();
        grid.add(milesField, 1, 0);

        grid.add(new Label("Gallons:"), 0, 1);
        gallonsField = new TextField();
        grid.add(gallonsField, 1, 1);
        
        grid.add(new Label("MPG:"), 0, 2);
        mpgField = new TextField();
        mpgField.setEditable(false);
        grid.add(mpgField, 1, 2);

        Button btn = new Button();
        btn.setText("Calculate");
        btn.setOnAction(new EventHandler<ActionEvent>() {
            
            @Override
            public void handle(ActionEvent event) {
                double miles = Double.parseDouble(milesField.getText());
                double gallons = Double.parseDouble(gallonsField.getText());
                double mpg = miles / gallons;
                
                NumberFormat num = NumberFormat.getNumberInstance();
                mpgField.setText( num.format(mpg) );
            }
        });
        grid.add(btn, 1, 3);
        
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
    
}
