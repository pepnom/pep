import java.io.*;
import java.nio.charset.Charset;

/** 
  A class to test a program from the command line
  */

public class ptest {

  public static void printHelp()
  {
    StringBuffer text = new StringBuffer();
    text.append(
      "h    - display commands \n" +
      "ha   - display help about how to add new instructions \n" +
      "reset- reset the program \n" +
      "a    - add a new instruction to the program \n" +
      "st ..- set the machine input to the given text \n" +
      "pp   - show the machine & program state \n" +
      "l    - list the program \n" +
      "c ...- compile the following text into a program \n" +
      "ipm  - decrease the instruction pointer by one \n" +
      "ip 0 - set the instruction pointer to the number \n" +
      "x    - execute the current instruction \n" +
      "q    - exit \n"
    );
    System.out.print(text);
  }

  public static void printAddHelp()
  {
    StringBuffer text = new StringBuffer();
    text.append(
      "a    - add a new instruction to the program \n" +
      " eg: aj 0      adds a 'jump' 0 instruction \n" +
      " eg: a u tes   adds an 'until' instuction to the program \n" +
      " eg: ad        adds a 'clear' instruction \n" +
      "reset- resets or deletes the program \n" +
      "  \n"
    );
    System.out.print(text);
  }

  public static void main(String[] args) throws Exception 
  {
    String text = 
       new String("\u54ca\u5434x**xon1234\"\u53cb\u53cbx\"\tand\\\"is\" \t e*two*\"quote\"023three*vvv");
    InputStream is = new ByteArrayInputStream(text.getBytes());
    System.out.println("Testing the program");
    System.out.println("with text: " + text);
    System.out.println("Default Charset: " + Charset.defaultCharset());

    Program pp = new Program(is);
    Instruction ii;
    pp.addInstruction(new Instruction("read"));
    pp.addInstruction(new Instruction("add", "gg"));
    pp.addInstruction(new Instruction("jump", 0));
    pp = ptest.testProgram(pp);

    String input = new String("h");
    String parameter = new String("");
    String command = new String("");
    String argument = new String("");

    BufferedReader in = 
      new BufferedReader(new InputStreamReader(System.in));
    
    while (true)
    {
      if (input.equals("q"))
      {
        System.out.println("goodbye!");
        System.exit(0);
      }

      if (input.equals("reset"))
      {
        System.out.println("resetting (deleting) the program");
        pp.resetProgram();
      }

      if (input.startsWith("a"))
      {
        parameter = input.substring(1).trim();
        if (parameter.indexOf(" ") == -1)
        {
          pp.addInstruction(new Instruction(parameter)); 
        }
        else 
        {
          pp.addInstruction(new Instruction(
            parameter.substring(0, parameter.indexOf(" ")).trim(),
            parameter.substring(parameter.indexOf(" ")).trim()));
        }
      }

      if (input.startsWith("st"))
      {
        text = input.substring(2).trim();
        is = new ByteArrayInputStream(text.getBytes());
        Reader reader = new InputStreamReader(is);
        pp.setMachineInput(reader);
      }

      if (input.equals("pp"))
        pp.printState(); 

      if (input.equals("l"))
        pp.list();
   
      if (input.startsWith("c"))
      {
        parameter = input.substring(1).trim();
        pp.compile(parameter);
      }
   
      else if (input.equals("ipm"))
        pp.setInstructionPointer(pp.getInstructionPointer() - 1);

      else if (input.startsWith("ip"))
      {
        parameter = input.substring(2).trim();
        int i = Integer.parseInt(parameter);
        pp.setInstructionPointer(i);
      }

      else if (input.equals("x"))
        pp.execute();
   
      if (input.startsWith("x"))
      {
        parameter = input.substring(1).trim();
      }

      if (input.equals("h"))
        ptest.printHelp();
   
      if (input.equals("ha"))
        ptest.printAddHelp();
   
      if (!input.matches("^[l]$"))
      {
        System.out.println("\nparam:" + parameter + "\ntext:" + text);
        pp.printState();
      }
      System.out.print(">");
      input = in.readLine().trim();
    }

  }

  /** create a test program to test the machine and program */
  public static Program testProgram(Program pp)
  {
    pp.resetProgram();
    pp.addInstruction(new Instruction("read"));
    pp.addInstruction(new Instruction("add", "go\u5467go*"));
    pp.addInstruction(new Instruction("clear"));
    pp.addInstruction(new Instruction("add", "\u53adthis*"));
    pp.addInstruction(new Instruction("print"));
    pp.addInstruction(new Instruction("state"));
    pp.addInstruction(new Instruction("tape"));
    pp.addInstruction(new Instruction("burp"));
    pp.addInstruction(new Instruction("clear"));
    pp.addInstruction(new Instruction("add", "\\\u53aa\\*\\d\\this*"));
    pp.addInstruction(new Instruction("unescape"));
    pp.addInstruction(new Instruction("escape", "*"));
    pp.addInstruction(new Instruction("escape", "\\"));
    pp.addInstruction(new Instruction("replace"));
    pp.addInstruction(new Instruction("prefix", "aa"));
    pp.addInstruction(new Instruction("clip"));
    pp.addInstruction(new Instruction("clop"));
    pp.addInstruction(new Instruction("push"));
    pp.addInstruction(new Instruction("pop"));
    pp.addInstruction(new Instruction("put"));
    pp.addInstruction(new Instruction("get"));
    pp.addInstruction(new Instruction("swap"));
    pp.addInstruction(new Instruction("++"));
    pp.addInstruction(new Instruction("--"));
    pp.addInstruction(new Instruction("read"));
    pp.addInstruction(new Instruction("until", "*"));
    pp.addInstruction(new Instruction("while", "[a]"));
    pp.addInstruction(new Instruction("inca"));
    pp.addInstruction(new Instruction("inca"));
    pp.addInstruction(new Instruction("inca"));
    pp.addInstruction(new Instruction("count"));
    pp.addInstruction(new Instruction("deca"));
    pp.addInstruction(new Instruction("count"));
    pp.addInstruction(new Instruction("zero"));
    pp.addInstruction(new Instruction("jumptrue", 30));
    pp.addInstruction(new Instruction("check"));
    pp.addInstruction(new Instruction("clear"));
    pp.addInstruction(new Instruction("add", " \u5555"));
    pp.addInstruction(new Instruction("testeq", " \u5555"));
    pp.addInstruction(new Instruction("add", "x"));
    pp.addInstruction(new Instruction("testeq", " \u5555x"));
    pp.addInstruction(new Instruction("testbegins", "gg"));
    pp.addInstruction(new Instruction("testbegins", " "));
    pp.addInstruction(new Instruction("testends", "\u5555"));
    pp.addInstruction(new Instruction("testends", "\u5555x"));
    pp.addInstruction(new Instruction("testclass"));
    pp.addInstruction(new Instruction("testdict"));
    pp.addInstruction(new Instruction("testeof"));
    pp.addInstruction(new Instruction("testtape"));
    pp.addInstruction(new Instruction("undefined")); 
    pp.addInstruction(new Instruction("nop"));
    pp.addInstruction(new Instruction("jump", 0));
    pp.addInstruction(new Instruction("crash"));
    return pp;
  }

}
