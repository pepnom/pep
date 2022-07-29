    import javax.swing.*;
    import java.awt.*;
    import java.awt.event.*;
    import java.lang.reflect.*;
    import java.util.jar.*;
    import java.util.zip.*;
    import java.io.*;
    import java.awt.*;
    import java.util.Enumeration;
    public class ClassInfo extends JPanel implements ActionListener {
      JList list;
      DefaultListModel model;
      JComboBox box;
      String className;
      String filterName; 
      public ClassInfo(String filterName) {
        super(new BorderLayout());
        this.filterName = filterName;
        this.className = new String(" ");
        this.box = new JComboBox(new DefaultComboBoxModel());
        this.box.setEditable(true);
        this.box.setFont(new Font("Georgia", Font.PLAIN, 24));
        this.add(this.box, BorderLayout.NORTH);
        this.model = new DefaultListModel();
        this.list = new JList(this.model);
        this.list.setFont(new Font("Georgia", Font.PLAIN, 20));
        this.list.setForeground(Color.darkGray);
        this.list.setBorder(BorderFactory.createEmptyBorder(9,9,9,9));
        this.setComboItems();
        this.box.addActionListener(this);
        JScrollPane scroll = new JScrollPane(list);
        scroll.setBorder(null);
        this.add(scroll, BorderLayout.CENTER);
        this.setBorder(BorderFactory.createEmptyBorder(9,9,9,9));
      }

      public void setComboItems() {
       this.box.removeAllItems();
       String name = new String();
       int index = 0;
       try {
         JarFile jar = new JarFile(
           new File(System.getProperty("java.home") + "/lib/rt.jar"));
         Enumeration<? extends JarEntry> enumeration = jar.entries();
         while (enumeration.hasMoreElements()) {
           ZipEntry zipEntry = enumeration.nextElement();
           name = zipEntry.getName().replace(".class", "")
              .replace("/", ".");
           //if (name.startsWith("com.") || name.startsWith("sun."))
           //  continue;

           if (name.endsWith(this.filterName)) {
             this.box.addItem(name);
           }
           if (name.matches(this.filterName)) {
             this.box.addItem(name);
           }


         }
       } catch (IOException e) {}
       // this is throwing an exception because the box is not visible
       //this.box.showPopup();
       //this.box.setSelectedIndex(index);
      }

      public void setListData() {
        this.model.removeAllElements();
        if (this.className == null) return;
        try {
          Class c = Class.forName(this.className);
          Constructor co[] = c.getConstructors();
          for (int i = 0; i < co.length; i++)
            this.model.addElement(
              co[i].toString()
                .replace("public ", "").replace("java.lang.", "") 
                .replace(this.className + ".", "")
            );
          Method mm[] = c.getMethods();
          for (int i = 0; i < mm.length; i++)
            this.model.addElement(
              mm[i].toString()
                .replace("public ", "").replace("java.lang.", "") 
                .replace(this.className + ".", "")
            );

        }
        catch (ClassNotFoundException e) { 
          this.model.addElement(
            String.format("class '%s' not found", this.className)); 
        }
      }

      public void actionPerformed (ActionEvent e) {
        if (e.getSource() == this.box) {
          if ("comboBoxEdited".equals(e.getActionCommand())) {
            this.filterName = (String)this.box.getSelectedItem();
            this.setComboItems();
          }
          else if ("comboBoxChanged".equals(e.getActionCommand())) {
            System.out.println("action command=" + e.getActionCommand());
            this.className = (String)this.box.getSelectedItem();
            this.setListData();
          }
        }
      }
  
      public static void main(String[] args) throws Exception {
        String filter;
        if (args.length > 0)
          filter = args[0];
        else
          filter = "ImageReader";
        ClassInfo p = new ClassInfo(filter);
        JFrame f = new JFrame("Information About Classes");
        f.add(p);
        f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        f.pack(); f.setExtendedState(Frame.MAXIMIZED_BOTH);
        f.setVisible(true);
      }
    }
