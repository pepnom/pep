
 /**
 *  
 *  This file provides a simpile program to test the 
 *  Instruction class (http://bumble.sf.net/machine/Instruction.h )
 *  The instruction class is used by and is a member of the
 *  Program class (http://bumble.sf.net/machine/Program.h ).
 *  The Instruction class represents one instruction from a 
 *  compiled parse-language script. For more documentation about this
 *  parse-language see http://bumble.sf.net/machine/doc
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

     sUserMessage.append("This program is designed to test the Instruction class");
     sUserMessage.append("\n");
     sUserMessage.append("See http://bumble.sf.net/machine for more information");
     sUserMessage.append("\n");
     sUserMessage.append("Commands;");
     sUserMessage.append("\n");
     sUserMessage.append(" a - add a parameter");
     sUserMessage.append("\n");
     sUserMessage.append(" j - set the true-jump parameter");
     sUserMessage.append("\n");
     sUserMessage.append(" f - set the false-jump parameter");
     sUserMessage.append("\n");
     sUserMessage.append(" n - toggle the negation flag");
     sUserMessage.append("\n");
     sUserMessage.append(" c - set the command []");
     sUserMessage.append("\n");
     sUserMessage.append(" p - print the instruction (in script format) [print]");
     sUserMessage.append("\n");
     sUserMessage.append(" d - display the instruction [display]");
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
       cout << "command[" << sCommand << "]" << endl;

       //--------------------------------
       if (sCommand.at(0) == 'c')
       {
         testInstruction.setCommand(sCommand.substr(1));               
       }

       //--------------------------------
       if ((sCommand == "p") || (sCommand == "print"))
       {
         cout << testInstruction.print();
       }

       //--------------------------------
       if ((sCommand == "d") || (sCommand == "display"))
       {
         cout << testInstruction.toString();
       }

       //--------------------------------
       if ((sCommand == "n") || (sCommand == "negate"))
       {
         cout << testInstruction.toggleNegation();
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
       if (sCommand.at(0) == 'f') 
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "The 'f' command requires an argument: \n" 
	        << "eg f10 sets the false-jump parameter to 10";
	 }
	 else
	 {
	   testInstruction.setFalseJump(atoi(sCommand.substr(1).c_str())); 
	 }
       }

       //--------------------------------
       if (sCommand.at(0) == 'j')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "The 'j' command requires an argument: \n" 
	        << "eg j10 sets the true-jump parameter to 10";
	 }
	 else
	 {
	   testInstruction.setTrueJump(atoi(sCommand.substr(1).c_str())); 
	 }
       }

       //--------------------------------
       // 
       if ((sCommand == "?") || (sCommand == "h"))
       {
         cout << sUserMessage;               
       }


       cout << testInstruction.toString() << endl;
       cout << ">";
       sCommand.clear();
       getline(cin, sCommand);
     } //-- while


    cout << testInstruction.print();
    

  } //-- main()
  



