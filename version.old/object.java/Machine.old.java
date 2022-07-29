/*
 June 2010
*/
 
 import java.io.*;

 public class Machine
 {
   private int peep;

   private StringBuffer workspace;

   private Stack stack;

   /** the tape where attributes are stored */
   private StringBuffer[100] tape;

   /** pointer to the current tape element */
   private int pointer;

   /** the text input stream */
   private Reader input; 

   /** whether the end of the file has been reached **/
   private boolean eof;    

   /** the result of the last test instruction */
   private boolean flag;
   
   public Machine(InputStream in)
   {
     Reader reader = new InputStreamReader(in);
     this.input = new BufferedReader(reader);
     this.eof = false;
     this.flag = false;
     this.workspace = new StringBuffer("");
     this.stack = new Stack("");
     this.pointer = 0;
     this.tape = new StringBuffer[100];
     for (int ii = 0; ii < this.tape.length; ii++)
     {
       this.tape[ii] = new StringBuffer(); 
     }

     try
       { this.peep = this.input.read(); } 
     catch (java.io.IOException ex)
     {
       System.out.println("read error");
       System.exit(-1);
     }
   }

   public String getWorkSpace()
   {
     return this.workspace.toString();
   }

   public Character getPeep()
   {
     return new Character((char)this.peep);
   }

   public int getPeepCode()
   {
     return this.peep;
   }

   /** get the peep character in a visible format */
   public String getVisiblePeep()
   {
     if (this.peep == '\n') { return "\\n"; } 
     if (this.peep == '\r') { return "\\r"; } 
     if (this.peep == '\t') { return "\\t"; } 
     if (this.peep == -1) { return "-E"; } 
     return (new Character((char)this.peep)).toString();
   }

   public void clear()
   {
     this.workspace.setLength(0);     
   }

   public void add(String suffix)
   {
     this.workspace.append(suffix);     
   }

   public void pop()
   {
     //System.out.println("pop " + this.stack.pop());
     this.workspace.insert(0, this.stack.pop());     
     //todo: tapepointer
   }

   public void push()
   {
     
     String sItem;
     int iFirstStar = this.workspace.indexOf("*");
     if (iFirstStar != -1)
     {
       sItem = this.workspace.toString().substring(0, iFirstStar + 1);
       this.workspace.delete(0, iFirstStar + 1);
     }
     else
     {
       sItem = this.workspace.toString();
       this.workspace.setLength(0); }
     this.stack.push(sItem);     
   }

   public Stack getStack()
   {
     return this.stack; 
   }

   public String[] stackArray()
   {
     return this.stack.toArray(); 
   }

   public String printMachine()
   {
     String sReturn = 
       "I:" + this.getPeep() + "W:" ;
     return sReturn;
   }

   /** A test method to print out the whole input stream */
   public void readAll()
   {
     int r;
     try
     {
       while ((r = this.input.read()) != -1)
       {
         char ch = (char) r;
         System.out.println("Do something with " + ch);
       }
     }
     catch (IOException ex) { }
   }

   /** read one character from the input stream and 
       update the machine. */
   public void read()
   {
     int iChar;
     try
     {
       if (this.eof) { System.exit(0); }
       this.workspace.append((char)this.peep);
       this.peep = this.input.read(); 
       if (this.peep == -1) { this.eof = true; }
     }
     catch (IOException ex) 
     {
       System.out.println("Error reading input stream" + ex);
       System.exit(-1);
     }
   }

   /** reads the input stream until the workspace end with text */
   public void until(String sSuffix)
   {
     this.read();
     while (!this.workspace.toString().endsWith(sSuffix))
       { this.read(); }
   }

   /** reads the input stream until the workspace end with text */
   public void whilePeep(String sClass)
   {

     if (sClass.equals("[1]"))
     {
       while (Character.isDigit(this.peep))
       {
         this.read();
       }
       return;
     }

     if (sClass.equals("[a1]"))
     {
       while (Character.isLetterOrDigit(this.peep))
       {
         this.read();
       }
       return;
     }

     if (sClass.equals("[a]"))
     {
       while (Character.isLetter(this.peep))
       {
         this.read();
       }
       return;
     }

     if (sClass.equals("[ ]"))
     {
       while (Character.isWhitespace(this.peep))
       {
         this.read();
       }
       return;
     }

     int iType = -1;
     System.out.println("type=" + iType);

     int iPeepType;

     iPeepType = Character.getType((char)this.peep);
     while (iPeepType == iType)
     {
       this.read();
       iPeepType = Character.getType((char)this.peep);
     }

   }

   //while
   //clip, clop

   public static void main(String[] args) 
   {
     Machine mm = new Machine(System.in);
     mm.read();
   }
 }
