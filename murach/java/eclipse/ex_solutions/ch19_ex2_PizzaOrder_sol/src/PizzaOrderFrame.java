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

        smallRadioButton = new JRadioButton("Small");
        mediumRadioButton = new JRadioButton("Medium");
        largeRadioButton = new JRadioButton("Large");
        smallRadioButton.setSelected(true);

        ButtonGroup sizeGroup = new ButtonGroup();
        sizeGroup.add(smallRadioButton);
        sizeGroup.add(mediumRadioButton);
        sizeGroup.add(largeRadioButton);

        JPanel sizePanel = new JPanel();
        sizePanel.setBorder(BorderFactory.createTitledBorder("Size"));
        sizePanel.setLayout(new FlowLayout());
        sizePanel.add(smallRadioButton);
        sizePanel.add(mediumRadioButton);
        sizePanel.add(largeRadioButton);

        sausageCheckBox = new JCheckBox("Sausage");
        pepperoniCheckBox = new JCheckBox("Pepperoni");
        salamiCheckBox = new JCheckBox("Salami");
        olivesCheckBox = new JCheckBox("Olives");
        mushroomsCheckBox = new JCheckBox("Mushrooms");
        anchoviesCheckBox = new JCheckBox("Anchovies");

        JPanel toppingsPanel = new JPanel();
        toppingsPanel.setBorder(BorderFactory.createTitledBorder("Toppings"));
        toppingsPanel.setLayout(new GridBagLayout());
        toppingsPanel.add(sausageCheckBox, getConstraints(0, 0));
        toppingsPanel.add(pepperoniCheckBox, getConstraints(0, 1));
        toppingsPanel.add(salamiCheckBox, getConstraints(0, 2));
        toppingsPanel.add(olivesCheckBox, getConstraints(1, 0));
        toppingsPanel.add(mushroomsCheckBox, getConstraints(1, 1));
        toppingsPanel.add(anchoviesCheckBox, getConstraints(1, 2));

        priceTextField = new JTextField();
        priceTextField.setEditable(false);
        
        Dimension dim = new Dimension(100, 20);
        priceTextField.setPreferredSize(dim);
        priceTextField.setMaximumSize(dim);
        
        JPanel pricePanel = new JPanel();
        pricePanel.setLayout(new FlowLayout(FlowLayout.LEFT));        
        pricePanel.add(new JLabel("Price:"));
        pricePanel.add(priceTextField);
        
        JButton calculateButton = new JButton("Calculate");
        calculateButton.addActionListener(e -> {
            calculateButtonClicked();
        });
        JButton exitButton = new JButton("Exit");
        exitButton.addActionListener(e -> {
            exitButtonClicked();
        });
        
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(calculateButton);
        buttonPanel.add(exitButton);
        
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        panel.add(sizePanel);
        panel.add(toppingsPanel);
        panel.add(pricePanel);        
        
        add(panel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);

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

   private void calculateButtonClicked() {
        double price = 0.0;
        if (smallRadioButton.isSelected()) {
            price = 6.99;
        } else if (mediumRadioButton.isSelected()) {
            price = 8.99;
        } else if (largeRadioButton.isSelected()) {
            price = 10.99;
        }
        if (sausageCheckBox.isSelected()) {
            price += 1.49;
        }
        if (pepperoniCheckBox.isSelected()) {
            price += 1.49;
        }
        if (salamiCheckBox.isSelected()) {
            price += 1.49;
        }
        if (olivesCheckBox.isSelected()) {
            price += .99;
        }
        if (mushroomsCheckBox.isSelected()) {
            price += .99;
        }
        if (anchoviesCheckBox.isSelected()) {
            price += .99;
        }

        NumberFormat currency = NumberFormat.getCurrencyInstance();
        priceTextField.setText(currency.format(price));
    }

    private void exitButtonClicked() {
        System.exit(0);
    }

    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            PizzaOrderFrame frame = new PizzaOrderFrame();
            frame.setVisible(true);
        });
    }
}