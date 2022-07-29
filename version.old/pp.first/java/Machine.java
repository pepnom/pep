
import java.util.ArrayList;

public class Machine {

  private static int INITIALSTORAGE = 18;
  private static int DATASEGMENT = 10;

  /** code and data memory for the machine */
  private ArrayList storage;       

  /** a pointer to the data storage segment */
  private int dataPointer;         

  /** current code instruction */
  private int codePointer;        

  /** current tape element */
  private int tapePointer;        

  /** a pointer to the start of the the workspace */
  private int workspacePointer;

  /** a stack-like string and a work buffer */
  private StringBuffer buffer;

  /** the next character in the input stream */
  private char peep;
  
  /** the input stream */
  
  public Machine()
  {
    this.buffer = new StringBuffer("");
    this.dataPointer = DATASEGMENT;
    this.tapePointer = this.dataPointer;

    storage = new ArrayList();
    for (int ii = 0; ii < INITIALSTORAGE; ii++)
    {
      storage.add("");
    }
  }

  public int getTapePointer()
    { return this.tapePointer; }

  public void incrementTape()
  {
    if (this.tapePointer == this.storage.size())
    {
      // handle
    }

    this.tapePointer++;
  }

  public void decrementTape()
  {
    if (this.tapePointer < this.dataPointer)
      { System.out.println("Error"); }
      
    if (this.tapePointer == this.dataPointer)
      { return; }
      
    this.tapePointer--;
  }

  public void add(String text)
  {
    this.buffer.append(text);
  }

  public void clear()
    { this.buffer.setLength(this.workspacePointer); }
  
  public void pop() {}
  
  public void push() {}
  
  public void get() {}
  
  public void put() {}
  
  public void read() {}
  
  public void until() {}
   
  public void printStorage()
  {
    for (int ii = 0; ii < storage.size(); ii++)
    {
      if (ii == this.dataPointer)
        { System.out.println("---"); }

      if (ii == this.tapePointer)
        { System.out.println("T>" + ii + ":" + this.storage.get(ii)); }
      else if (ii == this.codePointer)
        { System.out.println("C>" + ii + ":" + this.storage.get(ii)); }
      else
        { System.out.println("  " + ii + ":" + this.storage.get(ii)); }
    }
  }

  public void print()
  {
    StringBuffer s = new StringBuffer();
    s.append(
      "buffer:" + this.buffer + "\n" +
      "stack:" + this.buffer + "\n" +
      "workspace:" + this.buffer + "\n" +
      "cp:" + this.codePointer + ", " +
      "dp:" + this.dataPointer + ", " +
      "wp:" + this.workspacePointer + ", " +
      "tp:" + this.tapePointer + "\n"
      );
    System.out.println(s);
  }

  public static void main(String[] args) 
  {
    System.out.println("hi");
    Machine mm = new Machine();
    //mm.incrementTape();
    //mm.incrementTape();
    //mm.print(); 
  }
  
}
