# Assembled with the script 'compile.pss' 
start:
 
#   tr/translate.go.pss 
#
#   This is a parse-script which translates parse-scripts into "go"
#   (golang) code, using the 'pep' tool. The script creates a standalone 
#   go program
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/pep.c. This implements a script
#   language with a syntax reminiscent of sed and awk (simpler than
#   awk, but more complex than sed).
#   
#STATUS
#
#   28 aug 2021
#     1st and 2nd gen working in pep.tt go (tr/tr.test.txt)
#
#NOTES
#   
#   Really I should remove the syntax <while "x";> from the 
#   script language because this can be expressed with
#   <while [x]>. This will reduce complexity. Also, in the 
#   case <while [x]> we should translate as "for mm.peep=='x' { read }
#
#   maybe should use go's unicode.IsPunct('.') functions
#   instead of regular expressions, that should be faster
#   also that solves our multi-return value problem.
#   strings.ContainsAny("Hello World", ",|or")) for [xyz]
#
#   * So for "while" command it will be
#   >> while strings.ContainsAny(mm.peep, "abc") { read }
#
#   * for tests eg [abc] {...} it will be
#   >> if strings.ContainsAny(mm.work, "abc") { }
#   
#   * write function isType() with function argument
#   ---
#    type fn func(rune) bool
#    // eg unicode.IsLetter('x')
#    func isType(type fn, s string) {
#      loop through each char in s
#    }
#    // call
#    if isType(unicode.IsLetter, mm.work) 
#    while isType(unicode.IsLetter, mm.peep) read
#   ,,,
#
#
#   unicode.IsLetter('x') for [:alpha:]
#   * see if all chars in workspace are in range
#   ---
#    f := func(r rune) bool {
#      return r < 'A' || r > 'z'
#    }
#    if strings.IndexFunc(mm.work, f) != -1 {
#        fmt.Println("Found special char")
#    }
#   ,,,
#
#   * or pass the function straight in?
#    if strings.IndexFunc(mm.work, func(r rune) bool { return r<'A'||r>'z'}) != -1 {
#        fmt.Println("Found special char")
#    }
#
#   if square, _ := squareAndCube(n); square > m {
#   this is tricky, because cant have anonymous value from
#
#   * regexp syntax in go.
#   >> match, _ := regexp.MatchString("p([a-z]+)ch", "peach")
#    fmt.Println(match)
#
#   In other translation scripts, we use labelled loops and
#   break/continue to implement the parse> label and .reparse .restart
#   commands. Breaks could be used to implement the quit command but arent.
#
#   Does go support labelled loops? yes
#
#   We can use "run once" loops eg " for true do ... break; end " an 
#   example is in the translate.tcl.pss script. 
#
#SEE ALSO
#   
#   At http://bumble.sf.net/books/pars/
#
#   tr/translate.java.pss, tr/translate.py.pss tr/translate.rb.pss
#     very similar scripts for compiling scripts into java and python,
#     ruby and more
#
#   compile.pss
#     compiles a script into an "assembly" format that can be loaded
#     and run on the parse-machine with the -a  switch. This performs
#     the same function as "asm.pp" 
#
#TESTING
#
#   Comprehensive testing can be done with
#   >> pep.tt go
#
#   A simple "state" command maybe useful for debugging these 
#   translation scripts and the corresponding machines. 
#
#   test begin blocks. parse> .reparse .restart
#  
#   Try 2nd generation 
#   ---
#     pep -f tr/translate.go.pss tr/translate.go.pss > eg/go/translate.go.go  
#     echo "r;[a-d]{t;}t;d;" | eg/go/translate.go.go > test.go
#     echo "abxy" | ./test.go
#     # and the output is "aabbxy"
#   ,,,,
#
#   So the script translates itself into go, then the new go translator
#   translates another script into go.
#
#   * use a helper script to test begin blocks, stack delimiter, and pushing
#   >> pep.gos 'begin { delim "/";} r; add "/";push; state; d;' 
#   >> pep.gos 'begin { delim "/";} r; add "/";push; state; d;' "abcd"
#
#   * a simple test procedure 
#   ---------
#    pep -f translate.go.pss -i "r;t;t;d;" > test.go
#    go build test.go
#    echo "abc" | ./test
#    # should print 'aabbcc'
#   ,,,
#
#   * use the bash helper functions to test (from helpers.pars.sh)
#   >> pep.gof eg/json.check.pss '{"here":2}'
#
#   The line above compiles the script to go in the folder
#   pars/eg/go/json.check.pss and runs it with the input.
#
#   check multiline text with 'add' and 'until'
#
#   * one comprehensive test is to run the script on itself
#   >> pep -f translate.go.pss translate.go.pss > eg/go/translate.go.go
#   >> cd eg/go/; go build translate.go.go 
#   >> echo "r;t;t;d;" | eg/go/translate.go
#
#WATCH OUT FOR
#
#  treatment of regexes is different (for while whilenot etc). Eg in
#  ruby [[:space:]] is unicode aware but \s is not
#
#  make sure .reparse and .restart work before and after the 
#  parse> label.
#
#  Make sure escaping and multiline arguments work.
#
#BUGS
#   
#  will reparse or restart work in a begin block?
#
#  parse> label just after begin block or after all code.
#
#  multiline add not working?
#
#  mark code may not be correct
#
#SOLVED BUGS TO WATCH FOR 
#
#  * the line below was throwing an error, problem was in compile.pss 
#  >> add '", "\\'; get; add '")'; --; put; clear;
#
#  Java needs a double escape \\\\ before some chars, but ruby doesnt languages no.
#
#  escape needs to use the machine escape char. 
#  found and fixed a bug in java whilenot/while. The code exits if the 
#  character is not found, which is not correct.
#
#  Found and fixed a bug in the (==) code ie in java (stringa == stringb)
#  doesnt work. 
#
#  "until" bug where the code did not read 
#  at least one character.
#
#  Read must exit if at end of stream, but while/whilenot/until, no.
#
#TASKS 
#
#HISTORY
#
#  17 June 2022
#    Trying to make the tape dynamically growable, which is necessary
#    for scripts like eg/palindrome.pss
#  28 aug 2021
#    fixing class tests and while class code, using helper 
#    functions isInClass etc
#  26 aug 2021
#    continuing to debug. need to convert class regex syntax.
#    Using "pep.tt go" to find errors.
#  15 july 2021
#    continued the work of syntax conversion, but scripts are 
#    not yet compiling with 'go build test.go' etc. I made some 
#    helper scripts in helpers.pars.sh for testing.
#
#
read
#--------------
testclass [:space:]
jumpfalse block.end.6053
  clear
  jump parse
block.end.6053:
#---------------
# We can ellide all these single character tests, because
# the stack token is just the character itself with a *
# Braces {} are used for blocks of commands, ',' and '.' for concatenating
# tests with OR or AND logic. 'B' and 'E' for begin and end
# tests, '!' is used for negation, ';' is used to terminate a 
# command.
testis "{"
jumptrue 16
testis "}"
jumptrue 14
testis ";"
jumptrue 12
testis ","
jumptrue 10
testis "."
jumptrue 8
testis "!"
jumptrue 6
testis "B"
jumptrue 4
testis "E"
jumptrue 2 
jump block.end.6489
  put
  add "*"
  push
  jump parse
block.end.6489:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.6942
  # save the start line number (for error messages) in case 
  # there is no terminating quote character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  add "\""
  until "\""
  testends "\""
  jumptrue block.end.6884
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.6884:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.6942:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.7621
  # save the start line number (for error messages) in case 
  # there is no terminating quote character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  until "'"
  testends "'"
  jumptrue block.end.7406
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.7406:
  # empty quotes '' may be legal, for example as the second arg
  # to replace.
  clip
  escape "\""
  unescape "'"
  put
  clear
  add "\""
  get
  add "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.7621:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.12095
  # save the start line number (for error messages) in case 
  # there is no terminating bracket character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  add "["
  until "]"
  testis "[]"
  jumpfalse block.end.8145
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.8145:
  testends "]"
  jumptrue block.end.8432
    clear
    add "Unterminated class text ([...]) starting at "
    get
    add "\n"
    add "      class text can be used in tests or with the 'while' and \n"
    add "      'whilenot' commands. For example: \n"
    add "        [:alpha:] { while [:alpha:]; print; clear; }\n"
    add "      "
    print
    quit
  block.end.8432:
  # need to escape quotes? 
  escape "\""
  # the caret is not a negation operator in pep char classes
  # but dont have to escape caret because not using regexs
  # replace "^" "\\^";
  # save the class on the tape
  put
  clop
  clop
  testbegins "-"
  jumptrue block.end.8862
    # not a range class, eg [a-z] but dont need to escape '-' chars
    # because not using regexs
    #clear; get; replace '-' '\\-'; put;
    nop
  block.end.8862:
  testbegins "-"
  jumpfalse block.end.9541
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.9244
      clear
      add "Error in pep script at line "
      ll
      add " (character "
      cc
      add "): \n"
      add " Incorrect character range class "
      get
      add "\n"
      add "   For example:\n"
      add "     [a-g]  # correct\n"
      add "     [f-gh] # error! \n"
      print
      clear
      quit
    block.end.9244:
    # correct format, eg: [a-z] now translate to a 
    # format that can be used by a go function
    clear
    get
    replace "[" "'"
    replace "]" "'"
    replace "-" "','"
    # now='a','z'
    put
    clear
    add "isInRange("
    get
    put
    clear
    add "class*"
    push
    jump parse
  block.end.9541:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.9706
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.9706:
  # class in the form [:digit:]
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.11334
    clip
    clip
    clop
    clop
    # unicode posix character classes 
    # Also, abbreviations (not implemented in pep.c yet.)
    # classes like [[:alpha:]] are only ascii in golang, but
    # see also unicode.IsLower('x');
    # fix!
    testis "alnum"
    jumptrue 4
    testis "N"
    jumptrue 2 
    jump block.end.10068
      clear
      add "isInClass(unicode.IsLetter"
    block.end.10068:
    #"alpha","A" { clear; add "[[:alpha:]]"; }
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.10180
      clear
      add "isInClass(unicode.IsLetter"
    block.end.10180:
    # check! 
    # non-standard posix class 'word' and ascii
    # check!
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.10340
      clear
      add "isInRange(rune(0), rune(unicode.MaxASCII) "
    block.end.10340:
    testis "word"
    jumptrue 4
    testis "W"
    jumptrue 2 
    jump block.end.10402
      clear
      add "isInClass(unicode.IsLetter"
    block.end.10402:
    # fix!
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.10477
      clear
      add "isInClass(unicode.IsSpace"
    block.end.10477:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.10541
      clear
      add "isInClass(unicode.IsControl"
    block.end.10541:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.10603
      clear
      add "isInClass(unicode.IsDigit"
    block.end.10603:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.10667
      clear
      add "isInClass(unicode.IsGraphic"
    block.end.10667:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.10729
      clear
      add "isInClass(unicode.IsLower"
    block.end.10729:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.10791
      clear
      add "isInClass(unicode.IsPrint"
    block.end.10791:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.10853
      clear
      add "isInClass(unicode.IsPunct"
    block.end.10853:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.10915
      clear
      add "isInClass(unicode.IsSpace"
    block.end.10915:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.10977
      clear
      add "isInClass(unicode.IsUpper"
    block.end.10977:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.11048
      clear
      add "isInList(\"0123456789abcdefABCDEF\""
    block.end.11048:
    testbegins "isIn"
    jumptrue 3
    testbegins "["
    jumpfalse 2 
    jump block.end.11280
      put
      clear
      add "pep script error at line "
      ll
      add " (character "
      cc
      add "): \n"
      add "Unknown character class '"
      get
      add "'\n"
      print
      clear
      quit
    block.end.11280:
    put
    clear
    add "class*"
    push
    jump parse
  block.end.11334:
  
  #     alnum - alphanumeric like [0-9a-zA-Z] 
  #     alpha - alphabetic like [a-zA-Z] 
  #     blank - blank chars, space and tab 
  #     cntrl - control chars, ascii 000 to 037 and 177 (del) 
  #     digit - digits 0-9 
  #     graph - graphical chars same as :alnum: and :punct: 
  #     lower - lower case letters [a-z] 
  #     print - printable chars ie :graph: + space 
  #     punct - punctuation ie !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~. 
  #     space - all whitespace, eg \n\r\t vert tab, space, \f 
  #     upper - upper case letters [A-Z] 
  #     xdigit - hexadecimal digit ie [0-9a-fA-F] 
  #    
  # must be a list eg [abcdefg]
  clear
  get
  replace "[" "\""
  replace "]" "\""
  put
  clear
  add "isInList("
  get
  put
  clear
  add "class*"
  push
  jump parse
block.end.12095:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.12566
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.12249
    clear
    add "eof*"
    push
    jump parse
  block.end.12249:
  testis "=="
  jumpfalse block.end.12302
    clear
    add "tapetest*"
    push
    jump parse
  block.end.12302:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.12566:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.13808
  clear
  read
  testis "\n"
  jumpfalse block.end.12702
    clear
    jump parse
  block.end.12702:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.13566
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.13311
      # convert to go comments (/*...*/ and //)
      # or just one multiline
      clip
      clip
      replace "\n" "\n//"
      put
      clear
      # create a "comment" parse token
      # comment-out this line to remove multiline comments from the 
      # translated golang code 
      # add "comment*"; push; 
      jump parse
    block.end.13311:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    add "stating at line number "
    get
    add "\n"
    print
    clear
    quit
  block.end.13566:
  # single line comments. some will get lost.
  put
  clear
  add "//"
  get
  until "\n"
  clip
  put
  clear
  # comment out this below to remove single line comments
  # from the output
  add "comment*"
  push
  jump parse
block.end.13808:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.14195
  # error message about a misplaced character
  put
  clear
  add "!! Misplaced character '"
  get
  add "' in script near line "
  ll
  add " (character "
  cc
  add ") \n"
  print
  clear
  quit
block.end.14195:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEOFKGPRUWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
# make ll an alias for "lines" and cc an alias for chars
testis "ll"
jumpfalse block.end.14779
  clear
  add "lines"
block.end.14779:
testis "cc"
jumpfalse block.end.14811
  clear
  add "chars"
block.end.14811:
# one letter command abbreviations
testis "a"
jumpfalse block.end.14878
  clear
  add "add"
block.end.14878:
testis "k"
jumpfalse block.end.14908
  clear
  add "clip"
block.end.14908:
testis "K"
jumpfalse block.end.14938
  clear
  add "clop"
block.end.14938:
testis "D"
jumpfalse block.end.14971
  clear
  add "replace"
block.end.14971:
testis "d"
jumpfalse block.end.15002
  clear
  add "clear"
block.end.15002:
testis "t"
jumpfalse block.end.15033
  clear
  add "print"
block.end.15033:
testis "p"
jumpfalse block.end.15062
  clear
  add "pop"
block.end.15062:
testis "P"
jumpfalse block.end.15092
  clear
  add "push"
block.end.15092:
testis "u"
jumpfalse block.end.15125
  clear
  add "unstack"
block.end.15125:
testis "U"
jumpfalse block.end.15156
  clear
  add "stack"
block.end.15156:
testis "G"
jumpfalse block.end.15185
  clear
  add "put"
block.end.15185:
testis "g"
jumpfalse block.end.15214
  clear
  add "get"
block.end.15214:
testis "x"
jumpfalse block.end.15244
  clear
  add "swap"
block.end.15244:
testis ">"
jumpfalse block.end.15272
  clear
  add "++"
block.end.15272:
testis "<"
jumpfalse block.end.15300
  clear
  add "--"
block.end.15300:
testis "m"
jumpfalse block.end.15330
  clear
  add "mark"
block.end.15330:
testis "M"
jumpfalse block.end.15358
  clear
  add "go"
block.end.15358:
testis "r"
jumpfalse block.end.15388
  clear
  add "read"
block.end.15388:
testis "R"
jumpfalse block.end.15419
  clear
  add "until"
block.end.15419:
testis "w"
jumpfalse block.end.15450
  clear
  add "while"
block.end.15450:
testis "W"
jumpfalse block.end.15484
  clear
  add "whilenot"
block.end.15484:
testis "n"
jumpfalse block.end.15515
  clear
  add "count"
block.end.15515:
testis "+"
jumpfalse block.end.15543
  clear
  add "a+"
block.end.15543:
testis "-"
jumpfalse block.end.15571
  clear
  add "a-"
block.end.15571:
testis "0"
jumpfalse block.end.15601
  clear
  add "zero"
block.end.15601:
testis "c"
jumpfalse block.end.15632
  clear
  add "chars"
block.end.15632:
testis "l"
jumpfalse block.end.15663
  clear
  add "lines"
block.end.15663:
testis "^"
jumpfalse block.end.15695
  clear
  add "escape"
block.end.15695:
testis "v"
jumpfalse block.end.15729
  clear
  add "unescape"
block.end.15729:
testis "z"
jumpfalse block.end.15760
  clear
  add "delim"
block.end.15760:
testis "S"
jumpfalse block.end.15791
  clear
  add "state"
block.end.15791:
testis "q"
jumpfalse block.end.15821
  clear
  add "quit"
block.end.15821:
testis "s"
jumpfalse block.end.15852
  clear
  add "write"
block.end.15852:
testis "o"
jumpfalse block.end.15881
  clear
  add "nop"
block.end.15881:
testis "rs"
jumpfalse block.end.15915
  clear
  add "restart"
block.end.15915:
testis "rp"
jumpfalse block.end.15949
  clear
  add "reparse"
block.end.15949:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.16060
  put
  clear
  add "eof*"
  push
  jump parse
block.end.16060:
testis "<==>"
jumpfalse block.end.16118
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.16118:
testis "jump"
jumptrue 18
testis "jumptrue"
jumptrue 16
testis "jumpfalse"
jumptrue 14
testis "testis"
jumptrue 12
testis "testclass"
jumptrue 10
testis "testbegins"
jumptrue 8
testis "testends"
jumptrue 6
testis "testeof"
jumptrue 4
testis "testtape"
jumptrue 2 
jump block.end.16446
  put
  clear
  add "The instruction '"
  get
  add "' near line "
  ll
  add " (character "
  cc
  add ")\n"
  add "can be used in pep assembly code but not scripts. \n"
  print
  clear
  quit
block.end.16446:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 4
testis "bail"
jumptrue 2 
jump block.end.16780
  put
  clear
  add "The instruction '"
  get
  add "' near line "
  ll
  add " (character "
  cc
  add ")\n"
  add "is no longer part of the pep language. \n"
  add "use 'quit' instead of 'bail'' \n"
  print
  clear
  quit
block.end.16780:
testis "add"
jumptrue 82
testis "clip"
jumptrue 80
testis "clop"
jumptrue 78
testis "replace"
jumptrue 76
testis "upper"
jumptrue 74
testis "lower"
jumptrue 72
testis "cap"
jumptrue 70
testis "clear"
jumptrue 68
testis "print"
jumptrue 66
testis "state"
jumptrue 64
testis "pop"
jumptrue 62
testis "push"
jumptrue 60
testis "unstack"
jumptrue 58
testis "stack"
jumptrue 56
testis "put"
jumptrue 54
testis "get"
jumptrue 52
testis "swap"
jumptrue 50
testis "++"
jumptrue 48
testis "--"
jumptrue 46
testis "mark"
jumptrue 44
testis "go"
jumptrue 42
testis "read"
jumptrue 40
testis "until"
jumptrue 38
testis "while"
jumptrue 36
testis "whilenot"
jumptrue 34
testis "count"
jumptrue 32
testis "a+"
jumptrue 30
testis "a-"
jumptrue 28
testis "zero"
jumptrue 26
testis "chars"
jumptrue 24
testis "lines"
jumptrue 22
testis "nochars"
jumptrue 20
testis "nolines"
jumptrue 18
testis "escape"
jumptrue 16
testis "unescape"
jumptrue 14
testis "delim"
jumptrue 12
testis "quit"
jumptrue 10
testis "write"
jumptrue 8
testis "nop"
jumptrue 6
testis "reparse"
jumptrue 4
testis "restart"
jumptrue 2 
jump block.end.17181
  put
  clear
  add "word*"
  push
  jump parse
block.end.17181:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There is
# no "goto" in go so we need to use labelled loops to 
# implement .reparse/parse>
testis "parse>"
jumpfalse block.end.17838
  clear
  count
  testis "0"
  jumptrue block.end.17682
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.17682:
  clear
  add "# parse> parse label"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.17838:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.18049
  put
  add "*"
  push
  jump parse
block.end.18049:
add " << unknown command on line "
ll
add " (char "
cc
add ")"
add " of source file. \n"
print
clear
quit
# ----------------------------------
# PARSING PHASE:
# Below is the parse/compile phase of the script. Here we pop tokens off the
# stack and check for sequences of tokens eg "word*semicolon*". If we find a
# valid series of tokens, we "shift-reduce" or "resolve" the token series eg
# word*semicolon* --> command*
# At the same time, we manipulate (transform) the attributes on the tape, as
# required. 
parse:
#-------------------------------------
# 2 tokens
#-------------------------------------
pop
pop
# All of the patterns below are currently errors, but may not
# be in the future if we expand the syntax of the parse
# language. Also consider:
#    begintext* endtext* quoteset* notclass*, !* ,* ;* B* E*
# It is nice to trap the errors here because we can emit some
# (hopefully not very cryptic) error messages with a line number.
# Otherwise the script writer has to debug with
#   pep -a asm.pp -I scriptfile 
testis "word*word*"
jumptrue 50
testis "word*}*"
jumptrue 48
testis "word*begintext*"
jumptrue 46
testis "word*endtext*"
jumptrue 44
testis "word*!*"
jumptrue 42
testis "word*,*"
jumptrue 40
testis "quote*word*"
jumptrue 38
testis "quote*class*"
jumptrue 36
testis "quote*state*"
jumptrue 34
testis "quote*}*"
jumptrue 32
testis "quote*begintext*"
jumptrue 30
testis "quote*endtext*"
jumptrue 28
testis "class*word*"
jumptrue 26
testis "class*quote*"
jumptrue 24
testis "class*class*"
jumptrue 22
testis "class*state*"
jumptrue 20
testis "class*}*"
jumptrue 18
testis "class*begintext*"
jumptrue 16
testis "class*endtext*"
jumptrue 14
testis "class*!*"
jumptrue 12
testis "notclass*word*"
jumptrue 10
testis "notclass*quote*"
jumptrue 8
testis "notclass*class*"
jumptrue 6
testis "notclass*state*"
jumptrue 4
testis "notclass*}*"
jumptrue 2 
jump block.end.19789
  add " (Token stack) \nValue: \n"
  get
  add "\nValue: \n"
  ++
  get
  --
  add "\n"
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of pep script (missing semicolon?) \n"
  print
  clear
  quit
block.end.19789:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.19984
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of pep script: misplaced semi-colon? ; \n"
  print
  clear
  quit
block.end.19984:
testis ",*{*"
jumpfalse block.end.20154
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra comma in list? \n"
  print
  clear
  quit
block.end.20154:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.20343
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra semi-colon? \n"
  print
  clear
  quit
block.end.20343:
testis "!*!*"
jumpfalse block.end.20606
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: \n double negation '!!' is not implemented \n"
  add " and probably won't be, because what would be the point? \n"
  print
  clear
  quit
block.end.20606:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.20921
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced negation operator (!)? \n"
  add " The negation operator precedes tests, for example: \n"
  add "   !B'abc'{ ... } or !(eof),!'abc'{ ... } \n"
  print
  clear
  quit
block.end.20921:
testis ",*command*"
jumpfalse block.end.21097
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced comma? \n"
  print
  clear
  quit
block.end.21097:
testis "!*command*"
jumpfalse block.end.21302
  push
  push
  add "error near line "
  ll
  add " (at char "
  cc
  add ") \n"
  add " The negation operator (!) cannot precede a command \n"
  print
  clear
  quit
block.end.21302:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.21511
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: no test for brace block? \n"
  print
  clear
  quit
block.end.21511:
testis "{*}*"
jumpfalse block.end.21645
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.21645:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.21876
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.21876:
testis "comment*{*"
jumpfalse block.end.22068
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.22068:
testis "}*command*"
jumpfalse block.end.22218
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.22218:

#  E"begin*".!"begin*" {
#    push; push;
#    add "error near line "; lines;
#    add " of script: Begin blocks must precede code \n";
#    print; clear; quit;
#  }
#  
#------------ 
# The .restart command jumps to the first instruction after the
# begin block (if there is a begin block), or the first instruction
# of the script.
testis ".*word*"
jumpfalse block.end.23582
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.23045
    clear
    count
    # this is the opposite of .reparse, using run-once loops
    # cant do next before label, infinite loop
    # need to set flag variable. I think go has labelled loops
    # before the parse> label
    testis "0"
    jumpfalse block.end.22910
      clear
      add "restart = true; continue // restart"
    block.end.22910:
    testis "1"
    jumpfalse block.end.22947
      clear
      add "break"
    block.end.22947:
    # after the parse> label
    put
    clear
    add "command*"
    push
    jump parse
  block.end.23045:
  testis "reparse"
  jumpfalse block.end.23369
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.23264
      clear
      add "break"
    block.end.23264:
    testis "1"
    jumpfalse block.end.23301
      clear
      add "continue"
    block.end.23301:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.23369:
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script:  \n"
  add " misplaced dot '.' (use for AND logic or in .reparse/.restart \n"
  print
  clear
  quit
block.end.23582:
#---------------------------------
# Compiling comments so as to transfer them to the java 
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.23833
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "command*"
  push
  jump parse
block.end.23833:
testis "comment*comment*"
jumpfalse block.end.23947
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "comment*"
  push
  jump parse
block.end.23947:
# -----------------------
# negated tokens.
# This is a new more elegant way to negate a whole set of 
# tests (tokens) where the negation logic is stored on the 
# stack, not in the current tape cell. We just add "not" to 
# the stack token.
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
#  This format is used to indicate a negative test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
testis "!*quote*"
jumptrue 12
testis "!*class*"
jumptrue 10
testis "!*begintext*"
jumptrue 8
testis "!*endtext*"
jumptrue 6
testis "!*eof*"
jumptrue 4
testis "!*tapetest*"
jumptrue 2 
jump block.end.24745
  # a simplification: store the token name "quote*/class*/..."
  # in the tape cell corresponding to the "!*" token. 
  replace "!*" "not"
  push
  # this was a bug?? a missing ++; ??
  # now get the token-value
  get
  --
  put
  ++
  clear
  jump parse
block.end.24745:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.25251
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.25208
    # empty argument is an error
    clear
    add "pep script error near line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty argument for end-test (E\"\") \n"
    print
    quit
  block.end.25208:
  --
  put
  ++
  clear
  jump parse
block.end.25251:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.25798
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.25755
    # empty argument is an error
    clear
    add "pep script error near line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty argument for begin-test (B\"\") \n"
    print
    quit
  block.end.25755:
  --
  put
  ++
  clear
  jump parse
block.end.25798:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.28890
  clear
  # check if command requires parameter
  get
  testis "add"
  jumptrue 20
  testis "until"
  jumptrue 18
  testis "while"
  jumptrue 16
  testis "whilenot"
  jumptrue 14
  testis "mark"
  jumptrue 12
  testis "go"
  jumptrue 10
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "delim"
  jumptrue 4
  testis "replace"
  jumptrue 2 
  jump block.end.26364
    put
    clear
    add "'"
    get
    add "'"
    add " << command needs an argument, on line "
    ll
    add " of script.\n"
    print
    clear
    quit
  block.end.26364:
  testis "clip"
  jumpfalse block.end.26424
    clear
    add "mm.clip()"
    put
  block.end.26424:
  testis "clop"
  jumpfalse block.end.26483
    clear
    add "mm.clop()"
    put
  block.end.26483:
  testis "clear"
  jumpfalse block.end.26550
    clear
    add "mm.work = \"\"          // clear"
    put
  block.end.26550:
  testis "upper"
  jumpfalse block.end.26633
    clear
    add "mm.work = strings.ToUpper(mm.work) /* upper */"
    put
  block.end.26633:
  testis "lower"
  jumpfalse block.end.26716
    clear
    add "mm.work = strings.ToLower(mm.work) /* lower */"
    put
  block.end.26716:
  testis "cap"
  jumpfalse block.end.26813
    clear
    add "mm.work = strings.Title(strings.ToLower(mm.work)) // capital"
    put
  block.end.26813:
  testis "print"
  jumpfalse block.end.26887
    clear
    add "fmt.Printf(\"%s\", mm.work)    // print"
    put
  block.end.26887:
  testis "state"
  jumpfalse block.end.26954
    clear
    add "mm.printState()       // state"
    put
  block.end.26954:
  testis "pop"
  jumpfalse block.end.26998
    clear
    add "mm.pop();"
    put
  block.end.26998:
  testis "push"
  jumpfalse block.end.27044
    clear
    add "mm.push();"
    put
  block.end.27044:
  testis "unstack"
  jumpfalse block.end.27123
    clear
    add "for mm.pop() {}   /* unstack */ "
    put
  block.end.27123:
  testis "stack"
  jumpfalse block.end.27197
    clear
    add "for mm.push() {}  /* stack */"
    put
  block.end.27197:
  testis "put"
  jumpfalse block.end.27283
    clear
    add "mm.tape[mm.cell] = mm.work  /* put */"
    put
  block.end.27283:
  testis "get"
  jumpfalse block.end.27368
    clear
    add "mm.work += mm.tape[mm.cell] /* get */"
    put
  block.end.27368:
  testis "swap"
  jumpfalse block.end.27484
    clear
    add "mm.work, mm.tape[mm.cell] = mm.tape[mm.cell], mm.work  /* swap */"
    put
  block.end.27484:
  testis "++"
  jumpfalse block.end.27548
    clear
    add "mm.increment()     /* ++ */ \n"
    put
  block.end.27548:
  testis "--"
  jumpfalse block.end.27625
    clear
    add "if mm.cell > 0 { mm.cell-- }  /* -- */"
    put
  block.end.27625:
  testis "read"
  jumpfalse block.end.27694
    clear
    add "mm.read()             /* read */"
    put
  block.end.27694:
  testis "count"
  jumpfalse block.end.27792
    clear
    add "mm.work += strconv.Itoa(mm.counter) /* count */ "
    put
  block.end.27792:
  testis "a+"
  jumpfalse block.end.27853
    clear
    add "mm.counter++    /* a+ */"
    put
  block.end.27853:
  testis "a-"
  jumpfalse block.end.27914
    clear
    add "mm.counter--    /* a- */"
    put
  block.end.27914:
  testis "zero"
  jumpfalse block.end.27977
    clear
    add "mm.counter = 0  /* zero */"
    put
  block.end.27977:
  testis "chars"
  jumpfalse block.end.28085
    clear
    add "mm.work += strconv.Itoa(mm.charsRead) /* chars */"
    put
  block.end.28085:
  testis "lines"
  jumpfalse block.end.28193
    clear
    add "mm.work += strconv.Itoa(mm.linesRead) /* lines */"
    put
  block.end.28193:
  testis "nochars"
  jumpfalse block.end.28262
    clear
    add "mm.charsRead = 0 /* nochars */"
    put
  block.end.28262:
  testis "nolines"
  jumpfalse block.end.28331
    clear
    add "mm.linesRead = 0 /* nolines */"
    put
  block.end.28331:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.28420
    clear
    add "os.Exit(0)"
    put
  block.end.28420:
  # inline this?
  testis "write"
  jumpfalse block.end.28776
    clear
    # go syntax
    add "/* write */\n"
    add "f, err := os.Create(\"sav.pp\")\n"
    add "if err != nil { panic(err) }\n"
    add "defer f.Close()\n"
    add "_, err = f.WriteString(mm.work)\n"
    add "if err != nil { panic(err) }\n"
    add "f.Sync()"
    put
  block.end.28776:
  testis "nop"
  jumpfalse block.end.28837
    clear
    add "/* nop eliminated */"
    put
  block.end.28837:
  clear
  add "command*"
  push
  jump parse
block.end.28890:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.29214
  clear
  add "commandset*"
  push
  # format the tape attributes. Add the next command on a newline 
  --
  get
  add "\n"
  ++
  get
  --
  put
  ++
  clear
  jump parse
block.end.29214:
#-------------------
# here we begin to parse "test*" and "ortestset*" and "andtestset*"
# 
#-------------------
# eg: B"abc" {} or E"xyz" {}
# transform and markup the different test types
testis "begintext*,*"
jumptrue 36
testis "endtext*,*"
jumptrue 34
testis "quote*,*"
jumptrue 32
testis "class*,*"
jumptrue 30
testis "eof*,*"
jumptrue 28
testis "tapetest*,*"
jumptrue 26
testis "begintext*.*"
jumptrue 24
testis "endtext*.*"
jumptrue 22
testis "quote*.*"
jumptrue 20
testis "class*.*"
jumptrue 18
testis "eof*.*"
jumptrue 16
testis "tapetest*.*"
jumptrue 14
testis "begintext*{*"
jumptrue 12
testis "endtext*{*"
jumptrue 10
testis "quote*{*"
jumptrue 8
testis "class*{*"
jumptrue 6
testis "eof*{*"
jumptrue 4
testis "tapetest*{*"
jumptrue 2 
jump block.end.30452
  testbegins "begin"
  jumpfalse block.end.29738
    clear
    add "strings.HasPrefix(mm.work, "
    get
    add ")"
  block.end.29738:
  testbegins "end"
  jumpfalse block.end.29809
    clear
    add "strings.HasSuffix(mm.work, "
    get
    add ")"
  block.end.29809:
  testbegins "quote"
  jumpfalse block.end.29857
    clear
    add "mm.work == "
    get
  block.end.29857:
  testbegins "class"
  jumpfalse block.end.29982
    # go condition syntax
    # use helper function isInClass
    clear
    get
    add ", mm.work)"
  block.end.29982:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.30113
    clear
    put
    add "mm.eof"
  block.end.30113:
  testbegins "tapetest"
  jumpfalse block.end.30199
    clear
    put
    add "mm.work == mm.tape[mm.cell]"
  block.end.30199:
  put
  
  #    #  maybe we could ellide the not tests by doing here
  #    B"not" { clear; add "!"; get; put; }
  #    
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.30452:
#-------------------
# negated tests
# eg: !B"xyz {} !(eof) {} !(==) {}
#     !E"xyz" {} 
#     !"abc" {}
#     ![a-z] {}
testis "notbegintext*,*"
jumptrue 36
testis "notendtext*,*"
jumptrue 34
testis "notquote*,*"
jumptrue 32
testis "notclass*,*"
jumptrue 30
testis "noteof*,*"
jumptrue 28
testis "nottapetest*,*"
jumptrue 26
testis "notbegintext*.*"
jumptrue 24
testis "notendtext*.*"
jumptrue 22
testis "notquote*.*"
jumptrue 20
testis "notclass*.*"
jumptrue 18
testis "noteof*.*"
jumptrue 16
testis "nottapetest*.*"
jumptrue 14
testis "notbegintext*{*"
jumptrue 12
testis "notendtext*{*"
jumptrue 10
testis "notquote*{*"
jumptrue 8
testis "notclass*{*"
jumptrue 6
testis "noteof*{*"
jumptrue 4
testis "nottapetest*{*"
jumptrue 2 
jump block.end.31568
  testbegins "notbegin"
  jumpfalse block.end.30955
    clear
    add "!strings.HasPrefix(mm.work,"
    get
    add ")"
  block.end.30955:
  testbegins "notend"
  jumpfalse block.end.31029
    clear
    add "!strings.HasSuffix(mm.work,"
    get
    add ")"
  block.end.31029:
  testbegins "notquote"
  jumpfalse block.end.31080
    clear
    add "mm.work != "
    get
  block.end.31080:
  testbegins "notclass"
  jumpfalse block.end.31215
    # produces !isInClass(.. or !isInList(.. or !isInRange(..
    clear
    add "!"
    get
    add ", mm.work)"
  block.end.31215:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.31349
    clear
    put
    add "!mm.eof"
  block.end.31349:
  testbegins "nottapetest"
  jumpfalse block.end.31431
    clear
    put
    add "mm.work != mm.tape[mm.cell]"
  block.end.31431:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.31568:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some 3 token errors!!!
# not a comprehensive list
testis "{*quote*;*"
jumptrue 12
testis "{*begintext*;*"
jumptrue 10
testis "{*endtext*;*"
jumptrue 8
testis "{*class*;*"
jumptrue 6
testis "commandset*quote*;*"
jumptrue 4
testis "command*quote*;*"
jumptrue 2 
jump block.end.32027
  push
  push
  push
  add "[pep error]\n invalid syntax near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (misplaced semicolon?) \n"
  print
  clear
  quit
block.end.32027:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.32223
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.32223:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.32690
  # push the tokens back to make debugging easier
  push
  push
  push
  add " error: mixing AND (.) and OR (,) concatenation in \n"
  add " in pep script near line "
  ll
  add " (character "
  cc
  add ") \n"
  add " \n"
  add "  For example:\n"
  add "     B\".\".!E\"/\".[abcd./] { print; }  # Correct!\n"
  add "     B\".\".!E\"/\",[abcd./] { print; }  # Error! \n"
  print
  clear
  quit
block.end.32690:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.37817
  clear
  get
  testis "replace"
  jumpfalse block.end.33033
    # error 
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.33033:
  # disable "while <quote>" syntax since it is not necessary
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.33343
    add "[error] while/whilenot should not have quoted  \n"
    add "single character argument. Use eg: while [x] instead\n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.33343:
  # check whether argument is single character, otherwise
  # throw an error. Also, convert to single quotes for go
  # which is
  testis "delim"
  jumptrue 6
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.34989
    # This is trickier than I thought it would be.
    clear
    ++
    get
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.33944
      clear
      add "[pep error] near line "
      ll
      add " (or char "
      cc
      add "): \n"
      add "  command '"
      --
      get
      ++
      add "' "
      add "cannot have an empty argument (\"\") \n"
      print
      quit
    block.end.33944:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    # Also, unicode escape sequences like \u0x2222
    clip
    clop
    clip
    testis ""
    jumptrue 3
    testbegins "\\"
    jumpfalse 2 
    jump block.end.34395
      clear
      add "[pep error] Pep script error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add "  command '"
      get
      add "' takes only a single character argument. \n"
      print
      quit
    block.end.34395:
    testbegins "\\"
    jumpfalse block.end.34765
      clip
      testis ""
      jumptrue block.end.34757
        clear
        add "[pep error] Pep script error near line "
        ll
        add " (character "
        cc
        add "): \n"
        add "  command '"
        --
        get
        add "' takes only a single character argument or \n"
        add " and escaped single char eg: \n \t \f etc"
        print
        quit
      block.end.34757:
    block.end.34765:
    # replace double quotes with single for argument
    clear
    get
    escape "'"
    unescape "\""
    clip
    clop
    put
    clear
    add "'"
    get
    add "'"
    put
    # re-get the command name
    --
    clear
    get
  block.end.34989:
  testis "mark"
  jumpfalse block.end.35137
    clear
    add "mm.marks[mm.cell] = "
    ++
    get
    --
    add " /* mark */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35137:
  testis "go"
  jumpfalse block.end.35448
    clear
    # convert to go
    add "/* go to mark */\n"
    add "for ii := range mm.marks {\n"
    add "  if mm.marks[ii] == "
    ++
    get
    --
    add " {\n"
    add "    mm.cell = ii; break; \n"
    add "  }\n"
    add "}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35448:
  testis "delim"
  jumpfalse block.end.35650
    clear
    # the delimiter should be a single character, no?
    add "mm.delimiter = "
    ++
    get
    --
    add " /* delim */ "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35650:
  testis "add"
  jumpfalse block.end.35863
    clear
    add "mm.work += "
    ++
    get
    --
    # handle multiline text check this! \\n or \n
    replace "\n" "\"\nmm.work += \"\\n"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35863:
  # not used now
  testis "while"
  jumpfalse block.end.36114
    clear
    add "/* while */\n"
    add "for mm.peep == "
    ++
    get
    --
    add " {\n"
    add "  if mm.eof { break }\n  mm.read()\n"
    add "}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36114:
  # not used now
  testis "whilenot"
  jumpfalse block.end.36356
    clear
    add "/* whilenot */\n"
    add "for mm.peep != "
    ++
    get
    --
    add " {\n"
    add "  if mm.eof { break }\n  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36356:
  testis "until"
  jumpfalse block.end.36957
    clear
    add "mm.until("
    ++
    get
    --
    # error until cannot have empty argument
    testis "mm.until(\"\""
    jumpfalse block.end.36821
      clear
      add "Pep script error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add " empty argument for 'until' \n"
      add " \n"
      add "   For example:\n"
      add "     until '.txt'; until \">\";    # correct   \n"
      add "     until '';  until \"\";        # errors! \n"
      print
      quit
    block.end.36821:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36957:
  testis "escape"
  jumpfalse block.end.37312
    clear
    ++
    # argument still has quotes around it
    # it should be a single character since this has been previously
    # checked.
    add "mm.work = strings.Replace(mm.work, string("
    get
    add "), string(mm.escape)+string("
    get
    add "), -1)"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.37312:
  # replace \n with n for example (only 1 character)
  testis "unescape"
  jumpfalse block.end.37626
    clear
    ++
    # use the machine escape char
    add "mm.work = strings.Replace(mm.work, string(mm.escape)+string("
    get
    add "), string("
    get
    add "), -1)"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.37626:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.37817:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.38585
  clear
  get
  testis "while"
  jumpfalse block.end.38179
    clear
    add "/* while */\n"
    add "for "
    ++
    get
    --
    add ", string(mm.peep)) {\n"
    add "  if mm.eof { break }\n  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38179:
  testis "whilenot"
  jumpfalse block.end.38432
    clear
    add "/* whilenot */\n"
    add "for !"
    ++
    get
    --
    add ", string(mm.peep)) {\n"
    add "  if mm.eof { break; }\n"
    add "  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38432:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.38585:
# arrange the parse> label loops
testeof 
jumpfalse block.end.39738
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.39734
    clear
    # indent both code blocks
    add "  "
    get
    replace "\n" "\n  "
    # go has labelled loops, but complains if the label
    # is not used. So we have to use the flag technique
    # to make restart with before/after/without the parse> label
    replace "continue // restart" "break // restart"
    put
    clear
    ++
    ++
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    --
    --
    # add a block so that .reparse works before the parse> label.
    # it appears that go has labelled loops
    add "\n/* lex block */\n"
    add "for true { \n"
    get
    add "\n  break \n}\n"
    ++
    ++
    add "if restart { restart = false; continue; }"
    # indent code block
    # add "  "; get; replace "\n" "\n  "; put; clear;
    # using flag technique 
    add "\n// parse block \n"
    add "for true {\n"
    get
    add "\n  break \n} // parse\n"
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.39734:
block.end.39738:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.40644
  clear
  get
  # check! go replace syntax
  # not used here
  # match1, err := regexp.MatchString("geeks", str)
  testis "replace"
  jumpfalse block.end.40475
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    clear
    add "/* replace */\n"
    # add 'if mm.work != "" { \n';
    add "mm.work = strings.Replace(mm.work, "
    ++
    get
    add ", "
    ++
    get
    add ", -1)\n"
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.40475:
  add "Pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.40644:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.41028
  clear
  ++
  ++
  get
  --
  --
  put
  clear
  add "beginblock*"
  push
  jump parse
block.end.41028:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.41372
  clear
  get
  add " || "
  ++
  ++
  get
  --
  --
  put
  clear
  add "ortestset*{*"
  push
  push
  jump parse
block.end.41372:
# dont mix AND and OR concatenations 
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# it is possible to elide this block with the negated block
# for compactness but maybe readability is not as good.
# negated tests can be chained with non negated tests.
# eg: B'http' . !E'.txt' { ... }
testis "test*.*andtestset*{*"
jumptrue 4
testis "test*.*test*{*"
jumptrue 2 
jump block.end.41941
  clear
  get
  add " && "
  ++
  ++
  get
  --
  --
  put
  clear
  add "andtestset*{*"
  push
  push
  jump parse
block.end.41941:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.42525
  clear
  # indent the code for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "if ("
  get
  add ") {\n"
  ++
  ++
  get
  # block end required
  add "\n}"
  --
  --
  put
  clear
  add "command*"
  push
  # always reparse/compile
  jump parse
block.end.42525:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.43320
  testends "begintext*"
  jumptrue 10
  testends "endtext*"
  jumptrue 8
  testends "test*"
  jumptrue 6
  testends "ortestset*"
  jumptrue 4
  testends "andtestset*"
  jumptrue 2 
  jump block.end.42835
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.42835:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.43060
    put
    clear
    add "Error at end of pep script near line "
    ll
    add ": missing semi-colon? \n"
    add "Parse stack: "
    get
    add "\n"
    print
    clear
    quit
  block.end.43060:
  testends "{*"
  jumptrue 16
  testends "}*"
  jumptrue 14
  testends ";*"
  jumptrue 12
  testends ",*"
  jumptrue 10
  testends ".*"
  jumptrue 8
  testends "!*"
  jumptrue 6
  testends "B*"
  jumptrue 4
  testends "E*"
  jumptrue 2 
  jump block.end.43316
    put
    clear
    add "Error: misplaced terminal character at end of script! (line "
    ll
    add "). \n"
    add "Parse stack: "
    get
    add "\n"
    print
    clear
    quit
  block.end.43316:
block.end.43320:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.52950
  print
  clear
  # create the virtual machine object code and save it
  # somewhere on the tape.
  add "\n"
  add "// code generated by \"translate.go.pss\" a pep script\n"
  add "// http://bumble.sf.net/books/pars/tr/\n"
  add "\n"
  add "\n"
  add "// s.HasPrefix can be used instead of strings.HasPrefix\n"
  add "package main\n"
  add "import (\n"
  add "  \"fmt\"\n"
  add "  \"bufio\"  \n"
  add "  \"strings\"\n"
  add "  \"strconv\"\n"
  add "  \"unicode\"\n"
  add "  \"io\"  \n"
  add "  \"os\"\n"
  add "  \"unicode/utf8\"\n"
  add ")\n"
  add "\n"
  add "// an alias for Println for brevity\n"
  add "var pr = fmt.Println\n"
  add "\n"
  add "  /* a machine for parsing */\n"
  add "  type machine struct {\n"
  add "    SIZE int  // how many elements in stack/tape/marks\n"
  add "    eof bool\n"
  add "    charsRead int\n"
  add "    linesRead int\n"
  add "    escape rune \n"
  add "    delimiter rune\n"
  add "    counter int\n"
  add "    work string\n"
  add "    stack []string\n"
  add "    cell int\n"
  add "    tape []string\n"
  add "    marks []string\n"
  add "    peep rune\n"
  add "    reader *bufio.Reader\n"
  add "  }\n"
  add "\n"
  add "  // there is no special init for structures\n"
  add "  func newMachine(size int) *machine { \n"
  add "    mm := machine{SIZE: size}\n"
  add "    mm.eof = false     // end of stream reached?\n"
  add "    mm.charsRead = 0   // how many chars already read\n"
  add "    mm.linesRead = 1   // how many lines already read\n"
  add "    mm.escape = \'\\\\\'\n"
  add "    mm.delimiter = \'*\'    // push/pop delimiter (default \"*\")\n"
  add "    mm.counter = 0        // a counter for anything\n"
  add "    mm.work = \"\"          // the workspace\n"
  add "    mm.stack = make([]string, 0, mm.SIZE)   // stack for parse tokens \n"
  add "    mm.cell = 0                             // current tape cell\n"
  add "    // slices not arrays\n"
  add "    mm.tape = make([]string, mm.SIZE, mm.SIZE)  // a list of attribute for tokens \n"
  add "    mm.marks = make([]string, mm.SIZE, mm.SIZE) // marked tape cells\n"
  add "    // or dont initialse peep until \"parse()\" calls \"setInput()\"\n"
  add "    // check! this is not so simple\n"
  add "    mm.reader = bufio.NewReader(os.Stdin)\n"
  add "    var err error\n"
  add "    mm.peep, _, err = mm.reader.ReadRune()\n"
  add "    if err == io.EOF { \n"
  add "      mm.eof = true \n"
  add "    } else if err != nil {\n"
  add "      fmt.Fprintln(os.Stderr, \"error:\", err)\n"
  add "      os.Exit(1)\n"
  add "    }\n"
  add "    return &mm\n"
  add "  }\n"
  add "\n"
  add "  // method syntax.\n"
  add "  // func (v * vertex) abs() float64 { ... }\n"
  add "  // multiline strings are ok ?\n"
  add "\n"
  add "  func (mm *machine) setInput(newInput string) {\n"
  add "    print(\"to be implemented\")\n"
  add "  }\n"
  add "\n"
  add "  // read one utf8 character from the input stream and \n"
  add "  // update the machine.\n"
  add "  func (mm *machine) read() { \n"
  add "    var err error\n"
  add "    if mm.eof { os.Exit(0) }\n"
  add "    mm.charsRead += 1\n"
  add "    // increment lines\n"
  add "    if mm.peep == \'\\n\' { mm.linesRead += 1 }\n"
  add "    mm.work += string(mm.peep)\n"
  add "    // check!\n"
  add "    mm.peep, _, err = mm.reader.ReadRune()\n"
  add "    if err == io.EOF { \n"
  add "      mm.eof = true \n"
  add "    } else if err != nil {\n"
  add "      fmt.Fprintln(os.Stderr, \"error:\", err)\n"
  add "      os.Exit(1)\n"
  add "    }\n"
  add "  }\n"
  add "\n"
  add "  // remove escape character: trivial method ?\n"
  add "  // check the python code for this, and the c code in machine.interp.c\n"
  add "  func (mm *machine) unescapeChar(c string) {\n"
  add "    // if mm.work = \"\" { return }\n"
  add "    mm.work = strings.Replace(mm.work, \"\\\\\"+c, c, -1)\n"
  add "  }\n"
  add "\n"
  add "  // add escape character : trivial\n"
  add "  func (mm *machine) escapeChar(c string) {\n"
  add "    mm.work = strings.Replace(mm.work, c, \"\\\\\"+c, -1)\n"
  add "  }\n"
  add "\n"
  add "  /** a helper function to count trailing escapes */\n"
  add "  func (mm *machine) countEscapes(suffix string) int {\n"
  add "    count := 0\n"
  add "    ss := \"\"\n"
  add "    if strings.HasSuffix(mm.work, suffix) {\n"
  add "      ss = strings.TrimSuffix(mm.work, suffix)\n"
  add "    }\n"
  add "    for (strings.HasSuffix(ss, string(mm.escape))) { \n"
  add "      ss = strings.TrimSuffix(ss, string(mm.escape))\n"
  add "      count++\n"
  add "    }\n"
  add "    return count\n"
  add "  }\n"
  add "\n"
  add "  // reads the input stream until the workspace ends with the\n"
  add "  // given character or text, ignoring escaped characters\n"
  add "  func (mm *machine) until(suffix string) {\n"
  add "    if mm.eof { return; }\n"
  add "    // read at least one character\n"
  add "    mm.read()\n"
  add "    for true { \n"
  add "      if mm.eof { return; }\n"
  add "      // we need to count the mm.Escape chars preceding suffix\n"
  add "      // if odd, keep reading, if even, stop\n"
  add "      if strings.HasSuffix(mm.work, suffix) {\n"
  add "        if (mm.countEscapes(suffix) % 2 == 0) { return }\n"
  add "      }\n"
  add "      mm.read()\n"
  add "    }\n"
  add "  }  \n"
  add "\n"
  add "  /* increment the tape pointer (command ++) and grow the \n"
  add "     tape and marks arrays if necessary */\n"
  add "  func (mm *machine) increment() { \n"
  add "    mm.cell++\n"
  add "    if mm.cell >= len(mm.tape) {\n"
  add "      mm.tape = append(mm.tape, \"\")\n"
  add "      mm.marks = append(mm.marks, \"\")\n"
  add "      mm.SIZE++\n"
  add "    }\n"
  add "  }\n"
  add "\n"
  add "  /* pop the last token from the stack into the workspace */\n"
  add "  func (mm *machine) pop() bool { \n"
  add "    if len(mm.stack) == 0 { return false }\n"
  add "    // no, get last element of stack\n"
  add "    // a[len(a)-1]\n"
  add "    mm.work = mm.stack[len(mm.stack)-1] + mm.work\n"
  add "    // a = a[:len(a)-1]\n"
  add "    mm.stack = mm.stack[:len(mm.stack)-1]\n"
  add "    if mm.cell > 0 { mm.cell -= 1 }\n"
  add "    return true\n"
  add "  }\n"
  add "\n"
  add "  // push the first token from the workspace to the stack \n"
  add "  func (mm *machine) push() bool { \n"
  add "    // dont increment the tape pointer on an empty push\n"
  add "    if mm.work == \"\" { return false }\n"
  add "    // push first token, or else whole string if no delimiter\n"
  add "    aa := strings.SplitN(mm.work, string(mm.delimiter), 2)\n"
  add "    if len(aa) == 1 {\n"
  add "      mm.stack = append(mm.stack, mm.work)\n"
  add "      mm.work = \"\"\n"
  add "    } else {\n"
  add "      mm.stack = append(mm.stack, aa[0]+string(mm.delimiter))\n"
  add "      mm.work = aa[1]\n"
  add "    }\n"
  add "    mm.increment()\n"
  add "    return true\n"
  add "  }\n"
  add "\n"
  add "  // \n"
  add "  func (mm *machine) printState() { \n"
  add "    fmt.Printf(\"Stack %v Work[%s] Peep[%c] \\n\", mm.stack, mm.work, mm.peep)\n"
  add "    fmt.Printf(\"Acc:%v Esc:%c Delim:%c Chars:%v\", \n"
  add "      mm.counter, mm.escape, mm.delimiter, mm.charsRead)\n"
  add "    fmt.Printf(\" Lines:%v Cell:%v EOF:%v \\n\", mm.linesRead, mm.cell, mm.eof)\n"
  add "    for ii, vv := range mm.tape {\n"
  add "      fmt.Printf(\"%v [%s] \\n\", ii, vv)\n"
  add "      if ii > 4 { return; }\n"
  add "    }\n"
  add "  } \n"
  add "\n"
  add "  // this is where the actual parsing/compiling code should go\n"
  add "  // so that it can be used by other go classes/objects. Also\n"
  add "  // should have a stream argument.\n"
  add "  func (mm *machine) parse(s string) {\n"
  add "  } \n"
  add "\n"
  add "  /* adapt for clop and clip */\n"
  add "  func trimLastChar(s string) string {\n"
  add "    r, size := utf8.DecodeLastRuneInString(s)\n"
  add "    if r == utf8.RuneError && (size == 0 || size == 1) {\n"
  add "        size = 0\n"
  add "    }\n"
  add "    return s[:len(s)-size]\n"
  add "  }\n"
  add "\n"
  add "  func (mm *machine) clip() {\n"
  add "    cc, _ := utf8.DecodeLastRuneInString(mm.work)\n"
  add "    mm.work = strings.TrimSuffix(mm.work, string(cc))  \n"
  add "  }\n"
  add "\n"
  add "  func (mm *machine) clop() {\n"
  add "    _, size := utf8.DecodeRuneInString(mm.work) \n"
  add "    mm.work = mm.work[size:]  \n"
  add "  }\n"
  add "\n"
  add "  type fn func(rune) bool\n"
  add "  // eg unicode.IsLetter(\'x\')\n"
  add "  /* check whether the string s only contains runes of type\n"
  add "     determined by the typeFn function */\n"
  add "\n"
  add "  func isInClass(typeFn fn, s string) bool {\n"
  add "    if s == \"\" { return false; }\n"
  add "    for _, rr := range s {\n"
  add "      //if !unicode.IsLetter(rr) {\n"
  add "      if !typeFn(rr) { return false }\n"
  add "    }\n"
  add "    return true\n"
  add "  }\n"
  add "\n"
  add "  /* range in format \'a,z\' */\n"
  add "  func isInRange(start rune, end rune, s string) bool {\n"
  add "    if s == \"\" { return false; }\n"
  add "    for _, rr := range s {\n"
  add "      if (rr < start) || (rr > end) { return false }\n"
  add "    }\n"
  add "    return true\n"
  add "  }\n"
  add "\n"
  add "  /* list of runes (unicode chars ) */\n"
  add "  func isInList(list string, s string) bool {\n"
  add "    return strings.ContainsAny(s, list)\n"
  add "  }\n"
  add "\n"
  add "func main() {\n"
  add "  // This size needs to be big for some applications. Eg \n"
  add "  // calculating big palindromes. Really \n"
  add "  // it should be dynamically allocated.\n"
  add "  var size = 30000\n"
  add "  var mm = newMachine(size);\n"
  add "  var restart = false; \n"
  add "  // the go compiler complains when modules are imported but\n"
  add "  // not used, also if vars are not used.\n"
  add "  if restart {}; unicode.IsDigit(\'0\'); strconv.Itoa(0);\n"
  add "  "
  # save the code in the current tape cell
  put
  clear
  #---------------------
  # check if the script correctly parsed (there should only
  # be one token on the stack, namely "commandset*" or "command*").
  pop
  pop
  testis "commandset*"
  jumptrue 4
  testis "command*"
  jumptrue 2 
  jump block.end.51469
    clear
    # indent generated code for readability.
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    # restore the go preamble from the tape
    ++
    get
    --
    #add 'script: \n';
    add "for !mm.eof { \n"
    get
    add "\n  }\n"
    add "}\n"
    add "\n\n// end of generated 'go' code\n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.51469:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.52253
    clear
    # indentation not needed here 
    #add ""; get; 
    #replace "\n" "\n"; put; clear; 
    # indent main code for readability.
    ++
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    --
    # get go preamble (Machine object definition) from tape
    ++
    ++
    get
    --
    --
    get
    add "\n"
    ++
    # a labelled loop for "quit" (but quit can just exit?)
    #add "script: \n";
    add "for !mm.eof { \n"
    get
    # end block marker required in 'go'
    add "\n  }\n"
    add "}\n"
    add "\n\n// end of generated golang code\n"
    # put a copy of the final compilation into the tapecell
    # for interactive debugging.
    put
    print
    clear
    quit
  block.end.52253:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.52519
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.52519:
  put
  clear
  clear
  add "[error] After compiling with 'translate.go.pss' (at EOF): \n "
  add "  parse error in input script. \n "
  print
  clear
  unstack
  put
  clear
  add "Parse stack: "
  get
  add "\n"
  add "   * debug script "
  add "   >> pep -If script -i 'some input' \n "
  add "   *  debug compilation. \n "
  add "   >> pep -Ia asm.pp script' \n "
  print
  clear
  quit
block.end.52950:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
