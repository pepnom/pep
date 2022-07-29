   import java.awt.*;
   import java.awt.event.*;
   import javax.swing.*;
   
   public class ApplicationPanel extends JPanel {
     public ApplicationPanel() {
       super();
       JLabel label = new JLabel("A very simple Swing application");
       this.add(label);
     }
     public static void main(String[] args) {
       SwingUtilities.invokeLater(new Runnable() {
         public void run() {
           JFrame frame = new JFrame("LabelDemo");
           frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
           frame.getContentPane().add(new ApplicationPanel());
           frame.pack(); frame.setVisible(true);
         }
       });
     }
   }
