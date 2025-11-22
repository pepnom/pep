
/*

ABOUT

  - www.nomlang.org/ 
    the new home site for the nom language and pep 
    (text register) virtual machine. This contains lots of documentation.
  - http://bumble.sourceforge.net/books/pars/
    And older site which has a mirror of the code 

  This file and the other files in this folder /books/pars/object/ implements
  a virtual machine which is particularly apt for parsing context free
  languages. Along with the files /books/pars/asm.pp and /books/pars/compile.pp
  a simple scripting language is also implemented. The language is very
  similar to the "sed" stream editor syntax.

  With this parsing machine and script language it is simple, enjoyable
  and interesting to implement LR "bottom-up" shift-reduce parsers and 
  translators/compilers. Both the "lexing" and "parsing/compiling" phases
  are contained in the one script file.

  The parsing machine consists of a string stack, a string "workspace" (or
  string accumulator), a "tape" (string array) structure, 1 "look-ahead"
  character (called the "peep"), an integer accumulator (for simple
  counting), 1 flag register (true or false), and several other utility
  registers. In general all instructions operate on the "workspace" buffer,
  sometimes in conjuntion with other registers and machine data structures.

  This stack/tape combination, which is maintained in synchronisation through
  "pop" and "push" commands, appears to be able to recognise and transform
  the nested structures of context-free languages (as well as some, limited,
  context-sensitive languages. It is such a simple idea, its hard to think
  why it hasnt been implemented before (perhaps it has, and I just dont know
  about it).

  The general aim of the machine is to create unix-style stream filters
  which can parse and transform context-free language patterns. This means
  that it receives a text stream as input (which could represent data
  or code in some context-free language) and produces a transformed 
  text stream as output (which may represent the data transformed to a 
  different format, or the code transformed into a different language).

  This file also includes a testing "interpreter" with help information
  and interactive commands for inspecting the machine and program 
  state, and stepping through scripts.

PARSING WITH THE MACHINE

  The general procedure for parsing is to 'put' the attribute into the tape,
  then clear the workspace, create a token and push that token onto the stack.
  Then a series of tokens are popped off the stack, compared for sequences,
  and 'reduced' as in a bnf (backus-naur form) grammar. At the same time the
  values or attributes of the tokens are got from the tape and transformed as
  required, and then put back into the tape or printed to stdout.

  tokenA*tokenB* the asterix comes at the end of the token.

LIMITATIONS 

 * It may be tricky to parse indentation "offside" languages with
   the machine (such as python), but the "mark" and "go" commands
   may provide a way to do this.

 * Because I have only recently managed to code a decent working
 implementation of this parsing machine (as of August 2019) I am only now
 discovering the limitations of the machine.

 * It seems very difficult to use the parsing machine to transform
   N.Wirth's ebnf extensions, such as optionals [...], continuations
   {...} and groupings (...). An example of the problem can be seen 
   if we have the rule:
     r = (a|b)(c|d).
   (I am using N.Wirth's ebnf syntax, also known as WSN- wirth syntax
    notation).
     In order to use the parse machine (and language) we need this to
     be transformed into the format
     r= ac|ad|bc|bd.
     In other words, we need to factor out all grouping brackets (and 
     the same applies to optionals and repetitions.) and leave only
     the alternation symbol "|". This is quite easy to do by hand, but
     I can not currently see a way to do it with the parse machine, because
     the parse machine can only do simple string manipulations (append/
     replace etc).

 * Currently the machine is using standard c chars which is clearly
   inadequate for real world text transformation purposes. One solution
   is to create a "wchar" c version. But this may not be necessary, 
   since we can write a java/python/ruby/javascript machine object,
   and then use a script like translate.c.pss to compile scripts into
   that new target language.

 * It may be difficult/impossible to implement context-sensitive features
   of programming languages (such as type-checking) using this machine.
   But perhaps, the machine could be used in combination with other techniques
   to implement these features. If we add an "attribute dictionary" to
   each tape-cell then this task becomes easy. The attribute dictionary
   is a set of name/value pairs. Or eache attribute could be a kind
   of "protocol/interface" (in the oo sense of the word). I think this 
   idea has great potential because the protocol/interface idea seems 
   to be the most flexible and powerful way to express complex 
   interdependant ontologies. This would also enhance the ability of 
   the machine to translate human language. So we might have a 
   "plurality" protocol which might have possible values of "singular",
   "dual", "plural". 
   
   If I get around to implementing this, I will create
   a new Machine object with these capabilities (probably in some easy
   high level scripting language) rather than extending the current 
   machine object system.

 * Seemingly simple parsing challenges, such as parsing/transforming 
   palindromes, can produce more complex script code than a simple 
   recursive c function. This is because the machine parses the input
   stream as it receives it in a "left-to-right" fashion. On the 
   other hand, the machine palindrome parse can be made to find all
   (sub-palindromes) of the input string.

 * Features like "operator precedence" when parsing arithmetic expressions
   require carefully constructing the parsing grammar (bnf) so that it
   contains 1 look-ahead token.

POTENTIAL

 * The virtual parsing machine appears to me to have great potential
   to change the way simple languages are parsed and transformed.
   I believe the machine can potentially be implemented in an extremely
   minimalistic way, which means that a programer can have access to 
   a wide array of syntaxes.

 * Possibly, the parse machine could be implemented on a microcontroller
   thus providing the ability to create expressive languages in those
   minimalistic environments (programs could actually be compiled on
   the microcontroller). Currently, as far as I am aware, the only language
   that can actually be compiled and run on a (eg: AVR atmega328) 
   microcontroller is the venerable Forth (maybe lisp as well?). 
    
 * If the machine is extended in certain simple ways, I believe it
   has the potential to almost parse and translate human language. The
   extension may be quite simple and consists in attaching a "protocol"
   dictionary object to each tape-cell (or possibly to each stack token).
   This protocol/interface will contain a hierarchy of attribute:value
   pairs which will be matched to the protocols of adjacent tape-cells
   during stack-reduction operations. These ideas need to made concrete.
   
DEBUG
   
   * how to find segmentation faults
   ------
     # recompile with debugging info
     gcc -g my_program.c -o my_program
     # launch with gdb
     gdb ./prog
     # run with gdb, give command line args here.
     (gdb) run
     # should get

      Program received signal SIGSEGV, Segmentation fault.
      0x00005555555546c3 in main () at my_program.c:6
      6       printf("ptr value is : %d", *pVal);
     # view the chain of functions that led to the crash.
     (gdb) backtrace
     # print the value of a variable. 
     (gdb) print val
     # show context of source code
     list
     # all local variables.
     info locals
   ,,,,

   causes of seg faults
    - null or uninitialized pointer
    - out of bounds array or memory
    - write to read only memory
    - stack overflow, use too much stack (infinite recursion)
    - access free memory
    - bad scanf

POSSIBLE USES FOR THE PARSING MACHINE 

  * Transform a "markdown"-like text format language into html, XML
    or some other text format. Instead of using regular expressions 
    to discover and transform text patterns, the machine will use
    a BNF grammar and parse the document as a hierarchical structure
    (eg: chapter -> section -> text -> links etc).

  * Transform JSON text data into different formats. Use the script
    compile.ccode.pss to create stand-alone executable text data 
    transformation scripts. 

  * create simple language compilers with the output being 
    an assembly language for the given microcontroller.

CHALLENGES FOR PARSING AND TRANSLATING OR COMPILING ....

  * parse and convert ebnf structures into simple bnf alternation:
    for example, parse and convert
      >> r = (a|b)[c].
      into
      >> r = a|b|ac|ab.
    This is actually really tricky and possibly impossible given the 
    current capabilities of the machine.

  * write a simple "markdown"-style document converter (generate html,
    Unix man page, asciidoc, or some other format). 
    see eg/mark.html.pss for a first attempt at this.

  * sed to python converter. The difficulty might be in converting 
    regular expression syntax. Also the gnu-sed syntax
      >> s#old#new#g   (i.e the delimiter can be any character)
    is tricky for the machine at the moment. The machine would need 
    an "untiltape" command, which reads the input stream until the 
    tape ends with text contained in the current tape cell (with
    the usual escaping).

  * Simple arithmetic expression parser/compiler
    eg: n = 4*y+(6-x)/2
    operator precedence is difficult but need to be put
    into the grammar. see eg/expression.pss

  * parse palindromes: 
    see test.palindrome.pss for a incomplete example. We may
    need an extra "testhas" machine command to parse strings
    (eg: "eeee", "ggg").
  natural language parsing: 
    see test.natural.language.pss for a limited example
  toy forth parser compiler
  toy lisp parser/compiler


  ideas:
    a machineInfo array to explain each part of the 
    machine... stack, peep, tape, accumulator etc

  The syntax for the argument indicates what type of argument it is. Eg: "abc"
  is text; [a-z] in brackets, is a range; [abcd] is a list; [:space:] is a
  character class. This is incorporated into the compile() function.

WORK DONE

   * expanded the negation operator to include equals tests
     (not just class tests).  eg: !"tree" { nop; }  
     (in compile.pss)
   * done: changed /restart/ syntax to .restart
   * done: changed <pp> parse label to just "parse:"
   * done: changed begintest/endtest syntax to b"text" {...} and e"text" {}
      this is also to make way for the multiple quote test syntax below
   * done: added multiple quote test syntax like this 
      "c*palindrome*c*","c*c*c*" { #* block commands. *#  }
     This is important because often two BNF rules have the same 
     effect. Otherwise the block commands have to be repeated in 
     their entirety.
   * done: added an -i switch for text inline input. useful for testing. Also
     because when we are working interactively we cannot pipe input
     into the program.
   * added a 'begin' section to scripts for configuration such
     as setting the delimiter, start messages
   * allowed scripts to be compiled! see translate.c.pss and 
     object/machine.methods.c

TASKS
   
   * add a "tape truncation" switch to pep which will only
     print a certain amount of each tape cell. Once tape cell 
     contents become very big, it is hard to see what is happening
     when stepping through a script.

   * improve un-terminated quote error handling in "compile.pss"
     (give a line number for the start quote.

   * split pep into 2 (just an interpreter that can get input from
     STDIN and a viewer debugger, that can't)

   * upload to sourceforge git repo

   * could write an "errorcheck" script rather than having
     it in compile.pss

   * write a man page. generate the manpage option help from the 
     pep -h command. Look at asciidoc conversion to man page

   * write a sed script to convert comments in pep.c to asciidoc

   * replace.tape command so that we can compile quoteset well

   * testtapehas or testtapecontains and testtapeends. (for palindrome
     parsing

   * make a help switch that prints out a list of machine commands
     and descriptions to stdout. Then include that in pep-book.txt

   * look at how to compile ebnf to simple bnf eg:
       a := b , { c } , d ;
     becomes:
       cc+ := c , c ;
       cc+ := cc++ , c ;
       a := b , d ;
       a := b , c , d ;
       a := b , cc+ , d ;
     Once we have these simple rules we can convert to .pss scripts 
     But it looks a bit tricky since any expression can go in 
     { ... }

   * convert the toy pascal assignment compiler to .pss script.
     Add if/then 

   * reorganise the code files into:

      a program needs a machine but a machine does not need a 
      program. So machine doesn't need a struct Program member
      variable.

   * write pretty.pss which will pretty print a script with indentation

   * write explain.pss which will explain a script by listing each 
     command with a short description of what it does. (also will convert
     abbreviated command names to full name)

COMPILING AND RUNNING THIS CODE

  tools:
    bash shell (or any other shell for compiling etc)
    some unixy OS (makes things easier), sed, date, vim, 
    asciidoctor, enscript - for formatting and printing source code

  * create a printable pdf of the code in 2 columns landscape format
  >> enscript -o - -2r -f Courier7 pep.c | ps2pdf - os.pdf

  I call the executable "pep" for "pattern parser". The file is called 
  pep.c because I already had a folder called "pp"

  * compile code
  >> see the functions in helpers.pep.sh 

  * a bash alias to run the code
  >> alias pep='cd ~/sf/htdocs/books/pars/; ./pp'

  * a bash function to compile the source code pep.c and add a date stamp
  ---------------------
  # 
  ppc.mono() {
     echo "Compiling 'pep.c' as executable 'pp'" 
     echo "Datestamp: $(date +%d%b%Y-%I%P)"
     # The line below adds the compile time and date to the version
     cd ~/sf/htdocs/books/pars
     cp pep.c pep.pre.c
     sed -i "/v31415\"; *$/s/v31415/version.$(date +%d%b%Y-%I%P)/" pep.pre.c 
     gcc pep.pre.c -o pep
  }
  ,,,

COMPILATION OF SCRIPTS

   The file "asm.pp" compiles scripts into an assembly format
   The script "compile.pss" does the same in a more readable way.
   The script "translate.c.pss" produces compilable c code for a 
     stand-alone executable. (10 Sept 2019: translate.c.pss needs 
     to be updated to use new syntax features of the parse language).

   In a somewhat reflexive manner a machine program "asm.pp" compiles a script
   language into machine programs. Or more explicitly the compilation of a
   script happens as follows. The machine loads an assembly-code text file
   called "asm.pp". It then uses that program to compile a given script into
   the equivalent assembly-code (and saves the assembly code in a text file
   called "sav.pp" . Then it loads that assembly-code file and uses it to
   process the input stream. 

   In order to achieve this I removed line numbers from assembly saving and
   loading, and made (conditional) jumps relative and allowed labels in
   assembly scripts. This made hand-coding of assembly programs feasible and
   possible. But it is still easier to use the script language instead.

SEE ALSO
   
   www.nomlang.org

   www.nomlang.org/eg/
     A set of example scripts for pep and nom

   www.nomlang.org/tr/
     Nom scripts to translate nom scripts into other languages.

   www.nomlang.org/doc/
     lots of documentation for the pep/nom system. 

   compile.pss
     A parse-script which can compile parse-scripts into an assembler format.
     This does just the same job as 'asm.pp' but is more readable
     and compact.

   translate.c.pss
     This is somewhat not up-to-date compared to other translations 
     scripts (in the www.nomlang.org/tr folder)
     A script which produces compilable c code for any given script. 
     The c code is linked against the libmachine.a library to produce
     an executable parser/translator. see the pepcl bash function in
     helpers.pep.sh for the exact gcc compiling code. 

   /eg/text.tohtml.pss
     Translate text into html.

   /eg/maths.parse.pss
     This parses maths expressions like (1^2 + sqrt(a+b)/2)

   /eg/maths.tolatex.pss
     converts maths expressions like (1^2 + sqrt(a+b)/2) to latex.

   eg/natural.language.pss
     a very limited example of a natural language recogniser. Test with:
       >> pep -f eg/natural.language.pss -i "a big dog eats meat"

   object/machine.methods.c
     a set of functions which correspond to each instruction of the 
     machine. This is used by translate.c.pss

   object folder
     The object folder contains a set of 'objects' (c structures
     and related functions) which form the components of the 
     virtual parsing machine.

   asm.pp
     a parse machine 'assembler' program which compiles scripts to an
     intermediate format (which I call an 'assembler' format because of its
     similarities to real assembler languages on real chips). This
     intermediate assembler format can be, and is loaded and run directly by
     the virtual parse machine, to transform the input stream.

   pep -Ie "read; print; clear;" -i "otto"
     explore the machine interactively (view registers and step
     through programs and input) using the simplest possible 
     program and input.

   helpers.pep.sh
     A set of bash functions to make compiling the code easier 
     among other things.

TO DO

HOW TO ADD NEW COMMANDS

  To add a new command to the machine, do the following
    - add a new enum in /object/command.h
    - add a new command description to the info[] array in /object/command.c In 
      the command name field, use a distinct name that can be
      used to test the command interactively with
      >> pep -I -i "some example text"
    - add a new switch case in /object/machine.interp.c
    - compile the files in the /object/ folder.
    - copy the 'pep' executable to whereever is the pep home folder.
    - try *pep -c* a look for the new command in the output.
    - test in the interpreter with
      >> pep -I -i "some example text"
      and type the command name with any arguments in quotes.
    - add syntax to compile.pss to recognise and compile the 
      new command.
    - add to machine.methods.c so that the command can be compiled
      to c.
    - add syntax to the translator scripts in tr/ to translate
      the new command.
    - add tests to tr/translate.test.txt and tr/translate.unicode.test.txt
    - document at nomlang.org/doc/ 

FIXED BUGS

    * probably fixed the duplicate mark bug (did not delete duplicate
      marks on the tape before marking the current cell)
    * using pep -Ii "abc" -e "r;U;d;" caused a malloc segfault.
      (U is unimplemented). Any "misplaced" character appears to
      cause the segfault. The problem was 2 freemachine() at line
      2165.
    * found a bug in "until", eg: if work=" and peep="
      then until '"' actually read past the next ". Fixed this 
      in machine.methods.c as well
    * classtests returned true for an empty workspace
    * The following was not working because I wasnt using "escape"
      on the embedded double quotes.
        add '#include "machine.methods.c" \n';
    * range had a <= >= bug
    * the "until" bug. this was cause by assigning the char *
      lastc before a growBuffer() call. So when realloc was called
      by growBuffer() there was no problem until realloc() actually
      assigned a new memory block (usually when the buffer size was
      about 950 bytes). When realloc() assigned a new memory block
      then suddenly char * lastc was not pointing at the actual data.
      I found it quite hard to track this bug down.
    * fixed segfaults with valgrind analysis. still 2 memory bugs 
      to fix, one in "until" in execute() in machine.interp.c

BUGS 

    * while "," does not seem to work but 'while [,]' does work
      I think I should regard this as a bug, buts its not so 
      important
    * having an unterminated " quote character in a script may
      cause a segfault....
    * the escape command does not check for sufficient memory
      in the workspace buffer. Need to fix execute() and also
      the escape method in machine.methods.c
    * saveAssembledProgram will not deal with the second 
      parameter currently (aug 2019) and so will not save 
      the "replace" command correctly. This is not so important
      because saveAssembledProgram is not being used for anything 
      significant, currently (august 2019).  

    * when program grows, it often creates a segmentation fault.
      Also, the first instruction of the program becomes 'undefined'

    * some label error while loading asm.pp ".token" label
      not found. This was after writing parameterFromText().  Basically after
      the first call to parameterFromText() the scan position was not updated
      properly to the end of the text. So the system thought there was a
      second label (for the same jump instruction) which it attempted to
      resolve into a line number. Obviously jumps cannot have two target
      address for the same jump. I ignored the bug by ignoring the 
      second parameter for any jump instruction, but this may rear its head
      up later.

    * eg: b interactively, requires argument, then 'n', segmentation fault.
    * segmentation fault when growing the program.
    * if labels have trailing space, they dont work.
    * all scripts need (still?) an extra space at the end, other wise
      asm.pp cant read the final character. 

INFLUENCES

  A small side-note at the beginning of Nicolas Wirths book "Compilerbau"
  started me thinking about the possibility of a stack/tape combination
  machine for parsing language, using shift-reductions. 

  Using a unix system made me think about the idea of a compiler/translator
  as a stream editor. Using the "sed" stream editor, made me think
  about the potential of a simple text-buffer virtual machine.
  
HISTORY

  I have been working on this off and on for a number of years
  (since about 2003) with many stops and starts in the meantime 
  as well as many dead-ends. The idea seems new, experimental but 
  very powerful. 
  
  Nevertheless I have a hunch that this approach to parsing and translating (or
  'compiling') formal languages is very interesting. The system is now at a
  useful stage (Aug 2025). There are a number of useful and (to me) interesting
  example scripts in the www.nomlang.org/eg/ folder

  The idea of a parsing machine derived from thinking about the "sed" unix
  stream editor and its limitations, bnf grammars, context-free languages,
  human languages, the limitations of regular expressions and regular
  languages. 
  
  The coding of this version was begun around mid-2014. A number of other
  versions have been written in the past but none was successful or
  complete. 

  26 aug 2025
    Made the nom://quit command return the accumulator as an exit 
    code. This seems to me a very simple and useful way for the 
    script to indicate an error or success code. Also, in the process
    of adding a nom://system command that execute a system command and 
    reads the result into the pep://workspace buffer. This is a somewhat 
    omnipotent command and was something that I have been avoiding for 
    several decades, but it is simple to implement and allows nom to 
    be used for a much wider range of tasks. Also, the main motivation
    was trying to create tiny language models, or nom scripts that react 
    to plain english prompts and can remember some 'context' just like
    LLMs

  20 aug 2022
    will try to add a new until command (until ends with tape)
    also "w filename;" also "quit <code>;"

  15 June 2021
    Trying to get this to look for ASMPP env variable to find the "asm.pp"
    file which it needs to actually compile and run scripts, here is a 
    code snippet
    ----- 
     printf("test\n");
     const char* s = getenv("PATH");
     printf("PATH :%s\n",(s!=NULL)? s : "getenv returned NULL");
     printf("end test\n");
    ,,,,

  23 April 2021
    First new code for a while. I may add a switch that prints 
    the stack when .reparse is called. (Editor: no I never added this
    because it is easy just to print the current stack state after the
    nomsyn://parse> label with a line and character number. This is a 
    very effective grammar debugging tool that I use in every non-trivial
    script... see the examples in the /eg/ folder, such as 
    /eg/maths.parse.pss )

  14 March 2020
    using an environment variable to locate 'asm.pp'
    
  6 september 2019
    Added "stack" and "unstack" commands which nom://push all tokens
    onto the pep://stack (the nom://stack command) or nom://pop all
    tokens off (the nom://unstack command).

  28 august 2019

    Small adjustments to "compile.pss".
    Starting to rewrite translate.c.pss to convert back to a 
    single class test and also convert to changes made to compile.pss
    (eg negation and "ortestset*" compilation). This is a maintainance
    problem trying to keep compile.pss and translate.c.pss in sync
    so that they recognise the same syntax.

  24 august 2019

    Added the nom://delim command which changes the stack token delimiter
    for push and pop commands.

  23 august 2019

    rewrote quoteset parsing in compile.pss Much better now, doesnt
    use "hops". Also, replaced asm.pp with an asm.pp generated from
      >> pep -f compile.pss compile.pss
    Thought it would be nice to have a javascript machine object ...
   
    * create a javascript script parser/compiler 
    >> pep -f convert.javascript.pss convert.javascript.pss > pep.js

    (need to write the machine object and command methods, and the convert
    script. The convert script is a straightforward conversion of the
    "translate.c.pss" script, but the machine object will take a little longer
    to write - but presumable, much less time than writing the struct machine
    object in c). 

    Once we have these things we will be able to run scripts in 
    a browser which will be nice for testing. An we will also 
    be able to use unicode characters!!

  20 august 2019: sunny

    Writing a man page for pep. But I will use asciidoc and convert
    to html and troff. Also wrote ghman which installs the page 
    (in linux at least).

    Cleaning up memory leaks with valgrind. Still one problem
    in UNTIL in execute() function in machine.interp.c Also an
    unitialised value bug in TESTIS (need a newParameter func?)
    But TESTIS should not be called unless the parameter .text 
    value is set...

  19 august 2019: public holiday, Bogota.
      
    Fixed a "one-off" bug. Also, found a bug in "until" in the execute()
    function in machine.interp.c (via valgrind). Can fix with endsWith() in
    buffer.c. Memory leaks when growing cells and buffer needs to be fixed. 
    Valgrind on osx doesnt work properly so I need to use linux for
    this job.

    Discovered many memory leaks and "one-off" errors 
    and other more obvious bugs using valgrind

  14 august 2019: Bogota, Colombia - raining
      
    Added begin-blocks to compile.pss, asm.pp and translate.c.pss
    These work in a similar way to awk's begin {} rules.
    Added negated text tests to compile.pss and compilable but 
    not to asm.pp . So now we can do 
     >> pep -f compile.pss -i ' !""{a"not empty!!";}t;d;'
    to check if the workspace is empty

    made the script eg/exp.recogniser.pss work and also
    eg/exp.tolist.pss

    Need to deal with a segmentation fault. I think it has to 
    do with "scriptFile" not being closed properly, but am not 
    sure. Also, when we do the "quit" command we should free
    the machine and inputstreams no?

    Changed the enum boolean because true and false were back to 
    front.

    Can compile test/test.natural.language.pss with the 
    script translate.c.pss (see the "pepcl" helper bash function)
    and it runs as a standalone.

    Compiled the files in the object/ folder to a static library
    libmachine.a and then compiled the output of compile.ccode.pss
    successfully with "gcc -o test test.c -Lobject/ -lmachine"

    So, we can generate standalone executable parsing/transforming
    programs from a script with
      pep -f compile.ccode.pss script > script.c
      gcc -o scriptx script.c -Lobject/ -lmachine

  13 august 2019

    Continued to separate the code in pep.c into separate 'object' 
    files in the pars/object/ folder. Currently up to machine.c 
    now will do machine.interp.c  The code is compiling with the bash 
    function ppco which is in the file pars/helpers.pars.sh . I am
    not using 'make' to compile, currently.

  12 august 2019

    Reorganising the source code files. The main c file is now
    pars/object/pep.c and this includes the other 'object' files which
    are in this directory. Moved the old pep.c source code files 
    to the folder Monolith.gh (because everything was in the one
    file).

    Made the files in the pars/object folder the canonical source code for
    the machine. This means I need to make ppc etc compile with these
    files.

    Discovered a bug in classtests. An empty workspace returns
    true for a range test. 

    Because eg/expression.pss to parse arithmetic expressions 
    such as "(7 + 100) * -100". Need to arrange the grammar so
    that it has a "lookahead" of 1 token so that operator
    precedence can be handled. also thought that "/" would be 
    a better token delimiter. Need a command to set the token
    delimiter character on the machine. Also need a way to 
    give statements to a script that are only executed once, when
    the script starts. Perhaps the (eof) section/test should work
    in the same way (be a script section, rather than a state-test).

    Also, thought that the machine needs a "testhas" test, which 
    would return true if the workspace currently contains the 
    text in the current tapecell. This would allow parsing strings
    such as "eeee", "fffff". Also a "testtapeend" which returns true
    if the workspace currently ends with the text in the current 
    tapecell.

    Also, maybe need a "untiltape" command which reads until the 
    workspace ends with the text in the current tape cell. 
    This would allow parsing sed syntax "s#...##" or "s/...//" where
    the delimiter character can be anything which occurs after 
    the "s" character.

  10 august 2019

    trying to organise the pep.c source code into separate objects
    in the pars/object/ folder.

  8 august 2019
    Continued working on compile.ccode.pss
    split the class* token into charclass*, range* and list* 
    with corresponding negated classes.

  7 august 2019
    worked on compile.ccode.pss
  6 august 2019
    would be handy to have multiline quotes....
    working on compile.ccode.pss

  4 august 2019
    I think I finally tracked down the "until" bug, which was
    actually a bug in readc(). A character pointer lastc was
    assigned before a growBuffer() call (which calls realloc()).
    When realloc() assigned a new memory block the character
    pointer was no longer valid.

  3 august 2019
   
    Still looking at the "until" bug. Basically the problem
    occurs when the text read with until is greater than
    about 950 bytes. This is caused because <950 bytes realloc()
    basically did nothing, hence no problem!

  30 july 2019

    A useful command for calculating jumps: "+int" which
    will add the given integer to all integers in the workspace.
    This command may be necessary when certain forward jumps are 
    not known during compilation.

    Maybe, it could be useful to have a very basic pattern matching syntax
    for tests. Similar to a filename match: eg /word*?\*\* /
    where ? matches any one character, * matches multiple, and
    \* is a literal asterix. This could be useful in error handling
    blocks, so as not to have to write out every single combination
    of tokens. However, it would not be very readable.

    Compile.pss appears to be working. It is more readable and
    maintainable than asm.pp but in the case of quoteset* it
    compiles not very efficient code (multiple jumps where 
    asm.pp compiles only one). See the asm.pp file for a much
    better error handling idea.

    compile.pss 664 lines
         asm.pp 1485 lines

    Had the idea for an "expand" command in which the machine will
    convert an abbreviated command into its full form in the 
    workspace. Probably not.

    Converting asm.pp into compile.pss which is much more compact
    and readable. Finished converting, but not debugged. 

    Creating notclass* syntax in asm.pp. eg ![a-z] { nop; }

    realised that I can just directly translate asm.pp into
    a compiling script. It will be convenient to have ![class] {}
    syntax. We can implement this in asm.pp quite easily.eg:
      notclass* <- !*class*
      command* <- notclass*{*commandset*}*
    Started translating asm.pp into parse-script language. It seems
    quite straight forward. Also, we could write a script that
    compiles "recognisers", just like the 2 bnf grammar rules above
    eg:
      notclass <- ! class
      command <- notclass { commandset } 

  29 july 2019

    Continued converting execute() into functions in machine.methods.c
    Realised that I have to modify how jumps and tests work when
    creating executable scripts. In fact it may be necessary to use
    the c "goto" instruction in order to implement ".reparse" and
    ".restart".

      file sizes: 
        pep.c 187746 bytes
        pep    99432 bytes
        machine.methods.c 16761 bytes

  28 july 2019
   
    created some machine methods in machine.methods.c by copying 
    code from execute(). The process seems straight forward.

    added an -i switch to make it easier to provide input
    when running interactively. (we will be able to do
    echo "abcd" | pep -f palindrome.pss  eventually)
    Looking again at the test.palindrome.pss script, which doesnt
    quite work because of ".restart" on eof.

  27 july 2019, in bogota, Colombia

    Wrote a palindrome detecter which seems very complicated for the simple
    task that it does, and also it does not actually work in all cases. 
    
    I implemented "quotesets" with a few nifty tricks. quotesets allow
    multiple equals tests for a given block. The difficulty is that they are
    parsed before the braces are encountered in the stream, so it is not
    possible to resolve the forward jump. But there was a solution to this,
    best understood by looking at the source code in "asm.pp". So multiple
    tests for one block are possible with "quotesets" which are implemented
    in asm.pp and resolve into tests for blocks. They are very useful
    because they allow syntax like this:

      "noun*verb*object*", 
      "article*verb*object*",
      "verb*object" {
         # translate here 
      }
     
  26 july 2019

    Discovered that the "until" instruction was not growing the 
    workspace buffer properly, leading to bugs. The same bug will
    apply to "while". See the bugs: section for more information.
    For some reason readc() is not growing the workspace properly
    at the right time. The bug become apparent when parsing 
    test.commands.pss and trying to read past a large multiline
    comment block. eg:
      >> pep -If test.commands.pss input.txt
  
  25 july 2019

   Worked on test.commands.pss which acts like a kind of syntax check
   and demonstration for all commands and structures implemented in
   asm.pp

   working on the asm.pp compiler. wrote the .reparse keyword and 
   the "parse>" parse label. Finished end- and beginstest and blocks.

   Implemented the "replace" machine instruction but not really debugged.
   Added replace to the asm.pp compiler so that it can be used in
   scripts as well.
   
  24 july 2019

   Writing the parameterFromText() function. This will allow parsing
   multiple parameters to an instruction. The tricky bit is that 
   parameterFromText() has to return the last character scanned 
   to that the next call to it, will start and the current scan
   position. Once I have multiple parameters, then I can write the 
   "replace" command: eg replace "one" "two";

   realised that I need a replace command, and this requires the use of 2
   parameters. Maybe a bit of infrastructure will have to be written. An
   example of the use of "replace" is converting c multiline comments into
   bash style comments.  It would be possible to parse line by line and
   achieve this without "replace" but it is a lot more work.

  23 july 2019

   various bits of tidying up. Still cant accept input from standard
   in for some reason (program hangs and waits for console input)

  22 july 2019

   Implemented the swap instruction (x) to swap current tape cell
   and the workspace buffer.

   Fixed a bug in the get command which did not allocate
   enough memory for the stack/workspace buffer.

  20 july 2019

   Its all working more or less!. We can write
     pep -f script.pss input.txt
   and the system compiles the script to assembler, loads it,
   and runs it against the input stream in input.txt. No doubt
   there are a number of bugs, but the general idea works.

   Made progress with "asm.pp". Class blocks seem to be working.
   Some nested blocks now work. Asm.pp is at a useful stage. It
   can now compile many scripts. Still need to work out how
   to implement the -f switch (segmentation fault at the moment).
   In theory the process is simple... load asm.pp, run it on
   the script file (-f), then load sav.pp (output of asm.pp) and
   run it on the inputstream.

  19 july 2019

   Bug! when program grows during loading a segmentation fault
   occurs.

   created test.commands.pss which contains simple commands which
   can be parsed and compiled by the asm.pp script.
   
   Also, realised that the compilation from assembler should stop
   with errors when an undefined instruction is found. Dealt with
   a great many warnings that arise when one uses "gcc -Wall"

   implemented
    command 'cc' adds the input stream character count to the 
    workspace buffer
    Also made an automatic newline counter, which is incremented
    every time a \n character is encountered. And the 'll'
    command which appends the newline counter as a string onto the 
    end of the workspace buffer.

    Since the main function of this parse-machine is to compile
    "languages" from a text source, the commands above are very
    useful because they allow the compilation script to give
    error messages when the source document is not in the correct
    format (with line number and possibly character count).

    Did some work on "asm.pp" which is the assembler file which 
    compiles scripts. Sounds very circular but it works.
    Realised that after applying bnf rules, need to jump back to
    the "parse:" label in case other previous rules apply.

  18 july 2019

    Discovered a bug when running "asm.pp" in unix filter mode
    "Abort trap: 6" which means writing to some memory location
    that I should not be. Strangely, when I run the same script
    interactively (with "rr") it works and doesnt cause the 
    abort.

    Created a "write" command, on the machine, which writes the
    current workspace to a file called "sav.pp". This has a parallel
    in sed (which also has a 'w' write command). This command 
    should be useful when compiling scripts and then running them
    (since they are compiled to an intermediate "assembler" phase,
    and then loaded into the machine).

    Made some progress to use the pattern-machine as a unix-style filter
    program. Added some command line options with getopt(). 
    The parser should be usable (in the future) like sed: eg
      cat somefile | pep -sf script.pp > result.txt
    or 
      cat somefile | pep -sa script.ppa > result.txt
    where script.ppa is an "assembler" listing which can be loaded into
    the machine.

  16 july 2019
   
    Working on parsing with asm.pp. Seem to have basic commands 
    parsing and compiling eg: add "this"; pop; push; etc
    Simple blocks are parsing and compiling.
    There are still some complications concerning the order of 
    shift-reductions.
       
    Made execute() have a return value eg:
    ---
      0: success no problems
      1: end of stream reached
      2: undefined instruction
      3: quit/crash executed (exit script)
      4: write command could not open file sav.pp for writing
    ,,,,

    More work. Some aesthetic fixes to make it easier to see what 
    the machine is doing. wrote showMachineTapeProgram() to give a nice
    view of pretty much everything that is going on in the machine at once.
    Working on how to collate "attributes" in the tape array register.
    Made an optional parameter to printSomeTape() that escapes \n \r etc
    in the tape cells which makes the output less messy.

  15 july 2019 
    A lot of progress. Starting to work on asm.pp again. Have
    basic shift-reduction of stack tokens working. Now to get
    the tape "compiling" attributes as well. 

    The bug seems to be: that JUMP is not treated as a relative
    jump by execute() but is being compiled as a relative jump
    by instructionFromText(). So, either make, JUMPs relative or ...

    Made the "labelTable" (or jumpTable) a property of the program.
    This is a good idea. Also made the command 'jj' print out the 
    label table. Still using "jumptable" phrase but this is not 
    a good name for this.

    I should organise this file: first structure definitions.
    then prototype declarations, and then functions. I havent done
    this because it was convenient to write the function immediately
    after the structure def (so I could look at the properties). 
    But if I rearrange, then it will be easier to put everything in
    a header file, if that is a good idea.

    Lots of minor modifications. made searchHelp also search the 
    help command name, for example. Added a compileTime (milliseconds)
    property to the Program structure, and a compileDate (time_t).
    81 instructions (which is how many instructions in asm.pp at the 
    moment) are taking 4 milliseconds to compile. which seems pretty
    slow really.
    sizes:
    ----
      pep.c 138430 bytes
      pep   80880 bytes
    ,,,,

    Trying to eliminate warnings from the gcc compiler, which are actually
    very handy. Also seem to have uncovered a bug where the "getJump" 
    function was actually after where it was used (and this pep.c does
    not use any header files, which is very primitive). So the 
    label jumptable code should not have been working at all...
    changing lots of %d to %ld for long integers. Also, on BSD unix
    the ansi colour escape code for "grey" appears to be black.

  13 july 2019
    Looking at this on an OSX macbook. The code compiles (with a number of 
    warnings) and seems to run. The colours in this bash environment are 
    different.
    
  12 Dec 2018
    After stepping through the "asm" program I discovered that 
    unconditional jump targets are not being correctly encoded. This 
    probably explains why the script was not running properly. Also
    I may put labels into the deassembled listings so that the listings
    are more readable.

  19 sept 2018
    Revisiting. 
    Need to create command line switches: eg -a <name> for loading
    an assembler script. and -f <name> to load a script file.
    Need to step through the asm.pp script and 
    work out why stack reduction is not working... (see above for
    the answer). An infinite
    loop is occurring. Also, need to write the treemap app for iphone
    android, not related to this. Also, need to write a script that
    converts this file and book files to an 'asciidoctor' format for 
    publishing in html and pdf. Then send all this to someone more 
    knowledgeable.
  5 sept 2018
    ----
      pep.c 133423 bytes
      pep   78448 bytes
    ,,,,

    Would be handy to have a "run until 10 more chars read" function.
    This would help to debug problematic scripts.

    Segmentation fault probably caused by trying to "put" to 
    non-existent tape cell (past the end). Need to check tape size
    before putting, and grow the tape if necessary.

    Could try to make a palindrome parser (see /eg/palindrome.pss ).  Getting a
    segmentation fault when running the asm.pp program right through. Wrote an
    INTERPRET mode for testing- where commands are executed on the machine but
    not compiled into the current program. Wrote runUntilWorkspaceIs() and
    adding a testing command to invoke this. This should make is easier to test
    particular parts of a script. Found and fixed a problem with how labels
    are resolved, this was cause by buildJumpTable() not ignoring multiline
    comments.

  4 sept 2018
    Made multi-line comments (#* ... *#) work in assembler scripts.  Made the
    machine.delimiter character visible and used by push and pop in
    execute(). There is no way to set the delimiter char or the escape char
    in scripts. (Editor: use the nom://delim command)

  3 sept 2018
    Added multiline comments to asm.pp (eg #* ... *#) as well
    as single line comments with #.
    Idea: make pep.c produce internal docs in asciidoctor format
    so we can publish to html5/docbook/pdf etc.
    working on the asm.pp script. Made "asm" command reset the 
    machine and program and input stream. Added quoted text and
    comments to the asm.pp script parsing, but no stack parsing yet.

    Need to add multiline comments to the loadAssembledProgram() function.
    while and whilenot cannot use a single char: 
    eg: whilenot "\n" doesnt work. So, write 'whilenot [\n]' instead
    Also should write checkInstruction() called by 
    instructionFromText() to make sure that the instruction has 
    the correct parameter types. Eg: add should have parameter type
    text delimited by quotes. Not a list [...] or a range [a-z]

    If the jumptable is a global variable then we can test 
    jump calculations interactively. Although its not really 
    necessary. Would be good to time how long the machine 
    takes to load assembler files, and also how long it takes
    to parse and transform files. 

  2 sept 2018
    wrote getJump() and made instructionFromText() lookup the label
    jump table and calculate the relative jump. It appears to be 
    working. Which removes perhaps the last obstacle to actually writing 
    the script parser. Need to make program listings "page" so I can
    see long listings.

  1 Sept 2018
    writing printJumpTable() and trying to progress. Looking at
    Need to add "struct label table[]" jumptable parameter 
    to instructionFromText(), and compile().
    asciidoctor.

  31 aug 2018
    Continued to work on buildJumpTable(). Will write printJumpTable()
    Renamed the script assembler to "asm.pp"
    Made a bash function to insert a timestamp. Created an
    "asm" command in the test loop to load the asm.pp file into the program.
    Started a buildTable function for a label jump table. These
    label offsets could be applied by the "compile" function.
  30 August 2018
    "pep.c" source file is 117352 bytes.
    Compiled code is 72800 bytes. I could reduce this dramatically
    by separating the test loop from the machine code.

    Revisiting this after taking a long detour via a forth bytecode
    machine which currently boots on x86 in real mode (see
    http://bumble.sourceforge.net/books/osdev/os.asm ) and then trying
    to port it to the atmega328p architecture (ie arduino) at
    http://bumble.sf.net/books/arduino/os.avr.asm
    The immediate task seems to be to write code to create a label
    table for assembly listings, and then use that code to replace
    labels with relative jump offsets. After that, we can start to write
    the actual code (in asm.pp) which will parse and compile scripts.

    So the process is: the machine loads the script parser code (in
    "asm" format) from a text file. The machine uses that program to
    parse a given script and convert to text "asm" format. The machine 
    then loads the new text asm script and uses it to parse and
    transform ("compile") an input text stream.

  20 dec 2017
    Allowed assembly listings with no line numbers as default. It 
    would be good idea to allow labels in assembly listings, eg 'here:' to
    make it easier to hand code assembly. So, need a label table. Look at
    the info arrays for the syntax... Made conditional jumps relative so
    that they would be easier to "hand-code" as integers (although labels
    are really needed).  Also, need to add a loadAsm() function which is
    shorthand to load the script assembler. 

 17 decembre 2017
   For some reason, the code was left in a non compilable
   state in 2016. I think the compile() and instructionFromText()
   functions could be rewritten but seem to be working at 
   the moment.

 13 dec 2017
   The code is not compiling because the parameter to the "compile()"
   function is wrong. When we display instructions, it would be good to
   always indicate the data type of the parameter (eg: text, int, range etc)
   Modify "test" to use different parameter types, eg list, range, class.

 29 september 2016
   used instructionFromText() within the compile() function and changed
   compile to accept raw instruction text (not command + arguments) wrote
   scanParameter which is a usefull little function to grab an argument up
   to a delimiter. It works out the delimiter by looking at the first char
   of the argument and unescapes all special chars. Now need to change
   loadAssembled to use compile(). 

 28 sept 2016
   Added a help-search / and a command help search //. Added
   escapeText() and escapeSpecial(), and printEscapedInstruction().
   add writeInstruction() which escapes and writes an instruction
   to file. Added instructionFromText() and a test command 
   which tests that function.
   Worked on loadAssembledProgram() to properly load
   formats such as "while [a-z]" and "while [abc\] \\ \r \t]" etc.
   All this work is moving towards having the same parse routine
   loading assembled scripts from text files as well as interactively
   in the test loop.

 26 sept 2016
   Discovered that nom://swap is not implemented.
 22 sept 2016
   Added loadlast, savelast, runzero etc. a few convenience functions
   in the interpreter. One hurdle: I need to be able to write
     testis "\n" etc where \n indicates a newline so that we can
     test for non printing characters. So this needs to go into the 
     machine as its ascii code.
   Also, when showing program listings, these special characters
   \n \t \r should be shown in a different colour to make it 
   obvious that they are special chars...
   Also: loadprogram() is broken at the moment.... need to deal
   with datatypes.

  21 Sept 2016
    When in interpreter mode, reading the last character should not 
    exit, it should return to the command prompt for testing purposes.

  15 August 2016
    Wrote an "int read" function which reads one character from
    <stdin> and simplifies the code greatly. Still need to 
    fix "escaping". need to make ss give better output, configurable
    Escaping in 'until' command seems to be working.

  13 August 2016
    Added a couple more interpreter commands to allow the 
    manipulation of the program and change the ip pointer. Now
    it is possible to jump the ip pointer to a particular 
    instruction. Also, looked at the loadAssembledProgram and
    saveAssembledProgram functions to try to rewrite them correctly.
    The loadAssembledProgram needs to be completely cleaned up
    and the logic revised. 
    My current idea is to write a program which transforms a pep
    script into a text assembly format, and then use the 
    'loadAssembledProgram' to load that script into the machine.
    Wrote 'runUntilTrue' function which executes
    program instructions until the machine flag is set to true (by
    one of the test instructions, such as testis testbegins, testends...
    This should be useful for debugging complex machine programs.

  7 Jan 2016
    wrote a cursory freeMachine() function with supporting functions
  4 Jan 2016
    tidying up the help system. had the idea of a program browser,
    ie browse 'prog' subfolder and load selected program into
    the machine. Need to write the actual script compilation
    code.
  3 Jan 2016
    Writing a compile function which compiles one instruction
    given command and args. changed the cells array in Tape
    to dynamic. Since we can use array subscripts with pointers
    the code hardly changes. Added the testclass test
    Made program.listing and tape.cells pointers with dynamic
    memory allocation.
  1 Jan 2016
    working on compiling function pointers for the character 
    class tests with the while and testis instructions.
    Creating reflection arrays for class and testing.

  Late Dec 2015
    Continued work. Trying to resolve all "malloc"
    and "realloc" problems. Using a program with instruction listing
    within the machine. Each command executed interactively gets
    added to this. 
  26 Dec 2015
    Saving and loading programs as assembler listings.
    Validate program function. "until" & "pop" more or less working.
    "testends" working ...

  19 Dec 2015 
    Lots of small changes. The code has been polished up to an almost
    useable stage. The machine can be used interactively. Several
    instructions still need to be implemented. Push and pop need to be
    written properly.  Need to realloc() strings when required.  The info
    structure will include "number of parameter fields" so that the code
    knows how many parameters a given instruction needs. This is useful
    for error checking when compiling.

  16 Dec 2015
    Revisiting this after a break. Got rid of function pointers, and
    individual instruction functions. Just have one executing function
    "execute()" with a big switch statement. Same with the test
    (interpreter) loop. A big switch statement to process user commands.
    Start with the 'read' command.  Small test file. The disadvantage of not
    having individual instruction functions.

    * instruction functions
    ----
     (eg void pop(struct Machine * mm) 
         void push(struct Machine * mm) etc) 
    ,,,,

    is that we cannot implement the script compiler as a series of function
    calls.  However the nom://read instruction does have a dedicated function.

  23 Feb 2015
    The development strategy has been to incrementally add small bits to the
    machine and concurrently add test commands to the interpreter.

  22 Feb 2015
    Had the idea to create a separate test loop file (a command interpreter)
    with a separate help info array. Show create showTapeHtml to print the
    tape in html. These functions will allow the code to document itself,
    more or less.

    Changes to make:
    The conditional jumps should be relative, not absolute. This will make it
    easier to hand write the compiler in "assembly language". Line numbers are
    not necessary in the assembly listings. The unconditional jump eg jump 0
    can still be an absolute line number.
    
    Put a field width in the help output.
    Change help output colours. Make "pep" help command "ls"
       >> make p.x -> px or just "."

 * 2009 was working on a c version of this called "chomski"

 * 2006 - 2014
    Attempted to write various versions of this machine, in java, perl, c++
    etc, but none was completed successfully see http://bumble.sf.net/pp/cpp
    for an incomplete implementation in c++. But better to look at the current
    version, which is much much better.

 * 2005 approximately
    I started to think about this parsing machine while living
    in Almetlla de Mar. My initial ideas were prompted by trying
    to write parsing scripts in sed and then reading snippets of
    Compilerbau by N. Wirth, thinking about compilers and grammars

   [/dates]

GLOSSARY

d/- pattern
      A very general term which is at the heart of how human beings
      understand the world. Formal languages specify patterns in
      one-dimensional alphabets of symbols; they determine if a 
      particular sequence of symbols is included in a given language
      or not.
  - formal language
      A set of sequences of symbols (letters) arranged in a single
      line. For example (aa, ab, ba) is a language with symbols
      "a" and "b". 
  - markdown
      a minimalistic way to specify the structure/appearance of 
      a plain-text document.
  - virtual machine
      a logic machine which is implemented in software but not in 
      hardware (silicon logic circuits).
  - lex/parse
      2 phases often used during compilation/transformation/translation
  - recogniser
      A piece of software that determines whether a given input has 
      a correct format for a given language or data format. The 
      recogniser does not transform the input in any way, it simply
      returns true or false.
  - bnf, backus-naur form 
      A way to specify the structure of a context-free language. This
      is called the "grammar" of the language. 
  - context-free language
      A simple type of (formal/mathematical) language which has often
      formed the basis for computer languages. A context-free language
      is more complex than a "regular" language but (much) simpler 
      than human language
  - regular language
      A very simple type of (formal) language which is familiar to 
      programmers from "regular expression" patterns. In general, a 
      regular language cannot express "nested" structures (that is:
      text which is contained by other text delimiters). These are the 
      patterns that sed and grep and see.
   - natural language, human language
      These languages involve grammars in which there is an interdependence
      between semantics and grammatical structure. For this reason 
      no good algorithms have yet been developed for the translation
      of human language (despite corporate hype and publicity).


TERMINOLOGY

   * tape pointer:
   * stack: a text buffer that can be manipulated like a stack.
   * command: one of the permitable instructions for
      the VM (eg push pop etc)
   * instruction: a command & parameter (maybe) compiled
      into a 'program' (array) which can be executed by
      the Virtual Machine 
   *

*/

// <code> 

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#include "colours.h" 
#include "tapecell.h" 
#include "tape.h" 
#include "buffer.h" 
#include "charclass.h" 
#include "command.h" 
#include "parameter.h" 
#include "instruction.h" 
#include "labeltable.h" 
#include "program.h" 
#include "exitcode.h" 
#include "machine.h" 
#include "machine.interp.h" 

/*
 execute a compiled instruction. Possible return values might be
        0: success no problems
        1: end of stream reached (tried to read eof)
        2: trying to execute undefined instruction
        3: quit/crash command executed (exit script)
        4: could not open 'sav.pp' for writing (from write command) 
        5: tried to execute unimplemented command
 */

// commands to test and analyse the machine
// these enumerations are in the same order as the informational 
// array below for convenience
enum TestCommand { 
  HELP=0, COMMANDHELP, SEARCHHELP, SEARCHCOMMAND, LISTMACHINECOMMANDS,
  DESCRIBEMACHINECOMMANDS, MACHINECOMMANDDOC, LISTCLASSES, LISTCOLOURS,
  MACHINEPROGRAM, MACHINESTATE, MACHINETAPESTATE, MACHINEMETA, BUFFERSTATE,
  STACKSTATE, TAPESTATE, TAPEINFO, TAPECONTEXTLESS, TAPECONTEXTMORE,
  RESETINPUT, RESETMACHINE,
  STEPMODE, PROGRAMMODE, MACHINEMODE, COMPILEMODE,
  IPCOMPILEMODE, ENDCOMPILEMODE, INTERPRETMODE, LISTPROGRAM, LISTSOMEPROGRAM, 
  LISTPROGRAMWITHLABELS, PROGRAMMETA, SAVEPROGRAM, 
  SHOWJUMPTABLE, LOADPROGRAM, LOADASM,
  LOADLAST, LOADSAVED, LISTSAVFILE, SAVELAST, CHECKPROGRAM, 
  CLEARPROGRAM, CLEARLAST, INSERTINSTRUCTION, 
  EXECUTEINSTRUCTION, PARSEINSTRUCTION, TESTWRITEINSTRUCTION, 
  STEPCODE, RUNCODE, RUNZERO, RUNCHARSLESSTHAN, RUNTOLINE, RUNTOTRUE, 
  RUNTOWORK, RUNTOENDSWITH,
  IPZERO, IPEND, IPGO, IPPLUS, IPMINUS,
  SHOWSTREAM,
  EXIT, UNKNOWN
};

// stepcode and executeinstruction below seem to be the 
// same exactly
struct {
  enum TestCommand c;
  char * names[2];
  char * argText;   // eg <command>
  char * description;
} testInfo[] = { 
  { HELP, {"hh", ""}, "",
     "list all interactive commands" },
  { COMMANDHELP, {"H", ""}, "<command>", 
     "show help for a given machine command" },
  { SEARCHHELP, {"/", "h/"}, "<search term>", 
     "searches help system for an interpreter command containing search term" },
  { SEARCHCOMMAND, {"//", "//"}, "<command search term>", 
     "searches help for a machine command containing search term" },
  { LISTMACHINECOMMANDS, {"com", ""}, "", 
     "list all machine commands" },
  { DESCRIBEMACHINECOMMANDS, {"Com", ""}, "", 
     "list and describe machine commands" },
  { MACHINECOMMANDDOC, {"doc", ""}, "", 
     "output machine commands in a documentation style format." },
  { LISTCLASSES, {"class", "cl"}, "", 
     "list all valid character classes for testclass and while" },
  { LISTCOLOURS, {"col", "colours"}, "", 
     "list all ansi colours" },
  { MACHINEPROGRAM, {"m", ""}, "", 
     "show state of machine, tape and current program instructions" },
  { MACHINESTATE, {"M", ""}, "", 
     "show the state of the machine" },
  { MACHINETAPESTATE, {"s", ""}, "", 
     "show state of the machine buffers with some tape cells" },
  { MACHINEMETA, {"Mm", ""}, "", 
     "show some meta information about the machine" },
  { BUFFERSTATE, {"bu", ""}, "", 
     "show the state of the machine buffer (stack/workspace)" },
  { STACKSTATE, {"Ss", "showstack"}, "", 
     "show the state of the machine stack" },
  { TAPESTATE, {"T", "t.."}, "", 
     "show the state of the machine tape" },
  { TAPEINFO, {"TT", "tapeinfo"}, "", 
     "show detailed info of the state of the machine tape" },
  { TAPECONTEXTLESS, {"tcl", "lesstape"}, "", 
     "reduce ammount of tape that will be displayed by printSomeTapeInfo()" },
  { TAPECONTEXTMORE, {"tcm", "moretape"}, "", 
     "increase ammount of tape to be displayed by printSomeTapeInfo()" },
  { RESETINPUT, {"i.r", ""}, "", 
     "reset the input stream" },
  { RESETMACHINE, {"M.r", ""}, "", 
     "reset the machine to original state" },
  { STEPMODE, {"m.s", ""}, "", 
     "make <enter> step through instructions" },
  { PROGRAMMODE, {"m.p", ""}, "", 
     "make <enter> display program state" },
  { MACHINEMODE, {"m.m", ""}, "", 
     "make <enter> display machine state" },
  { COMPILEMODE, {"m.c", ""}, "", 
     "set mode: entered instructions are compiled but "
     "not executed" },
  { IPCOMPILEMODE, {"m.ipc", ""}, "", 
     "set mode: entered instructions are compiled at current ip position" },
  { ENDCOMPILEMODE, {"m.ec", ""}, "", 
     "set mode: entered instructions are compiled at end of program" },
  { INTERPRETMODE, {"m.int", "interpret"}, "", 
     "set mode: entered instructions are executed but not compiled" },
  { LISTPROGRAM, {"ls", "p.ls"}, "", 
     "list all instructions in the machines current program" },
  { LISTSOMEPROGRAM, {"l", "list"}, "", 
     "list current instructions in the machines program" },
  { LISTPROGRAMWITHLABELS, {"pl", "p.ll"}, "", 
     "list all instructions in program with labels (and jump labels)" },
  { PROGRAMMETA, {"pm", "pi"}, "", 
     "show some meta information about the current program" },
  { SAVEPROGRAM, {"wa", "p.w"}, "<file>", 
     "save the current program as 'assembler'" },
  { SHOWJUMPTABLE, {"jj", "showjumps"}, "", 
     "Show the jumptable generated by buildJumpTable()" },
  { LOADPROGRAM, {"l.asm", "l.a"}, "<file>", 
     "load machine assembler commands from text file" },
  { LOADASM, {"asm", "as"}, "", 
     "load 'asm.pp' (the script parser) and reset the machine" },
  { LOADLAST, {"last", "p.ll"}, "", 
     "load 'last.pp' (the program automatically saved on exit)" },
  { LOADSAVED, {"sav", "l.sav"}, "", 
     "load 'sav.pp' (output of the 'write' command.)" },
  { LISTSAVFILE, {"lss", "ls.sav"}, "", 
     "list the contents of 'sav.pp' (output of the 'write' command.)" },
  { SAVELAST, {"ww", "p.ww"}, "", 
     "save 'last.pp' (the program automatically saved on exit)" },
  { CHECKPROGRAM, {"p.v", ""}, "", 
     "validate or check the machines compiled program " },
  { CLEARPROGRAM, {"p.dd", "dd"}, "", 
     "delete the machines compiled program " },
  { CLEARLAST, {"p.dl", "pdl"}, "", 
     "delete the last instruction in the compiled program " },
  { INSERTINSTRUCTION, {"pi", "p.i"}, "", 
     "insert an instruction at the current program ip " },
  { EXECUTEINSTRUCTION, {"n", "."}, "", 
     "execute the next (current) compiled instruction in program" },
  { PARSEINSTRUCTION, {"pi:", "pi"}, "<test instruction text>", 
     "parse some example text into a compiled instruction" },
  { TESTWRITEINSTRUCTION, {"twi", "twi"}, "", 
     "shows how the current instruction will be written by writeInstruction()" },
  { STEPCODE, {"p.s", "ps"}, "", 
     "step through the next instruction in compiled program" },
  { RUNCODE, {"rr", "p.r"}, "", 
     "run the whole compiled program from the current instruction" },
  { RUNZERO, {"r0", "p.r0"}, "", 
     "run the whole compiled program from instruction zero" },
  { RUNCHARSLESSTHAN, {"rrc", "runchars"}, "<number>", 
     "run program while characters read less than <number>" },
  { RUNTOLINE, {"rrl", "p.rl"}, "<number>", 
     "run the compiled program until given input stream line number" },
  { RUNTOTRUE, {"rrt", "p.rt"}, "", 
     "run the compiled program until flag is set to true" },
  { RUNTOWORK, {"rrw", "runwork"}, "<text>", 
     "run program until the workspace is exactly the given text" },
  { RUNTOENDSWITH, {"rre", "runworkendswith"}, "<text>", 
     "run program until the workspace ends with the given text" },
  { IPZERO, {"p<<", "p0"}, "", 
     "set the instruction pointer to zero" },
  { IPEND, {"p>>", "p.e"}, "", 
     "set the instruction pointer to the end of the program" },
  { IPGO, {"pg", "p.g"}, "", 
     "set the instruction pointer to the given instruction" },
  { IPPLUS, {"p>", "p.>"}, "", 
     "increment the instruction pointer without executing" },
  { IPMINUS, {"p<", "p.<"}, "", 
     "decrement the instruction pointer without executing" },
  { SHOWSTREAM, {"ss", "ss"}, "", 
     "shows the next few characters from the input stream" },
  { EXIT, {"X", "exit"}, "", 
     "exit the maching testing program" },
  { UNKNOWN, {"", ""}, "", ""}
};

/* display help for one interactive help command
   (not a machine command. which may be should be referred to 
   as instructions to avoid confusion) */
void printHelpCommand(int command, int comColour, int helpColour) {
  int ii = command;
  printf("%s%4s: %s%s%s ", 
     colourInfo[comColour].ansi, testInfo[ii].names[0], 
     colourInfo[helpColour].ansi,
     testInfo[ii].description, NORMAL);
}

/* Display help just for core help commands to assist the 
   user to start to use the interactive system */
void printUsefulCommands() {
  int commands[] = {
    HELP, MACHINEPROGRAM, LISTMACHINECOMMANDS, EXECUTEINSTRUCTION,
    LISTPROGRAM, RUNCODE};

  printf("\nUseful interactive commands: \n"
           "---------------  \n");
  int nn; 
  for (nn = 0; nn < 6; nn++) {
    printHelpCommand(commands[nn], YELLOWc, WHITEc); printf("\n");
  }
}

// check datatype of instruction etc
int checkInstruction(struct Instruction * ii, FILE * file) {
 
  if ((info[ii->command].args > 0) && (ii->a.datatype == UNSET))  {
    fprintf(file, "error: missing argument for command \n");
  }
  if ((commandType(ii->command) == JUMPS) && (ii->a.datatype != INT))  {
    //printf(file, "error: non integer \n");
  }
  if ((info[ii->command].args == 0) && (ii->a.datatype != UNSET))  {
    fprintf(file, "warning: superfluous argument for command %s%s%s \n",
        YELLOW, info[ii->command].name, NORMAL);
  }

  switch (ii->command) {
    case ADD:
      if (ii->a.datatype != TEXT) {
        fprintf(file, "Error: ADD requires 'text' datatype \n");
      }
      if (*ii->a.text == 0) {
        fprintf(file, "No text parameter for ADD \n");
      }
      break;
    case CLIP:
      break;
    case CLOP:
      break;
    case CLEAR:
      break;
    case PRINT:
      break;
    case POP:
      break;
    case PUSH:
      break;
    case PUT:
      break;
    case GET:
      break;
    case SWAP:
      break;
    case INCREMENT:
      break;
    case DECREMENT:
      break;
    case READ:
      break;
    case UNTIL:
    case WHILE:
    case WHILENOT:
      break;
    case JUMP:
      // validate all jump targets... is target undefined, in 
      // range of program etc etc.
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case JUMPTRUE:
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case JUMPFALSE:
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case TESTIS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTIS \n");
      }
      break;
    case TESTBEGINS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTBEGINS \n");
      }
      break;
    case TESTENDS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTENDS \n");
      }
      break;
    case TESTEOF:
      break;
    case TESTTAPE:
      break;
    case COUNT:
      break;
    case INCC:
      break;
    case DECC:
      break;
    case ZERO:
      break;
    case CHARS:
      break;
    case STATE:
      break;
    case QUIT:
      break;
    case WRITE:
      break;
    case NOP:
      break;
    case UNDEFINED:
      break;
    default:
      break;
  } // switch

  return -1;
} // checkInstruction

// steps through one instruction of the machines program
void step(struct Machine * mm) {
  //int result = 
  execute(mm, &mm->program.listing[mm->program.ip]);
}


/*
 runs the compiled program in the machine
 but this will exit when the last read is performed...
 execute() has the following exit codes which we might need to 
 handle:
  0: success no problems
  1: end of stream reached (tried to read eof)
  2: trying to execute undefined instruction
  3: quit/crash command executed (exit script)

*/

enum ExitCode run(struct Machine * mm) {
  int result;
  for (;;) { 
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
  return result;
}

void runDebug(struct Machine * mm) {
  int result;
  long ii = 0;  // a counter
  for (;;) { 
    printf("%6ld: ip=%3d T(n)=%3d", ii, mm->program.ip, mm->tape.currentCell);
    printInstruction(&mm->program.listing[mm->program.ip]);
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    printf("\n");
    if (result != 0) {
      printf("execute() returned error code (%d)\n", result);
      break;
    }
    ii++;
  }
}

/* another debugging tool: run while the number of characters read
   by the machine is less than maximum. This actually has a bug, 
   namely that we need to execute script commands even when the 
   peep is EOF. should exit when readc on EOF is executed.

   */ 
void runWhileCharsLessThan(struct Machine * mm, long maximum) {
  int result;
  while ((mm->peep != EOF) && (mm->charsRead < maximum)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/* another debugging tool: run until the input stream line number 
   is equal to the number */ 
void runToLine(struct Machine * mm, long maximum) {
  int result;
  while ((mm->peep != EOF) && (mm->lines < maximum)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

// runs the compiled program in the machine until the 
// flag register is set to true 
void runUntilTrue(struct Machine * mm) {
  int result;  
  while (mm->flag == FALSE) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/*
  runs the compiled program in the machine until the workspace
  is exactly the specified text */

void runUntilWorkspaceIs(struct Machine * mm, char * text) {
  int result;
  while ((mm->peep != EOF) && (strcmp(mm->buffer.workspace, text) != 0)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/*
int endsWith(const char *str, const char *suffix) {
  if (!str || !suffix) return 0;
  size_t lenstr = strlen(str);
  size_t lensuffix = strlen(suffix);
  if (lensuffix >  lenstr) return 0;
  return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}
*/

int startsWith(const char * text, const char * prefix)
{
  return strncmp(text, prefix, strlen(prefix));
}


/*
  runs the compiled program until the workspace
  is ends with the specified text */
void runUntilWorkspaceEndsWith(struct Machine * mm, char * text) {
  int result;
  while ((mm->peep != EOF) && (!endsWith(mm->buffer.workspace, text))) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

// given user input text return the test command
enum TestCommand textToTestCommand(const char * text) {
  int ii;
  if (*text == 0) return UNKNOWN;
  for (ii = 0; ii < UNKNOWN; ii++) {
    if ((strcmp(text, testInfo[ii].names[0]) == 0) ||
        (strcmp(text, testInfo[ii].names[1]) == 0)) {
       return (enum TestCommand)ii;
    }
  }
  return UNKNOWN;
}

void showTestHelp() {
  int ii;
  int key;
  printf("%s[ALL HELP COMMANDS]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < UNKNOWN; ii++) {
    printf("%s%5s%s %s %s-%s %s%s \n",
      GREEN, testInfo[ii].names[0], PALEGREEN, testInfo[ii].argText,
      NORMAL, WHITE, testInfo[ii].description, NORMAL); 
    if ( (ii+1) % 14 == 0 ) {
      pagePrompt();
      key = getc(stdin);
      if (key == 'q') { return; }
    }
  }
}

// information about different modes the test program can be in
// eg step where enter steps through the next instruction.
// Or maybe 2 mode variables enterMode and programMode. enterMode
// determines what the <enter> key does, and programMode determines
// whether instructions are compiled or executed or both
enum TestMode {
  COMPILE=0, IPCOMPILE, ENDCOMPILE, INTERPRET, 
  MACHINE, PROGRAM, STEP, RUN } mode; 
// contain information about all commands
struct {
  enum TestMode mode;
  char * name;
  char * description;
} modeInfo[] = { 
  { COMPILE, "compile", 
    "enter displays the compiled program. Instructions entered are \n"
    "compiled into the machines program listing, but are not executed "},
  { IPCOMPILE, "ipcompile", 
    "Instructions are compiled into the machines program listing \n"
    "at the current instruction pointer position instead of at  \n"
    "the end of the program. This is a slightly clunky way of \n"
    "modifying the in-memory program, but possibly easier than trying \n"
    "to manually modify the text assembler listing. "},
  { ENDCOMPILE, "endcompile", 
    "Instructions are compiled into the machines program listing \n"
    "at the end of the program  \n" },
  { INTERPRET, "interpret", 
    "Instructions entered are executed but not compiled into the \n"
    "machine's program.  \n" },
  { MACHINE, "machine", "enter displays the state of the machine"},
  { PROGRAM, "", ""},
  { STEP, "step", 
    "When enter is pressed the next instruction is executed and "
    "the state of the machine is displayed "},
  { RUN, "run", 
    "When enter is pressed the current program is run. "}
};

// searches testInfo array for commands matching a search term
void searchHelp(char * text) {
  int ii; int jj = 0;
  char key;
  printf("%s[Searching help commands]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < UNKNOWN; ii++) {
    if ((strstr(testInfo[ii].description, text) != NULL) || 
        (strstr(testInfo[ii].names[1], text) != NULL) || 
        (strstr(testInfo[ii].names[0], text) != NULL))  {
      jj++; 
      printf("%s%5s%s %s %s-%s %s%s \n",
        PURPLE, testInfo[ii].names[0], YELLOW, testInfo[ii].argText,
        NORMAL, BROWN, testInfo[ii].description, NORMAL); 
      if ( (jj+1) % 14 == 0 ) {
        pagePrompt();
        key = getc(stdin);
        if (key == 'q') { return; }
      }
    } // if search term found
  } // for

  if (jj == 0) {
    printf("No results found for '%s'\n", text); 
  }
}

/* load a script from file and install in the machines program at
   instruction number "position". This allows us to append one
   script at the end of another which may be useful, but hasn't been
   so far. */
enum ExitCode loadScript(
   struct Program * program, FILE * scriptFile, int position) {

    /* the procedure is:
      load asm.pp, run it on the script-file (assembly is saved to sav.pp)
      load sav.pp, run it on the input stream. */

    char * asmVar = "ASMPP";
    char * asmName = "asm.pp";
    int BUFSIZE = 256;
    char asmPath[BUFSIZE];
    struct stat statbuffer;   
    // if asm.pp found in current folder
    if (stat(asmName, &statbuffer) == 0) {
      strcpy(asmPath, asmName);
    }
    //if (stat(asmName, &statbuffer) != 0) {
    // if not found in current folder
    else {
      if(!getenv(asmVar)) {
        fprintf(stdout, 
          "The script assembler '%s' was not found.\n" 
          "Try setting the environment variable '%s' to the folder \n"
          "where the script assembler is located, eg: \n"
          "  export %s=~/pars/ \n"
          "A copy of the script assembler can be found at: \n"
          "  http://bumble.sf.net/books/pars/asm.pp \n", 
         asmName, asmVar, asmVar);
         exit(1);
      }
      // Make sure the buffer is large enough to hold the environment variable
      // Make sure the buffer is large enough to hold the environment variable
      // value. 
      if(snprintf(asmPath, BUFSIZE, "%s%s", getenv(asmVar),asmName) 
         >= BUFSIZE) {
        fprintf(stderr, "BUFSIZE of %d was too small to hold asm path name. Aborting\n", 
          BUFSIZE);
        exit(1);
      }
      if (stat(asmPath, &statbuffer) != 0) {
        fprintf(stdout, "The script assembler '%s' was not found.\n",
         asmPath);
         exit(1);
      } 

    }
    FILE * asmFile;
    if ((asmFile = fopen(asmPath, "r")) == NULL) {
       printf("loadScript(): Could not open script assembler, path:%s \n", 
       asmPath);
       exit(1);
    }

    FILE * savFile;
    // first delete contents of the sav.pp file to avoid confusion
    // later.
    if ((savFile = fopen("sav.pp", "w")) == NULL) {
      printf("Could not open script file %s'sav.pp'%s for writing \n", 
        YELLOW, NORMAL);
      return(1);
    } 

    fputs("add \"no script\" \n", savFile);
    fputs("quit \n", savFile);
    fclose(savFile);

    struct Machine new;
    newMachine(&new, scriptFile, TAPESTARTSIZE, 10);
    loadAssembledProgram(&new.program, asmFile, 0);

    int result = 0;
    result = run(&new);

    /*
     check if the compilation was successful. (which means 
     ExitCode SUCCESS of EXECQUIT) If not successful, do not proceed.
     because the script file was not properly compiled by asm.pp
    */

    if (result > EXECQUIT) {
      // try to give a more informative error message here
      // showMachineTapeProgram(&new, 3);
    }

    //runDebug(&m);
    fclose(asmFile);
    freeMachine(&new);

    if (result > EXECQUIT) {
      return result;
    }

    // asm.pp has created a new sav.pp file, which is the 
    // script in a "compiled" form (a type of assembly language
    // for the parse virtual machine. We can now open, load  
    // it and run it. 
    if ((savFile = fopen("sav.pp", "r")) == NULL) {
      printf("Could not open script file %s'sav.pp'%s for reading. \n", 
        YELLOW, NORMAL);
      return READSAVERROR;
    } 
    loadAssembledProgram(program, savFile, 0);
    fclose(savFile);
    //freeMachine(&new);
    return SUCCESS;
}

void printUsageHelp() {
  fprintf(stdout, "'pep' a pattern parsing machine \n"
    "Usage: pep [-shI] [-i 'text'] [-e 'snippet'] [-f script-file] [-a file] [inputfile] \n"
    " \n"
    "  -f script-file   text input file \n"
    "  -e expression    add inline script commands to script \n"
    "  -i text          use 'text' as input for the script \n"
    "  -c               show machine command names and descriptions \n"
    "  -C               show just machine command names \n"
    "  -h               print this help \n"
    "  -s               run in unix filter mode (the default).\n"
    "  -a [file]        load script-assembly source file \n"
    "  -I               run in interactive mode (with shell) \n");
    //"  -M               print the state of the machine after compiling \n"
    //"                   a script. This option is useful for debugging. \n"
}

// The main testing loop for the machine. This accepts interactive 
// commands and executes them, among other things. Allows the state
// of the machine to be observed, including the compiled program.
int main (int argc, char *argv[]) {

  // the stream that will be read from.
  FILE * inputStream = NULL;

  // script commands on the command line with the -e switch
  // this pointer was getting corrupted by something below.
  char * inlineScript = NULL;
  int c;
  // name of the file with script assembly commands
  char * asmFileName = NULL;
  // name of file to serve as input stream
  char * inputFile = NULL;
  // name of the file with parse script commands
  char * scriptFileName = NULL;
  // inline input (instead of an input file) 
  char * inlineInput = NULL;

  char source[64] = "input.txt";
  // if asm.pp generates an error, then the machine parse state will
  // be printed.
  enum Bool printState = FALSE;
  /* filtermode means the program is used as a unix filter, like sed, grep etc
     intermode means the program starts an interactive shell, so that 
     the user can debug scripts and learn about the machine */
  enum { FILTERMODE, INTERMODE } progmode = FILTERMODE;
  // determines how much of the tape will be shown by printSomeTapeInfo()
  // and showMachineTapeProgram()
  int tapeContext = 3;
  // (initial) number of tapecells
  int tapeSize = 500;

  opterr = 0;

  while ((c = getopt (argc, argv, "i:f:e:IsMcCha:")) != -1) {
    switch (c) {
      // a text input file, but this should be a non-option argument
      // (just the file name).
      case 'f':
        scriptFileName = optarg;
        break;
      case 'e':
        inlineScript = optarg;
        break;
      case 'i':
        inlineInput = optarg;
        break;
      case 'I':
        progmode = INTERMODE; 
        break;
      case 's':
        progmode = FILTERMODE; 
        break;
      case 'M':
        printState = TRUE; 
        break;
      case 'c':
        printCommandNamesAndDescriptions();
        exit(1);
        break;
      case 'C':
        showCommandNames();
        exit(1);
        break;
      case 'h':
        printUsageHelp();
        break;
      case 'a':
        asmFileName = optarg;
        break;
      case '?':
        switch (optopt) {
          case 'a':
            fprintf (stderr, "Option -%c requires an argument.\n", optopt);
            fprintf (stderr, " -a scriptAssemblyFile \n");
            break;
          case 'f': 
            fprintf (
              stderr, "%s: option -%c requires an argument.\n", 
              argv[0], optopt);
            break;
          case 'e': 
          case 'i': 
            fprintf (
              stderr, "%s: option -%c requires an argument.\n", 
              argv[0], optopt);
            break;
          default:
            fprintf (stderr, "%s: unknown option -- %c \n", argv[0], optopt);
            break;
        }
        printUsageHelp(); 
        exit(1);
      default:
        abort ();

    }
  } // while

  if (argv[optind] != NULL) 
    { inputFile = argv[optind]; }

  if ((asmFileName != NULL) && (scriptFileName != NULL)) {
    printf("cannot load assembly and script at the same time (-a and -f)");
    printUsageHelp();
    exit(1);
  }

  char version[64] = "v31415";

  if (progmode != FILTERMODE) {
    banner() ;
    // printf("Compiled: %s%s%s \n", YELLOW, version, NORMAL);
  }

  struct Machine m; 

  //struct Instruction i;

  if (inputFile != NULL) { 
    strcpy(source, inputFile);
  }


  if ((inlineInput == NULL) && (inputFile == NULL)) {
    fprintf(stdout, "No input given to script (use -i or inputFile)\n");
    printUsageHelp();
    exit(1);
  }

  if ((inlineInput != NULL) && (inputFile != NULL)) {
    fprintf(stdout, "cannot use -i switch and inputFile together\n");
    printUsageHelp();
    exit(1);
  }

  /* use input given to the -i switch. This is a convenience for 
     testing scripts */
  if (inlineInput != NULL) {
    FILE * temp = NULL;
    if ((temp = fopen("tempInput.txt", "w")) == NULL) {
      printf("Could not open temporary file %stempInput.txt%s for writing \n", 
        YELLOW, NORMAL);
      exit(1);
    } 
    fputs(inlineInput, temp);
    if (temp != NULL) { 
      fclose(temp); temp = NULL;
    }
    strcpy(source, "tempInput.txt");
  }

  // mode determines how the enter key behaves. Also, in compile mode
  // instructions are compiled into the machines program but not automatically
  // executed
  enum TestMode mode = INTERPRET;
  enum TestCommand testCom;


  if((inputStream = fopen (source, "r")) == NULL) {
    printf ("Cannot open file %s%s%s \n", YELLOW, source, NORMAL);
    printf ("Try %s%s -i <inputfile>%s \n", CYAN, argv[0], NORMAL);
    exit (1);
  }
  //else { inputStream = stdin; }

  if (progmode != FILTERMODE) {
    printf("Using source file %s%s%s as input stream \n", 
      YELLOW, source, NORMAL);
    printUsefulCommands();

  }

  FILE * asmFile;
  FILE * scriptFile;

  // machine, input stream, tape cells, tape cells size, and program listing
  newMachine(&m, inputStream, tapeSize, 10);
  // now we can use the machine to parse etc
  if (asmFileName != NULL) {
    if ((asmFile = fopen(asmFileName, "r")) == NULL) {
      printf("Could not open script-assembler file %s%s%s \n", 
        YELLOW, asmFileName, NORMAL);
      freeMachine(&m);
      exit(1);
    } 
    if (progmode != FILTERMODE) {
      printf("\n");
      printf("Loading assembler file %s%s%s \n", YELLOW, asmFileName, NORMAL);
    }
    strcpy(m.program.source, "asm.pp"); 
    loadAssembledProgram(&m.program, asmFile, 0);

    if (progmode != FILTERMODE) {

      printf("Compiled %s%d%s instructions "
             "from '%s%s%s' in about %s%ld%s milliseconds \n",
        CYAN, m.program.count, NORMAL, 
        CYAN, m.program.source, NORMAL,
        CYAN, m.program.compileTime, NORMAL);
    }
    fclose(asmFile);
  }

  if (scriptFileName != NULL) {
    if ((scriptFile = fopen(scriptFileName, "r")) == NULL) {
      printf("Could not open script file %s%s%s \n", 
        YELLOW, scriptFileName, NORMAL);
      freeMachine(&m);
      exit(1);
    } 
    if (progmode != FILTERMODE) {
      printf("\n");
      printf("Loading script file %s%s%s \n", YELLOW, scriptFileName, NORMAL);
    }
    /* the procedure is:
      load asm.pp, run it on the script-file (assembly is saved to sav.pp)
      load sav.pp, run it on the input stream. */
    int result = loadScript(&m.program, scriptFile, 0);
    fclose(scriptFile);
    /*
    if (printState == TRUE) {
      showMachineTapeProgram(&m, 3);
    } */

    if (result > EXECQUIT) {
      fprintf(stderr, 
        "The script file '%s' could not be compiled. \n", scriptFileName); 
      printExitCode(result);
      freeMachine(&m);
      exit(result);
    }
  }
  /* add commands given to the -e switch to the current program */
  if (inlineScript != NULL) {
    /* the procedure is:
      save the -e script commands to a temporary file
      compile the commands to sav.pp with asm.pp 
      load sav.pp, run it on the input stream. */
    FILE * temp = NULL;
    if ((temp = fopen("temp.pp", "w")) == NULL) {
      printf("Could not open temporary file %stemp.pp%s for writing \n", 
        YELLOW, NORMAL);
      freeMachine(&m);
      exit(1);
    } 

    // printf("inline script: %s \n", inlineScript);
    fputs(inlineScript, temp);
    // this is a cludge because asm.pp doesnt deal with
    // the last character of input. 
    fputs(" ", temp);
    fclose(temp);

    if ((temp = fopen("temp.pp", "r")) == NULL) {
      printf("Could not open temporary file %stemp.pp%s for reading \n", 
        YELLOW, NORMAL);
      freeMachine(&m);
      exit(1);
    } 

    char * asmVar = "ASMPP";
    char * asmName = "asm.pp";
    struct stat statbuffer;   
    if (stat(asmName, &statbuffer) != 0) {
      if(!getenv(asmVar)) {
        fprintf(stdout, 
          "The script assembler '%s' was not found.\n" 
          "Try setting the environment variable '%s' to the folder \n"
          "where the script assembler is located, eg: \n"
          "  export %s=~/pars/ \n"
          "A copy of the script assembler can be found at: \n"
          "  http://bumble.sf.net/books/pars/asm.pp \n", 
         asmName, asmVar, asmVar);
         exit(1);
      }
      // Make sure the buffer is large enough to hold the environment variable
      // value. 
      int BUFSIZE = 256;
      char asmPath[BUFSIZE];
      if(snprintf(asmPath, BUFSIZE, "%s%s", getenv(asmVar),asmName) 
         >= BUFSIZE) {
        fprintf(stderr, "BUFSIZE of %d was too small. Aborting\n", BUFSIZE);
        exit(1);
      }
      if (stat(asmPath, &statbuffer) != 0) {
        fprintf(stdout, "The script assembler '%s' was not found.\n",
         asmPath);
         exit(1);
      } else {
        if ((asmFile = fopen(asmPath, "r")) == NULL) {
           printf("Could not open script assembler '%s' \n", 
           asmPath);
           exit(1);
        }
      }
    // todo: revise this logic
    } else {
      if ((asmFile = fopen(asmName, "r")) == NULL) {
        printf("Could not open script assembler '%s' \n", asmName);
        exit(1);
      } 
    }

    if (progmode != FILTERMODE) {
      printf("Loading assembler %sasm.pp%s \n", YELLOW, NORMAL);
    }

    // need a parameter to loadScript if we want to show machine
    // state after a compilation error
    int result = loadScript(&m.program, temp, m.program.count);
    fclose(temp);
    if (result > EXECQUIT) {
      fprintf(stderr, 
        "The inline script in -e '%s' "
        "was not compiled. \n", inlineScript); 
      printExitCode(result);
      freeMachine(&m);
      if (inputStream != NULL) { 
        fclose(inputStream); inputStream = NULL;
      }
      exit(result);
    }
  }

  if (progmode == FILTERMODE) {
    //or runDebug(&m);
    run(&m);

    freeMachine(&m);

    /*
     fix:
     this was causing a segmentation fault probably because
     the inputStream pointer was corrupted.
    */
    if (inputStream != NULL) { 
      fclose(inputStream); inputStream = NULL;
    }

    // return the accumulator value here 
    // if the script exited with 'quit' 
    exit(m.accumulator);
    // exit(0);
  }

  char line[401];
  char command[201];
  char argA[201];
  char argB[201];
  char args[300];

  while (1) {
    printf(">");
    fgets(line, 400, stdin);
    // remove newline
    line[strlen(line) - 1] = '\0';
    //printf("input[%s]\n", line);
      
    command[0] = args[0] = argA[0] = argB[0] = '\0';
    // int result;
    sscanf(line, "%200s %200[^\n]", command, args);

    // we also need to deal with quoted arguments such as
    //  a "many words"
    //  eg ranges [a-z] character classes :alpha: etc.

   /*
   A good example of sscanf with different cases
    res = sscanf(buf, 
      " \"%5[^\"]\" \"%19[^\"]\" \"%29[^\"]\" %lf %d", 
      p->number, p->name, p->description, &p->price, &p->qty);

   if (res < 5) {
     static const char *where[] = {
        "number", "name", "description", "price", "quantity"};
    if (res < 0) res = 0;
    fprintf(stderr, 
      "Error while reading %s in line %d.\n", where[res], nline);
       break;
   }
   */

    // eg sscanf(line, "%200s '%200[^']'", command, argA)
    // printf("c=%s, argA=%s, argB=%s \n", command, argA, argB);

    testCom = textToTestCommand(command);
    //printf("testcom= %s \n", testInfo[testCom].description);

    if (testCom == HELP) {
      showTestHelp();
    }
    else if (testCom == SEARCHCOMMAND) {
      if (strlen(args) == 0) {
        printf("No command seach term specified. \n");
        printf("Try: // <search-term> \n");
        continue;
      }
      searchCommandHelp(args);
    }
    else if (testCom == SEARCHHELP) {
      if (strlen(args) == 0) {
        printf("No seach term specified. \n");
        printf("Try: / <search-term> \n");
        continue;
      }
      searchHelp(args);
    }
    else if (testCom == COMMANDHELP) {
      if (strlen(args) == 0) {
        printf("No machine command specified. \n");
        continue;
      }
      if (textToCommand(args) == UNDEFINED) {
        printf("Not a valid machine command %s%s%s \n", YELLOW, args, NORMAL);
        continue;
      }
      enum Command thisCom = textToCommand(args);
      printf("name: %s %s(%s%c%s)%s \n", 
        info[thisCom].name, GREY, GREEN, info[thisCom].abbreviation, 
        GREY, NORMAL);
      printf("   %s \n", info[thisCom].shortDesc);
      printf("   %s \n", info[thisCom].longDesc);
      printf("example: %s \n", info[thisCom].example);
      printf("takes %s%d%s argument(s) \n", YELLOW, info[thisCom].args, NORMAL);
    }
    else if (testCom == LISTMACHINECOMMANDS) {
      showCommandNames();
    }
    else if (testCom == DESCRIBEMACHINECOMMANDS) {
      machineCommandHelp();
    }
    else if (testCom == MACHINECOMMANDDOC) {
      machineCommandAsciiDoc(stdout);
    }
    else if (testCom == LISTCLASSES) {
      printClasses();
    }
    else if (testCom == LISTCOLOURS) {
      showColours();
    }
    else if (testCom == MACHINEPROGRAM) {
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == MACHINESTATE) {
      showMachine(&m, TRUE);
    }
    else if (testCom == MACHINETAPESTATE) {
      showMachineWithTape(&m);
    }
    else if (testCom == MACHINEMETA) {
      printMachineMeta(&m);
    }
    else if (testCom == BUFFERSTATE) {
      showBufferInfo(&m.buffer);
    }
    else if (testCom == STACKSTATE) {
      showStackWorkPeep(&m, TRUE);
    }
    else if (testCom == TAPESTATE) {
      printSomeTape(&m.tape, TRUE);
    }
    else if (testCom == TAPEINFO) {
      printTapeInfo(&m.tape);
    }
    else if (testCom == TAPECONTEXTLESS) {
      if (tapeContext > 0) tapeContext--;
      printf("Tape display variable set to %d\n", tapeContext);
    }
    else if (testCom == TAPECONTEXTMORE) {
      tapeContext++;
      printf("Tape display variable set to %d\n", tapeContext);
    }
    else if (testCom == RESETINPUT) {
      rewind(inputStream);
      printf ("%s Rewound the input stream %s \n", YELLOW, NORMAL);
    }
    else if (testCom == RESETMACHINE) {
      colourPrint("reinitializing machine ...\n");
      resetMachine(&m);
    }
    else if (testCom == STEPMODE) {
      mode = STEP;
      printf(
        "%sSTEP%s mode (<enter> steps next instruction)\n", 
        YELLOW, NORMAL);
    }
    else if (testCom == PROGRAMMODE) {
      mode = PROGRAM;
      printf(
        "%sPROGRAM%s mode (<enter> displays program listing)\n", 
         YELLOW, NORMAL);
    }
    else if (testCom == MACHINEMODE) {
      mode = MACHINE;
      printf(
        "%sMACHINE%s mode (<enter> displays machine state)\n", 
        YELLOW, NORMAL);
    }
    else if (testCom == COMPILEMODE) {
      printf ("Not implemented ... \n");
    }
    else if (testCom == IPCOMPILEMODE) {
      mode = IPCOMPILE;
      printf ("Mode set to %sIPCOMPILE%s \n", YELLOW, NORMAL);
      printf (
        "  Instructions will be compiled into the program \n"
        "  at the current instruction pointer position, instead \n"
        "  of at the end of the program. \n");
    }
    else if (testCom == ENDCOMPILEMODE) {
      mode = ENDCOMPILE;
      printf ("Mode set to %sENDCOMPILE%s \n", YELLOW, NORMAL);
    }
    else if (testCom == INTERPRETMODE) {
      mode = INTERPRET;
      printf("Mode set to %sINTERPRET%s \n", YELLOW, NORMAL);
      printf("  %smachine commands will be executed but not compiled \n"
             "  to the internal program.%s \n",
             WHITE, NORMAL);
    }
    // ENTER key pressed ....
    else if (strcmp(command, "") == 0) {
      if (mode == MACHINE) {
        // to do: show the stream with ftell and fseek
        showMachine(&m, TRUE);
      }
      else if (mode == STEP) {
        step(&m);
        printSomeProgram(&m.program, 5);
        showMachine(&m, TRUE);
      }
      else if (mode == PROGRAM) {
        printSomeProgram(&m.program, 5);
      }
    }
    else if (strcmp(command, "BB") == 0) {
      showBufferAndPeep(&m);
    }
    else if (testCom == LISTPROGRAM) {
      printProgram(&m.program);
    }
    else if (testCom == LISTSOMEPROGRAM) {
      printSomeProgram(&m.program, 7);
    }
    else if (testCom == LISTPROGRAMWITHLABELS) {
      printProgramWithLabels(&m.program);
    }
    else if (testCom == PROGRAMMETA) {
      printProgramMeta(&m.program);
    }
    else if (testCom == SAVEPROGRAM) {
      FILE * savefile;
      if (strlen(args) == 0) {
        printf ("%s No save file given! %s \n", CYAN, NORMAL);
        printf ("%s Try %sP.wa <filename> %s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      if ((savefile = fopen (args, "w")) == NULL) {
        printf ("Could not open file %s%s%s for writing \n", 
          YELLOW, args, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);
      fclose(savefile);
    }
    else if (testCom == SHOWJUMPTABLE) {
      printJumpTable(m.program.labelTable);
    }
    else if (testCom == LOADPROGRAM) {
      FILE * loadfile;
      if (strlen(args) == 0) {
        printf ("%s No assembly text file given to load %s \n", GREEN, NORMAL);
        continue;
      }
      if ((loadfile = fopen (args, "r")) == NULL) {
        printf ("Could not open file %s%s%s for reading\n", YELLOW, args, NORMAL);
        continue;
      }
      loadAssembledProgram(&m.program, loadfile, 0);
      strcpy(m.program.source, args); 
      fclose(loadfile);
    }
    else if (testCom == LOADASM) {
      FILE * loadfile;
      if ((loadfile = fopen ("asm.pp", "r")) == NULL) {
        printf ("Could not open file %sasm.pp%s for reading\n", 
           YELLOW, NORMAL);
        continue;
      }
      printf("%sresetting machine and loading '%sasm.pp%s'... \n",
        BROWN, PINK, NORMAL);
      rewind(inputStream);
      resetMachine(&m);
      clearProgram(&m.program);
      strcpy(m.program.source, "asm.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LOADLAST) {
      FILE * loadfile;
      if ((loadfile = fopen ("last.pp", "r")) == NULL) {
        printf ("Could not open file %slast.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      strcpy(m.program.source, "last.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LOADSAVED) {
      FILE * loadfile;
      if ((loadfile = fopen ("sav.pp", "r")) == NULL) {
        printf ("Could not open file %ssav.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      strcpy(m.program.source, "sav.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LISTSAVFILE) {
      FILE * loadfile;
      char line[200];
      char key;
      int ii = 0;

      if ((loadfile = fopen("sav.pp", "r")) == NULL) {
        printf ("Could not open file %ssav.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      while (fgets(line, sizeof(line), loadfile)) {
        printf("%s", line);
        if ((ii+1) % 14 == 0) {
          pagePrompt();
          key = getc(stdin);
          if (key == 'q') { break; }
        }
      }
      fclose(loadfile);
    }
    else if (testCom == SAVELAST) {
      FILE * savefile;
      if ((savefile = fopen ("last.pp", "w")) == NULL) {
        printf ("Could not open file %slast.pp%s for writing \n", 
          YELLOW, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);
      fclose(savefile);
    }
    else if (testCom == CHECKPROGRAM) {
      printf("Not implemented \n");
    }
    else if (testCom == CLEARPROGRAM) {
      clearProgram(&m.program);
    }
    else if (testCom == CLEARLAST) {
      // need to set last instruction to undefined 
      newInstruction(&m.program.listing[m.program.count-1], UNDEFINED);
      m.program.count--;
      printSomeProgram(&m.program, 7);
    }
    else if (testCom == INSERTINSTRUCTION) {
      // insert an instruction at the current program ip
      // need to recalculate jump address (add 1)
      printf ("Inserting instruction at %s%d%s \n",
        YELLOW, m.program.ip, NORMAL);
      insertInstruction(&m.program);
      printProgram(&m.program);
    }
    else if (testCom == EXECUTEINSTRUCTION) {
      execute(&m, &m.program.listing[m.program.ip]);
      showMachineTapeProgram(&m, tapeContext);
      /*
      printSomeProgram(&m.program, 6);
      printf("%s--------- Machine State ----------%s \n", 
         YELLOW, NORMAL);
      showMachine(&m);
      */
    }
    else if (testCom == PARSEINSTRUCTION) {
      struct Instruction * ii;
      struct Label table[100];  // void jumptable
      printf("testing instructionFromText()...\n");
      if (strlen(args) == 0) {
        printf ("%s No example instruction given... %s \n"
                " Try %spi: add {this}%s \n", GREEN, NORMAL, YELLOW, NORMAL);
        continue;
      }
      newInstruction(ii, UNDEFINED);
      instructionFromText(stdout, ii, args, -1, table);
      printEscapedInstruction(ii);
      printf("\n");
    }
    else if (testCom == TESTWRITEINSTRUCTION) {
      printf("Testing writeInstruction()... \n");
      writeInstruction(&m.program.listing[m.program.ip], stdout);  
    }
    else if (testCom == STEPCODE) {
      printf("step through next compiled instruction:\n");
      step(&m);
      printSomeProgram(&m.program, 6);
    }
    else if (testCom == RUNCODE) {
      printf("%sRunning program from instruction %s%d%s...%s\n", 
        GREEN, CYAN, m.program.ip, GREEN, NORMAL);
      run(&m);
      printf("\n%s--------- Machine State ----------%s \n", 
         YELLOW, NORMAL);
      showMachine(&m, TRUE);
    }
    else if (testCom == RUNZERO) {
      printf("%sRunning program from ip 0%s\n", GREEN, NORMAL);
      m.program.ip = 0;
      run(&m);
    }
    else if (testCom == RUNCHARSLESSTHAN) {
      int maximum;
      if (!sscanf(args, "%d", &maximum) ||  (strlen(args) == 0)) {
        printf ("%sNo number argument given%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrc %s<number>%s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      printf("%sRunning while characters less than %d%s\n", 
         GREEN, maximum, NORMAL);
      runWhileCharsLessThan(&m, maximum);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOLINE) {
      int maximum;
      if (!sscanf(args, "%d", &maximum) ||  (strlen(args) == 0)) {
        printf ("%sNo line number argument given%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrc %s<number>%s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      printf("%sRunning until input line number is %d%s\n", 
         GREEN, maximum, NORMAL);
      runToLine(&m, maximum);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOTRUE) {
      printf("run program until the flag is set to true\n");
      runUntilTrue(&m);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOWORK) {
      if (strlen(args) == 0) {
        printf ("%sNo text given to compare%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrw %s<text>%s \n", GREEN, YELLOW, NORMAL);
        printf ("   runs the current program until workspace is <text> \n");
        continue;
      }
      printf("Running program until workspace is \"%s%s%s\" \n", 
         YELLOW, args, NORMAL);
      runUntilWorkspaceIs(&m, args);
      // printf("%s--------- Machine State ----------%s \n", 
      //   YELLOW, NORMAL);
      showMachineWithTape(&m);
    }
    else if (testCom == RUNTOENDSWITH) {
      if (strlen(args) == 0) {
        printf ("%sNo text given to compare%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrw %s<text>%s \n", GREEN, YELLOW, NORMAL);
        printf ("   runs the program until workspace ends with <text> \n");
        continue;
      }
      printf("Running program until workspace ends with \"%s%s%s\" \n", 
         YELLOW, args, NORMAL);
      runUntilWorkspaceEndsWith(&m, args);
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == IPZERO) {
      m.program.ip = 0;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPEND) {
      m.program.ip = m.program.count-1;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPGO) {
      if (strlen(args) == 0) {
        printf ("%s No number given to jump to %s \n", GREEN, NORMAL);
        continue;
      }
      int ipnumber = 0;
      int res = sscanf(args, " %d", &ipnumber);
      if (res < 1) {
        printf ("%s Couldnt parse number %s \n", GREEN, NORMAL);
        continue;
      }
      m.program.ip = ipnumber; 
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPPLUS) {
      m.program.ip++;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPMINUS) {
      m.program.ip--;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == SHOWSTREAM) {
      // show some upcoming chars from stream and then
      // reset stream position
      long pos = ftell(m.inputstream);
      int num = 40;
      char c;
      int ii = 0;
      printf ("%sNext %s%d%s chars in input stream...%s\n", 
        GREEN, YELLOW, num, GREEN, BLUE);
      while (((c = fgetc(m.inputstream)) != EOF) && (ii < num)) {
        printf("%c", c);
        ii++;
      }
      printf("%s\n", NORMAL);
      fseek(m.inputstream, pos, SEEK_SET);
    }
    // deal with pure machine commands (not testing commands)
    else if (textToCommand(command) != UNDEFINED) {
      void * p = NULL; // no jump table here
      if (mode == IPCOMPILE) {
        compile(&m.program, line, m.program.ip, p);
      }
      else if (mode == INTERPRET) {
        // execute the entered command but dont insert it 
        // in the program.
        struct Instruction ii;
        instructionFromText(stdout, &ii, line, 0, p);
        execute(&m, &ii);
        // execute automatically advances ip pointer, which we
        // dont want in this case. Jumps will probably not be entered
        // interactively so, should not cause trouble here.
        m.program.ip--;
        showMachineTapeProgram(&m, tapeContext);
        continue;
      }
      else {
        compile(&m.program, line, m.program.count, p);
      }
      // check if the instruction is ok
      // checkInstruction(&m.program.listing[m.program.count-1], stdout);

      if (mode == COMPILE) {
        showMachineTapeProgram(&m, tapeContext);
      } else step(&m);

      m.program.ip = m.program.count;
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == EXIT) {
      printf("%sSaving program to '%slast.pp%s'...\n", 
        GREEN, YELLOW, GREEN);
      FILE * savefile;
      if ((savefile = fopen ("last.pp", "w")) == NULL) {
        printf ("Could not open file %slast.pp%s for writing \n", 
          YELLOW, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);

      if (savefile != NULL) { 
        fclose(savefile); savefile = NULL;
      }
      if (inputStream != NULL) { 
        fclose(inputStream); inputStream = NULL;
      }
      colourPrint("Freeing Machine memory...\n");
      freeMachine(&m);
      colourPrint("Goodbye !!\n");
      exit(1);
    }
    else {
      printf("%sUnrecognised command:%s %s %s \n", 
        BROWN, command, GREEN, NORMAL);
    }

  }

  if (inputStream != NULL) { 
    fclose(inputStream); inputStream = NULL;
  }
  return(0);
}
// </code>

/*
*/
