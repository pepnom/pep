import java.io.*;

public class MachineTest {

  public static void printHelp()
  {
    StringBuffer text = new StringBuffer();
    text.append(
      "h    - display commands \n" +
      "pp   - print the machine \n" +
      "ps   - print the machine storage \n" +
      "++   - increment the tape pointer \n" +
      "--   - decrement the tape pointer \n" +
      "aj   - add something to the buffer \n" +
      "q    - exit \n"
    );
    System.out.print(text);
  }

  public static void main(String[] args) throws Exception 
  {
    System.out.println("hi");
    Machine mm = new Machine();
    String input = new String("h");

    BufferedReader in = 
      new BufferedReader(new InputStreamReader(System.in));

    while (!input.equals("q"))
    {
      if (input.equals("pp"))
        { mm.print(); }

      if (input.equals("ps"))
        { mm.printStorage(); }

      if (input.equals("++"))
      {
        mm.incrementTape();
        System.out.println("tape pointer:" + mm.getTapePointer());
      }

      if (input.equals("--"))
      {
        mm.decrementTape();
        System.out.println("tape pointer:" + mm.getTapePointer());
      }
      
      if (input.equals("h"))
        { this.buffer.append("test*"); }

      if (input.equals("h"))
        { MachineTest.printHelp(); }

      System.out.print(">");
      input = in.readLine();
    }

    System.out.print("bye");
  }
}
