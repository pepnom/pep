# this file tests the code assembly process as carried out by
# the loadAssembledProgram() function. It includes numerous error 
# cases for parse checking
1:
2: while [::]
3: while [:]
4: while [:and:]
5: whilenot [:space:]
6: add " \" \r \n \"; \\ "
7: add " \n"
8:
: add
9: add " \t "
10: until [a-z]
11: while [b-q]
12: while [abc \];\\ \r \t ]
