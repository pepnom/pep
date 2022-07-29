  import javax.swing.*;
  import javax.swing.table.*;
  import javax.swing.plaf.FontUIResource;
  import java.awt.Font;
  public class TableTest extends JPanel {
    JTable table;
    TableModel model = new AbstractTableModel() {
      public int getColumnCount() { return 10; }
      public int getRowCount() { return 10;}
      public Object getValueAt(int row, int col) { 
        return new Integer(row*col); 
        //return "row 
      }
    };
    public TableTest() {
      super();
      this.table = new JTable(this.model);
      this.table.setFont(new Font("Monospaced", Font.PLAIN, 20));
      this.add(new JScrollPane(this.table));
    } 

    public static void main(String[] args) throws Exception { 
       UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");
       UIManager.put("Table.font", new FontUIResource("Serif", Font.PLAIN, 38));
       JFrame f = new JFrame("A Table with an AbstractTableModel");
       f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
       f.getContentPane().add(new TableTest());
       f.pack(); f.setLocationRelativeTo(null);
       f.setVisible(true);
    }
  }
