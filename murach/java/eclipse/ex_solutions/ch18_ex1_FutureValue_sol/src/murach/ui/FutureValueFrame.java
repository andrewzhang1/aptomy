package murach.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.text.NumberFormat;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import murach.business.FinancialCalculations;

@SuppressWarnings("serial")
public class FutureValueFrame extends JFrame {

    private JTextField investmentField;
    private JTextField interestRateField;
    private JTextField yearsField;
    private JTextField futureValueField;

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
        yearsField = new JTextField();
        futureValueField = new JTextField();

        futureValueField.setEnabled(false);

        Dimension dim = new Dimension(150, 20);
        investmentField.setPreferredSize(dim);
        interestRateField.setPreferredSize(dim);
        yearsField.setPreferredSize(dim);
        futureValueField.setPreferredSize(dim);
        investmentField.setMinimumSize(dim);
        interestRateField.setMinimumSize(dim);
        yearsField.setMinimumSize(dim);
        futureValueField.setMinimumSize(dim);

        JButton calculateButton = new JButton("Calculate");
        JButton exitButton = new JButton("Exit");

        calculateButton.addActionListener(e -> calculateButtonClicked());
        exitButton.addActionListener(e -> exitButtonClicked());

        // button panel
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(calculateButton);
        buttonPanel.add(exitButton);        

        // main panel
        JPanel panel = new JPanel();
        panel.setLayout(new GridBagLayout());
        panel.add(new JLabel("Monthly Investment:"), getConstraints(0, 0));
        panel.add(investmentField, getConstraints(1, 0));
        panel.add(new JLabel("Yearly Interest Rate:"), getConstraints(0, 1));
        panel.add(interestRateField, getConstraints(1, 1));
        panel.add(new JLabel("Years:"), getConstraints(0, 2));
        panel.add(yearsField, getConstraints(1, 2));
        panel.add(new JLabel("Future Value:"), getConstraints(0, 3));
        panel.add(futureValueField, getConstraints(1, 3));

        // add button panel to last row of main panel
        GridBagConstraints c = getConstraints(0, 4);
        c.anchor = GridBagConstraints.LINE_END;
        c.gridwidth = 2;
        panel.add(buttonPanel, c);

        add(panel, BorderLayout.CENTER);
        
        setSize(new Dimension(320, 180));
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
        SwingValidator sv = new SwingValidator(this);
        if (sv.isPresent(investmentField, "Monthly Investment") &&
            sv.isDouble(investmentField, "Monthly Investment") && 
            sv.isPresent(interestRateField, "Yearly Interest Rate") &&
            sv.isDouble(interestRateField, "Yearly Interest Rate") &&                 
            sv.isPresent(yearsField, "Years") &&
            sv.isInteger(yearsField, "Years")) {
            
            double investment = Double.parseDouble(
                    investmentField.getText());
            double interestRate = Double.parseDouble(
                    interestRateField.getText());
            int years = Integer.parseInt(
                    yearsField.getText());

            double futureValue = FinancialCalculations.calculateFutureValue(
                    investment, interestRate, years);

            NumberFormat currency = NumberFormat.getCurrencyInstance();
            futureValueField.setText(currency.format(futureValue));
        }        
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