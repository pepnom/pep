 #include <stdio.h>
 #include <stdlib.h>
 #include <stdbool.h>
 #include <wchar.h>
 #include "machine.h"

  Machine * init(Machine * mm)
  {
    // 日本語
    mm->peep = L'日';
    //this.input = reader;
    mm->input = stdin;
    mm->eof = false;
    mm->flag = false;
    mm->accumulator = 0;
    mm->stack = (wchar_t *)malloc(1000 * sizeof(wchar_t));
    if (mm->stack == NULL)
    {
      fwprintf(L"cant get memory for stack\n", stderr);
      exit(1);
    }
    mm->stack[0] = 0;
    mm->workspace = mm->stack;
    wcscpy(mm->escape, L"\\");
    mm->pointer = 0;
    /*
      this.tape = new StringBuffer[LENGTH];
      for (int ii = 0; ii < this.tape.length; ii++)
      {
        this.tape[ii] = new StringBuffer(); 
      }
      this.peep = this.input.read();
     */
  }

  /* just exit */
  void crash()
  {
    exit(0);
  }

  /* read one character from the input stream and update the machine. */
  wchar_t * read(Machine * mm)
  {
    if (mm->eof) exit(0);
    /*
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
    */
  }

  void printState(Machine * mm)
  {
    wprintf(
      L"\n P:%lc|V|%x W:\n"
      L" FLAG:%s EOF:%s ESC:%ls ACC:%d \n"
      L" S: \n"
      L" T[p]:|||...\n",
      mm->peep, mm->peep, 
      mm->flag?"true":"false", mm->eof?"true":"false",
      mm->escape, mm->accumulator);
      // for (int ii = 0; ii < this.pointer + 10; ii++)
      // { sReturn.append(this.tape[ii] + "|"); }
  }


