
/* -------------------------------------------*/
int fnExecuteInstruction (Program * program, Machine * machine,
   FILE * inputstream)
{
  Instruction * instruction =
    &program->instructionSet[program->instructionPointer];

  FILE * fListFile;     //-- for the list file test
  char * sClass; //--
  char sTemp[TEMPSTRINGSIZE];
  char sTemp2[TEMPSTRINGSIZE];
  char sFileLine[MAXFILELINELENGTH];
  char * pTemp;
  Element * ee;
  pTemp = sTemp;
  int ii;
  int iOldStackSize = 0;
  Element * eCurrentTapeElement;

  switch (instruction->command)
  {
    /* -------------------------------------*/
    case ADD:
      machine = appendToWorkspace(machine, instruction->argument1); 
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case CLEAR:
      *machine->workspace = '\0';
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case PRINT:
      printf("%s", machine->workspace);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case STATE:
      fnPrintMachine(machine);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case REPLACE:
      // fnStringReplace(machine->workspace);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case INDENT:      
      if (strlen(machine->workspace) >= TEMPSTRINGSIZE)
      {
        pTemp = (char *) realloc(pTemp, strlen(machine->workspace) * sizeof(char) + GROWFACTOR);
      }

      if (pTemp == NULL)
      {
        printf ("\nError reallocating memory for a temporary string \n");
        exit (1);
      }
 
      strcpy(pTemp, machine->workspace);
      strcpy(machine->workspace, "  ");
  
      for (ii = 0; ii < strlen(pTemp); ii++)
      {
        sprintf(sTemp2, "%c", pTemp[ii]);
        machine = appendToWorkspace(machine, sTemp2);
        if (pTemp[ii] == '\n') 
        {
           machine = appendToWorkspace(machine, "  ");
        } 
    
      } //-- for 

      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case CLIP:
      if (strlen(machine->workspace) > 0)
        { machine->workspace[strlen(machine->workspace) - 1] = '\0'; }
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case CLOP:
      if (strlen(machine->workspace) > 0)
      {
        for (ii = 0; ii < strlen(machine->workspace); ii++)
        {
          machine->workspace[ii] = machine->workspace[ii + 1]; 
        }
      }
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case NEWLINE:
      strcat(machine->workspace, "\n");
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case PUSH:
      if (*machine->workspace == '\0')
      {
        program->instructionPointer++;
        break;
      }
 
      machine->workspace++;
      while ((*machine->workspace != '*') &&
             (*machine->workspace !='\0'))
      {
        machine->workspace++;
      }

      if (*machine->workspace == '*')
      {
        machine->workspace++;
      }

      // printf("machine->tapepointer = %d \n", machine->tapepointer);
      // printf("&machine->tape[MAXTAPELENGTH] =x %d \n", &machine->tape[MAXTAPELENGTH]);
      if (machine->tapepointer < &machine->tape[MAXTAPELENGTH - 1])
      {
         machine->tapepointer++;
      }
      else
      {
        printf("Maximum tape length (%d) exceeded \n", MAXTAPELENGTH);
        printf("The possible remedies are: \n");
        printf(" a. increase the MAXTAPELENGTH constant in 'library.c' and recompile \n");
        printf(" b. rewrite the script to use less tape elements. \n");
        printf(" c. use the -d switch to view a trace of the script. \n");
        printf("Below is shown the final state of the virtual machine \n\n");
        fnPrintMachineState(machine);
        exit(2);
      }

      machine->stacksize++;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case POP:
      if (machine->workspace == machine->stack)
      {
        program->instructionPointer++;
        break;
      }
       
      machine->workspace--;
      if (machine->workspace == machine->stack)
      {
        machine->tapepointer--;
        machine->stacksize--;
        program->instructionPointer++;
        break;
      }
     
      if (*machine->workspace == '*')
       { machine->workspace--; }

      while ((*machine->workspace != '*') &&
             (machine->workspace != machine->stack))
      {
        machine->workspace--;
      }

      if (*machine->workspace == '*')
        { machine->workspace++; }

      if (machine->tapepointer > &machine->tape[0])
       { machine->tapepointer--; }

      machine->stacksize--;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case PUT:
      if (strlen(machine->workspace) >= (machine->tapepointer->size) - 1)
      {
	machine->tapepointer->size = strlen(machine->workspace) + GROWFACTOR;
        machine->tapepointer->text = 
          (char *) realloc(machine->tapepointer->text, machine->tapepointer->size * sizeof(char));
      }

      if (machine->tapepointer->text == NULL)
      {
         printf ("\nError reallocating memory for a tape element \n");
         exit (1);
      }

      strcpy(machine->tapepointer->text, machine->workspace);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case GET:

      machine = appendToWorkspace(machine, machine->tapepointer->text);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case INCREMENT:
      if (machine->tapepointer >= &machine->tape[MAXTAPELENGTH])
      {
        printf("maximum tape length exceeded (%d)\n", MAXTAPELENGTH);
        printf("change the MAXTAPELENGTH constant and recompile \n");
        exit(2);
      }
      machine->tapepointer++;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case DECREMENT:
      if (machine->tapepointer > &machine->tape[0])
       { machine->tapepointer--; }
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case READ:
      if (machine->peep == EOF)
      {
        return ENDOFSTREAM;
      }
      sprintf(sTemp, "%c", machine->peep);
      machine = appendToWorkspace(machine, sTemp);
      machine->peep = getc(inputstream);
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case UNTIL:
      if (machine->peep == EOF)
      {
        program->instructionPointer++;
        break;
      }

      int bLoop = TRUE;
      sprintf(sTemp, "%c", machine->peep);
      machine = appendToWorkspace(machine, sTemp);
      machine->peep = getc(inputstream);
     
      if (fnStringEndsWith(machine->workspace, instruction->argument1) == TRUE)
      {
        bLoop = FALSE;
      }

      while (bLoop == TRUE)
      {

        sprintf(sTemp, "%c", machine->peep);
        machine = appendToWorkspace(machine, sTemp);
        machine->peep = getc(inputstream);
        if (machine->peep == EOF)
        {
          program->instructionPointer++;
          break;
        }
    
        if (fnStringEndsWith(machine->workspace, instruction->argument1) == TRUE)
        {
          bLoop = FALSE;
          if ((fnStringEndsWith(machine->workspace, instruction->argument2) == TRUE) &&
              (strlen(instruction->argument2) > 0))
          {
            bLoop = TRUE;
          }
        }
      } //-- while

      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case WHILE:
      if (machine->peep == EOF)
      {
        program->instructionPointer++;
        break;
      }

      bLoop = TRUE;
      sClass = instruction->argument1;
      if ((fnIsInClass(sClass, machine->peep) == FALSE) &&
            (instruction->isNegated == FALSE))
      {
        program->instructionPointer++;
        break;
      }
      if ((fnIsInClass(sClass, machine->peep) == TRUE) &&
            (instruction->isNegated == TRUE))
      {
        program->instructionPointer++;
        break;
      }
 

      while (bLoop)
      {

        sprintf(sTemp, "%c", machine->peep);
        machine = appendToWorkspace(machine, sTemp);
        machine->peep = getc(inputstream);

        if (machine->peep == EOF)
        {
          bLoop = FALSE;
        }
    
        if ((fnIsInClass(sClass, machine->peep) == FALSE) &&
            (instruction->isNegated == FALSE))
        {
          bLoop = FALSE;
        }
        if ((fnIsInClass(sClass, machine->peep) == TRUE) &&
            (instruction->isNegated == TRUE))
        {
          bLoop = FALSE;
        }
     } //-- while

     
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case WHILENOT:
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case TESTIS:
      if (strcmp(machine->workspace, instruction->argument1) == 0)
        { program->instructionPointer = instruction->trueJump; }
      else
        { program->instructionPointer = instruction->falseJump; }
      break;
    /* -------------------------------------*/
    case TESTLIST:
      fListFile = fopen(instruction->argument1, "r");
      strcpy(program->listFile, instruction->argument1);
      if (fListFile == NULL)
      {
        program->fileError = TRUE;
        program->instructionPointer++;
        break;
      } 

      program->instructionPointer = instruction->falseJump; 
      while (fgets(sFileLine, MAXFILELINELENGTH, fListFile) != NULL)      
      {
        fnStringTrim(sFileLine);
        // printf ("sFileLine=[%s]\n", sFileLine);
        if (strcmp(sFileLine, machine->workspace) == 0)
          {program->instructionPointer = instruction->trueJump; }
      } 

      fclose(fListFile);
      break;
    /* -------------------------------------*/
    case TESTBEGINS:
      if (fnStringBeginsWith(machine->workspace, instruction->argument1))
         { program->instructionPointer = instruction->trueJump; }
      else
        { program->instructionPointer = instruction->falseJump; }
      break;
    /* -------------------------------------*/
    case TESTENDS:
      if (fnStringEndsWith(machine->workspace, instruction->argument1))
         { program->instructionPointer = instruction->trueJump; }
      else
        { program->instructionPointer = instruction->falseJump; }
      break;
    /* -------------------------------------*/
    case TESTCLASS:
      sClass = instruction->argument1;
      program->instructionPointer = instruction->falseJump; 
      if (fnIsInClass(sClass, *machine->workspace))
        { program->instructionPointer = instruction->trueJump; }

      break;
    /* -------------------------------------*/
    case TESTTAPE:
      if (strcmp(machine->workspace, machine->tapepointer->text) == 0)
        { program->instructionPointer = instruction->trueJump; }
      else
        { program->instructionPointer = instruction->falseJump; }
      break;
    /* -------------------------------------*/
    case TESTEOF:
      if (machine->peep == EOF)
        { program->instructionPointer = instruction->trueJump; }
      else
        { program->instructionPointer = instruction->falseJump; }
      break;
    /* -------------------------------------*/
    case COUNT:
      /* add the counter to the workspace */
      /* add the text to the workspace 'count' times */
      if (strlen(instruction->argument1) == 0)
      {
        sprintf(sTemp, "%d", machine->counter);
        machine = appendToWorkspace(machine, sTemp);        
      }
      else
      {
        strcpy(sTemp, "");
        for (ii = 0; ii < machine->counter; ii++)
         { strcat(sTemp, instruction->argument1); }
        machine = appendToWorkspace(machine, sTemp);        
       
      }

      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case INCC:
      machine->counter++;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case DECC:
      machine->counter--;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case CRASH:
      program->instructionPointer++;
      return ENDOFSTREAM;
      break;
    /* -------------------------------------*/
    case JUMP:
      program->instructionPointer = instruction->trueJump; 
      break;
    /* -------------------------------------*/
    case LABEL:
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case UNDEFINED: /* the default */
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case NOP:     /* no operation */
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case ZERO:    /* set the counter to zero */
      machine->counter = 0;
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case OPENBRACE:
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    case CLOSEBRACE:
      program->instructionPointer++;
      break;
    /* -------------------------------------*/
    default:
      printf(
        "runtime error: unexpected instruction at instruction %d",
        program->instructionPointer);
      exit(2);
      break;

    
  } //-- switch

  machine->lastoperation = instruction->command;
  return TRUE;

} //-- fnExecuteInstruction
