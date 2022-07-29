    import javax.swing.*;
    import javax.swing.event.*;
    import java.awt.*;
    import java.awt.event.*;
    import java.lang.reflect.*;
    public class MethodPanel extends JPanel implements ActionListener,
      DocumentListener {
      Font listFont = new Font("Monospaced", Font.PLAIN, 40);
      Font panelFont = new Font("Serif", Font.PLAIN, 40);
      Color sandstone = new Color(212, 191, 142);
      JList list;
      DefaultListModel model;
      JTextField box;
      JLabel statusLabel;
      String className;
      String filter;   /* the part after the class-name and . */

      /** just checks if a class name exists or not */
      public static boolean classExists(String name) {
        try {
          Class c = Class.forName(name); return true;
        } catch (ClassNotFoundException e) { return false; }
      }

      // document listener protocol
      @Override
      public void insertUpdate(DocumentEvent e)
        { this.setFilter(); }
      @Override
      public void removeUpdate(DocumentEvent e)
        { this.setFilter(); }
      @Override
      public void changedUpdate(DocumentEvent e)
      { }
        

      public MethodPanel(String className) {
        super(new BorderLayout());
        this.className = className;
        this.filter = new String();
        this.box = new JTextField(className);
        this.box.setFont(panelFont);
        this.box.addActionListener(this);
        this.box.getDocument().addDocumentListener(this);

        this.add(this.box, BorderLayout.NORTH);
        this.statusLabel = new JLabel("+/- change font size");
        this.statusLabel.setFont(panelFont);
        this.add(statusLabel, BorderLayout.SOUTH);

        this.model = new DefaultListModel();
        this.setListData();
        this.list = new JList(this.model);
        this.list.setSelectionBackground(sandstone);
        this.list.setFont(listFont);
        this.list.setForeground(Color.darkGray);
        this.list.setBorder(BorderFactory.createEmptyBorder(9,9,9,9));
        this.list.addKeyListener(new KeyAdapter() {
          JList list = MethodPanel.this.list;
          JLabel label = MethodPanel.this.statusLabel;
          public void keyTyped(KeyEvent e) {
            char key = e.getKeyChar();
            if ((key == '+') || (key == 'b')) {
              Font font = list.getFont();
              float size = font.getSize() + 2.0f;
              list.setFont(font.deriveFont(size));
              label.setText("Font: " + size);
            }
            if ((key == '-') || (key == 's')) {
              Font font = MethodPanel.this.list.getFont();
              float size = font.getSize() - 2.0f;
              list.setFont(font.deriveFont(size));
              MethodPanel.this.statusLabel.setText("Font: " + size);
            }
            list.requestFocusInWindow();
          }
        });

        JScrollPane scroll = new JScrollPane(list);
        scroll.setBorder(null);
        this.add(scroll, BorderLayout.CENTER);
        this.setBorder(BorderFactory.createEmptyBorder(9,9,9,9));
      }

      public void setListData() {
        // try to filter names based on text after '.'
        // this will be triggered by key events.
        // setting the class name is only triggered by <enter>
        this.model.removeAllElements();
        try {
          Class c = Class.forName(this.className);
          Constructor co[] = c.getConstructors();
          for (int i = 0; i < co.length; i++)
            this.model.addElement(
              co[i].toString()
                .replace(this.className + ".", "")
                //.replace("public ", "").replace("java.lang.", "") 
            );
          Method mm[] = c.getMethods();
          String ss = new String("");
          for (int i = 0; i < mm.length; i++) {
            ss = mm[i].toString();
              //mm[i].toString().split(" ",2)[1];
            if (this.filter.length() > 0) {
              if (mm[i].toString().matches("(?i).*" + this.filter + ".*")) {
                this.model.addElement(ss);
                  //mm[i].toString()
                   //   .replace(this.className + ".", "")
                 //   .replace("public ", "").replace("java.lang.", "") 
              }
            } else { this.model.addElement(ss); }
          }
        }
        catch (ClassNotFoundException e) { 
          this.model.addElement(
            String.format("class '%s' not found", this.className)); 
        }
      }

      public void actionPerformed (ActionEvent e) {
        if (e.getSource() == this.box) {
          this.className = this.box.getText().trim();
          this.filter = "";
          if (!classExists(className)) {
            // try to find the classname 
            if (className.indexOf('.') == -1) {
              if (!Character.isUpperCase(className.charAt(0))) {
                className = Character.toUpperCase(className.charAt(0)) + 
                className.substring(1);
              }
              if (!Character.isUpperCase(className.charAt(1)) &&
                 (className.charAt(0) == 'J')) {
                className = "J" + Character.toUpperCase(className.charAt(1)) + 
                className.substring(2);
              }
            }
            if (classExists("java.lang." + className)) 
              { className = "java.lang." + className; }
            else if (classExists("java.util." + className)) 
              { className = "java.util." + className; }
            else if (classExists("java.io." + className)) 
              { className = "java.io." + className; }
            else if (classExists("java.nio." + className)) 
              { className = "java.nio." + className; }
            else if (classExists("javax.swing." + className)) 
              { className = "javax.swing." + className; }
            else if (classExists("javax.swing.event." + className)) 
              { className = "javax.swing.event." + className; }
            else if (classExists("java.awt." + className)) 
              { className = "java.awt." + className; }
            else if (classExists("java.lang.reflect." + className)) 
              { className = "java.lang.reflect." + className; }
            this.box.setText(className);
          }
          this.setListData();
        }
      }
  
      public void setFilter() {
        String ss;
        ss = box.getText().trim();
        if (ss.lastIndexOf('.') == MethodPanel.this.className.length()) {
          this.filter = ss.substring(ss.lastIndexOf(".")+1);
          System.out.println("key! " + this.filter);
          this.box.setBackground(Color.orange);
        } else {
          this.box.setBackground(Color.white);
        }
        // apply the filter to the method names
        this.setListData();
      }

      public static void main(String[] args) throws Exception {
        MethodPanel p = new MethodPanel("javax.swing.JList");
        JFrame f = new JFrame("Java Constructors & Methods");
        f.add(p);
        f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        f.pack(); 
        f.setExtendedState(Frame.MAXIMIZED_BOTH);
        f.setVisible(true);
        p.list.requestFocusInWindow();
      }
    }
