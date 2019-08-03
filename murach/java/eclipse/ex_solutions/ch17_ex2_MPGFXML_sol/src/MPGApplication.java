import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MPGApplication extends Application {
    
    @Override
    public void start(Stage stage) throws Exception {
        Parent root = FXMLLoader.load(getClass().getResource("MPG.fxml"));
        
        Scene scene = new Scene(root, 275, 175);
        
        stage.setScene(scene);
        stage.setTitle("Miles Per Gallon Calculator");
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
    
}
