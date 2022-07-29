/*
 Sept 2010, one instruction which can be executed by a machine 
*/
 
 import java.io.*;

 public class Instruction
 {
  public enum Opcode { 
   ADD,         /* adds a given text to the workbuffer */
   CLEAR,       /* clears the workspace */
   PRINT,       /* prints the workspace to stdout */
   STATE,       /* prints the current state of the machine */
   TAPE,        /* prints all tape elements and stack */
   BURP,        /* prints a very detailed dump of the machine */ 
   UNESCAPE,    /* remove escape sequences in the workspace to chars */
   SETESCAPE,   /* set the escape character used by the machine */
   REPLACE,     /* ??? unimplemened ???  */
   PREFIX,      /* inserts text at start of each line of the workspace */
   CLIP,        /* removes the last character of the workspace */
   CLOP,        /* removes the first character of the workspace */
   PUSH,        /* pushes the next token in the  workspace onto the stack */
   POP,         /* pops the next token onto the workspace */
   PUT,         /* put the contents of the workspace in the tape */
   GET,         /* adds the current tape element to the workspace */
   SWAP,        /* swaps the current tape element with the workspace */
   INCREMENT,   /* increases the tape pointer by one */
   DECREMENT,   /* decreases the tape pointer by one */
   READ,        /* read one (wide) character from the input stream */
   UNTIL,       /* read the input stream until the workspace ends with ... */
   WHILE,       /* read the input stream while the 'peep' is ... */
   COUNT,       /* add the accumulator to the workspace */ 
   INCA,        /* increment the accumulator or counter */
   DECA,        /* decrement the accumulator or counter */
   CRASH,       /* exits the script immediately */
   ZERO,        /* sets the accumulator to zero */
   JUMP,        /* an unconditional jump to a line number */
   JUMPTRUE,    /* jump if the machine flag is true */
   CHECK,       /* ??? a shift reduce jump, remove ??? */
   TESTEQ,      /* test if workspace equal to */
   TESTBEGINS,  /* test if begins with */
   TESTENDS,    /* test if workspace ends with */
   TESTCLASS,   /* test if first char of workspace is in class */ 
   TESTDICT,
   TESTEOF,
   TESTTAPE, 
   UNDEFINED, 
   NOP          /* no operation */
 }

   /** what type of instruction is this */
   private Opcode opcode;

   /** the text parameter */
   private String text;

   /** an integer parameter for jumps etc */
   private int number;

   /** negation for test instructions */
   private boolean negated;

   public Instruction(Opcode op)
   {
     this.opcode = op;
     this.text = new String("");
     this.negated = false;
     this.number = -1;
   }

   public Instruction(Opcode op, String sParameter)
   {
     this.opcode = op; 
     this.text = new String(sParameter);
     this.negated = false;
     this.number = -1;
   }

   public Instruction(String sCommand)
   {
     this.opcode = Instruction.textToOpcode(sCommand); 
     this.text = new String("");
     this.negated = false;
     this.number = -1;
   }

   public Instruction(String sCommand, String sParameter)
   {
     this.opcode = Instruction.textToOpcode(sCommand); 
     this.negated = false;
     if ((this.opcode == Instruction.Opcode.JUMP) ||
         (this.opcode == Instruction.Opcode.JUMPTRUE))
     {
       this.text = new String("");
       this.number = Integer.parseInt(sParameter);
     }
     else
     {
       this.text = new String(sParameter);
       this.number = -1;
     }
   }

   public Instruction(String sCommand, int iNumber)
   {
     this.opcode = Instruction.textToOpcode(sCommand); 
     this.text = new String("");
     this.negated = false;
     this.number = iNumber;
   }

   public Instruction(String sCommand, String sParameter, int iNumber)
   {
     this.opcode = Instruction.textToOpcode(sCommand); 
     this.text = new String(sParameter);
     this.negated = false;
     this.number = iNumber;
   }

   /** print the instruction nicely */
   public void print()
   {
     String sNegate = "+";
     if (this.negated) sNegate = "!";
     StringBuffer s = new StringBuffer(
       "" + this.opcode + " <" + this.text + "," + this.number + 
       "," + sNegate + ">");
     System.out.println(s);
   }

   public void setJump(int iJump)
   {
     this.number = iJump;
   }

   public boolean isNegated()
   {
     return this.negated;
   }

   public void toggleNegation()
   {
     this.negated = !this.negated;
   }

   public Opcode getOpcode()
   {
     return this.opcode;
   }

   public String getText()
   {
     return this.text;
   }

   public int getNumber()
   {
     return this.number;
   }

   /** return true if the operation needs a parameter */
   public static boolean requiresParameter(Opcode opcode)
   {
     if (opcode == Opcode.ADD) return true;
     if (opcode == Opcode.SETESCAPE) return true; 
     if (opcode == Opcode.REPLACE) return true;
     if (opcode == Opcode.PREFIX) return true;
     if (opcode == Opcode.UNTIL) return true;
     if (opcode == Opcode.WHILE) return true;
     if (opcode == Opcode.JUMP) return true;
     if (opcode == Opcode.JUMPTRUE) return true;
     if (opcode == Opcode.TESTEQ) return true;
     if (opcode == Opcode.TESTBEGINS) return true;
     if (opcode == Opcode.TESTENDS) return true;
     if (opcode == Opcode.TESTCLASS) return true;
     if (opcode == Opcode.TESTDICT) return true;
     return false;
   }

   /** return true if the command needs a parameter */
   public static boolean requiresParameter(String sCommand)
   {
     Opcode opcode = Instruction.textToOpcode(sCommand); 
     return Instruction.requiresParameter(opcode);
   }

   public static Opcode textToOpcode(String sText)
   {
     if (sText.equals("add") || sText.equals("a"))
       return Opcode.ADD;
     if (sText.equals("clear") || sText.equals("d"))
       return Opcode.CLEAR;
     if (sText.equals("print") || sText.equals("p"))
       return Opcode.PRINT;
     if (sText.equals("state") || sText.equals("P"))
       return Opcode.STATE;
     if (sText.equals("state") || sText.equals("P"))
       return Opcode.TAPE;
     if (sText.equals("burp") || sText.equals("B"))
       return Opcode.BURP;
     if (sText.equals("unescape") || sText.equals("E"))
       return Opcode.UNESCAPE;    
     if (sText.equals("escape") || sText.equals("e"))
       return Opcode.SETESCAPE;
     if (sText.equals("prefix") || sText.equals("f"))
       return Opcode.PREFIX;
     if (sText.equals("clip") || sText.equals("c"))
       return Opcode.CLIP; 
     if (sText.equals("clop") || sText.equals("C"))
       return Opcode.CLOP;
     if (sText.equals("pop") || sText.equals("o"))
       return Opcode.POP;
     if (sText.equals("push") || sText.equals("O"))
       return Opcode.PUSH;
     if (sText.equals("put") || sText.equals("G"))
       return Opcode.PUT;         
     if (sText.equals("get") || sText.equals("g"))
       return Opcode.GET;         
     if (sText.equals("swap") || sText.equals("x"))
       return Opcode.SWAP;        
     if (sText.equals("++") || sText.equals("+"))
       return Opcode.INCREMENT;   
     if (sText.equals("--") || sText.equals("-"))
       return Opcode.DECREMENT;   
     if (sText.equals("read") || sText.equals("r"))
       return Opcode.READ;        
     if (sText.equals("until") || sText.equals("u"))
       return Opcode.UNTIL;       
     if (sText.equals("while") || sText.equals("w"))
       return Opcode.WHILE;       
     if (sText.equals("count") || sText.equals("c"))
       return Opcode.COUNT;       
     if (sText.equals("+a") || sText.equals("inca"))
       return Opcode.INCA;        
     if (sText.equals("-a") || sText.equals("deca"))
       return Opcode.DECA;        
     if (sText.equals("crash") || sText.equals("q"))
       return Opcode.CRASH;       
     if (sText.equals("zero") || sText.equals("00"))
       return Opcode.ZERO;        
     if (sText.equals("jump") || sText.equals("j"))
       return Opcode.JUMP;        
     if (sText.equals("jumptrue") || sText.equals("jt"))
       return Opcode.JUMPTRUE;    
     if (sText.equals("check") || sText.equals("k"))
       return Opcode.CHECK;       
     if (sText.equals("testeq") || sText.equals("?="))
       return Opcode.TESTEQ;      
     if (sText.equals("testclass") || sText.equals("?["))
       return Opcode.TESTCLASS;      
     if (sText.equals("testbegins") || sText.equals("?>"))
       return Opcode.TESTBEGINS;  
     if (sText.equals("testends") || sText.equals("?<"))
       return Opcode.TESTENDS;    
     if (sText.equals("testtape") || sText.equals("?tape"))
       return Opcode.TESTTAPE;    
     if (sText.equals("testdict") || sText.equals("?dict"))
       return Opcode.TESTDICT;    
     if (sText.equals("testeof") || sText.equals("?eof"))
       return Opcode.TESTEOF;
     if (sText.equals("undef") || sText.equals("???"))
       return Opcode.UNDEFINED; 
     if (sText.equals("noop") || sText.equals("nop"))
       return Opcode.NOP; 
   
     return Opcode.UNDEFINED;
   }

   public static void main(String[] args) 
   {
     Instruction ii = new Instruction(Opcode.PRINT);
     Instruction jj = new Instruction(Opcode.UNTIL, "a*");
     Instruction kk = new Instruction("clear", "this");
     ii.print();
     jj.print();
     kk.print();
   }
 }
