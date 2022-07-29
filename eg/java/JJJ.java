   import java.lang.reflect.*;
   public class JJJ 
   {
     public static void main(String args[]) throws Exception
     {
       Class c = Class.forName("java.lang.StringBuffer");
       Constructor cc[] = c.getDeclaredConstructors();
       Method m[] = c.getMethods();
       for (int i = 0; i < cc.length; i++)
         System.out.println(cc[i]);
       for (int i = 0; i < m.length; i++)
         System.out.println(m[i]);
     }
   }
