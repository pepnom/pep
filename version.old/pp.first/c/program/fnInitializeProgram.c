

  /* -------------------------------------------*/
  void fnInitializeProgram(Program * program)
  {
    int ii;
    program->size = 0;
    program->instructionPointer = 0;
    program->compileTime = -1;
    program->executionTime = -1;
    strcpy(program->listFile, "");
    program->fileError = FALSE;

    for (ii = 0; ii < MAXPROGRAMLENGTH; ii++)
    {
      fnInitializeInstruction(&program->instructionSet[ii]);
    }

    for (ii = 0; ii < MAXNESTING; ii++)
    {
      program->braceStack[ii] = -1;
    }
  }
