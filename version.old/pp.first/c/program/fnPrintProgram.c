
void fnPrintProgram(Program * program)
{
  
  int ii;

  printf("IP=%d: Size=%d \n", program->instructionPointer, program->size);
  printf("Maximum program length  =%d \n", MAXPROGRAMLENGTH);
  printf("Maximum nesting of '{'  =%d \n", MAXNESTING);
  printf("Maximum argument length =%d \n", MAXARGUMENTLENGTH);
  printf("Maximum tape length     =%d \n", MAXTAPELENGTH);
  printf("Compilation time (msec) =%d \n", program->compileTime);
  printf("Execution time          =%d \n", program->executionTime);
  printf("List file name          =%s \n", program->listFile);
  printf("List file error         =%d \n", program->fileError);
  printf("Brace stack=(");
  for (ii = 0; ii < MAXNESTING - 1; ii++)
  {
    printf("%d, ", program->braceStack[ii]);
  }  
  printf("%d)\n", program->braceStack[ii]);

  for (ii = 0; ii < program->size; ii++)
  {
    
    if (ii == program->instructionPointer)
      { printf("> "); }
    else
      { printf("  "); }

    printf("%d:", ii);
    fnPrintInstruction(program->instructionSet[ii]);
    printf("\n");
  }
   
}

