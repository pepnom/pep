
 /**
 *  
 *  Is a virtual machine for parsing. It has some ideas
 *  drawn from the sed tool.
 *
 *  @author http://bumble.sf.net
 */
// good examples
// http://www.josuttis.com/libbook/i18n/loc1.cpp.html

#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <ctype.h>
#include "Instruction.h" 

using namespace std;
 


  //--------------------------------------------
  /** provides a command loop to test the Instruction class */
  int main(int argc, char* argv[]) 
  {
    
    string sUsageMessage("");
    sUsageMessage.append("usage: Instruction");
    sUsageMessage.append("\n");
    ifstream in;
    string sMessage("");

    if (argc == 5) {
       cout << sUsageMessage;
       exit(-1);
    }
    else
    {
    } //-- if
 

    Instruction testInstruction;

     string sCommand("");
     string sUserMessage("");

     sUserMessage.append("Commands;");
     sUserMessage.append("\n");
     sUserMessage.append(" a - add a parameter");
     sUserMessage.append("\n");
     sUserMessage.append(" c - set the command []");
     sUserMessage.append("\n");
     sUserMessage.append(" p - print the contents of the instruction [print]");
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
     while (sCommand != "q")
     {
       cout << "command[" << sCommand << "]";

       //--------------------------------
       if (sCommand.at(0) == 'c')
       {
         testInstruction.setCommand(sCommand.substr(1));               
       }

       //--------------------------------
       if ((sCommand == "p") || (sCommand == "print"))
       {
         cout << testInstruction.toString();
       }

       //--------------------------------
       if (sCommand.at(0) == 'a')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "The 'a' command requires an argument: \n" 
	        << "eg aBig adds the string big as parameter";
	 }
	 else
	 {
	   testInstruction.addParameter(sCommand.substr(1)); 
	 }
       }


       //--------------------------------
       // 
       if ((sCommand == "?") || (sCommand == "h"))
       {
         cout << sUserMessage;               
       }


       cout << testInstruction.print();
       cout << ">";
       sCommand.clear();
       getline(cin, sCommand);
     } //-- while


    cout << testInstruction.print();
    

  } //-- main()
  



