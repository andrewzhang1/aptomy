package murach.ui;

import javax.swing.*;
import java.awt.*;
import java.time.LocalDate;

@SuppressWarnings("serial")
public class PaymentFrame extends JFrame {
    private JRadioButton creditCardRadioButton;
    private JRadioButton billCustomerRadioButton;
    private JList cardTypeList;
    private JTextField cardNumberTextField;
    private JComboBox monthComboBox;
    private JComboBox yearComboBox;
    private JCheckBox verifiedCheckBox;

    public PaymentFrame() {
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
        // set up frame
        setTitle("Payment Form");
        setLocationByPlatform(true);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);        

        // set up Billing components
        ButtonGroup billingGroup = new ButtonGroup();
        creditCardRadioButton = new JRadioButton("Credit card");
        billCustomerRadioButton = new JRadioButton("Bill customer");
        billingGroup.add(creditCardRadioButton);
        billingGroup.add(billCustomerRadioButton);
        creditCardRadioButton.setSelected(true);
        creditCardRadioButton.addActionListener(
                event -> billingRadioButtonClicked());
        billCustomerRadioButton.addActionListener(
                event -> billingRadioButtonClicked());
        
        // set up Billing panel
        JPanel billingPanel = new JPanel();
        billingPanel.setBorder(BorderFactory.createTitledBorder("Billing"));
        billingPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
        billingPanel.add(creditCardRadioButton);
        billingPanel.add(billCustomerRadioButton);
        
        // set up Card Type list
        String[] cardTypes = {"Visa", "Master Card", "American Express"};
        cardTypeList = new JList(cardTypes);
        cardTypeList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        JScrollPane cardTypeScrollPane = new JScrollPane(cardTypeList);
        cardTypeScrollPane.setPreferredSize(new Dimension(150, 60));

        // set up Card Number text field
        cardNumberTextField = new JTextField();
        Dimension dim = new Dimension(150, 20);
        cardNumberTextField.setPreferredSize(dim);
        cardNumberTextField.setMinimumSize(dim);

        // set up Expiration month combo
        String[] months = {"January", "February", "March", "April", 
                           "May", "June", "July", "August", 
                           "September", "October", "November", "December"};
        monthComboBox = new JComboBox(months);

        // set up Expiration year combo
        LocalDate currentDate = LocalDate.now();
        int startYear = currentDate.getYear();
        int endYear = startYear + 8;
        yearComboBox = new JComboBox();
        for (int i = startYear; i < endYear; i++) {
            yearComboBox.addItem(Integer.toString(i));
        }        
        
        // set up Expiration Date panel
        JPanel expirationDatePanel = new JPanel();
        expirationDatePanel.setLayout(new FlowLayout(FlowLayout.LEFT));
        expirationDatePanel.add(monthComboBox);
        expirationDatePanel.add(yearComboBox);        
               
        // set up Verified check box
        verifiedCheckBox = new JCheckBox();
        verifiedCheckBox.setText("Verified");

        // set up the grid panel
        JPanel gridPanel = new JPanel();
        gridPanel.setLayout(new GridBagLayout());
        
        gridPanel.add(new JLabel("Card type:"), getConstraints(0, 0));
        gridPanel.add(cardTypeScrollPane, getConstraints(1, 0));        
        gridPanel.add(new JLabel("Card number:"), getConstraints(0, 1));
        gridPanel.add(cardNumberTextField, getConstraints(1, 1));
        gridPanel.add(new JLabel("Expiration Date:"), getConstraints(0, 2));
        gridPanel.add(expirationDatePanel, getConstraints(1, 2));
        gridPanel.add(verifiedCheckBox, getConstraints(1, 3));
               
        // set up Accept and Exit buttons
        JButton acceptButton = new JButton("Accept");
        acceptButton.addActionListener(event -> acceptButtonClicked());
        JButton exitButton = new JButton("Exit");
        exitButton.addActionListener(event -> exitButtonClicked());

        // set up button panel
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(acceptButton);
        buttonPanel.add(exitButton);        
        
        // add billing panel to NORTH
        add(billingPanel, BorderLayout.NORTH);
        
        // add grid bag panel to CENTER
        add(gridPanel, BorderLayout.CENTER);
        
        // add button panel to SOUTH
        add(buttonPanel, BorderLayout.SOUTH);

        pack();
    }

    // Helper method to return GridBagConstraints objects
    private GridBagConstraints getConstraints(int x, int y) {
        GridBagConstraints c = new GridBagConstraints();
        c.anchor = GridBagConstraints.LINE_START;
        c.insets = new Insets(5, 5, 0, 5);
        c.gridx = x;
        c.gridy = y;
        return c;
    }

    private void billingRadioButtonClicked() {
        if (creditCardRadioButton.isSelected()) {
            enableCreditCardControls(true);
        } else if (billCustomerRadioButton.isSelected()) {
            enableCreditCardControls(false);
        }
    }

    private void enableCreditCardControls(boolean enable) {
        cardTypeList.setEnabled(enable);
        cardNumberTextField.setEnabled(enable);
        monthComboBox.setEnabled(enable);
        yearComboBox.setEnabled(enable);
        verifiedCheckBox.setEnabled(enable);
    }

    private void acceptButtonClicked() {
        String message;
        if (creditCardRadioButton.isSelected()) {
            message = "Bill " + (String) cardTypeList.getSelectedValue()
                    + "\nNumber: " + cardNumberTextField.getText()
                    + "\nExpiration date: "
                    + (String) monthComboBox.getSelectedItem()
                    + ", " + (String) yearComboBox.getSelectedItem();
            if (verifiedCheckBox.isSelected()) {
                message += "\nCard has been verified.";
            } else {
                message += "\nCard has not been verified.";
            }
        } else {
            message = "Customer will be billed.";
        }
        
        // display message
        JOptionPane.showMessageDialog(this, message);
        
        // reset controls
        cardTypeList.setSelectedIndex(0);
        cardNumberTextField.setText("");
        monthComboBox.setSelectedIndex(0);
        yearComboBox.setSelectedIndex(0);
        verifiedCheckBox.setSelected(false);
    }

    private void exitButtonClicked() {
        System.exit(0);
    }

    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            new PaymentFrame().setVisible(true);            
        });
    }
}