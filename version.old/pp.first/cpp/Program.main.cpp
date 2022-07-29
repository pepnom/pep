
 /**
 *  
 * This class represents a compiled program of instructions
 * which have been obtained by parsing an input script written
 * in a language which appears syntactically similar to the 
 * sed stream editor and which shares a few ideas with sed
   but which has been redesigned to make it suitable for the 
   parsing of generative or backus naur languages.

   More documentation is available at http://bumble.sf.net/machine

   Like sed, the commands in the script file of the language are
   executed one time for each cycle of the engine. In sed one
   cycle corresponds to one line of the input text stream and thus
   the sed commands in a script are executed one time for each
   line of the input stream (speaking generally). however in the 
   parse language the commands in a script are executed one time
   for -character- in the input stream, in order to allow the 
   input stream to be properly tokenized and parsed. This means
   that an interpreter for the language really needs to create
   some compiled form of the instructions in the script in order to
   overcome the inefficiency of reparsing the input script each time
   a new character is read from the input stream. this is the 
   explanation for the current class, which represents that compiled
   program.
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
#include "Program.h" 

using namespace std;
 


  //--------------------------------------------
  /** provides a command loop to test the Instruction class */
  int main(int argc, char* argv[]) 
  {
    
    string sUsageMessage("");
    sUsageMessage.append("usage: Program file");
    sUsageMessage.append("\n");
    sUsageMessage.append("test the Program class which is part of the ");
    sUsageMessage.append("\n");
    sUsageMessage.append("parse-language system. More information is available at");
    sUsageMessage.append("\n");
    sUsageMessage.append("http://bumble.sf.net/machine/");
    sUsageMessage.append("\n");
    ifstream in;
    string sMessage("");

    if (argc != 2) {
       cout << sUsageMessage;
       exit(-1);
    }
    else
    {
      in.open(argv[1]);
      if (!in.is_open())
      {
        cout << "couldnt open file " << argv[1] << endl;
      }
    } //-- if
 

    Program testProgram;

     string sCommand("");
     string sUserMessage("");

     sUserMessage.append("Tests the Program class ");
     sUserMessage.append("\n");
     sUserMessage.append("Commands;");
     sUserMessage.append("\n");
     sUserMessage.append(" a - add an instruction");
     sUserMessage.append("\n");
     sUserMessage.append(" x - execute the current instruction [exe]");
     sUserMessage.append("\n");
     sUserMessage.append(" r - run the program [run]");
     sUserMessage.append("\n");
     sUserMessage.append(" s - reset instruction pointer to 0 [reset]");
     sUserMessage.append("\n");
     sUserMessage.append(" p - display everything [print]");
     sUserMessage.append("\n");
     sUserMessage.append(" l - print a program listing [list]");
     sUserMessage.append("\n");
     sUserMessage.append(" m - show the state of the machine [machine]");
     sUserMessage.append("\n");
     sUserMessage.append(" c - display the current instruction");
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
     cout << sCommand;
     while (sCommand != "q")
     {
       //cout << "last command [" << sCommand << "]" << endl;

       //--------------------------------
       if ((sCommand == "p") || (sCommand == "print"))
       {
         cout << testProgram.toString();
       }

       //--------------------------------
       if ((sCommand == "l") || (sCommand == "list"))
       {
         cout << testProgram.listing();
       }

       //--------------------------------
       if ((sCommand == "m") || (sCommand == "machine"))
       {
         cout << testProgram.showMachine();
       }

       //--------------------------------
       if ((sCommand == "c"))
       {
         cout << "current instruction:" << testProgram.showNext() << endl;
       }

       //--------------------------------
       if ((sCommand == "x") || (sCommand == "exe"))
       {
         testProgram.execute(in);
       }

       //--------------------------------
       if ((sCommand == "r") || (sCommand == "run"))
       {
         testProgram.run(in);
       }

       //--------------------------------
       if ((sCommand == "s") || (sCommand == "reset"))
       {
         testProgram.reset();
       }

       //--------------------------------
       if (sCommand.at(0) == 'a')
       {
         if (sCommand.length() == 1)
         {
           cout << "The 'a' command requires an argument: \n" 
                << "eg aBig adds the string big as parameter" << endl;
         }
         else
         { 
           int iFirstComma = sCommand.find(",");
           if (iFirstComma != string::npos)
           {
             string sParameter1 = sCommand.substr(1, iFirstComma - 1);
             string sParameter2 = sCommand.substr(iFirstComma + 1);
             cout << "p1:" << sParameter1 << "\n"
                  << "p2:" << sParameter2 << "\n";

             int iSecondComma = sParameter2.find(",");
             if (iSecondComma != string::npos)
             {
                string sParameter3 = sParameter2.substr(iSecondComma + 1);
                sParameter2 = sParameter2.substr(0, iSecondComma);
                cout << "p1:" << sParameter1 << "\n"
                     << "p2:" << sParameter2 << "\n"
                     << "p3:" << sParameter3 << "\n";
               testProgram.addInstruction(sParameter1, sParameter2, sParameter3);
             }
             else
             { 
               testProgram.addInstruction(sParameter1, sParameter2);
             }  
           }
           else 
           {
           testProgram.addInstruction(sCommand.substr(1)); 
           }
         }
       }


       //--------------------------------
       // 
       if ((sCommand == "?") || (sCommand == "h"))
       {
         cout << sUserMessage;               
       }


       //cout << testProgram.print();
       cout << ">";
       sCommand.clear();
       getline(cin, sCommand);
     } //-- while


    cout << testProgram.print();
    

  } //-- main()
  



