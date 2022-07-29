
 /**
 *  
 *  This file provides a program to test the Machine class which
    represents a virtual machine with several buffers and commands.
    More documentation for this virtual machine is available at
    http://bumble.sourceforge.net/machine/     

    An earlier version of this machine was written in java and
    is located at http://bumble.sf.net/machine/java but the java 
    version has some implementation differences 
 *
 *
 *  @author http://bumble.sf.net
 */

#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <ctype.h>
#include "Machine.h" 


using namespace std;
 


  //--------------------------------------------
  /** provides a command loop to test the machine operations and view the machine */
  int main(int argc, char* argv[]) 
  {
    
    string sUsageMessage("");
    sUsageMessage.append("usage: Machine inputfile");
    sUsageMessage.append("\n");
    sUsageMessage.append("tests the Machine class see http://bumble.sf.net/machine");
    sUsageMessage.append("\n");
    sUsageMessage.append("for more documentation");
    sUsageMessage.append("\n");
    ifstream in;
    string sMessage("");

    if (argc == 1) {
       cout << sUsageMessage;
       exit(-1);
       // no argument => count lines of standard input
       //in = std::cin;
    }
    else
    {
      in.open(argv[1]);      
    } //-- if
 
     Machine testMachine;

     //Machine testMachine(std::cin);

     string sCommand("");
     char *ccCommand;
     string sUserMessage("");

     sUserMessage.append("tests the Machine class see http://bumble.sf.net/machine");
     sUserMessage.append("\n");
     sUserMessage.append("for more documentation");
     sUserMessage.append("\n");
     sUserMessage.append("Commands;");
     sUserMessage.append("\n");
     sUserMessage.append(" a - add to the workspace");
     sUserMessage.append("\n");
     sUserMessage.append(" c - clear the work space [clear, cl]");
     sUserMessage.append("\n");
     sUserMessage.append(" pr - print the contents of the workspace [print]");
     sUserMessage.append("\n");
     sUserMessage.append(" i - indents the work space [indent]");
     sUserMessage.append("\n");
     sUserMessage.append(" n - add newline to the work space [newline, nl]");
     sUserMessage.append("\n");
     sUserMessage.append(" s - clip one char from the workspace [clip]");
     sUserMessage.append("\n");
     sUserMessage.append(" p - push the workspace onto the stack [push]");
     sUserMessage.append("\n");
     sUserMessage.append(" r - read the next character from the stream [read]");
     sUserMessage.append("\n");
     sUserMessage.append(" l - read until workspace ends with text");
     sUserMessage.append("\n");
     sUserMessage.append(" e - check if workspace ends with text");
     sUserMessage.append("\n");
     sUserMessage.append(" b - check if workspace begins with text");
     sUserMessage.append("\n");
     sUserMessage.append(" w - read while peep is- [:digit:], [:space:], [:letter:]");
     sUserMessage.append("\n");
     sUserMessage.append(" x - read while peep is not- character or [:digit:], [:space:], [:letter:]");
     sUserMessage.append("\n");
     sUserMessage.append(" o - pop the stack into the workspace [pop]");
     sUserMessage.append("\n");
     sUserMessage.append(" u - put the workspace on the tape [put]");
     sUserMessage.append("\n");
     sUserMessage.append(" g - get the tape item into the workspace ");
     sUserMessage.append("\n");
     sUserMessage.append(" - - decrement the tape pointer");
     sUserMessage.append("\n");
     sUserMessage.append(" + - increment the tape pointer");
     sUserMessage.append("\n");
     sUserMessage.append(" h - help, show this message [?]");
     sUserMessage.append("\n");
     sUserMessage.append(" q - quit");
     sUserMessage.append("\n");
     cout << sUserMessage;

     //----------------------------------
     //-- the command loop
     //--
     sCommand = " ";
     while (!(sCommand == "q"))
     {
       cout << "command[" << sCommand << "]";

       //--------------------------------
       if (sCommand.at(0) == 'a')
       {
         testMachine.add(sCommand.substr(1));               
       }

       //--------------------------------
       if ((sCommand == "c") || (sCommand == "clear"))
       {
         testMachine.clear();
       }

       //--------------------------------
       if ((sCommand == "pr") || (sCommand == "print"))
       {
         testMachine.print();
       }

       //--------------------------------
       if ((sCommand == "n") || (sCommand == "newline"))
       {
         testMachine.newline();
       }

       //--------------------------------
       if ((sCommand == "s") || (sCommand == "clip"))
       {
         testMachine.clip();
       }

       //--------------------------------
       // 
       if ((sCommand == "i") || (sCommand == "indent"))
       {
         testMachine.indent();
       }

       //--------------------------------
       if ((sCommand == "p") || (sCommand == "push"))
       {
         testMachine.push();               
       }

       //--------------------------------
       if ((sCommand == "r") || (sCommand == "read"))
       {
         testMachine.readNext(in);               
       }

       //--------------------------------
       if (sCommand.at(0) == 'l')
       {
         testMachine.readUntil(in, sCommand.substr(1));               
       }

       //--------------------------------
       if (sCommand.at(0) == 'e')
       {
	 if (testMachine.endsWith(sCommand.substr(1)))
	  { cout << "true"; }
         else
	  { cout << "false"; }
       }

       //--------------------------------
       if (sCommand.at(0) == 'b')
       {
	 if (testMachine.beginsWith(sCommand.substr(1)))
	  { cout << "\nbegins-with == true"; }
         else
	  { cout << "\nbegins-with == false"; }
       }

       //--------------------------------
       if (sCommand.at(0) == 'w')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "This command requires an argument: \n" 
	        << "eg 'w[:digit:]' reads stream while the peep contains a digit";
	 }
	 else
	 {
           testMachine.readWhile(in, sCommand.substr(1));               
	 }
       }

       //--------------------------------
       if (sCommand.at(0) == 'x')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "This command requires an argument: \n" 
	        << "eg 'x%' reads stream until the peep has a % character";
	 }
	 else
	 {
	   testMachine.readWhileNot(in, sCommand.substr(1)); 
	 }
       }

       //--------------------------------
       // 
       if ((sCommand == "o") || (sCommand == "pop"))
       {
         testMachine.pop();               
       }

       //--------------------------------
       // 
       if ((sCommand == "u") || (sCommand == "put"))
       {
         testMachine.put();
       }

       //--------------------------------
       // 
       if ((sCommand == "g") || (sCommand == "get"))
       {
         testMachine.get();
       }

       //--------------------------------
       // 
       if (sCommand == "-")
       {
         testMachine.decrementTape();               
       }

       //--------------------------------
       // 
       if (sCommand == "+")
       {
         testMachine.incrementTape();               
       }

       //--------------------------------
       // 
       if ((sCommand == "?") || (sCommand == "h"))
       {
         cout << sUserMessage;               
       }


       cout << testMachine.printState();
       cout << ">";
       //cin.getline(ccCommand);
       sCommand.clear();
       //sCommand.append(ccCommand);
       getline(cin, sCommand);
     } //-- while


    cout << testMachine.printState();
    

  } //-- main()
  




