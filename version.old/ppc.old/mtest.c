 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <stdlib.h>
 #include <stdbool.h>
 #include "machine.h"

 // compile with:gcc machine.c mtest.c -o mtest

 void printHelp();

 int main()
 {
   wchar_t input[200];
   wchar_t command[100];
   wchar_t parameter[100];
   Machine mm; 
   wchar_t * sDisplay = NULL;

   command[0] = L'\0'; 
   parameter[0] = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Testing the machine\n");
   printHelp();
   init(&mm);

   while(1)
   {
     wprintf(L">");
     command[0] = L'\0'; 
     parameter[0] = L'\0'; 

     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %ls", command, parameter);
     wprintf(L"command:%ls, parameter:%ls \n", command, parameter);

     /*
      if (input.equals("r"))
        mm.read(); 

      if (input.equals("R"))
      {
        System.out.println("not implemented");
      }

      if (input.startsWith("st"))
      {
        text = input.substring(2).trim();
        InputStream is = new ByteArrayInputStream(text.getBytes());
        Reader reader = new InputStreamReader(is);
        mm = new Machine(reader);
      }

      if (input.startsWith("esc"))
      {
        parameter = input.substring(3).trim();
        mm.setEscape(parameter); 
      }

      if (input.equals("ue"))
        mm.unescape(); 

      else if (input.startsWith("u"))
      {
        parameter = input.substring(1).trim();
        mm.until(parameter); 
      }

      else if (input.startsWith("w"))
      {
        parameter = input.substring(1).trim();
        mm.whilePeep(parameter); 
      }

      if (input.equals("W"))
        System.out.println(mm.getWhileClasses()); 

      if (input.startsWith("teq"))
      {
        parameter = input.substring(3).trim();
        mm.testEquals(parameter); 
      }

      else if (input.startsWith("te"))
      {
        parameter = input.substring(2).trim();
        mm.testEndsWith(parameter); 
      }

      else if (input.startsWith("tc"))
      {
        parameter = input.substring(2).trim();
        mm.testClass(parameter); 
      }

      else if (input.startsWith("ts"))
      {
        parameter = input.substring(2).trim();
        mm.testBeginsWith(parameter); 
      }

      else if (input.startsWith("tt"))
      {
        parameter = input.substring(2).trim();
        mm.testTape(); 
      }

      else if (input.startsWith("td"))
      {
        parameter = input.substring(2).trim();
        mm.testDictionary(parameter); 
      }

      if (input.equals("pp"))
        mm.printState(); 

      if (input.equals("ps"))
        //mm.printStorage();

      if (input.equals("++"))
        mm.incrementTape();

      if (input.equals("--"))
        mm.decrementTape();
      
      if (input.equals("g"))
        mm.get();
      
      if (input.equals("G"))
        mm.put();
      
      if (input.equals("co"))
      {
        mm.count();
      }

      if (input.equals("zero"))
      {
        mm.zero();
      }

      if (input.equals("inc"))
      {
        mm.inca();
      }

      if (input.equals("dec"))
      {
        mm.deca();
      }

      if (input.equals("clip"))
      {
        mm.clip();
      }
      
      if (input.equals("clop"))
      {
        mm.clop();
      }
      
      if (input.startsWith("a"))
      {
        parameter = input.substring(1).trim();
        mm.add(parameter);
      }

      if (input.equals("p"))
      {
        mm.print();
      }

      if (input.equals("d"))
      {
        mm.clear();
      }

      //Stack commands

      if (input.equals("o"))
      {
        mm.pop();
      }
   
      if (input.equals("O"))
      {
        mm.push();
      }
   
      if (input.equals("h"))
      {
        mtest.printHelp();
      }
   
      if (!input.matches("^ababab[h]$"))
      {
        System.out.println("\nparam:" + parameter + "\ntext:" + text);
        mm.printState();
      }
      System.out.print(">");
      */

     if (!wcscmp(command, L"q"))
       exit(0);

     else if (!wcscmp(command, L"h"))
       printHelp();

     else if (wcscmp(command, L"r") == 0)
       printHelp();

     else if (wcscmp(command, L"pp") == 0)
       printState(&mm);

     else if (wcscmp(command, L"s") == 0)
     {
       if (parameter[0] == L'\0')
        { wprintf(L"missing argument\n"); continue; }
     }

     else
     { 
       wprintf(L"unknown command '%ls'\n", command);
       printHelp();
     }
   }

   //freeMachine(&mm);
   return 0;
 }

 void printHelp()
 {
   wprintf(
     L"h    - display commands \n"
     L"r    - read one character from the input stream \n"
     L"R    - reset the input stream \n"
     L"st ..- set the text to use to the following \n"
     L"u xx - read the input until the workspace ends with 'xx'\n"
     L"esc x- set the machine escape character to 'x'\n"
     L"ue   - remove escapes in the workspace \n"
     L"w    - read the input while the peep is \n"
     L"W    - show the legal character classes usable with 'w'\n"
     L"teq  - test if the workspace is equal to the text \n"
     L"te   - test if the workspace ends with the text \n"
     L"tc   - test if the 1st workspace char is in the class \n"
     L"ts   - test if the workspace start with the text \n"
     L"tt   - test if the workspace is the same as the tape cell \n"
     L"td   - test if the workspace matches a dictionary\n"
     L"pp   - print the machine \n"
     L"ps   - print the machine storage \n"
     L"++   - increment the tape pointer \n"
     L"--   - decrement the tape pointer \n"
     L"g    - append the current tape cell to the workspace \n"
     L"G    - put the workspace into the current tape cell \n"
     L"co   - append the accumulator to the workspace \n"
     L"inc  - increment the accumulator \n"
     L"dec  - decrement the accumulator \n"
     L"zero - set the accumulator to zero \n"
     L"p    - print the workspace \n"
     L"d    - clear the workspace \n"
     L"clip - clip one character from the end of the workspace \n"
     L"clop - clip one character from the beginning of the workspace \n"
     L"a xx - add 'xx' to the workspace \n"
     L"o    - pop the stack into the workspace \n"
     L"O    - push the workspace onto \n"
     L"q    - exit \n");
 }
