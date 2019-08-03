import java.awt.*;
import javax.swing.*;
import java.text.NumberFormat;

@SuppressWarnings("serial")
public class PizzaOrderFrame extends JFrame {

    private JCheckBox anchoviesCheckBox;
    private JRadioButton largeRadioButton;
    private JRadioButton mediumRadioButton;
    private JRadioButton smallRadioButton;
    private JCheckBox mushroomsCheckBox;
    private JCheckBox olivesCheckBox;
    private JCheckBox pepperoniCheckBox;
    private JCheckBox salamiCheckBox;
    private JCheckBox sausageCheckBox;
    private JTextField priceTextField;

    public PizzaOrderFrame() {
        try {
            UIManager.setLookAndFeel(
                    UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException |
                 IllegalAccessException | UnsupportedLookAndFeelException e) {
            System.out.println(e);
        }
        initComponents();
    }

    private void initComponents() {
        setTitle("Pizza Calculator");
        setLocationByPlatform(true);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);


        setSize(270, 280);
    }

     // helper method for getting a GridBagConstraints object
    private GridBagConstraints getConstraints(int x, int y) {
        GridBagConstraints c = new GridBagConstraints();
        c.anchor = GridBagConstraints.LINE_START;
        c.insets = new Insets(5, 5, 0, 5);
        c.gridx = x;
        c.gridy = y;
        return c;
    }

    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            PizzaOrderFrame frame = new PizzaOrderFrame();
            frame.setVisible(true);
        });
    }
}