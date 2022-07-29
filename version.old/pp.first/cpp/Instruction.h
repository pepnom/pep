/*
 *  
 *  http://bumble.sourceforge.net/machine
 *
 *  @author http://bumble.sf.net
 */

#if !defined (_INSTRUCTION_H)
#define _INSTRUCTION_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;
  
/*
 This class represents an instruction which will be 
 executed by the Program class using the "virtual machine"
 Machine class. a Program consists of a series of 
 Instructions which will be executed for each "cycle" of the
 program. An instruction consists of a command (analogous to
 the opcode of a real machine) and a series of parameters.
 For a "test" type instruction the format may be used:
   test, negation, truejump, falsejump, test-text
 This requires further explanation

*/

class Instruction
{

  private: 
     //--------------------------------------------
     /* the type of command to be executed, such as "add", "clear",... */
     string command;
     //--------------------------------------------
     /* a set of parameters for the command. These will have a 
        different meaning depending on the command that is to be
        executed */
     vector<string> parameters;
     //--------------------------------------------
     /* used for negative test instructions */
     bool negation;
     //--------------------------------------------
     /* for tests and jump instructions */
     int trueJump;
     //--------------------------------------------
     /* for tests and jump instructions, jumps over multiple tests */
     int falseJump;
     
  public: 
     //--------------------------------------------
     Instruction();
     //--------------------------------------------
     Instruction(string sCommand);
     //--------------------------------------------
     Instruction(string sCommand, string sParameter);
     //--------------------------------------------
     Instruction(string sCommand, string sFirstParameter, string sSecondParameter);
     //--------------------------------------------
     Instruction(string sCommand, vector<string> vParameters);
     //--------------------------------------------
     /* return a text representation of the instruction
        including the command and the parameters for the command */
     string toString();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     /* returns the number of parameters which the instruction
        has. */
     int size();
     //--------------------------------------------
     void toggleNegation();
     //--------------------------------------------
     /* determines if the negation flag is set, which is used for
        "test" style instructions to permit that the test also
        has a "not" version eg: !/token/{ ... } */
     bool isNegated();
     //--------------------------------------------
     void setCommand(string sValue);
     //--------------------------------------------
     string getCommand();
     //--------------------------------------------
     /* gets the value of the jump when a "test" type
        gnstruction evaluates to true. The jump is an integer
        value which represents the next instruction which 
        will be executed by the virtual machine. */
     int getTrueJump();
     //--------------------------------------------
     void setTrueJump(int iJump);
     //--------------------------------------------
     int getFalseJump();
     //--------------------------------------------
     void setFalseJump(int iJump);
     //--------------------------------------------
     /* is used as a way to implement negation of a test */
     void swapJumps();
     //--------------------------------------------
     /* determines if the instruction has any parameters.
        certain instructions require instructions and others
        do not. This functionality could be obtained using
        the "size" method as well */
     bool hasParameters();
     //--------------------------------------------
     void addParameter(string sValue);
     //--------------------------------------------
     string getParameter(int iParameter);
     //--------------------------------------------
};

#endif
