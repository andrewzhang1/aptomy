package CACC.week2;

import javax.swing.*;

public class HelloWorldJFrame {
    public static void main( String[] args ) {
        JFrame frame = new JFrame( "Hello World!" );
        JLabel label = new JLabel("Hello! World!", JLabel.CENTER );
        frame.add(label);
        frame.setSize( 300, 300 );
        frame.setVisible( true );
    }
}
