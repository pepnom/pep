/**
 June 2010
 This class is a changeable string which can viewed as 
 a stack or as a list.
*/
 
 import javax.swing.*;
 import javax.swing.event.*;

 public class Stack implements ListModel
 {
   protected StringBuffer data;
   protected String delimiter;

   public Stack(String sData)
   {
     this.data = new StringBuffer(sData);
     this.delimiter = "*";
   }

   public String data()
   {
     return this.data.toString();
   }

   public String toString()
   {
     return this.data.toString();
   }

   public boolean isEmpty()
   {
     if (this.data.length() == 0) return true;
     else return false;
   }

   public String pop()
   {
     int i = this.data.toString().lastIndexOf(
       this.delimiter, this.data.length() - 2);
     String item = this.data.substring(i + 1);
     this.data.setLength(i + 1);

     //System.out.println("index " + i);
     //System.out.println("return " + item);
     //System.out.println("data " + this.data);
     return item;
   }

   public void push(String sSuffix)
   {
     this.data.append(sSuffix); 
   }

   public String[] toArray()
   {
     String[] rr = this.data.toString().split("\\" + this.delimiter);
     for (int ii = 0; ii < rr.length; ii++)
       rr[ii] = rr[ii] + this.delimiter;
     return rr;
   }

   public void addListDataListener(ListDataListener l) {}
   public void removeListDataListener(ListDataListener l) {}

   public int getSize()
   {
     int count = 0;
     int i = 0;
     i = this.data.toString().indexOf(this.delimiter, 0);
     while (i != -1)
     {
       count++;
       i = this.data.toString().indexOf(this.delimiter, i + 1);
     }
     return count; 
   }

   public Object getElementAt(int index)
   {
     int iChar = 0;
     int iEnd = 0;
     String sItem = "";
     for (int ii = 0; ii < index; ii++)
     {
       iChar = this.data.toString().indexOf(this.delimiter, iChar + 1);
       if (iChar == -1) return "";
     }

     iEnd = this.data.toString().indexOf(this.delimiter, iChar + 1);
     if (iEnd == -1) return "";
     if (index > 0) { iChar++; }
     sItem = this.data.substring(iChar, iEnd + 1);
     //System.out.println("item=" + sItem);
     return ""; 
   }

   public static void main(String[] args) 
   {
     Stack s = new Stack("word*colon*list*");
     s.push("new*");
     s.push("*");
     s.push("add*");
     System.out.println("s=" + s.data());
     System.out.println("aa=" + 
       java.util.Arrays.toString(s.toArray()));
     s.getSize();
     s.getElementAt(1);
   }
 }
