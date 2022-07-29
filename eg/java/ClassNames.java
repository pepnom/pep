   import java.io.*;
   import java.util.*;
   public class ClassNames {
     List classNames;
     File apiDocFolder;
     public ClassNames() {
       this.classNames = new ArrayList();
     }
     public void list(File dir) {
       FileFilter filter = new FileFilter(){
         public boolean accept(File file) {
           if (file.getAbsolutePath().indexOf("class-use") > 0) 
             return false;
           if (file.getAbsolutePath().indexOf("package-") > 0) 
             return false;
           if (file.getAbsolutePath().indexOf("doc-files") > 0) 
             return false;
           return (file.getAbsolutePath().endsWith(".html") || 
                    file.isDirectory());
         }
       };
       File[] files = dir.listFiles(filter);
       if (files != null) {
         for (File f : files) {
           if (f.isDirectory()) { this.list(f); }
           else {
             System.out.println(
               f.getPath()
                .replaceAll("/usr/lib/jvm/java-6-sun/docs/api/","")
                .replaceAll("[.]html","")
                .replace('/','.'));
           }
         }
       }
     }
     public static void main(String[] args) throws Exception {
       ClassNames cn = new ClassNames();
       cn.list(new File("/usr/lib/jvm/java-6-sun/docs/api/java"));
       cn.list(new File("/usr/lib/jvm/java-6-sun/docs/api/javax"));
     }
   }
