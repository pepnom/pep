   import javax.swing.*;
   public class BoxPanel extends JPanel {
     public BoxPanel() {
       super();
       this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
       for (String s: new String[]{"yew", "oak", "elm", "walnut"}) {
         this.add(new JButton(s));  
         // java 1.6 bug? have to write javax.swing.Box
         if (s.equals("oak")) this.add(javax.swing.Box.createGlue());
       }
     }
     public static void main(String args[]) {
       SwingUtilities.invokeLater(new Runnable() {
         public void run() {
           JFrame f = new JFrame("A vertical BoxLayout with JButtons");
           f.add(new BoxPanel());
           f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
           f.pack(); f.setLocationRelativeTo(null);
           f.setVisible(true);
         }
       });
     }
   }
