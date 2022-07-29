// 1:9 pattern*
// 1:10 pattern*{*
// 1:11 pattern*{*action*
// 1:12 pattern*{*action*;*
// 1:12 pattern*{*command*
// 1:13 pattern*{*command*action*
// 1:14 pattern*{*command*action*;*
// 1:14 pattern*{*command*command*
// 1:14 pattern*{*commandset*
// 1:15 pattern*{*commandset*action*
// 1:16 pattern*{*commandset*action*;*
// 1:16 pattern*{*commandset*command*
// 1:16 pattern*{*commandset*
// 1:17 pattern*{*commandset*}*
// 1:17 command*
/* The token parse-stack was: command* */


 /* [ok] Sed syntax appears ok */
 /* ---------------------      */
 /* Java code generated by "sed.tojava.pss" */
 import java.io.*;
 import java.nio.file.*;
 import java.nio.charset.*;
 import java.util.regex.*;
 import java.util.*;   // contains stack

 public class Test {
   public StringBuffer patternSpace;
   public StringBuffer holdSpace;
   public StringBuffer line;         /* current line unmodified */
   public int linesRead;
   private boolean[] states;         /* pattern-seen state */
   private Scanner input;            /* what script will read */
   public Writer output;             /* where script will send output */
   private boolean eof;              /* end of file reached? */
   private boolean hasSubstituted;   /* a sub on this cycle? */
   private boolean lastLine;         /* last line of input (for $) */
   private boolean readNext;         /* read next line or not */
   private boolean autoPrint;        /* autoprint pattern space? */

   /** convenience: read stdin, write to stdout */
   public Test() {
     this(
       new Scanner(System.in), 
       new BufferedWriter(new OutputStreamWriter(System.out)));
   }

   /** convenience: read and write to strings */
   public Test(String in, StringWriter out) {
     this(new Scanner(in), out);
   }

   /** make a new machine with a character stream reader */
   public Test(Scanner scanner, Writer writer) {
     this.patternSpace = new StringBuffer(""); 
     this.holdSpace = new StringBuffer(""); 
     this.line = new StringBuffer(""); 
     this.linesRead = 0;
     this.input = scanner;
     this.output = writer;
     this.eof = false;
     this.hasSubstituted = false;
     this.readNext = true;
     this.autoPrint = true;
     // assume that a sed script has no more than 1K range tests! */
     this.states = new boolean[1000];
     for (int ii = 0; ii < 1000; ii++) { this.states[ii] = false; }
   }

   /** read one line from the input stream and update the machine. */
   public void readLine() {
     int iChar;
     if (this.eof) { System.exit(0); }
     // increment lines
     this.linesRead++;
     if (this.input.hasNext()) {
       this.line.setLength(0);
       this.line.append(this.input.nextLine());
       this.patternSpace.append(this.line);
     } 
     if (!this.input.hasNext()) { this.eof = true; }
   }

   /** command "x": swap the pattern-space with the hold-space */
   public void swap() {
     String s = new String(this.patternSpace);
     this.patternSpace.setLength(0);
     this.patternSpace.append(this.holdSpace.toString());
     this.holdSpace.setLength(0);
     this.holdSpace.append(s);
   }

   /** command "y/abc/xyz/": transliterate */
   public void transliterate(String target, String replacement) {
     // javacode for translit
     //String target      = "ab";
     //String replacement = "**";
     //char[] array = "abcde".toString().toCharArray();
     int ii = 0;
     char[] array = this.patternSpace.toString().toCharArray();
     for (ii = 0; ii < array.length; ii++) {
       int index = target.indexOf(array[ii]);
       if (index != -1) {
         array[ii] = replacement.charAt(index);
       }
     }
     this.patternSpace.setLength(0);
     this.patternSpace.append(array);
   }

   /** command "s///x": make substitutions on the pattern-space */
   public void substitute(
     String first, String second, String flags, String writeText) {
     // flags can be gip etc
     // gnu sed modifiers M,<num>,e,w filename may be tricky here.

     Process p;
     BufferedReader stdin;
     BufferedReader stderr;
     String ss = null;
     String temp = new String("");
     String old = new String(this.patternSpace);
     String opsys = System.getProperty("os.name").toLowerCase();
 
     // here replace 1 2 etc (gnu replace group syntax) with
     // $1 $2 etc (java syntax)
     //second = second.replaceAll("\\\\([0-9])","X$1");
     //System.out.println("sec = " + second);
     // also () gnu group syntax becomes () java group syntax
     // but this is already dealt with.

     // case insensitive: add "(?i)" at beginning
     if ((flags.indexOf('i') > -1) ||
         (flags.indexOf('I') > -1)) { first = "(?i)" + first; }

     // multiline matching, check!!
     if ((flags.indexOf('m') > -1) ||
         (flags.indexOf('M') > -1)) { first = "(?m)" + first; }

     // <num>- replace only nth match
     // todo

     // gnu sed considers a substitute has taken place even if the 
     // pattern space is unchanged! i.e. if matches first pattern.
     if (this.patternSpace.toString().matches(".*" + first + ".*")) {
       this.hasSubstituted = true;
     }

     // g- global, replace all.
     if (flags.indexOf('g') == -1) {
       temp = this.patternSpace.toString().replaceFirst(first, second);
     } else {
       temp = this.patternSpace.toString().replaceAll(first, second);
     }
     this.patternSpace.setLength(0);
     this.patternSpace.append(temp);
     try {
       if  (this.hasSubstituted) {
         // only print if substitution made, patternspace different ?
         if (flags.indexOf('p') != -1) {
           this.output.write(this.patternSpace.toString()+'\n');
         }
         // execute pattern space, gnu ext
         if (flags.indexOf('e') != -1) {
           this.output.write(this.execute(this.patternSpace.toString()));
           //System.out.print(this.execute(this.patternSpace.toString()));
         }
         // write pattern space to file, gnu extension, if sub occurred
         // The writeText parameter contains 'w' switch plus possible 
         // whitespace.
         if (writeText.length() > 0) {
           writeText = writeText.substring(1).trim();
           this.writeToFile(writeText);
         }
       }
     } catch (IOException e) {
       System.out.println(e.toString());
     }

   }

   /** execute command/pattspace for s///e or e <arg> or "e" */
   public String execute(String command) {
     Process p;
     BufferedReader stdin;
     BufferedReader stderr;
     String ss;
     StringBuffer output = new StringBuffer("");
     try {
       if (System.getProperty("os.name").toLowerCase().contains("win")) {
         p = Runtime.getRuntime().exec(new String[]{"cmd.exe", "/c", command});
       } else {
         p = Runtime.getRuntime().exec(new String[]{"bash", "-c", command});
       }
       stdin = new BufferedReader(new InputStreamReader(p.getInputStream()));
       stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
       while ((ss = stdin.readLine()) != null) { output.append(ss + '\n'); }  
       while ((ss = stderr.readLine()) != null) { output.append(ss + '\n'); } 
     } catch (IOException e) {
       System.out.println("sed exec 'e' failed: " + e);
     }
     return output.toString();
   }

   /** command "W": save 1st line of patternspace to filename */
   public void writeFirstToFile(String fileName) {
     try {
       File file = new File(fileName);
       Writer out = new BufferedWriter(new OutputStreamWriter(
          new FileOutputStream(file), "UTF8"));
       // get first line of ps
       out.append(this.patternSpace.toString().split("\\R",2)[0]);
       // yourString.split("\R", 2);
       out.flush(); out.close();
     } catch (Exception e) {
       System.out.println(e.getMessage());
     }
   }

   /** command "w": save the patternspace to filename */
   public void writeToFile(String fileName) {
     try {
       File file = new File(fileName);
       Writer out = new BufferedWriter(new OutputStreamWriter(
          new FileOutputStream(file), "UTF8"));
       out.append(this.patternSpace.toString());
       out.flush(); out.close();
     } catch (Exception e) {
       System.out.println(e.getMessage());
     }
   }

   /** handle an unsupported command (message + abort) */
   public void unsupported(String name) {
     String ss =
      "The " + name + "command has not yet been implemented\n" +
      "in this sed-to-java translator. Branching commands are hard in\n" +
      "in a language that doesn't have 'goto'. Your script will not \n" + 
      "execute properly. Exiting now... \n";
      System.out.println(ss); System.exit(0);
   }

   /** run the script with reader and writer. This allows the code to
       be used from within another java program, and not just as a 
       stream filter. */
   public void run() throws IOException {
     String temp = "";    
     while (!this.eof) {
       this.hasSubstituted = false;
       this.patternSpace.setLength(0);
       // some sed commands restart without reading a line...
       // hence the use of a flag.
       if (this.readNext) { this.readLine(); }
       this.readNext = true;

       if (this.line.toString().matches("^.*Instead.*$")) {
         this.swap();  /* x */
         this.output.write(this.patternSpace.toString()+'\n'); /* 'p' */
         this.swap();  /* x */
       }
       if (this.autoPrint) { 
         this.output.write(this.patternSpace.toString() + '\n');
         this.output.flush();
       }
     } 
   } 

   /* run the script as a stream filter. remove this main method
      to embed the script in another java program */
   public static void main(String[] args) throws Exception { 

     // read and write to stdin/stdout
     Test mm = new Test();
     // new Scanner(System.in), 
     // new BufferedWriter(new OutputStreamWriter(System.out)));
     mm.run();

     // convert sedstring to java and write to string.
     // Test mm = new Test("/class/s/ass/ASS/g", new StringWriter());
     // then use mm.output.toString() to get the result (java source code)
   }
 }