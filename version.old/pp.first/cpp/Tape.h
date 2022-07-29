//string example
//http://www.yolinux.com/TUTORIALS/LinuxTutorialC++StringClass.html
/*
 *  
 *  Is a virtual tape 
 *
 *  @author http://bumble.sf.net
 */

// good examples
// http://www.josuttis.com/libbook/i18n/loc1.cpp.html
#if !defined (_TAPE_H)
#define _TAPE_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;
  
class Tape
{

  private: 
     //--------------------------------------------
     vector<string> array;
     //--------------------------------------------
     int pointer;

  public: 
     //--------------------------------------------
     Tape();
     //--------------------------------------------
     string toString();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     void put(string sNewElement);
     //--------------------------------------------
     string get();
     //--------------------------------------------
     void incrementPointer();
     //--------------------------------------------
     void decrementPointer();

};

#endif
