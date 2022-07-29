/*
 Sept 2010, a program to run the machine. The program
 is also capable of compiling some instructions from text.
*/
 
 import java.io.*;

 public class Program
 {
   /** the instruction pointer */
   private int ip;

   /** how many instructions */
   private int programSize;

   private Instruction[] memory;

   private static int MEMORYSIZE = 10000; 

   private Machine machine;

   /** the number of instructions executed */
   private long count;

   public Program(InputStream is)
   {
     this.ip = 0;
     this.programSize = 0;
     this.count = 0;
     this.memory = new Instruction[MEMORYSIZE];
     this.machine = new Machine(new InputStreamReader(is));
   }

   public Program()
   {
     this(System.in);
   }
     
   /** set the input character stream for the machine */
   public void setMachineInput(Reader reader)
   {
     this.machine.setInput(reader);
   }

   /** execute the one instruction */
   public void execute()
   {
     Instruction ii = this.memory[this.ip];
     if (ii.getOpcode() == Instruction.Opcode.ADD)         
       machine.add(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.CLEAR)       
       machine.clear();

     if (ii.getOpcode() == Instruction.Opcode.PRINT)       
       machine.print();

     if (ii.getOpcode() ==Instruction.Opcode.STATE) 
       machine.state();

     if (ii.getOpcode() == Instruction.Opcode.TAPE) {}

     if (ii.getOpcode() == Instruction.Opcode.BURP) {}

     if (ii.getOpcode() == Instruction.Opcode.UNESCAPE)    
       machine.unescape();

     if (ii.getOpcode() == Instruction.Opcode.SETESCAPE)   
       machine.setEscape(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.REPLACE) {}

     if (ii.getOpcode() == Instruction.Opcode.PREFIX)      
       machine.prefix(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.CLIP)        
       machine.clip();

     if (ii.getOpcode() == Instruction.Opcode.CLOP)        
       machine.clop();

     if (ii.getOpcode() == Instruction.Opcode.PUSH)        
       machine.push();

     if (ii.getOpcode() == Instruction.Opcode.POP)         
       machine.pop();

     if (ii.getOpcode() == Instruction.Opcode.PUT)         
       machine.put();

     if (ii.getOpcode() == Instruction.Opcode.GET)         
       machine.get();

     if (ii.getOpcode() == Instruction.Opcode.SWAP)        
       machine.swap();
      
     if (ii.getOpcode() == Instruction.Opcode.INCREMENT)   
       machine.incrementTape();

     if (ii.getOpcode() == Instruction.Opcode.DECREMENT)   
       machine.decrementTape();

     if (ii.getOpcode() == Instruction.Opcode.READ)        
       machine.read();

     if (ii.getOpcode() == Instruction.Opcode.UNTIL)       
       machine.until(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.WHILE)       
       machine.whilePeep(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.COUNT)       
       machine.count();

     if (ii.getOpcode() == Instruction.Opcode.INCA)        
       machine.inca();

     if (ii.getOpcode() == Instruction.Opcode.DECA)        
       machine.deca();

     if (ii.getOpcode() == Instruction.Opcode.CRASH)       
       machine.crash();

     if (ii.getOpcode() == Instruction.Opcode.ZERO)        
       machine.zero();

     if (ii.getOpcode() == Instruction.Opcode.JUMP)        
     {
       if ((ii.getNumber() < 0) || (ii.getNumber() > this.programSize - 1))
       {
         System.out.println("invalid jump at instruction " + this.ip);
         this.printState();
         System.exit(1);
       }
       this.ip = ii.getNumber();
       this.count++;
       return;
     }

     if (ii.getOpcode() == Instruction.Opcode.JUMPTRUE)    
     {
       if (machine.getFlag())
       {
         if ((ii.getNumber() < 0) || (ii.getNumber() > this.programSize - 1))
         {
           System.out.println("invalid jump at instruction " + this.ip);
           this.printState();
           System.exit(1);
         }
         this.ip = ii.getNumber();
         this.count++;
         return;
       }
     }
     if (ii.getOpcode() == Instruction.Opcode.CHECK) {}

     if (ii.getOpcode() == Instruction.Opcode.TESTEQ)      
       machine.testEquals(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.TESTBEGINS)  
       machine.testBeginsWith(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.TESTENDS)    
       machine.testEndsWith(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.TESTCLASS)
       machine.testClass(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.TESTDICT)
       machine.testDictionary(ii.getText());

     if (ii.getOpcode() == Instruction.Opcode.TESTEOF)
       machine.testEof();

     if (ii.getOpcode() == Instruction.Opcode.TESTTAPE) 
       machine.testTape();

     if (ii.getOpcode() == Instruction.Opcode.UNDEFINED) 
     {
       System.out.println("Undefined instruction");
       //ii.print();
       //pp.list();
     }

     if (ii.getOpcode() == Instruction.Opcode.NOP)
     {
     }

     this.ip++;
     this.count++;
   }

   public void run()
   {
   }

   /** delete the program */
   public void resetProgram()
   {
     this.programSize = 0;
     this.ip = 0;
     this.count = 0;
   }

   public void setInstructionPointer(int iPosition)
   {
     this.ip = iPosition;
   }

   public int getInstructionPointer()
   {
     return this.ip;
   }

   /** add one instruction to the end of the program */
   public void addInstruction(Instruction ii)
   {
     if (this.programSize >= MEMORYSIZE)
     {
       System.out.println("memory exceeded (" + MEMORYSIZE + ")");
       System.exit(1);
     }
     this.memory[this.programSize] = ii;
     this.programSize++;
   }

   public Instruction getLastInstruction()
   {
     return this.memory[this.programSize - 1];
   }

   public void toggleLastNegation()
   {
     this.memory[this.programSize - 1].toggleNegation();
   }

   /** create a test program to test the machine and program */
   public void testProgram()
   {
     this.resetProgram();
     this.addInstruction(new Instruction("read"));
     this.addInstruction(new Instruction("add", "less*"));
     this.addInstruction(new Instruction("add", "ball*"));
     this.addInstruction(new Instruction("push"));
     this.addInstruction(new Instruction("push"));
     this.addInstruction(new Instruction("pop"));
     this.addInstruction(new Instruction("clear"));
     this.addInstruction(new Instruction("add", "gge"));
     this.addInstruction(new Instruction("add", "gge"));
     this.addInstruction(new Instruction("jump", 0));
   }

   /** compile the contents of a file into a program */
   public void compile(File file)
   {
     try
     {
       FileReader input = new FileReader(file);
       BufferedReader buffReader = new BufferedReader(input);
       this.compile(buffReader);
     }
     catch (FileNotFoundException ex)
       { System.out.println("file not found"); }
     catch (IOException ex)
       { System.out.println("io problem"); }
   }

   /** compile some text into a program */
   public void compile(String sProgramText)
   {
     InputStream is = new ByteArrayInputStream(sProgramText.getBytes());
     //Reader reader = new InputStreamReader(is, "UTF-8");
     Reader reader = new InputStreamReader(is);
     Reader buffReader = new BufferedReader(reader);
     try
       { this.compile(buffReader); }
     catch (IOException ex)
       { System.out.println("problem reading io"); }
   }

   /** compile a character stream into a program */
   public void compile(Reader reader) throws IOException
   {
     // a machine to do the parsing
     String sCommand = new String("");
     String sParameter = new String("");
     Machine mm = new Machine(reader);
     Instruction ii;

     while (!mm.eof())
     {
       mm.read();

       mm.testEquals(" ");
       if (mm.flag())
       {
         mm.whilePeep("[ ]");
         mm.clear();
       }
       
       mm.testEquals(";");
       if (mm.flag())
       {
         mm.put();
         mm.clear();
         mm.add("semi-colon*");
         mm.print();
         mm.push();
         // mm.clear();
       }
       
       mm.testEquals("!");
       if (mm.flag())
       {
         mm.put();
         mm.clear();
         mm.add("negation*");
         mm.print();
         mm.push();
         // mm.clear();
       }
       
       mm.testEquals("{");
       if (mm.flag())
       {
         mm.put();
         mm.clear();
         mm.add("openbrace*");
         mm.print();
         mm.push();
         // mm.clear();
       }
       
       mm.testEquals("}");
       if (mm.flag())
       {
         mm.put();
         mm.clear();
         mm.add("closebrace*");
         mm.print();
         mm.push();
         // mm.clear();
       }
       
       mm.testEquals("\"");
       if (mm.flag())
       {
         mm.clear();
         mm.until("\"");
         mm.clip();
         mm.put();
         mm.clear();
         mm.add("quoted*");
         mm.print();
         mm.push();
       }

       mm.testClass("[a]");
       if (mm.flag())
       {
         mm.whilePeep("[a]");
         sCommand = mm.getWorkSpace();
         if (Instruction.textToOpcode(sCommand) == 
               Instruction.Opcode.UNDEFINED)
         {
           System.out.println(
             "unknown command: " + sCommand + "\n" + 
             "nothing compiled");
           return;
         }
         mm.put();
         mm.clear();
         mm.add("keyword*");
         mm.print();
         mm.push();
       }

       mm.testEquals("/");
       if (mm.flag())
       {
         mm.clear();
         mm.until("/");
         mm.clip();
         mm.put();
         sParameter = mm.getWorkSpace();
         ii = new Instruction("testeq", sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("testequals*");
         mm.print();
         mm.push();
       }

       mm.testEquals("<");
       if (mm.flag())
       {
         mm.clear();
         mm.until(">");
         mm.clip();
         mm.put();
         sParameter = mm.getWorkSpace();
         ii = new Instruction("testbegins", sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("testbegins*");
         mm.print();
         mm.push();
       }

       mm.testEquals("(");
       if (mm.flag())
       {
         mm.clear();
         mm.until(")");
         mm.clip();
         mm.put();
         sParameter = mm.getWorkSpace();
         ii = new Instruction("testends", sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("testends*");
         mm.print();
         mm.push();
       }

       mm.testEquals("[");
       if (mm.flag())
       {
         mm.until("]");
         mm.put();
         sParameter = mm.getWorkSpace();
         ii = new Instruction("testclass", sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("testclass*");
         mm.print();
         mm.push();
       }

       mm.testEquals("=");
       if (mm.flag())
       {
         mm.clear();
         mm.until("=");
         mm.clip();
         mm.put();
         sParameter = mm.getWorkSpace();
         ii = new Instruction("testdict", sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("testdict*");
         mm.print();
         mm.push();
       }

       mm.pop(); mm.pop(); mm.pop();
       mm.testEquals("keyword*quoted*semi-colon*");
       if (mm.flag())
       {
         //mm.printState();
         mm.clear(); 
         mm.get();
         sCommand = mm.getWorkSpace();
         //if (!Instruction.requiresParameter(sCommand))
         mm.clear();
         mm.incrementTape();
         mm.get();
         sParameter = mm.getWorkSpace();
         mm.decrementTape();
         mm.clear();
         ii = new Instruction(sCommand, sParameter);
         ii.print();
         this.addInstruction(ii);
         mm.add("statement*");
         mm.push();
         mm.print();
       }
       mm.push(); mm.push(); mm.push();

       mm.pop(); mm.pop(); 
       mm.testEquals("keyword*semi-colon*");
       if (mm.flag())
       {
         mm.clear(); 
         mm.get();
         sCommand = mm.getWorkSpace();
         ii = new Instruction(sCommand);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("statement*");
         mm.print();
         mm.push();
       }
       mm.push(); mm.push();

       mm.pop(); mm.pop(); 
       mm.testEquals("statement*statement*");
       if (mm.flag())
       {
         mm.clear(); 
         mm.get();
         sCommand = mm.getWorkSpace();
         ii = new Instruction(sCommand);
         ii.print();
         this.addInstruction(ii);
         mm.clear();
         mm.add("statement*");
         mm.print();
         mm.push();
       }
       mm.push(); mm.push();

       mm.pop(); mm.pop(); 
       mm.testBeginsWith("test");
       mm.testEndsWith("negation*");
       if (mm.flag())
       {
         mm.clip(); mm.clip(); mm.clip(); mm.clip();
         mm.clip(); mm.clip(); mm.clip(); mm.clip();
         mm.clip();
         this.toggleLastNegation(); 
         //mm.print();
         mm.push();
       }
       mm.push(); mm.push();

       if (mm.eof())
       {
         mm.state();
       }

       //mm.print();
       mm.clear();
     }
   }

   /** test some programs */
   public void testMachine(Reader reader) 
   {
     // a test machine 
     Machine mm = new Machine(reader);
     while (!mm.eof())
     {
       mm.add(":");
       mm.print();
       mm.clear();
       mm.read();
     }
   }
   /** test the current character set */
   public void testCharacterSet(String sText)
   {
     InputStream is = new ByteArrayInputStream(sText.getBytes());
     //Reader reader = new InputStreamReader(is, "UTF-8");
     Reader reader = new InputStreamReader(is);
     Reader buffReader = new BufferedReader(reader);
     int iChar = -1;
     try
     {
       iChar = buffReader.read();
       while (iChar != -1)
       {
         System.out.print(":" + (char)iChar);
         iChar = buffReader.read();
       }
     }
     catch (IOException ex)
     {
       System.out.println("problem reading io");
     }

   }

   public void list()
   {
     for (int ii = 0; ii < this.programSize; ii++)
     {
       if (ii == this.ip)
         System.out.print(" *" + ii + ": ");
       else
         System.out.print("  " + ii + ": ");
       this.memory[ii].print();
     }
   }

   public void shortList()
   {
     int iStart = this.ip - 2;
     if (iStart < 0) iStart = 0;
     int iEnd = this.ip + 3;
     if (iEnd > this.programSize) iEnd = this.programSize;

     for (int ii = iStart; ii < iEnd; ii++)
     {
       if (ii == this.ip)
         System.out.print(" *" + ii + ": ");
       else
         System.out.print("  " + ii + ": ");
       this.memory[ii].print();
     }
   }

   public void printState()
   {
     System.out.print(" IP:" + this.ip + " IC:" + this.count);
     System.out.println(" Size:" + this.programSize);
     this.shortList(); 
     this.machine.printState();
   }

   public static void main(String[] args) 
   {
     Program pp = new Program();
     pp.addInstruction(new Instruction("clear"));
     pp.addInstruction(new Instruction("add", "gge"));
     pp.addInstruction(new Instruction("jump", 0));
     pp.list();
   }
 }
