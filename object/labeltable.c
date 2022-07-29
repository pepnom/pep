
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
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "colours.h"
#include "labeltable.h"

/* print out the label table, just to make sure that it is
   getting built correctly. this table can be, and is, a property
   of the Program structure */
void printJumpTable(struct Label table[]) {
  int ii;
  printf("%s[Program label table]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < 1000; ii++) {
     if (table[ii].text[0] == 0) break;
     printf("%s%15s:%s %d \n", 
       BROWN, table[ii].text, NORMAL, table[ii].instructNumber);
  }
}

/* given a text label get the line/instruction number from the table
   or else return -1
*/
int getJump(char * label, struct Label table[]) {
  int ii;
  for (ii = 0; ii < 1000; ii++) {
     // if not found
     if (table[ii].text[0] == 0) return -1;
     // return number if label found
     if (strcmp(table[ii].text, label) == 0) {
       return table[ii].instructNumber;
     }
  }
  return -1;
}

/* 
 return label for given instruction, or else null
 an empty string means "not found"
*/
char * getLabel(int instruction, struct Label table[]) {
  int ii = 0;
  for (ii = 0; ii < 1000; ii++) {
     // if not found
     if (table[ii].text[0] == 0) break;
     if (table[ii].instructNumber == instruction) {
       return table[ii].text;
     }
  }
  return table[ii].text;
}


/* just build an array with label line numbers
   returns the number of labels found
*/
int buildJumpTable(struct Label table[], FILE * file) {
  char buffer[1000];
  char * line;
  int lineNumber;
  char text[2001];
  char label[64]; // hold the asm label 
  int ii = 0;     // instruction number
  int ll = 0;     // label number 

  while (fgets(buffer, 999, file) != NULL) {
    // printf("%s", line);
    line = buffer;
    line[strlen(line) - 1] = '\0';
    text[0] = '\0';
    lineNumber = -1;

    // Trim leading space
    while (isspace((unsigned char)*line)) line++;
    // skip blank lines
    if (*line == 0) continue; 
    // lines starting with # are comments
    // if (line[0] == '#') continue;
    // lines starting with # are 1 line comments
    // lines starting with #* are multiline comments (to *#) 
    if (line[0] == '#') {
      if (strlen(line) == 1) continue;
      if (line[1] == '*') {
        
        line = line + 2;
        //printf("multiline comment! %s", line);
        // multiline comment #* ... need to search for next *#
        if(strstr(line, "*#") != NULL) {
          line = strstr(line, "*#") + 2;
        } else {
          // search next lines for *#
          while (fgets(buffer, 999, file) != NULL) {
            line = buffer;
            line[strlen(line) - 1] = '\0';
            if (strstr(line, "*#") != NULL) {
              line = strstr(line, "*#") + 2;
              break;
            }
          }
        }
      } else continue;
    }

    sscanf(line, "%d: %2000[^\n]", &lineNumber, text);
    //debug: check that the arguments are getting parsed properly
    //printf("parsed - lineNumber=%d, text=%s \n", lineNumber, text);

    if (lineNumber == -1) {
      // if no line number, parse anyway
      sscanf(line, "%s", text);
      // only whitespace on line, so skip it 
      if (text[0] == '\0') { continue; }
      sscanf(line, "%2000[^\n]", text);
    }

    // skip empty lines 
    if (text[0] == '\0') { continue; }

    // handle assembler labels using the jumpTable 
    // labels are lines ending in ':'
    if (text[strlen(text) - 1] == ':') {
      sscanf(text, "%64[^:]:", label);
      // printf("New Label '%s' at instruction %d \n", label, ii);
      table[ll].instructNumber = ii;
      strcpy(table[ll].text, label);
      ll++;     // increment label number
      continue;
    }
    // increment instruction number
    ii++;
  } // while
  return ll;
}

//-------------------------------
// unit test code

  // compile with gcc -DUNITTEST
  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif


