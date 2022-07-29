   import javax.swing.*;
   import javax.swing.border.*;
   import javax.swing.table.*;
   import javax.swing.plaf.FontUIResource;
   import java.awt.*;
   public class PropertiesTable extends JPanel {
     public PropertiesTable() {
       super();
       this.setBorder(new TitledBorder("Properties Table"));
       String[] header = {"Name", "Value"};
       String[] a = new String[0];
       String[] names =
         System.getProperties().stringPropertyNames().toArray(a);
       String[][] data = new String[names.length][2];
       for (int ii=0; ii<names.length; ii++) {
         data[ii][0] = names[ii];
         data[ii][1] = System.getProperty(names[ii]);
       }
       DefaultTableModel model = new DefaultTableModel(data, header);
       JTable table = new JTable(model);
       try { // java version 1.6+
         table.setAutoCreateRowSorter(true);
       } catch (Exception continuewithNoSort) { }
       this.add(new JScrollPane(table));
     }
   
     public static void main(String[] args) throws Exception {
       UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");
       SwingUtilities.invokeLater(new Runnable() {
         public void run() {
           JOptionPane.showMessageDialog(null, new PropertiesTable());
         }
       });
     }
   }
