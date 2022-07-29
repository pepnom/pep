   import javax.swing.*;
   import java.awt.*;
   public class GlueBoxPanel extends JPanel {
     Font f = new Font("Serif", Font.ITALIC, 35);
     JButton b;
     public GlueBoxPanel() {
       super();

       this.add(Box.createHorizontalGlue());
       //? this.add(left);
       //this.add(right);
       //this.add(Box.createHorizontalGlue());
       this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
       this.add(Box.createVerticalStrut(20));
       for (String s: new String[]{"yew", "oak", "elm", "walnut"}) {
         b = new JButton(s); b.setFont(f);
         b.setHorizontalAlignment(JButton.CENTER);
         b.setAlignmentX(CENTER_ALIGNMENT);
         this.add(b);  
         // java 1.6 bug? have to write javax.swing.Box
         // this.add(javax.swing.Box.createVerticalStrut(20));
         this.add(Box.createVerticalStrut(20));
       }
     }
     public static void main(String args[]) {
       SwingUtilities.invokeLater(new Runnable() {
         public void run() {
           JFrame f = new JFrame("A vertical BoxLayout with JButtons");
           f.add(new GlueBoxPanel());
           f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
           f.pack(); f.setLocationRelativeTo(null);
           f.setVisible(true);
         }
       });
     }
   }
