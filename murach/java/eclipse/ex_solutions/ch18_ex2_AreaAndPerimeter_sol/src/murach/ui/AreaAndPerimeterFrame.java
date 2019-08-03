package murach.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import murach.business.Rectangle;

@SuppressWarnings("serial")
public class AreaAndPerimeterFrame extends JFrame {

    private JTextField lengthField;
    private JTextField widthField;
    private JTextField areaField;
    private JTextField perimeterField;
    private JButton computeButton;
    private JButton resetButton;

    public AreaAndPerimeterFrame() {
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
        setTitle("Area and Perimeter Calculator");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationByPlatform(true);

        lengthField = new JTextField();
        widthField = new JTextField();
        areaField = new JTextField();
        perimeterField = new JTextField();

        areaField.setEditable(false);
        perimeterField.setEditable(false);

        Dimension dim = new Dimension(250, 20);
        lengthField.setPreferredSize(dim);
        widthField.setPreferredSize(dim);
        areaField.setPreferredSize(dim);
        perimeterField.setPreferredSize(dim);
        lengthField.setMinimumSize(dim);
        widthField.setMinimumSize(dim);
        areaField.setMinimumSize(dim);
        perimeterField.setMinimumSize(dim);

        computeButton = new JButton("Compute");
        resetButton = new JButton("Reset");

        computeButton.addActionListener(e -> { computeButtonClicked(); });
        resetButton.addActionListener(e -> { resetButtonClicked(); });

        // JLabel and JTextField panel
        JPanel dataPanel = new JPanel();
        dataPanel.setLayout(new GridBagLayout());
        dataPanel.add(new JLabel("Length:"),
                getConstraints(0, 0));
        dataPanel.add(lengthField,
                getConstraints(1, 0));
        dataPanel.add(new JLabel("Width:"),
                getConstraints(0, 1));
        dataPanel.add(widthField,
                getConstraints(1, 1));
        dataPanel.add(new JLabel("Area:"),
                getConstraints(0, 2));
        dataPanel.add(areaField,
                getConstraints(1, 2));
        dataPanel.add(new JLabel("Perimeter:"),
                getConstraints(0, 3));
        dataPanel.add(perimeterField,
                getConstraints(1, 3));
        add(dataPanel, BorderLayout.CENTER);

        // JButton panel
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(computeButton);
        buttonPanel.add(resetButton);
        add(buttonPanel, BorderLayout.SOUTH);

        pack();
        setVisible(true);
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

    private void computeButtonClicked() {
        SwingValidator sv = new SwingValidator(this);
        if (sv.isDouble(lengthField, "Length") &&
            sv.isDouble(widthField, "Width")) {
            
            double length = Double.parseDouble(lengthField.getText());
            double width = Double.parseDouble(widthField.getText());

            Rectangle r = new Rectangle(length, width);
            areaField.setText(r.getAreaNumberFormat());
            perimeterField.setText(r.getPerimeterNumberFormat());
        }
    }

    private void resetButtonClicked() {
        lengthField.setText("");
        widthField.setText("");
        areaField.setText("");
        perimeterField.setText("");
    }
    
    public static void main(String[] args) {
        java.awt.EventQueue.invokeLater(() -> {
            @SuppressWarnings("unused")
			JFrame frame = new AreaAndPerimeterFrame();
        });        
    }    
}