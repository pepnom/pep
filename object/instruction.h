#ifndef INSTRUCTIONH
#define INSTRUCTIONH


// a compiled instruction parsed from the script text, or
// user input
// eg: add 'xx'
struct Instruction {
  enum Command command;
  struct Parameter a;
  struct Parameter b;
};

//struct Instruction * newInstruction(struct Instruction * ii, enum Command cc) {
void newInstruction(struct Instruction * ii, enum Command cc);

// probably a memcpy of old and new would do the trick
// struct Instruction * copyInstruction(

void copyInstruction(struct Instruction * new, struct Instruction * old);

/*
display the instruction with parameters and parameter types.
*/
void debugInstruction(struct Instruction * ii);

/*
 show the instruction in a format suitable for program listings

 Use the escapeSpecial() function below to 
 to display special chars (eg \n \r ...) as escaped sequences
 in a different colour to the rest of the text.
 
 todo:!! 
  write function printParameter() to display a parameter
  with its datatype
*/
void printInstruction(struct Instruction * ii);

// show the instruction in a format suitable for program listings
// with special chars \n \r etc shown escaped in different colour
void printEscapedInstruction(struct Instruction * ii);

// this is used by saveAssembledProgram() or writeAssembledProgram()
// special and delim chars are escaped, eg: \n \r \] \"
// 
void writeInstruction(struct Instruction * ii, FILE * file);

// print to file the instruction with a line number and colours 
// this function is used in the validateProgram function to display
// or log program errors. We also need something like this in
// saveAssembledProgram()
// 
void numberedInstruction(struct Instruction * instruction, int lineNumber, FILE * file); 

#endif
