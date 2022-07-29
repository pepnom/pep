
/* -------------------------------------------*/
void fnCompile(Program * program, FILE * inputstream)
{
   int iCharacter; 
   int iLabelLine = -1;  
   int iLineMark = 1;
   int iLineCharacterMark = 1;
   int iLineCount = 1;
   int iCharacterCount = 1;
   int iLineCharacterCount = 1;
   int iOpenBraceCount = 0;
   int iCloseBraceCount = 0;
   int iTextLength = 0;
   int iTestPointer = 0;
   int iCommand = 0;
   clock_t tBeginCompile;
   clock_t tEndCompile;
   /* pointer into the program.braceStack array */
   int * pBraceStackPointer; 

   char sText[TEXTBUFFERSIZE];

   char sCommandName[20] = "";

   //FILE * inputstream = stdin;
   //Program program;
   //fnInitializeProgram(&program);

   tBeginCompile = clock(); 
   pBraceStackPointer = &program->braceStack[0];
   Instruction * instruction = &program->instructionSet[0];

   
   iCharacter = getc(inputstream);

   while (iCharacter != EOF)
   {
    
      if (program->size >= MAXPROGRAMLENGTH - 1)
      {
	      
         fprintf(stderr, "line %d: the maximum number of script statements \n",
                iLineCount);
         fprintf(stderr, "(%d) is exceeded. This may be remedied \n",
                MAXPROGRAMLENGTH);
         fprintf(stderr, "by changing the MAXPROGRAMLENGTH constant \n");
         fprintf(stderr, "in the file 'library.c' and recompiling. \n");
         exit(2);
      }
   
     switch (iCharacter)
     {
       /*-----------------------------------------*/ 
       case '"':
         iLineMark = iLineCount;
         switch (instruction->command)
         {
           case UNDEFINED:
             fprintf(stderr, "misplaced quote (\"): line %d, char %d", 
               iLineCount, iLineCharacterCount);
             exit(2);
           case CLEAR:
           case CLIP:
           case CLOP:
           case CRASH:
           case POP:
           case PUSH:
           case PUT:
           case GET:
           case INDENT:
           case INCREMENT:
           case DECREMENT:
           case INCC:
           case DECC:
           case NEWLINE:
           case READ:
           case TESTIS:
           case TESTBEGINS:
           case TESTCLASS:
           case TESTLIST:
           case TESTEOF:
           case STATE:
           case NOP:
           case JUMP:
           case ZERO:
             fnCommandToString(sCommandName, instruction->command);
             fprintf(stderr, 
              "\n Syntax error: Command %s cannot take an argument: line %d, char %d", 
              sCommandName, iLineCount, iLineCharacterCount);
             exit(2);
         } //-- switch

         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "stray quote (\") at line %d, char %d \n", iLineCount, iLineCharacterCount);
           exit(2);
         }

         if (iCharacter == '"')
         {
           fprintf(stderr, 
            "\n Script syntax error: empty quotes (\"\") at line %d, char %d \n",
            iLineCount, iLineCharacterCount);
           exit(2);
         }

         while ((iCharacter != EOF) && (iCharacter != '"') &&
                (iTextLength < MAXARGUMENTLENGTH))
         {
           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           { iLineCount++; iLineCharacterCount = 1; }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, "unterminated quote (\") starting at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr, 
             "\n Script error: the argument (text between quotes) at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n",
             MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter == '"')
         {
           if (strlen(instruction->argument1) == 0)
             { strcpy(instruction->argument1, sText); }
           else if (strlen(instruction->argument2) == 0)
             { strcpy(instruction->argument2, sText); }
           else
           {
             fprintf(stderr, "The instruction at line %d has too many arguments \n");
             fprintf(stderr, "The maximum permitted is 2. \n");
             exit(2);
           }
         } 
         else
         {  
           fprintf(stderr, "error parsing quoted text at line %d. \n",
             iLineCount, iLineCharacterCount); 
           fprintf(stderr, "this error indicates a bug in the code 'library.c' \n");
           exit(2); 
         }
         break;
       /*-----------------------------------------*/ 
       case '\'':
         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;
         switch (instruction->command)
         {
           case UNDEFINED:
             fprintf(stderr,
               "\n script syntax error: misplaced quote ('): line %d, char %d",
               iLineCount, iLineCharacterCount);
             exit(2);
           case CLEAR:
           case CLIP:
           case CLOP:
           case CRASH:
           case POP:
           case PUSH:
           case PUT:
           case GET:
           case INDENT:
           case INCREMENT:
           case DECREMENT:
           case INCC:
           case DECC:
           case NEWLINE:
           case READ:
           case TESTIS:
           case TESTBEGINS:
           case TESTENDS:
           case TESTCLASS:
           case TESTLIST:
           case TESTEOF:
           case STATE:
           case NOP:
           case JUMP: 
           case CHECK:
           case ZERO:
             fnCommandToString(sCommandName, instruction->command);
             fprintf(stderr, "syntax error: command %s cannot take an argument: line %d", 
               sCommandName, iLineCount, iLineCharacterCount);
             exit(2);
         }
         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "\n Script syntax error: stray quote (') at line %d, char %d \n",
             iLineCount, iLineCharacterCount);
           exit(2);
         }

         if (iCharacter == '\'')
         {
           fprintf(stderr,
              "\n Script syntax error: empty quotes ('') at line %d, char %d \n",
              iLineCount, iLineCharacterCount);
           exit(2);
         }

         while ((iCharacter != EOF) &&
                (iCharacter != '\'') &&
                (iTextLength < MAXARGUMENTLENGTH))
         {
           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           {
             iLineCount++;
             iLineCharacterCount = 1;
           }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "\n Script syntax error: unterminated quote (') at line %d, char %d \n",
             iLineCount, iLineCharacterCount);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr,
             "\n Script error: the argument (text between quotes) at line %d, char %d \n",
             iLineCount, iLineCharacterCount);
           fprintf(stderr, "is too long. The maximum is %d characters \n",
             MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter != '\'')
         {  
           fprintf(stderr, 
             "error parsing quoted text at line %d. \n", 
             iLineCount, iLineCharacterCount);  
           fprintf(stderr,
             "this error indicates a bug in the code 'library.c' near line 600 \n");
           exit(2); 
         }

         if (iCharacter == '\'')
         {
           if (strlen(instruction->argument1) == 0)
             { strcpy(instruction->argument1, sText); }
           else if (strlen(instruction->argument2) == 0)
             { strcpy(instruction->argument2, sText); }
           else
           {
             fprintf(stderr,
               "\n Script syntax error: The instruction at line %d, char %d has too many arguments (2 is the maximum number)\n",
               iLineCount, iLineCharacterCount);
             fprintf(stderr, "The maximum permitted is 2. \n");
             exit(2);
           }
         } //-- if

         break;
    
       /*-----------------------------------------*/ 
       //-- ignore comments in the script 

       case '#':
         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;
         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr,
             "syntax error: unterminated comment '#...#'  at at end of script, line %d, char %d \n",
             iLineCount, iLineCharacterCount);
           exit(2);
         }

         if (iCharacter == '#')
         {
           break;
         }

         while ((iCharacter != EOF) && (iCharacter != '#'))
         {
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           {
             iLineCount++;
             iLineCharacterCount = 1;
           }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr,
              "script error: unterminated comment (#..#) starting at line %d, char %d \n",
              iLineMark, iLineCharacterMark);
           exit(2);
         }

         if (iCharacter != '#')
         {  
           fprintf(stderr, "error parsing comment at line %d, char %d. \n", iLineMark, iLineCharacterMark); 
           fprintf(stderr, "this error indicates a bug in the code 'library.c' near line 700 \n");
           exit(2); 
         }

         break;
    
    
       /*-----------------------------------------*/ 
       // ignore whitespace
       case '\r':
       case '\t':
       case ' ': break;
       /*-----------------------------------------*/ 
       // parse 'begin tests'  <...> 
       case '<':
         switch(instruction->command)
         {
           case UNDEFINED:
             break;
           default:
             fprintf(stderr, 
               "Line %d, char %d: script error before '<' character. \n", 
               iLineCount, iLineCharacterCount);
             fprintf(stderr, "(missing semi-colon?)\n");
             exit(2);
         }
         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;
         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "script ends badly, unterminated test '<...>' starting at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           exit(2);
         }

         //-- End of file test can be written '<>'
         if (iCharacter == '>')
         {
           if (strlen(instruction->argument1) != 0)
           {
             fprintf(stderr, 
               "syntax error: The eof test '<>' at line %d, char %d already has an argument \n",
               iLineMark, iLineCharacterMark);
             exit(2);
           }

           instruction->command = TESTEOF;
           program->size++;
           instruction++;
	   break;
         }

         while ((iCharacter != EOF) && (iCharacter != '>') && (iTextLength < MAXARGUMENTLENGTH))
         {
           /* handle the escape sequence */
           if (iCharacter == '\\')
           {
             iCharacter = getc(inputstream);
             if (iCharacter == EOF)
             {
               fprintf(stderr, 
                 "script ends badly: unterminated test '<...>', and backslash starting at line %d, char %d \n", 
                 iLineMark, iLineCharacterMark);
               exit(2);
             }
           }

           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           {
             iLineCount++;
             iLineCharacterCount = 1;
           }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "unterminated test '<...>' starting at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr, "the test '<...>' starting at line %d, char %d \n", iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n", MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter != '>')
         { 
           fprintf(stderr, "error parsing test at line %d, char %d. \n",
              iLineCount, iLineCharacterCount); 
           fprintf(stderr, "code bug near line 740 of library.c \n");
           exit(2); 
         }

         if (iCharacter == '>')
         {
           if (strlen(instruction->argument1) == 0)
           {
             instruction->command = TESTBEGINS;
             strcpy(instruction->argument1, sText);
             
             program->size++;
             instruction++;
           }
           else
           {
             fprintf(stderr, "The test '<...>' at line %d, char %d already has an argument \n",
               iLineMark, iLineCharacterMark);
             fprintf(stderr, "code bug near line 740 of library.c \n");
             exit(2);
           }
         } 
         break;
       /*-----------------------------------------*/ 
       // parse 'ends tests'  (...) 
       case '(':
         switch(instruction->command)
         {
           case UNDEFINED:
             break;
           default:
             fprintf(stderr, 
               "Line %d, char %d: script error before '(' character. \n", 
               iLineCount, iLineCharacterCount);
             fprintf(stderr, "(missing semi-colon?)\n");
             exit(2);
         }
         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;
         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "script ends badly, unterminated test '(...)' starting at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           exit(2);
         }

         //-- some test can be written '()'
         if (iCharacter == ')')
         {
           fprintf(stderr, 
             "empty test '()' at line %d, char %d \n", iLineMark, iLineCharacterMark);
           exit(2);
         }

         while ((iCharacter != EOF) && (iCharacter != ')') && (iTextLength < MAXARGUMENTLENGTH))
         {
           /* handle the escape sequence */
           if (iCharacter == '\\')
           {
             iCharacter = getc(inputstream);
             if (iCharacter == EOF)
             {
               fprintf(stderr, 
                 "script ends badly: unterminated test '(...)', and backslash starting at line %d, char %d \n", 
                 iLineMark, iLineCharacterMark);
               exit(2);
             }
           }

           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           {
             iLineCount++;
             iLineCharacterCount = 1;
           }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, 
             "unterminated test '(...)' starting at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr, "the test '(...)' starting at line %d, char %d \n", iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n", MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter != ')')
         { 
           fprintf(stderr, "error parsing test at line %d, char %d. \n",
              iLineCount, iLineCharacterCount); 
           fprintf(stderr, "code bug near line 740 of library.c \n");
           exit(2); 
         }

         if (iCharacter == ')')
         {
           if (strlen(instruction->argument1) == 0)
           {
             instruction->command = TESTENDS;
             strcpy(instruction->argument1, sText);
             
             program->size++;
             instruction++;
           }
           else
           {
             fprintf(stderr, "The test '(...)' at line %d, char %d already has an argument \n",
               iLineMark, iLineCharacterMark);
             fprintf(stderr, "code bug near line 1312 of library.c \n");
             exit(2);
           }
         } 
         break;
       /*-----------------------------------------*/ 
       //-- parse 'class tests' 
       case '[': 
         switch(instruction->command)
         {
           case UNDEFINED:
             break;
           default:
             fprintf(stderr,
                "Line %d, char %d: syntax error before '[' character. \n", 
                iLineCount, iLineCharacterCount);
             fprintf(stderr, "(missing semi-colon?)\n");
             exit(2);
         }
         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;
         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, "script ends badly, unterminated test \n");
           exit(2);
         }

         if (iCharacter == ']')
         {
           fprintf(stderr, 
             "empty test '[]' at line %d, char %d \n", iLineMark, iLineCharacterMark);
           exit(2);
         }

         while ((iCharacter != EOF) && (iCharacter != ']') && (iTextLength < MAXARGUMENTLENGTH))
         {
           /* handle the escape sequence */
           if (iCharacter == '\\')
           {
             iCharacter = getc(inputstream);
             if (iCharacter == EOF)
             {
               fprintf(stderr, 
                "script ends badly: unterminated test, and backslash starting at line %d, char %d",
                iLineMark, iLineCharacterMark);
               exit(2);
             }
           }

           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
           {
              iLineCount++;
              iLineCharacterCount = 1;
           }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, "unterminated test '[]' starting at line %d, char \n", iLineMark, iLineCharacterCount);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr, 
             "script error: the class test '[...]' starting at line %d, char %d \n", 
             iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n", MAXARGUMENTLENGTH);
           fprintf(stderr, "This limit can be changed by editing the value ");
           fprintf(stderr, "of MAXARGUMENTLENGTH in library.c and recompiling  \n");
           exit(2);
         }

         if (iCharacter == ']')
         {
           if (strlen(instruction->argument1) == 0)
           {
             instruction->command = TESTCLASS;
             strcpy(instruction->argument1, sText); 
             program->size++;
             instruction++;
           }
           else
           {
             fprintf(stderr,
               "The test '[...]' starting at line %d, char %d already has an argument \n",
               iLineMark, iLineCharacterMark);
             fprintf(stderr, "This indicates a code bug near line 820 of library.c \n");
             exit(2);
           }
         } 
         else
         { 
           fprintf(stderr, "error parsing test at line %d. \n", iLineCount, iLineCharacterCount); 
           fprintf(stderr, "code bug near line 820 of library.c \n");
           exit(2); 
         }
         break;
       /*-----------------------------------------*/ 
       case '=':
         switch(instruction->command)
         {
           case UNDEFINED:
             break;
           default:
             fprintf(stderr, "Line %d, char %d: syntax error before '=' character. \n", 
               iLineCount, iLineCharacterCount);
             fprintf(stderr, "(missing semi-colon?)\n");
             exit(2);
         }

         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;

         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, "The '=' at line %d, char %d, seems misplaced \n", iLineMark, iLineCharacterMark);
           exit(2);
         }

         /* the test == is used to determine if the workspace is 
            the same as the current tape cell */
         if (iCharacter == '=')
         {
           if (strlen(instruction->argument1) != 0)
           {
             fprintf(stderr, 
               "syntax error: The tape test '==' at line %d, char %d already has an argument \n",
               iLineMark, iLineCharacterMark);
             exit(2);
           }

           instruction->command = TESTTAPE;
           program->size++;
           instruction++;
	   break;
         }

         while ((iCharacter != EOF) && (iCharacter != '=') && (iTextLength < MAXARGUMENTLENGTH))
         {
           /* handle the escape sequence */
           if (iCharacter == '\\')
           {
             iCharacter = getc(inputstream);
             if (iCharacter == EOF)
             {
               fprintf(stderr, "unterminated test (=...=), and backslash starting at line %d, char %d", 
                 iLineMark, iLineCharacterMark);
               exit(2);
             }
           }

           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
            { iLineCount++; }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, "unterminated test (=...=) at line %d, char %d \n",
              iLineMark, iLineCharacterCount);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr, "the test (==) at line %d, char %d \n", iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n", MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter != '=')
         { 
           fprintf(stderr, "error parsing test at line %d, char %d\n", iLineMark, iLineCharacterMark); exit(2); 
           fprintf(stderr, "this error indicates a bug in the code 'library.c' near line 1160 \n");
           exit(2); 
         }

         if (strlen(instruction->argument1) == 0)
         {
             instruction->command = TESTLIST;
             strcpy(instruction->argument1, sText); 
             program->size++;
             instruction++;
         }
         else
         {
             fprintf(stderr, "syntax error: The test (==) at line %d already has an argument \n",
                     iLineMark);
             fprintf(stderr, " \n");
             exit(2);
         }
         break;
       /*-----------------------------------------*/ 
       case '/':
         switch(instruction->command)
         {
           case UNDEFINED:
             break;
           default:
             fprintf(stderr,
                "Line %d, char %d: syntax error before '/' character. \n",
                 iLineCount, iLineCharacterCount);
             fprintf(stderr, "(missing semi-colon?)\n");
             exit(2);
         }

         iLineMark = iLineCount;
         iLineCharacterMark = iLineCharacterCount;

         strcpy(sText, "");
         iTextLength = 0;
         iCharacter = getc(inputstream);
         iCharacterCount++;
         if (iCharacter == EOF)
         {
           fprintf(stderr, "The '/' at line %d, char %d, seems misplaced \n", iLineMark, iLineCharacterMark);
           exit(2);
         }

         /*
         if (iCharacter == '/')
         {
           fprintf(stderr, "empty test (//) at line %d, char %d \n", iLineMark, iLineCharacterMark);
           exit(2);
         }
         */

         while ((iCharacter != EOF) && (iCharacter != '/') && (iTextLength < MAXARGUMENTLENGTH))
         {
           /* handle the escape sequence */
           if (iCharacter == '\\')
           {
             iCharacter = getc(inputstream);
             if (iCharacter == EOF)
             {
               fprintf(stderr, "unterminated test, and backslash starting at line %d, char %d", 
                 iLineMark, iLineCharacterMark);
               exit(2);
             }
           }

           sprintf(sText, "%s%c", sText, iCharacter);
           iTextLength++;
           iCharacter = getc(inputstream);
           if (iCharacter == '\n') 
            { iLineCount++; }
           iCharacterCount++;
         }
         
         if (iCharacter == EOF)
         {
           fprintf(stderr, "unterminated test (//) at line %d, char %d \n", iLineMark, iLineCharacterCount);
           exit(2);
         }

         if (iTextLength >= MAXARGUMENTLENGTH)
         {
           fprintf(stderr,
             "the test (//) at line %d, char %d \n",
             iLineMark, iLineCharacterMark);
           fprintf(stderr, "is too long. The maximum is %d characters \n",
             MAXARGUMENTLENGTH);
           exit(2);
         }

         if (iCharacter == '/')
         {
           if (strlen(instruction->argument1) == 0)
           {
             instruction->command = TESTIS;
             strcpy(instruction->argument1, sText); 
             program->size++;
             instruction++;
           }
           else
           {
             fprintf(stderr, "The test (//) at line %d already has an argument \n",
                     iLineMark);
             fprintf(stderr, " \n");
             exit(2);
           }
         } 
         else
         { 
           fprintf(stderr, "error parsing test at line %d, char %d\n", iLineMark, iLineCharacterMark); exit(2); 
           fprintf(stderr, "this error indicates a bug in the code 'library.c' \n");
           exit(2); 
         }
         break;
       /*-----------------------------------------*/ 
       case '\n':
         iLineCount++;
         iLineCharacterCount = 1;
         break;          
       /*-----------------------------------------*/ 
       case '!': //negations only before tests or a while command
         switch(instruction->command)
         {
           case UNDEFINED:
             if (instruction->isNegated == TRUE)
               { instruction->isNegated = FALSE; }
             else if (instruction->isNegated == FALSE)
               { instruction->isNegated = TRUE; }
             break;
           case WHILE:
             if (instruction->isNegated == TRUE)
               { instruction->isNegated = FALSE; }
             else if (instruction->isNegated == FALSE)
               { instruction->isNegated = TRUE; }
             break;
          default:
             fprintf(stderr,
               "Line %d, char %d: syntax error before '!' character. \n",
               iLineCount, iLineCharacterCount);
             fprintf(stderr, "\n");
             exit(2);
         }
         break;
       /*-----------------------------------------*/ 
       case ';':
         switch (instruction->command)
         {
           case UNDEFINED:
             fprintf(stderr, 
              "The semi-colon (;) at line %d, char %d seems misplaced. \n", 
              iLineCount, iLineCharacterCount);
             exit(2);
           case ADD:
           case WHILE:
           case UNTIL:
             if (strlen(instruction->argument1) == 0)
             {
               fnCommandToString(sCommandName, instruction->command);
               fprintf(stderr, 
                  "The command '%s' requires an argument: line %d, char %d \n",
                   sCommandName, iLineCount, iLineCharacterCount);
               exit(2);
             }  
             program->size++;
             instruction++;
             break;
           case LABEL:
             iLabelLine = program->size;
             program->size++;
             instruction++;
             break;
           case CHECK:
             //-- convert 'checks' to 'jumps' and set the jump line
             instruction->command = JUMP;
             if (iLabelLine == -1)
             {
               fprintf(stderr, 
                  "The check must be preceded by the '@@@' label: line %d, char %d \n",
                   iLineCount, iLineCharacterCount);
               exit(2);
             }
             instruction->trueJump = iLabelLine;
             program->size++;
             instruction++;
             break;
           default:
             program->size++;
             instruction++;
         } // switch
         break;
       /*-----------------------------------------*/ 
       case '{':
         // assign jumps
         if (instruction->command != UNDEFINED)
         {  
           fprintf(stderr, 
             "Line %d, char %d: syntax error before '{' \n", iLineCount, iLineCharacterCount);
           exit(2); 
         }  
         instruction->command = OPENBRACE;
         iOpenBraceCount++;
         if (program->size == 0)
         { 
           fprintf(stderr, "error: A script cannot start with '{' \n");
           exit(2);
         }  

         instruction--;
         switch (instruction->command)
         {
           case TESTIS:
           case TESTBEGINS:
           case TESTENDS:
           case TESTCLASS:
           case TESTEOF:
           case TESTTAPE:
           case TESTLIST:
             if (instruction->isNegated)
               { instruction->falseJump = program->size; }
             else
               { instruction->trueJump = program->size; }

             if (program->size == 1)
             {
               *pBraceStackPointer = program->size;
               pBraceStackPointer++;
               program->size++;
               instruction = &program->instructionSet[program->size];
               break;
             }  

             instruction--;
             iTestPointer = program->size - 1;
             while ((instruction->command == TESTIS) ||
                    (instruction->command == TESTBEGINS) ||
                    (instruction->command == TESTENDS) ||
                    (instruction->command == TESTLIST) ||
                    (instruction->command == TESTTAPE) ||
                    (instruction->command == TESTEOF) ||
                    (instruction->command == TESTCLASS))
             {
               if (instruction->isNegated)
               {
                 instruction->falseJump = program->size;  
                 instruction->trueJump = iTestPointer;   
               } 
               else
               {
                 instruction->falseJump = iTestPointer;
                 instruction->trueJump = program->size;
               }
               iTestPointer--;
               if (iTestPointer < 0) { break; }
               instruction--;
             } //-- while

            
             /* load the brace stack for calculated jumps */ 
             *pBraceStackPointer = program->size;
             pBraceStackPointer++;
             program->size++;
             instruction = &program->instructionSet[program->size];

             break;
           default:
             fprintf(stderr,
               "script error: The '{' character at line %d, char %d is not preceded by a test \n",
               iLineCount, iLineCharacterCount);
             exit(2); 
             break;
         } //-- switch    
         break;
       /*-----------------------------------------*/ 
       case '}':
         iCloseBraceCount++;
         if (iCloseBraceCount > iOpenBraceCount)
         {
           fprintf(stderr,
             "script error: the '}' character at line %d, char %d seems misplaced. \n",
             iLineCount, iLineCharacterCount);
           fprintf(stderr,
             "The are more close braces than open braces \n");
           exit(2); 
         }

         if (instruction->command != UNDEFINED)
         {  
           fnPrintInstruction(*instruction);
           fprintf(stderr, 
             "script error: The '}' character at line %d, char %d seems misplaced. \n",
             iLineCount, iLineCharacterCount);
           exit(2); 
         }  
         instruction->command = CLOSEBRACE;
         /* set the jumps for the test of the current brace pair, using the brace stack
          * to find the corresponding open brace */
         pBraceStackPointer--;
         instruction = &program->instructionSet[*pBraceStackPointer - 1];
         if (instruction->isNegated)
         { 
           instruction->trueJump = program->size;
           //instruction->trueJump = *pBraceStackPointer;
         }
         else  
         {  
           //instruction->falseJump = *pBraceStackPointer;
           instruction->falseJump = program->size;
         }  
         program->size++;
         instruction = &program->instructionSet[program->size];
         break;

       /*-----------------------------------------*/ 
       // commands
       default:
         strcpy(sText, "");

         if (iCharacter == '\0')
         { break; }

         if (!islower(iCharacter) && (iCharacter != '+') && (iCharacter != '-') && (iCharacter != '@'))
         {
           fprintf(stderr, "line %d: illegal character '%c' (%d) \n",
                   iLineCount, iCharacter, iCharacter);
           fprintf(stderr, "  this character may only occur between quotes");
           fprintf(stderr, "  or within tests.");
           exit(2);
         }

         while ((islower(iCharacter) || (iCharacter == '+') || (iCharacter == '@') || (iCharacter == '-')) 
                && (strlen(sText) < TEXTBUFFERSIZE))
         {
           sprintf(sText, "%s%c", sText, iCharacter);
           iCharacter = getc(inputstream);
           iCharacterCount++;
           iLineCharacterCount++;
         } //-- while

         if (strlen(sText) >= TEXTBUFFERSIZE)
         {
           fprintf(stderr, "syntax error: unrecognized command %s, line %d, char %d",
             sText, iLineCount, iLineCharacterCount);
           exit(2);
         }

         iCommand = -1;
         iCommand = fnCommandFromString(sText);
         if (iCommand == UNKNOWN)
         {
           fprintf(stderr, "line %d: unrecognized command '%s'",
                   iLineCount, sText);
           exit(2);
         }

         if (instruction->command != UNDEFINED)
         {
           fprintf(stderr, "line %d: syntax error before command '%s'",
                   iLineCount, sText);
           exit(2);
         }

         if (iCharacter == EOF)
         {
           fprintf(stderr, "script error: script ends badly");
           exit(2);
         }
       
         instruction->command = iCommand;

        /* process the character currently in iCharacter */
         continue;
         /* fnPrintInstruction(*instruction); */

     } //-- switch		 

 
     iCharacter = getc(inputstream);
     iCharacterCount++;
     iLineCharacterCount++;

     int bDebug = 0;
     if (bDebug)
     {
       printf("current char=%c \n", iCharacter);
       fnPrintProgram(program);
     }

   } //-- while	   

   //fnPrintInstruction(*instruction);

   if (iOpenBraceCount != iCloseBraceCount)
   {
     printf("error: unbalanced braces: \n", iLineCount);
     printf("open braces=%d, ", iOpenBraceCount);
     printf("close braces=%d \n", iCloseBraceCount);
     exit(2);
   }

   if (instruction->command != UNDEFINED)
   {
     fnCommandToString(sText, instruction->command);
     fprintf(stderr, "line %d: unfinished command '%s'.",
             iLineCount, sText);
     exit(2);
   }

   /* add a final read and jump(0) command so that the script loops */
   instruction->command = READ;
   program->size++;
   instruction = &program->instructionSet[program->size];
   instruction->command = JUMP;
   instruction->trueJump = 0;
   program->size++;
   instruction = &program->instructionSet[program->size];

   /* compute the compile time */
   tEndCompile = clock();
   int iCompileTime = (int) (((tEndCompile - tBeginCompile) * 1000)/ CLOCKS_PER_SEC);
   program->compileTime = iCompileTime;
   //printf("------------------- \n", iLineCount);
   //printf("     Lines parsed: %d \n", iLineCount);
   //printf("Characters parsed: %d \n\n", iCharacterCount);
   //printf("--Program Listing-- \n");

   //fnPrintProgram(program);

} //-- fnCompile
