
/**
 *  
 *  generates a program to execute a script
 *
 *  @author http://bumble.sf.net
 */
 
#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <stdlib.h>
#include <ctype.h>
//#include "Interpret.h" 
//#include "Machine.h" 
#include "Program.h" 

using namespace std;
  
  //--------------------------------------------
  /** this program uses the Machine class to parse a script and 
   *  
   */ 
  Program::Program()
  {
    Machine cpu;
    string errors;
    string runTimeErrors;
    string runTimeWarnings;
    vector<Instruction> instructionSet;
    instructionPointer = 0;
  }

  //--------------------------------------------
  string Program::toString()
  {
    string sReturn("");
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "------------------------------" << endl;
    ssReturn << "--program--" << endl;
    ssReturn << "------------------------------" << endl;
    ssReturn << "IP:" << this->instructionPointer << endl;
    if (this->instructionSet.size() == 0)
    {
      ssReturn << "(no instructions)" << endl;
    }
    else
    {
     for (int ii = 0; ii < this->instructionSet.size(); ii++)
     {
       currentItem = this->instructionSet[ii];
       if (ii == this->instructionPointer)
         { ssReturn << " >"; }
       else
         { ssReturn << "  "; }
       ssReturn << ii << ": " << currentItem.toString() << endl;
     } //-- for
    } //-- if, else

    ssReturn << "--cpu--\n" << this->cpu.toString() << endl;
    ssReturn << "--errors--\n" << this->errors << endl;
    sReturn = ssReturn.str();
    return sReturn;

  } //-- method: toString


  //--------------------------------------------
  string Program::showErrors()
  {
    return this->errors;
  } //-- method:

  //--------------------------------------------
  int Program::length()
  {
    return this->instructionSet.size();
  }

  //--------------------------------------------
  int Program::size()
  {
    return this->instructionSet.size();
  }

  //--------------------------------------------
  int Program::pointer()
  {
    return this->instructionPointer;
  }

  //--------------------------------------------
  string Program::print()
  {
    return "";
  } //-- method:


  //--------------------------------------------
  string Program::contextListing()
  {
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "IP:" << this->instructionPointer << endl;
    if (this->instructionSet.size() == 0)
    {
      ssReturn << "(no instructions)" << endl;
      return ssReturn.str();
    }

    for (int ii = 0; ii < this->instructionSet.size(); ii++)
    {
      if ((ii > this->instructPointer - 2) || (ii < this->instructionPointer + 2))
      {
       currentItem = this->instructionSet[ii];
       if (ii == this->instructionPointer)
        { ssReturn << " >"; }
       else
        { ssReturn << "  "; }

       ssReturn << ii << ": " << currentItem.toString() << endl;
      } //-if
    } //--for
    
    return ssReturn.str();
  } //-- method: contextListing

  //--------------------------------------------
  string Program::listing()
  {
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "IP:" << this->instructionPointer << endl;
    if (this->instructionSet.size() == 0)
    {
      ssReturn << "(no instructions)" << endl;
      return ssReturn.str();
    }

    for (int ii = 0; ii < this->instructionSet.size(); ii++)
    {
      currentItem = this->instructionSet[ii];
      if (ii == this->instructionPointer)
        { ssReturn << " >"; }
      else
        { ssReturn << "  "; }

      ssReturn << ii << ": " << currentItem.toString() << endl;
    }
    
    return ssReturn.str();
  } //-- method: listing

  //--------------------------------------------
  string Program::showMachine()
  {
    return this->cpu.toString();
  } //-- method:

  //--------------------------------------------
  string Program::showNext()
  {
    stringstream ssReturn;

    if ((this->instructionPointer >= this->instructionSet.size()) ||
        (this->instructionSet.size() == 0))
    {
      this->errors.append("attempt to access instruction out of range (");
      //this->errors += this->instructionPointer;
      this->errors.append(")");

      return "";
    }
    ssReturn << this->instructionPointer << ":" << 
                this->instructionSet.at(this->instructionPointer).toString();
    return ssReturn.str();

  } //-- method:

  //--------------------------------------------
  bool Program::setTrueJump(int iInstruction, int iJump)
  {
    if (this->instructionSet.size() == 0)
    { 
      return false;
    }
    if (iInstruction >= this->instructionSet.size())
     { return false; }

    this->instructionSet.at(iInstruction).setTrueJump(iJump);
    return true;
  } //-- method:

  //--------------------------------------------
  /* when a test block is parsed (that is, when the closing brace is
     found, the jumps for the test instructions have to be set. */
  bool Program::setJumps(int iStartInstruction, int iEndInstruction, int iJump)
  {
    if (this->instructionSet.size() == 0)
    { 
      return false;
    }

    if (iEndInstruction >= this->instructionSet.size())
     { return false; }

    for (int ii = iStartInstruction; ii < iEndInstruction + 1; ii++)
    {
      if (ii < iEndInstruction)
       { this->instructionSet.at(ii).setFalseJump(ii + 1); }
      else
       { this->instructionSet.at(ii).setFalseJump(iJump); }

      this->instructionSet.at(ii).setTrueJump(iEndInstruction + 1);
 
    }
    return true;
  } //-- method:

  //--------------------------------------------
  bool Program::setFalseJump(int iInstruction, int iJump)
  {
    if (this->instructionSet.size() == 0)
    { 
      return false;
    }

    if (iInstruction >= this->instructionSet.size())
     { return false; }

    this->instructionSet.at(iInstruction).setFalseJump(iJump);
    return true;
  } //-- method:

  //--------------------------------------------
  void Program::addParameter(string sParameter)
  {
    if (this->instructionSet.size() == 0)
    { 
      this->instructionSet.at(this->instructionPointer - 1).addParameter(sParameter);
    }
  } //-- method:

  //--------------------------------------------
  void Program::addInstruction(Instruction newInstruction)
  {
    this->instructionSet.push_back(newInstruction);
  } //-- method:

  //--------------------------------------------
  void Program::getInstruction(int iInstruction)
  {
    return this->instructionSet.at(iInstruction);
  } //-- method:
         
  //--------------------------------------------
  void Program::setInstruction(int iInstruction, Instruction instNew)
  {
    //??
    this->instructionSet.at(iInstruction) = instNew;
  } //-- method:
         
  //--------------------------------------------
  void Program::run(istream& inputstream)
  {
    this->run(inputstream, false);
  }
  //--------------------------------------------
  void Program::run(istream& inputstream, bool bDebug)
  {
    if (bDebug)
    {
      cout << this->showMachine();
    }

    while (!inputstream.eof())
    {
      if (bDebug)
      {
        //cout << this->showMachine();
        cout << this->toString();
      }

      if (this->pointer() >= this->length())
      { this->reset(); }

      this->execute(inputstream); 
    }
  }

  //--------------------------------------------
  /* resets the instructionPointer to zero */
  void Program::reset()
  {
    this->instructionPointer = 0;
  }

  //--------------------------------------------
  bool Program::execute(istream& inputstream)
  {
    int iTrueJump = -1;
    int iFalseJump = -1;

    string sCommand("");
    string sParameterA("");
    string sParameterB("");
    Instruction currentInstruction;

    if ((this->instructionPointer >= this->instructionSet.size()) ||
        (this->instructionSet.size() == 0))
    {
      this->errors.append("attempt to access instruction out of range (");
      //this->errors += this->instructionPointer;
      this->errors.append(")\n");
      return;
    } 

    currentInstruction = this->instructionSet.at(this->instructionPointer);

     int iInstruction = this->instructionPointer;
     sCommand = this->currentInstruction.getCommand();

      if (sCommand == "add") 
      {
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }

        this->cpu.add(currentInstruction.getParameter(0)); 
        this->instructionPointer++;
      } 
      else if (sCommand == "nop") 
      {
        this->instructionPointer++;
      } 
      else if (sCommand == "crash") 
      {
        exit(-1);
      }
      else if (sCommand == "flag") 
      {
        this->cpu.setFlag(); 
        this->instructionPointer++;
      }
      else if (sCommand == "print") 
      {
        this->cpu.print(); 
        this->instructionPointer++;
      }
      else if (sCommand == "clear") 
      {
        this->cpu.clear(); 
        this->instructionPointer++;
      }
      else if (sCommand == "read") 
      {
        /* if in a stack reduction loop, no read should be performed */
        if (!cpu.stackFlag())
        {
          this->cpu.readNext(inputstream); 
          this->instructionPointer++;
        }
      }
      else if (sCommand == "push") 
      {
        this->cpu.push(); 
        this->instructionPointer++;
      }
      else if (sCommand == "pop") 
      {
        this->cpu.pop(); 
        this->instructionPointer++;
      }
      else if (sCommand == "put") 
      {
        this->cpu.put(); 
        this->instructionPointer++;
      }
      else if (sCommand == "get") 
      {
        this->cpu.get(); 
        this->instructionPointer++;
      }
      else if (sCommand == "++") 
      {
        this->cpu.incrementTape(); 
        this->instructionPointer++;
      }
      else if (sCommand == "--") 
      {
        this->cpu.decrementTape(); 
        this->instructionPointer++;
      }
      else if (sCommand == "newline") 
      {
        this->cpu.newline(); 
        this->instructionPointer++;
      }
      else if (sCommand == "indent") 
      {
        this->cpu.indent(); 
        this->instructionPointer++;
      }
      else if (sCommand == "clip") 
      {
        this->cpu.clip(); 
        this->instructionPointer++;
      }
      else if (sCommand == "state") 
      {
        cout << this->cpu.printState(); 
        this->instructionPointer++;
      }
      else if (sCommand == "while") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }
        this->cpu.readWhile(inputstream, sParameterA); 
        this->instructionPointer++;
      }
      else if (sCommand == "whilenot") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }
        this->cpu.readWhileNot(inputstream, sParameterA); 
        this->instructionPointer++;
      }
      else if (sCommand == "until") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }

        if (this->instructionSet[instructionPointer].size() == 2)
        { 
          this->cpu.readUntil(inputstream, sParameterA); 
        }  
        else if (this->instructionSet[instructionPointer].size() == 3)
        { 
          this->cpu.readUntil(inputstream, sParameterA, sParameterB); 
        }  

        this->instructionPointer++;
      }
      else if (sCommand == "replace") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }
        this->cpu.replace(sParameterA, sParameterB); 
        this->instructionPointer++;
      }
      else if (sCommand == "test-is") 
      { 
        /* implement negation by swapping the jumps for tests */
        if (currentInstruction.isNegated())
        { currentInstruction.swapJumps(); }

        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }

        if (!cpu.workspace() == currentInstruction.getParameter(0))
        { this->instructionPointer = currentInstruction.getTrueJump(); } 
        else
        { this->instructionPointer = currentInstruction.getFalseJump(); }

      } 
      else if (sCommand == "test-begins-with") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }
        //-- include negation
        if (currentInstruction.isNegated())
        { currentInstruction.swapJumps(); }
        if (!cpu.beginsWith(currentInstruction.getParameter(0)))
        { this->instructionPointer = currentInstruction.getFalseJump(); } 
        else
        { this->instructionPointer = currentInstruction.getTrueJump(); }

      } 
      else if (sCommand == "test-class") 
      { 
        if (currentInstruction.size() < 1)
        {
          this->runTimeErrors.append("parameter required");
          return false;
        }
        if (sParameterA == ":space:")
        {
          //this->instructionPointer = currentInstruction.getJump(); 
        } 
        else
        {
          this->instructionPointer++; 
        }
      } 
      else
      {
        this->runTimeErrors.append("unrecognized instruction at ");
        //this->runTimeErrors += this->instructionPointer;
        this->runTimeErrors.append("(" + this->instructionSet[this->instructionPointer].toString() + ")");
        this->instructionPointer++;
        return false;
      } //-- if

     return true;  
  } //-- method: execute

 

