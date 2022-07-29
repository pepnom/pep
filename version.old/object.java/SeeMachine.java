/*
 A frame to show the machine
 todo
   tooltip on the ascii code
   no wrapping for ascii
   a table for the stack/tap
   peep a label not box
   reset the input stream
*/


import java.io.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;

public class SeeMachine extends JPanel implements ActionListener
{
  protected Machine machine;
  protected JList stackList;
  protected JTextField workField;
  protected JTextField peepField;
  protected JLabel peepLabel;
  protected JButton readButton;
  protected JButton untilButton;
  protected JTextField untilField;
  protected JButton whileButton;
  protected JTextField whileField;
  protected JButton clearButton;
  protected JButton addButton;
  protected JTextField addField;
  protected JButton pushButton;
  protected JButton popButton;
  protected JButton clipButton;
  protected JButton clopButton;

  protected JButton resetButton;

  protected JPanel stackPanel;
  protected JPanel commandPanel;
  protected JPanel mainPanel;

  public SeeMachine() {
    super();

    this.machine = new Machine(new InputStreamReader(System.in));
    this.machine.push(); this.machine.push();
    Font courier = new Font("Courier", Font.PLAIN, 18); 

    this.stackPanel = new JPanel();
    //String[] data = {"one", "two", "three", "four"};
    String[] data = this.machine.getStack().toArray();
    this.stackList = new JList(data);
    this.stackPanel.add(this.stackList);

    this.mainPanel = new JPanel();

    JLabel label = new JLabel("W:");
    this.mainPanel.add(label);

    this.workField = new JTextField(20);  
    this.workField.setFont(courier);
    this.mainPanel.add(this.workField);

    this.peepField = new JTextField(2);
    this.peepField.setFont(courier);
    this.mainPanel.add(this.peepField);

    this.peepLabel = new JLabel("  ");
    this.peepLabel.setFont(new Font("Serif", Font.ITALIC, 12));
    this.peepLabel.setToolTipText(
      "<html>the unicode value of the peep field");
    JPanel peepPanel = new JPanel();
    peepPanel.setBackground(Color.gray);
    peepPanel.add(peepLabel);
    this.mainPanel.add(peepPanel);

    this.commandPanel = new JPanel();
    this.commandPanel.setLayout(new GridLayout(0,2,5,5));

    readButton = new JButton("read");
    readButton.addActionListener(this);
    readButton.setToolTipText(
      "<html>read <em>one</em> character from the input stream");
    commandPanel.add(readButton);
    commandPanel.add(new JLabel(""));

    untilButton = new JButton("until");
    untilButton.addActionListener(this);
    untilButton.setToolTipText(
      "<html>read from the input stream until the <em>workspace</em>" +
      "      ends with the given text");
    commandPanel.add(untilButton);
    untilField = new JTextField(10);
    commandPanel.add(this.untilField);

    whileButton = new JButton("while");
    whileButton.addActionListener(this);
    whileButton.setToolTipText(
      "<html><center>read from the input stream while the peep <br>" +
      " field is the given character class or character <br>" +
      " valid character classes: <br>"); 
    commandPanel.add(whileButton);
    whileField = new JTextField(10);
    commandPanel.add(this.whileField);

    this.clearButton = new JButton("clear");
    clearButton.addActionListener(this);
    clearButton.setToolTipText(
      "<html>clear the <tt>workspace</tt></html>");
    this.commandPanel.add(clearButton);
    this.commandPanel.add(new JLabel(""));

    this.addButton = new JButton("add");
    addButton.addActionListener(this);
    addButton.setToolTipText(
      "<html>at the given text to the <tt>workspace</tt></html>");
    this.commandPanel.add(addButton);

    this.addField = new JTextField(10);
    this.commandPanel.add(this.addField);

    popButton = new JButton("pop");
    popButton.addActionListener(this);
    popButton.setToolTipText(
      "<html><center>push the contents of the workspace up to the " +
      "next <code><strong>*</strong></code> character onto the stack");
    commandPanel.add(popButton);
    commandPanel.add(new JLabel(""));

    pushButton = new JButton("push");
    pushButton.addActionListener(this);
    pushButton.setToolTipText(
      "<html><center>pop the top item of the stack and insert <br>" +
      " at the beginning of the workspace");
    commandPanel.add(pushButton);
    commandPanel.add(new JLabel(""));

    clipButton = new JButton("* clip");
    clipButton.addActionListener(this);
    clipButton.setToolTipText(
      "<html><center>remove the last character of the workspace <br>");
    commandPanel.add(clipButton);
    commandPanel.add(new JLabel(""));


   // to make a tabbed pane
   /* JTabbedPane jtp = new JTabbedPane();
       JPanel p1 = new JPanel(); p1.add(new JLabel("The 1st Tab Area"));
              JPanel p2 = new JPanel(); p2.add(new JLabel("The 2nd Tab Area"));
                     jtp.addTab("Tab1", p1);
                            jtp.addTab("Tab2", p2);

    */

    JPanel machinePanel = new JPanel();
    this.add(new JLabel("A parse machine"), BorderLayout.NORTH);
    this.add(stackPanel, BorderLayout.WEST);
    this.add(mainPanel, BorderLayout.CENTER);
    this.add(commandPanel, BorderLayout.EAST);
    this.add(new JLabel("--"), BorderLayout.SOUTH);
  }

  public void actionPerformed(ActionEvent e)
  {
    String command = e.getActionCommand();
    if ("read".equals(command)) {
      this.machine.read();
    }

    if ("until".equals(command)) {
      this.machine.until(this.untilField.getText());
    }

    if ("while".equals(command)) {
      this.machine.whilePeep(this.whileField.getText());
    }

    if ("clear".equals(command)) {
      this.machine.clear();
    }

    if ("add".equals(command)) {
      this.machine.add(this.addField.getText());
      this.addField.setText("");
    }

    if ("pop".equals(command)) { this.machine.pop(); }
    if ("push".equals(command)) { this.machine.push(); }
    this.updateView();
  }

  /** updates the elements of the panel to reflect the 
      current state of the machine */
  public void updateView() {
    this.workField.setText(this.machine.getWorkSpace());  
    this.peepField.setText(this.machine.getVisiblePeep());  
    this.peepLabel.setText("" + this.machine.getPeepCode());  
    this.stackList.setListData(this.machine.stackArray());  
  }

  public static void main(String[] args) {
    SeeMachine mg = new SeeMachine();
    JFrame display = new JFrame();
    //display.setUndecorated(true);
    display.getContentPane().add(mg);
    display.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    display.setLocationRelativeTo(null);
    display.pack();
    display.setVisible(true);
  }
}



