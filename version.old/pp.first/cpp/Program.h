/*
 *  
 *  The program class represents a "compiled" version of 
    a parsing scripting languagei which is based apon a 
    virtual machine. More documentation is availabe
    for the language and the code at 
    http://bumble.sf.net/machine/

    The purpose of this class is to allow a more efficient 
    execution of an interpreter by removing the necessity to
    reparse the input script file for each cycle of the 
    execution.

    This class can be tested by using the Program.main.cpp
    program which provides a command loop to add instructions
    to a test program and execute instructions one at a time
    while watching the state of the underlying virtual machine.
    
 *
 *  @author http://bumble.sf.net
 */

#if !defined (_PROGRAM_H)
#define _PROGRAM_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Machine.h"
#include "Instruction.h"

using namespace std;
  
class Program
{

  private: 
     //--------------------------------------------
     vector<Instruction> instructionSet;
     //--------------------------------------------
     Machine cpu;
     //--------------------------------------------
     int instructionPointer;
     //--------------------------------------------
     string errors; 
     //--------------------------------------------
     string runTimeErrors; 
     //--------------------------------------------
     string runTimeWarnings; 

  public: 
     //--------------------------------------------
     Program();
     //--------------------------------------------
     /* provides a plain text representation of the program, including
        the state of the machine (or cpu), a listing of all the instructions
        within the instruction set and run-time errors and warnings and other 
        errors which may have occurred */
     string toString();
     //--------------------------------------------
     /* displays runtime errors, such as a lack of required parameter for
        a given command. */
     string showErrors();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     /* lists all the instructions currently contained in the program
        instruction set. The phrase "instruction set" does not refer to the 
        possible types of instructions, but refers to what instructions are 
        in the program. */
     string listing();
     //--------------------------------------------
     /* provides a short listing of a few instructions before and 
        after the current instruction (as determined by the instruction
        pointer) */
     string contextListing();
     //--------------------------------------------
     /* provides a plain text representation of the current state of the 
        internal machine (which is a "virtual machine" or cpu). This representation
        is provided by the Machine class */
     string showMachine();
     //--------------------------------------------
     /* provides a text representation of the next instruction
        which will be executed by the program. This is determined
        by the value of the instruction pointer */
     string showNext();
     //--------------------------------------------
     /* sets the instruction pointer back to zero. this is used
        to begin a new "cycle" of the program. A new cycle should
        be executed for each character in the input-stream */
     void reset();
     //--------------------------------------------
     /* returns the number of instructions in the program,
        the same as the "size" method */
     int length();
     //--------------------------------------------
     /* returns the number of instructions which are contained
        in the program */
     int size();
     //--------------------------------------------
     /* returns the instruction pointer, which is the value
        which determines which instruction in the program will
        be next executed. The "test" instructions will change the 
        value of the instruction pointer in order to carry out
        jumps within the program */
     int pointer();
     //--------------------------------------------
     /* executes, using the virtual machine, the current instruction 
        in the program using the given input stream. The current 
        instruction is the instruction being pointed to by the 
        instruction pointer (in the same manner as a real cpu) */
     void execute(istream& inputstream);
     //--------------------------------------------
     /* executes the given instruction. this method is not used */
     void executeInstruction(int iInstruction);
     //--------------------------------------------
     /* add a parameter to the last instruction in the program */
     void addParameter(string sParameter);
     //--------------------------------------------
     void setTrueJump(int iInstruction, int iJump);
     //--------------------------------------------
     void setFalseJump(int iInstruction, int iJump);
     //--------------------------------------------
     /* when a test-block is parsed all the jumps for test conditions 
        must be set */
     void setJumps(int iStartInstruction, int iEndInstruction, int iJump);
     //--------------------------------------------
     void addInstruction(Instruction newInstruction);
     //--------------------------------------------
     /* return a particular instruction from the program */
     void getInstruction(int iInstruction);
     //--------------------------------------------
     void setInstruction(int iInstruction, Instruction instNew);
     //--------------------------------------------
     void run(istream& inputstream);
     //--------------------------------------------
     /* runs the program using the given input stream. the program
        has an implicit loop, in the sense that it runs each instruction
        in the program once for each character in the input stream, in
        the same manner that the sed stream editor runs each command in a 
        script once for each line in an input script. (note, in the 
        current implementation there appears to be no implicit "read"
        operation, in other words the loop is an infinite loop.
        if the bDebug parameter is true then the class prints the state
        of the machine and other information for each cycle of the program */ 
     void run(istream& inputstream, bool bDebug);
};

#endif
