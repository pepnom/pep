/*

This file is a java class that represents a virtual machine for 
parsing some context free languages. This class forms part of the 
'pp' system at bumble.sourceforge.net/books/pars/

SEE ALSO 


  books/pars/compile.java.pss
     a pp script that compiles scripts into java
  books/pars/compile.tcl.pss
     a similar script (untested) that does the same for tcl
  books/pars/gh.c
     The main source code for the script interpreter.

HISTORY

 
 24 Feb 2020

   Looking at this again after a break. I found a bug in 
   compile.java.pss which was not compiling negated tests properly.
   I think the same bug was in compile.java and the other compilers
   like compile.tcl.pss and compile.javascript.pss 
   After fixing the bug I successfully compiled the script eg/prices.pss
   into java using 
     >> pp -f compile.java.pss eg/prices.pss > object.java/Script.java
     >> cd object.java; javac Script.java

 27 Sept 2019

   Starting to revise this to work with compile.java.pss
   code compiles with javac Machine.java

   Code to convert into to unicode character 

     Character.toChars(int); (return char[] array)
     Character.toString(int); (java 11, june 2019)

 19 august 2019

   Revisiting this in order to make it suitable as a target for 
   a script like compile.java.pss

 Sept 2010, 

   Creating the machine. This class is supposed to be a machine capable of
   parsing a variety of text formats
 
*/
 
 import java.io.*;
 import java.util.regex.*;

 public class Machine {

   // using int instead of char so that all unicode code points are
   // available instead of just utf16. (emojis cant fit into utf16)

   /** a counter for counting */
   private int accumulator;

   /** the next char on the input stream */
   private int peep;

   private int charsRead;
   private int linesRead;

   // make public for convenience.
   public StringBuffer workspace;

   private Stack stack;

   /** the maximum length of the tape */
   private static int LENGTH = 100;

   /** the tape where parse "attributes" are stored */
   private StringBuffer[] tape;

   /** the tape where tape "marks" are stored */
   private StringBuffer[] marks;

   /** pointer to the current tape element */
   private int tapePointer;

   /** the text input stream */
   private Reader input; 

   /** whether the end of the file has been reached **/
   private boolean eof;    

   /** the result of the last test instruction */
   private boolean flag;

   /** the character which 'escapes' with until. I am using a 
       a StringBuffer here to avoid unicode codepoint problems
       for emojis etc that cant fit into utf16 */
   private StringBuffer escape;
   
   /** parse token delimiter character for push/pop - default is '*' */
   private StringBuffer delimiter;
   
   /** make a new machine with a character stream reader */
   public Machine(Reader reader) {
     this.input = reader;
     this.eof = false;
     this.flag = false;
     this.charsRead = 0; 
     this.linesRead = 1; 
     this.escape = new StringBuffer("\\");
     this.delimiter = new StringBuffer("*");
     this.accumulator = 0;
     this.workspace = new StringBuffer("");
     this.stack = new Stack("");
     this.tapePointer = 0;
     this.tape = new StringBuffer[LENGTH];
     this.marks = new StringBuffer[LENGTH];

     for (int ii = 0; ii < this.tape.length; ii++) {
       this.tape[ii] = new StringBuffer(); 
       this.marks[ii] = new StringBuffer(); 
     }

     try
     { this.peep = this.input.read(); } 
     catch (java.io.IOException ex) {
       System.out.println("read error");
       System.exit(-1);
     }
   }

    /*

    // read the inputstream until the workspace ends with the 
    // given text (but not the escaped text).
    this.until = function(text) {
      if (this.peep == null) return;          
      this.read();
      while (true) {
        if (this.workspace.endsWith(text) && 
           !this.workspace.endsWith(this.escape + text)) break;
        if (this.peep == null) break;
        this.read();
      }
    }

    // text is [a-c] or [abc] or [:space:] etc
    // need to translate classes like [:punct:] into 
    // javascript regex classes, eg: \W \w
    this.whilePeep = function(text) {
      text = classToRegex(text);
      var re = new RegExp(text);
      while (re.test(this.peep)) {
        this.read();
      }
    }

    this.whilenotPeep = function(text) {
      text = classToRegex(text);
      var re = new RegExp(text);
      while (!re.test(this.peep)) {
        this.read();
      }
    }

    // write workspace to file sav.pp but this is not possible
    // in some javascript environments 
    this.writeToFile = function() {}

   */

   public void setInput(Reader reader) {
     this.input = reader;
   }

   /** just exit */
   public void quit() {
     System.exit(0);
   }

   /** exit. I do not use the bail command in scripts. Its 
       original intention was to provide an error code when a 
       script exited badly. */
   public void bail() {
     System.exit(1);
   }

   /** set the flag if the peep contains the end of file marker. 
       This method seems unnecessary and unused. */
   public void testEof() { this.flag = this.eof; }

   /** set the flag if the workspace equals the text */
   public Boolean testEquals(String sText) {
     return (this.workspace.toString().equals(sText));
   }
    
   /** convert [:space:] type regex classes to a normal regex. This
       looks incomplete. Also java has a wide range of unicode character
       classes. */
   public String classToRegex(String text) {
     //todo fix
     if (text.equals("[:space:]")) return "\\s";
     if (text.equals("[:digit:]")) return "\\d";
     if (text.equals("[:alnum:]")) return "(\\d|\\l)";
     if (text.equals("[:xdigit:]")) return "[0-9a-hA-H]";
     return "";
   }

   /** test if the first workspace character is in the class.
       When translating with compile.java.pss we dont actually 
       use the Machine flag, but I will set it anyway just in
       case. */
   public boolean testClass(String text) {
     this.flag = false;
     if (this.workspace.length() == 0) return false;
     if (text.startsWith("[:")) {
       text = this.classToRegex(text);
     }
     //this.flag = Pattern.matches("a*b", "aaaaab");
     this.flag = Pattern.matches("^" + text + "+$", 
       this.workspace.toString());
     return this.flag;
   }

   /** set the flag if the workspace ends with the text */
   public void testEndsWith(String sText) {
     this.flag = false;
     if (this.workspace.toString().endsWith(sText))
       this.flag = true;
   }

   /** set the flag if the workspace ends with the text */
   public void testBeginsWith(String sText) {
     this.flag = false;
     if (this.workspace.toString().startsWith(sText))
       this.flag = true;
   }

   /** set the flag if the workspace matches the current tape item */
   public void testTape() {
     this.flag = false;
     if (workspace.toString().equals(tape[this.tapePointer].toString()))
        this.flag = true;
   }

   /** set the flag if the workspace matches a term in a dictionary
       This is not currently used in the c version  */
   public void testDictionary(String sFileName) {
   }

   /** appends the number of characters read to the workspace */
   public void chars() {
     this.workspace.append(this.charsRead);
   }

   /** appends the number of lines read to the workspace */
   public void lines() {
     this.workspace.append(this.linesRead);
   }

   /** appends the accumulator to the workspace */
   public void count() {
     this.workspace.append(this.accumulator);
   }

   /** sets the acc to zero */
   public void zero() {
     this.accumulator = 0;
   }

   /** increments the accumulator */
   public void incc() {
     this.accumulator++;
   }

   /** decrements the accumulator */
   public void decc() {
     this.accumulator--;
   }

   // the flag register is not used when translating a script
   // into java with the compile.java.pss script.
   public boolean flag() {
     return this.flag;
   }

   public boolean eof() {
     return this.eof;
   }

   public String getWorkSpace() {
     return this.workspace.toString();
   }

   public String workspace() {
     return this.workspace.toString();
   }

   public int peep() {
     return this.peep;
   }

   public int getPeepCode() {
     return this.peep;
   }

   /**  */
   public String visible(String text) {
     return text
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t");
   }

   /** get the peep character in a visible format */
   public String getVisiblePeep() {
     if (this.peep == '\n') { return "\\n"; } 
     if (this.peep == '\r') { return "\\r"; } 
     if (this.peep == '\t') { return "\\t"; } 
     if (this.peep == ' ') { return "\\s"; } 
     if (this.peep == -1) { return "-E"; } 
     return (new Character((char)this.peep)).toString();
   }

   /** set the escape character used by the machine */
   public void setEscape(String s) {
     this.escape.setLength(0);
     this.escape.append(s);
   }

   /** remove the escape char, eg: \" -> " and \\ -> \ */
   public void unescapeChar(char c) {
     //todo fix
     String s = this.workspace.toString();
     String esc = this.escape.toString();
     if (esc.equals("\\")) esc = "\\\\";
     s = s.replaceAll("" + esc + "(.)", "$1");
     this.workspace.setLength(0);
     this.workspace.append(s);
   }

   /** remove the escape character (usually '\') from in front 
       of each char c */
   public void escapeChar(String text) {
     char c = text.charAt(0);
     //todo 
   }

   /** change the stack delimiter used in pop and push */
   public void delim(String text) {
     this.delimiter.setCharAt(0, text.charAt(0));
   }

   // Workspace functions

   /** print the workspace to standard out */
   public void print() {
     System.out.print(this.workspace); 
   }

   public void clear() {
     this.workspace.setLength(0);     
   }

   /** clip one character from the end of the workspace */
   public void clip() {
     if (this.workspace.length() == 0) return;
     this.workspace.delete(this.workspace.length() - 1, 
       this.workspace.length());
   }

   /** clip one character from the beginning of the workspace */
   public void clop() {
     if (this.workspace.length() == 0) return;
     this.workspace.delete(0, 1);
   }

   /** replace text in workspace */
   public void replace(String oldtext, String newtext) {
     if (this.workspace.length() == 0) return;
     String s = this.workspace.toString().replace(oldtext, newtext);
     this.workspace.setLength(0);
     this.workspace.append(s);
   }

   public void add(String suffix) {
     this.workspace.append(suffix);     
   }

   /** pop the first token from the stack into the workspace */
   public Boolean pop() {
     if (this.stack.isEmpty()) return false;
     this.workspace.insert(0, this.stack.pop());     
     if (this.tapePointer > 0) this.tapePointer--;
     return true;
   }

   /** pop all tokens off the stack. This is the "unstack" command
       on the virtual machine. */
   public void popall() {
     while (this.pop());
   }

   /** push the first token from the workspace to the stack */
   public Boolean push() {
     String sItem;
     // dont increment the tape pointer on an empty push
     if (this.workspace.length() == 0) return false;
     int iFirstStar = this.workspace.indexOf("*");
     if (iFirstStar != -1) {
       sItem = this.workspace.toString().substring(0, iFirstStar + 1);
       this.workspace.delete(0, iFirstStar + 1);
     }
     else {
       sItem = this.workspace.toString();
       this.workspace.setLength(0);
     }
     this.stack.push(sItem);     
     this.increment(); return true;
   }

   /** push all tokens on the stack. This is the "stack" command 
       on the virtual machine. */
   public void pushall() {
     while (this.push());
   }

   /** mark the current tape cell */
   public void mark(String text) {
     this.marks[this.tapePointer].setLength(0);
     this.marks[this.tapePointer].append(text);
   }

   /** go to the marked tape cell */
   public void go(String text) {
     for (var ii = 0; ii < this.marks.length; ii++) {
       if (this.marks[ii].toString().equals(text)) {
         this.tapePointer = ii;
       }
     }
   }

   public Stack getStack() {
     return this.stack; 
   }

   public String[] stackArray() {
     return this.stack.toArray(); 
   }

   // Tape functions
   // ----

   public int getPointer() {
     return this.tapePointer;
   }

   public void swap() {
     String s = new String(this.workspace);
     this.workspace.setLength(0);
     this.workspace.append(this.tape[this.tapePointer].toString());
     this.tape[this.tapePointer].setLength(0);
     this.tape[this.tapePointer].append(s);
   }

   /** put the workspace in the current tape cell, overwrites */
   public void put() {
     this.tape[this.tapePointer].setLength(0);
     this.tape[this.tapePointer].append(this.workspace);
   }

   /** append the current cell to the workspace */ 
   public void get() {
     this.workspace.append(this.tape[this.tapePointer]);
   }

   /** increment the tape pointer by one */
   public void increment() {
     this.tapePointer++;
     if (this.tapePointer > Machine.LENGTH - 1) {
       System.out.println("Tape length exceeded [" + LENGTH + "]");
       System.exit(1);
     }
   }
   
   /** decrement the tape pointer by one */
   public void decrement() {
     if (this.tapePointer > 0) this.tapePointer--;
   }
   
   /** No operation, do nothing. When we compile a script into java 
       we can eliminate this instruction, but it seems advisable to
       be able to retain it. */
   public void nop() { return; }
   
   public void showTape(int length) {
      int ii;
      StringBuffer result = new StringBuffer("");
      StringBuffer cell = new StringBuffer("");
      for (ii = 0; ii < length; ii++) {
        cell.setLength(0); 
        cell.append(this.tape[ii]);
        if (ii == this.tapePointer) {
          result.append(ii + "> [" + cell + "]\n");
        } else {
          result.append(ii + "  [" + cell + "]\n");
        }
      }
      System.out.println(result); 
    }

   /** print state information */
   public void state() {
     StringBuffer vpeep = new StringBuffer("");
     // display the 'peep' as a unicode codepoint or "EOF" if
     // end of stream (-1 is not a codepoint)
     // toChars can return a char[] which is the codepoint in unicode
     if (this.peep == -1) { vpeep.append("EOF"); }
     else { vpeep.append(visible(new String(Character.toChars(this.peep)))); }

     StringBuffer result = new StringBuffer( 
       "\n---------- Machine State -----------\n" +
       "Stack[" + visible(this.stack.toString()) + "] " +
       "Work[" + visible(this.workspace.toString()) + "] " +
       "Peep[" + vpeep + "] \n" +
       "Acc:" + this.accumulator + " Flag:N/A " +
       "Esc:" + this.escape + " Delim:" + this.delimiter + " " +
       "Chars:" + this.charsRead + " " + 
       "Lines:" + this.linesRead + "\n" +
       "---------- Tape ---------------\n");
     System.out.println(result);
     this.showTape(10);  
   }

   /** A test method to print out the whole input stream */
   public void readAll() {
     int r;
     try {
       while ((r = this.input.read()) != -1) {
         char ch = (char) r;
         System.out.println("char:" + ch);
       }
     }
     catch (IOException ex) { }
   }

   /** read one character from the input stream and 
       update the machine. */
   public void read() {
     int iChar;
     try {
       if (this.eof) { System.exit(0); }
       this.charsRead++;
       // increment lines
       if (this.peep+"" == "\n") { this.linesRead++; }
       this.workspace.append(Character.toChars(this.peep));
       this.peep = this.input.read(); 
       if (this.peep == -1) { this.eof = true; }
     }
     catch (IOException ex) {
       System.out.println("Error reading input stream" + ex);
       System.exit(-1);
     }
   }

   /** reads the input stream until the workspace end with text */
   public void until(String sSuffix) {
     while (true) {
       if (this.eof) return;
       if (this.workspace.toString().endsWith(sSuffix) &&
          !this.workspace.toString().endsWith(this.escape.toString() + sSuffix))
         return;
       this.read();
     }
   }

   /** show legal character classes. This method is informative only */
   public String getCharacterClasses() {
     return "Not implemented"; 
   }

   //todo write whilenotPeep

   /** reads the input stream until the workspace end with text */
   public void whilePeep(String sClass) {
     //todo fix
     if (sClass.equals("[:digit:]")) {
       while (Character.isDigit(this.peep)) {
         this.read();
       }
       return;
     }

     if (sClass.equals("[:alnum:]")) {
       while (Character.isLetterOrDigit(this.peep)) {
         this.read();
       }
       return;
     }

     if (sClass.equals("[:alpha:]")) {
       while (Character.isLetter(this.peep)) {
         this.read();
       }
       return;
     }

     if (sClass.equals("[:space:]")) {
       while (Character.isWhitespace(this.peep)) {
         this.read();
       }
       return;
     }

     int iType = -1;
     int iPeepType;

     iPeepType = Character.getType((char)this.peep);
     //System.out.println("type=" + iPeepType);
     //todo check this code
     while (iPeepType == iType) {
       this.read();
       iPeepType = Character.getType((char)this.peep);
     }

   }


   // some test code could go here, but we normally test with
   // the bash functions in helpers.gh.sh
   public static void main(String[] args) throws Exception
   {
     Machine mm = new Machine(new InputStreamReader(System.in));
     mm.readAll();
   }
 }
