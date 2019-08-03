package murach.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.text.NumberFormat;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import murach.business.FinancialCalculations;

@SuppressWarnings("serial")
public class FutureValueFrame extends JFrame {

    private JTextField investmentField;
    private JTextField interestRateField;
    private JComboBox yearsComboBox;
    private JList futureValueList;
    private DefaultListModel<String> futureValueModel;

    public FutureValueFrame() {
        initComponents();
    }

    private void initComponents() {
        try {
            UIManager.setLookAndFeel(
                    UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException |
                 IllegalAccessException | UnsupportedLookAndFeelException e) {
            System.out.println(e);
        }

        setTitle("Future Value Calculator");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationByPlatform(true);

        investmentField = new JTextField();
        interestRateField = new JTextField();
        yearsComboBox = new JComboBox();
        futureValueList = new JList();
        futureValueModel = new DefaultListModel<>();        
        JScrollPane futureValuePane = new JScrollPane(futureValueList);
        
        Dimension dim = new Dimension(150, 20);
        investmentField.setPreferredSize(dim);
        investmentField.setMinimumSize(dim);
        interestRateField.setPreferredSize(dim);
        interestRateField.setMinimumSize(dim);
        yearsComboBox.setPreferredSize(dim);
        yearsComboBox.setMinimumSize(dim);

        Dimension dim2 = new Dimension(150, 80);
        futureValuePane.setPreferredSize(dim2);
        futureValuePane.setMinimumSize(dim2);

        JButton calculateButton = new JButton("Calculate");
        JButton exitButton = new JButton("Exit");

        calculateButton.addActionListener(e -> calculateButtonClicked());
        exitButton.addActionListener(e -> exitButtonClicked());

        // button panel
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(calculateButton);
        buttonPanel.add(exitButton);
        
        for (int i = 1; i < 21; i++) {
            yearsComboBox.addItem(i);
        }
        yearsComboBox.setSelectedIndex(2);

        // main panel
        JPanel panel = new JPanel();
        panel.setLayout(new GridBagLayout());
        panel.add(new JLabel("Monthly Investment:"), getConstraints(0, 0));
        panel.add(investmentField, getConstraints(1, 0));
        panel.add(new JLabel("Yearly Interest Rate:"), getConstraints(0, 1));
        panel.add(interestRateField, getConstraints(1, 1));
        panel.add(new JLabel("Years:"), getConstraints(0, 2));
        panel.add(yearsComboBox, getConstraints(1, 2));
        panel.add(new JLabel("Future Value:"), getConstraints(0, 3));
        panel.add(futureValuePane, getConstraints(1, 3));        

        add(panel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);
        
        pack();
        setVisible(true);
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
        double investment = Double.parseDouble(investmentField.getText());
        double interestRate = Double.parseDouble(interestRateField.getText());
        int years = (int) yearsComboBox.getSelectedItem();

        NumberFormat currency = NumberFormat.getCurrencyInstance();        
        futureValueModel.clear();
        double futureValue;
        String yearlyString;
        for (int year = 1; year <= years; year++) {
            futureValue = FinancialCalculations.calculateFutureValue(
                    investment, interestRate, year);
            yearlyString = "Year " + year + ": " + 
                    currency.format(futureValue);
            futureValueModel.addElement(yearlyString);
        }
        futureValueList.setModel(futureValueModel);
    }

    private void exitButtonClicked() {
        System.exit(0);
    }
    
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            @SuppressWarnings("unused")
			JFrame frame = new FutureValueFrame();
        });
    }    
}