

 /* Java code generated by "translate.java.pss" */
 import java.io.*;
 import java.util.regex.*;
 import java.util.*;   // contains stack

 public class exptolisp {
   // using int instead of char so that all unicode code points are
   // available instead of just utf16. (emojis cant fit into utf16)
   private int accumulator;         // counter for anything
   private int peep;                // next char in input stream
   private int charsRead;           // No. of chars read so far
   private int linesRead;           // No. of lines read so far
   public StringBuffer workspace;    // text accumulator
   private Stack<String> stack;      // parse token stack
   private static int LENGTH = 100;  // tape maximum length
   private StringBuffer[] tape;      // array of token attributes 
   private StringBuffer[] marks;     // tape marks
   private int tapePointer;          // pointer to current cell
   private Reader input;             // text input stream
   private boolean eof;              // end of stream reached?
   private boolean flag;             // not used here
   private StringBuffer escape;    // char used to "escape" others "\"
   private StringBuffer delimiter; // push/pop delimiter (default is "*")
   
   /** make a new machine with a character stream reader */
   public exptolisp(Reader reader) {
     this.input = reader;
     this.eof = false;
     this.flag = false;
     this.charsRead = 0; 
     this.linesRead = 1; 
     this.escape = new StringBuffer("\\");
     this.delimiter = new StringBuffer("*");
     this.accumulator = 0;
     this.workspace = new StringBuffer("");
     this.stack = new Stack<String>();
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

   /** read one character from the input stream and 
       update the machine. */
   public void read() {
     int iChar;
     try {
       if (this.eof) { System.exit(0); }
       this.charsRead++;
       // increment lines
       if ((char)this.peep == '\n') { this.linesRead++; }
       this.workspace.append(Character.toChars(this.peep));
       this.peep = this.input.read(); 
       if (this.peep == -1) { this.eof = true; }
     }
     catch (IOException ex) {
       System.out.println("Error reading input stream" + ex);
       System.exit(-1);
     }
   }

   /** increment tape pointer by one */
   public void increment() {
     this.tapePointer++;
     if (this.tapePointer > exptolisp.LENGTH - 1) {
       System.out.println("Tape length exceeded [" + LENGTH + "]");
       System.exit(1);
     }
   }
   
   /** remove escape character  */
   public void unescapeChar(char c) {
     if (workspace.length() > 0) {
       String s = this.workspace.toString().replace("\\"+c, c+"");
       this.workspace.setLength(0); workspace.append(s);
     }
   }

   /** add escape character  */
   public void escapeChar(char c) {
     if (workspace.length() > 0) {
       String s = this.workspace.toString().replace(c+"", "\\"+c);
       workspace.setLength(0); workspace.append(s);
     }
   }

   /** whether trailing escapes \\ are even or odd */
   // untested code. check! eg try: add "x \\"; print; etc
   public boolean isEscaped(String ss, String sSuffix) {
     int count = 0; 
     if (ss.length() < 2) return false;
     if (ss.length() <= sSuffix.length()) return false;
     if (ss.indexOf(this.escape.toString().charAt(0)) == -1) 
       { return false; }

     int pos = ss.length()-sSuffix.length();
     while ((pos > -1) && (ss.charAt(pos) == this.escape.toString().charAt(0))) {
       count++; pos--;
     }
     if (count % 2 == 0) return false;
     return true;
   }

   /* a helper to see how many trailing \\ escape chars */
   private int countEscaped(String sSuffix) {
     String s = "";
     int count = 0;
     int index = this.workspace.toString().lastIndexOf(sSuffix);
     // remove suffix if it exists
     if (index > 0) {
       s = this.workspace.toString().substring(0, index);
     }
     while (s.endsWith(this.escape.toString())) {
       count++;
       s = s.substring(0, s.lastIndexOf(this.escape.toString()));
     }
     return count;
   }

   /** reads the input stream until the workspace end with text */
   // can test this with
   public void until(String sSuffix) {
     // read at least one character
     if (this.eof) return; 
     this.read();
     while (true) {
       if (this.eof) return;
       if (this.workspace.toString().endsWith(sSuffix)) {
         if (this.countEscaped(sSuffix) % 2 == 0) { return; }
       }
       this.read();
     }
   }

   /** pop the first token from the stack into the workspace */
   public Boolean pop() {
     if (this.stack.isEmpty()) return false;
     this.workspace.insert(0, this.stack.pop());     
     if (this.tapePointer > 0) this.tapePointer--;
     return true;
   }

   /** push the first token from the workspace to the stack */
   public Boolean push() {
     String sItem;
     // dont increment the tape pointer on an empty push
     if (this.workspace.length() == 0) return false;
     // need to get this from this.delim not "*"
     int iFirstStar = 
       this.workspace.indexOf(this.delimiter.toString());
     if (iFirstStar != -1) {
       sItem = this.workspace.toString().substring(0, iFirstStar + 1);
       this.workspace.delete(0, iFirstStar + 1);
     }
     else {
       sItem = this.workspace.toString();
       this.workspace.setLength(0);
     }
     this.stack.push(sItem);     
     this.increment(); 
     return true;
   }

   /** swap current tape cell with the workspace */
   public void swap() {
     String s = new String(this.workspace);
     this.workspace.setLength(0);
     this.workspace.append(this.tape[this.tapePointer].toString());
     this.tape[this.tapePointer].setLength(0);
     this.tape[this.tapePointer].append(s);
   }

   /** save the workspace to file "sav.pp" */
   public void writeToFile() {
     try {
       File file = new File("sav.pp");
       Writer out = new BufferedWriter(new OutputStreamWriter(
          new FileOutputStream(file), "UTF8"));
       out.append(this.workspace.toString());
       out.flush(); out.close();
     } catch (Exception e) { 
       System.out.println(e.getMessage());
     }
   }

   /** parse/check/compile the input */
   public void parse(InputStreamReader input) {
     //this is where the actual parsing/compiling code should go 
     //but this means that all generated code must use
     //"this." not "mm."
   }

  public static void main(String[] args) throws Exception { 
    String temp = "";    
    exptolisp mm = new exptolisp(new InputStreamReader(System.in)); 

    script: 
    while (!mm.eof) {
      lex: { 
        mm.read(); /* read */
        if (mm.workspace.toString().equals("+") || mm.workspace.toString().equals("-")) {
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("opadd*"); /* add */
          mm.push();
        }
        if (mm.workspace.toString().equals("*") || mm.workspace.toString().equals("/")) {
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("opmul*"); /* add */
          mm.push();
        }
        if (mm.workspace.toString().equals("(") || mm.workspace.toString().equals(")")) {
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.append("*"); /* add */
          mm.push();
        }
        if (mm.workspace.toString().matches("^[0-9]+$")) {
          /* while */ 
          while (Character.toString((char)mm.peep).matches("^[0-9]+$")) { if (mm.eof) { break; } mm.read(); }
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("number*"); /* add */
          mm.push();
        }
        if (mm.workspace.toString().matches("^[a-z]+$")) {
          /* while */ 
          while (Character.toString((char)mm.peep).matches("^[a-z]+$")) { if (mm.eof) { break; } mm.read(); }
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("variable*"); /* add */
          mm.push();
        }
        if (mm.workspace.toString().matches("^\\p{Space}+$")) {
          mm.workspace.setLength(0);            /* clear */
        }
        // a trick to catch bad characters. 
        // better would be a !"text" test
        if (mm.workspace.toString().equals("")) {
          break lex;
        }
        mm.workspace.append(" << incorrect character (at character "); /* add */
        mm.workspace.append(mm.charsRead); /* chars */
        mm.workspace.append(" of input). \n"); /* add */
        System.out.print(mm.workspace); /* print */
        break script;
      }
      parse: 
      while (true) { 
        // The parse/compile/translate/transform phase involves 
        // recognising series of tokens on the stack and "reducing" them
        // according to the required bnf grammar rules.
        mm.pop();
        // resolve numbers to expressions to simplify grammar rules
        // add a preceding space to numbers and variables.
        if (mm.workspace.toString().equals("number*") || mm.workspace.toString().equals("variable*")) {
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append(" "); /* add */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("exp*"); /* add */
          mm.push();
          continue parse;
        }
        //-----------------
        // 3 tokens
        mm.pop();
        mm.pop();
        // we dont need any look ahead here because * and / have 
        // precedence.
        if (mm.workspace.toString().equals("exp*opmul*exp*")) {
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append(" ("); /* add */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.increment();                 /* ++ */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.workspace.append(")"); /* add */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("exp*"); /* add */
          mm.push();
          continue parse;
        }
        if (mm.workspace.toString().equals("(*exp*)*")) {
          mm.workspace.setLength(0);            /* clear */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("exp*"); /* add */
          mm.push();
          continue parse;
        }
        if (mm.eof) {
          if (mm.workspace.toString().equals("exp*opadd*exp*")) {
            mm.workspace.setLength(0);            /* clear */
            mm.workspace.append(" ("); /* add */
            mm.increment();                 /* ++ */
            mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
            if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
            mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
            mm.increment();                 /* ++ */
            mm.increment();                 /* ++ */
            mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
            mm.workspace.append(")"); /* add */
            if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
            if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
            mm.tape[mm.tapePointer].setLength(0); /* put */
            mm.tape[mm.tapePointer].append(mm.workspace); 
            mm.workspace.setLength(0);            /* clear */
            mm.workspace.append("exp*"); /* add */
            mm.push();
            continue parse;
          }
        }
        //-----------------
        // 4 tokens
        mm.pop();
        if (mm.workspace.toString().equals("exp*opadd*exp*opadd*")) {
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append(" ("); /* add */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.increment();                 /* ++ */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.workspace.append(")"); /* add */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("exp*opadd*"); /* add */
          mm.push();
          mm.push();
          continue parse;
        }
        if (mm.workspace.toString().equals("exp*opadd*exp*)*")) {
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append(" ("); /* add */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.increment();                 /* ++ */
          mm.increment();                 /* ++ */
          mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
          mm.workspace.append(")"); /* add */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          if (mm.tapePointer > 0) mm.tapePointer--; /* -- */
          mm.tape[mm.tapePointer].setLength(0); /* put */
          mm.tape[mm.tapePointer].append(mm.workspace); 
          mm.workspace.setLength(0);            /* clear */
          mm.workspace.append("exp*)*"); /* add */
          mm.push();
          mm.push();
          continue parse;
        }
        mm.push();
        mm.push();
        mm.push();
        mm.push();
        if (mm.eof) {
          mm.pop();
          mm.pop();
          if (mm.workspace.toString().equals("exp*")) {
            mm.workspace.setLength(0);            /* clear */
            // add "Yes, its an expression! \n";
            mm.workspace.append("lisp format: "); /* add */
            mm.workspace.append(mm.tape[mm.tapePointer]); /* get */
            mm.workspace.append("\n"); /* add */
            System.out.print(mm.workspace); /* print */
            mm.workspace.setLength(0);            /* clear */
            break script;
          }
          mm.push();
          mm.push();
          mm.workspace.append("No, it doesn't look like a valid 'in-fix' expression. \n"); /* add */
          mm.workspace.append("The parse stack was: "); /* add */
          System.out.print(mm.workspace); /* print */
          mm.workspace.setLength(0);            /* clear */
          while (mm.pop());          /* unstack */
          mm.workspace.append("\n"); /* add */
          System.out.print(mm.workspace); /* print */
          break script;
        }
        break parse;
      }
    }
  }
}
