   import java.util.jar.*;
   import java.util.zip.*;
   import java.io.*;
   import java.util.Enumeration;
   import javax.swing.*;
   import java.awt.*;
   public class ListRuntimeJar extends JPanel {
     private JList list;
     private String className;
     public ListRuntimeJar(String className) {
       super();
       this.className = className;
       this.list = new JList(new DefaultListModel());
       this.list.setFont(new Font(Font.SERIF, Font.PLAIN, 22));
       try {
         JarFile jar = new JarFile(
           new File(System.getProperty("java.home") + "/lib/rt.jar"));
         Enumeration<? extends JarEntry> enumeration = jar.entries();
         while (enumeration.hasMoreElements()) {
           ZipEntry zipEntry = enumeration.nextElement();
           if (zipEntry.getName().endsWith(className + ".class")) {
             ((DefaultListModel)this.list.getModel())
               .addElement(zipEntry.getName());
           }
         }
       } catch (IOException e) {}
       this.add(new JScrollPane(this.list));
     }
     public static void main(String[] args) throws Exception {
       SwingUtilities.invokeLater( new Runnable() {
        public void run() {
           ListRuntimeJar l = new ListRuntimeJar("ZipEntry");
           JOptionPane.showMessageDialog(null, new JScrollPane(l));
        }
      });
     }
   }
