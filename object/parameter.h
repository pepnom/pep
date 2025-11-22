
#ifndef PARAMETERH
#define PARAMETERH 


// parameters within a compiled instruction. They may have
// various data types; text numeric etc (eg: a jump to another instruction)
// hence the need for a union structure.
// 

struct Parameter {
  //int datatype;
  //the datatype determines how the parameter will be used.
  //eg: int as a jump target, text as something to add to workspace,
  //    range in a test etc
  enum Type { 
    TEXT,    // some string 
    INT,     // integer number
    CLASS,   // a character class (eg alnum, alpha, digit, xdigit)
    RANGE,   // range of characters eg a-z
    LIST,    // list of characters eg abxy 
    UNSET    // no value
  } datatype;

  union {
    char text[200];        // probably should be char * text, with malloc
    int number;            // eg for jumps (jump 6 - jump to instruction 6)
    int (* classFn)(int);  // a function pointer for the ctype.h functions
    char range[2];         // first, last
    char list[200];        // should be malloced 
  };  
};

/* this prints a compact display of the parameter suitable
   for including as part of printInstruction(). See showParameter()
   for a longer format */
int printParameter(struct Parameter parameter);

char * scanParameter(char * param, char * text, int line);

#endif
