
#ifndef LABELTABLEH 
#define LABELTABLEH 

/*
  This file contains methods to create and view a table of 
  labels and (relative/absolute) jumps. This table is used to 
  convert the line labels in the intermediate-format "assembly"
  parse-machine programs into line number targets.

  Line labels are essential for hand-coding assembly parse
  machine scripts. However, it is only really necessary to 
  hand-code these assembly programs in the case of "asm.pp". Once
  asm.pp is implemented we can use the parse script language in
  all cases.
  
*/

// one item in the label jump table (to convert asm labels to
// instruction/line numbers
struct Label {
  char text[64];       // label maximum 64 characters  
  int instructNumber;  // line/instruction number equivalent for label
};

/* print out the label table, just to make sure that it is
   getting built correctly. this table can be, and is, a property
   of the Program structure */
void printJumpTable(struct Label table[]);

/* given a text label get the line/instruction number from the table
   or else return -1
*/
int getJump(char * label, struct Label table[]);

/* 
 return label for given instruction, or else null
 an empty string means "not found"
*/
char * getLabel(int instruction, struct Label table[]);

/* just build an array with label line numbers
   returns the number of labels found
*/
int buildJumpTable(struct Label table[], FILE * file);

#endif
