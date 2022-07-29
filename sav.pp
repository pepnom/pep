# Assembled with the script 'compile.pss' 
start:
 
#
#  This script translates 'sed' (the unix stream editor) scripts
#  into java source code.
#
#STATUS
#
#  Syntax is parsing well, lots of functionality but still missing all
#  branching commands, which may be impossible or too difficult to 
#  bother with in java.
#
#  Also <nth> after s/// for nth occurrence substitution.
#  Syntax like "s#a#A#;" for substitutions is not supported yet.
#  The 0~8 gnu sed syntax (every 8th line) is supported . The syntax a\ c\
#  i\ is now being parsed with a special .restart trick.  
#  
#NOTES
#
#   Writing a translator for c++ might be more authentic because c++
#   supports the 'goto' statement, which seems to be needed for the 
#   branching commands in (gnu) sed.
#
#   It is possible to parse a\ etc by issuing a 
#   restart after every char and checking for \n without \\\n.
#   This is an interesting parsing technique used here for the 1st time.
#   The workspace is not cleared and .restart is issued to get the text
#   for a\ one character at a time. See the block B"a\\",B"c\\",B"i\\" {...}
#
#DONE
#
#  changed gnu regex to java - eg \1 \2 -> $1 $2 in replacement
#  but only 9 backrefs at the moment
#  also, \(\) group -> ()   
#  wrote s///w filename; syntax, write to file if sub has occured
#  made a\ i\ and c\  work properly 
#  support /rx/I (insensitive address) and /rx/M multiline
#  (But what is the meaning of "M" really?)
#  wrote s///4; only sub 4th occurance 
#  or "s///g4;" sub 4th occurance and all occurances after that.
#
#TODO
#  
#  Allow a different delimiter for s/// eg "s#a#b#gi" or even
#  s{a}{b}gi etc I could use the same technique that was used for 
#  a\ c\ i\ but it would be much easier to use the new until; syntax.
#
#  make all branching commands work eg : b t T etc, this could 
#  be almost impossible in a language that doesnt have goto ...?
#  But c++ does have goto.
#
#BUGS
#
#  Some regex patterns maybe java's not gnu seds.
#
#NOTES
#  
#  Adapting this script for an interpreted language would allow
#  sed scripts to be executed directly within the target language.
#  But not for java which has to be compiled.
#
#  string.matches and Pattern.matches matches the whole input string!
#  So I need to add .* to the front and back of regular expressions.
#
#  The script uses a similar strategy as tr/translate.java.pss Each machine
#  command is a method, except trivial commands, for which 'in-line' code can be
#  generated.
#
#  The file 'sed1line.txt' can be used to test this script.
#
#  This script is recognising a very large subset of gnu sed commands
#  at the moment. Also, it does not parse the regular expressions.
#  
#  Currently there is a difficulty for the pep machine in dealing
#  with the sed syntax 's#a#A#p'. That is, where alternative 
#  delimiters are used for substitutions. This could be solved with a 
#  new 'until' command that looks to the tapecell for the stop condition
#  (text).
#
#  Initially, I will only allow standard s/a/A/p syntax.
#
#HISTORY
#
#  26 July 2022
#    Added the "s/a/A/3;" syntax for doing only the nth substitution.
#    Also "s/a/A/3g;" to sub all occurences at 3rd and after.
#
#  23 july 2022
#    Added a\ i\ c\ syntax. There may be slight differences with how 
#    whitespace is handled in gnu sed with a\ etc.
#
#  15 july 2022
#    Added s///w<filename> syntax.
#
#  5 july 2022
#    Added 0~8 step-range syntax. Also, added ranges with single commands
#    which had been forgotten.
#
#  4 july 2022
#    Adding a/c/i commands but not a\ syntax yet.
#    converting to using a run() method for translating the script to
#    java source code. However, this is not so useful for a 'compiled'
#    language such as java. For a script language it would be very
#    useful, because the translated sed script could be executed 
#    immediately with piped input. But the sed script would have to be
#    read from file, or a string (not <stdin).
#  3 july 2022
#    Implemented lots of commands, but all branching commands are 
#    not implemented and may not be. Also a/c/i are not either but 
#    can be.
#    Did y/// command and read file command. There are a lot of details
#    to cover with this conversion, including seeing how gnu sed 
#    behaves. eg s/a/a/p does print the line twice.
#
#  1 july 2022
#    A lot of progress, need to do the rRwW commands. A big challenge
#    are the branching commands tTbB etc because java has no goto.
#    Also need to do the text insert command a/i/c.
#
#    Worked on ranges, which seem to be working now. 
#    The grammar is now a little different to eg/sed.parse.pss 
#    because of the necessity of generating java code.
#
#  30 june 2022
#    Started to adapt from sed.parse.pss 
#    Code is compiling with very simple commands. Use the 
#    pep.sedjas and pep.sedjaf helper functions to test this.
#
#
read
# make char number relative to line, for error messages
testclass [\n]
jumpfalse block.end.4803
  nochars
block.end.4803:
# newlines can separate commands in (gnu) sed so we will
# just add a dummy ';' here. Also, no trailing ; is required
testclass [\n]
jumpfalse block.end.4981
  put
  clear
  add ";*"
  push
  jump parse
block.end.4981:
# ignore extraneous white-space?
testclass [:space:]
jumpfalse block.end.5068
  clear
  testeof 
  jumpfalse block.end.5057
    jump parse
  block.end.5057:
  jump start
block.end.5068:
# comments, convert to java comments
testis "#"
jumpfalse block.end.5294
  clear
  add "/* "
  until "\n"
  testends "\n"
  jumpfalse block.end.5170
    clip
  block.end.5170:
  add " */\n"
  put
  clear
  # uncomment line below to include comments in output
  # add "comment*"; push; .reparse
block.end.5294:
# literal tokens '{' and '}' are used to group commands in
# sed, ';' is used to separate commands and ',' to separate line
# ranges. ! is the postfix negation operator for ranges
testis "~"
jumptrue 12
testis ","
jumptrue 10
testis "{"
jumptrue 8
testis "}"
jumptrue 6
testis ";"
jumptrue 4
testis "!"
jumptrue 2 
jump block.end.5540
  put
  add "*"
  push
  jump parse
block.end.5540:
# various actions: print, delete, swap
testis "="
jumptrue 30
testis "p"
jumptrue 28
testis "P"
jumptrue 26
testis "l"
jumptrue 24
testis "d"
jumptrue 22
testis "D"
jumptrue 20
testis "F"
jumptrue 18
testis "g"
jumptrue 16
testis "G"
jumptrue 14
testis "h"
jumptrue 12
testis "H"
jumptrue 10
testis "n"
jumptrue 8
testis "N"
jumptrue 6
testis "x"
jumptrue 4
testis "z"
jumptrue 2 
jump block.end.8762
  testis "="
  jumpfalse block.end.5836
    clear
    # print line-number + newline
    add "this.output.write(String.valueOf(this.linesRead)+'\\n');\n"
    add "this.output.flush(); /* '=' */"
  block.end.5836:
  testis "d"
  jumpfalse block.end.6128
    clear
    # 'd' delete pattern-space, restart 
    # the if true trick is necessary to avoid 'unreachable statement'
    # java compile errors (when multiple 'd' commands are given)
    add "if (true) { this.patternSpace.setLength(0); continue; } /* 'd' */"
  block.end.6128:
  testis "D"
  jumpfalse block.end.6507
    clear
    # add "/* 'D' delete pattern-space to 1st \\n, restart */";
    add "if (this.patternSpace.indexOf(\"\\n\") > -1) {\n"
    add "  this.patternSpace.delete(0, this.patternSpace.indexOf(\"\\n\"));\n"
    add "  this.readNext = false; if (true) continue; \n"
    add "} else { this.patternSpace.setLength(0); continue; } /* 'd' */"
  block.end.6507:
  testis "F"
  jumpfalse block.end.6668
    # F: print input filename + newline
    # maybe unsupported in java
    clear
    add "this.output.write(\"<unknown-file>\n\");  /* F */"
  block.end.6668:
  testis "g"
  jumpfalse block.end.6860
    # g: replace patt-space with hold-space
    clear
    add "this.patternSpace.setLength(0); \n"
    add "this.patternSpace.append(this.holdSpace);  /* 'g' */"
  block.end.6860:
  testis "G"
  jumpfalse block.end.7018
    # G; append hold-space to patt-space + \\n"
    clear
    add "this.patternSpace.append(\"\\n\" + this.holdSpace);  /* 'G' */"
  block.end.7018:
  testis "h"
  jumpfalse block.end.7208
    # h:  replace hold-space with patt-space
    clear
    add "this.holdSpace.setLength(0); \n"
    add "this.holdSpace.append(this.patternSpace);  /* 'h' */"
  block.end.7208:
  testis "H"
  jumpfalse block.end.7370
    # H:  append patt-space to hold-space + newline
    clear
    add "this.holdSpace.append(\"\\n\" + this.patternSpace);  /* 'H' */"
  block.end.7370:
  testis "l"
  jumpfalse block.end.7538
    # print pattern-space unambiguously, synonym for p ?
    clear
    add "this.output.write(this.patternSpace.toString()+'\\n'); /* 'l' */"
  block.end.7538:
  testis "n"
  jumpfalse block.end.7833
    # n: print patt-space, get next line into patt-space
    clear
    add "if (this.autoPrint) { \n"
    add "  this.output.write(this.patternSpace.toString()+'\\n');\n}\n"
    add "this.patternSpace.setLength(0);\n"
    add "this.readLine();   /* 'n' */"
  block.end.7833:
  testis "N"
  jumpfalse block.end.8004
    # N: append next line to patt-space + newline
    clear
    add "this.patternSpace.append('\\n'); "
    add "this.readLine();  /* 'N' */"
  block.end.8004:
  testis "p"
  jumpfalse block.end.8113
    clear
    add "this.output.write(this.patternSpace.toString()+'\\n'); /* 'p' */"
  block.end.8113:
  testis "P"
  jumpfalse block.end.8482
    # P: print pattern-space up to 1st newline"
    clear
    add "if (this.patternSpace.indexOf(\"\\n\") > -1) {\n"
    add "  this.output.write(\n"
    add "    this.patternSpace.substring(0, \n"
    add "    this.patternSpace.indexOf(\"\\n\"))+\'\\n\');\n"
    add "} else { this.output.write(this.patternSpace.toString()+'\\n'); }"
  block.end.8482:
  testis "x"
  jumpfalse block.end.8590
    # x:  # swap pattern-space with hold-space
    clear
    add "this.swap();  /* x */"
  block.end.8590:
  testis "z"
  jumpfalse block.end.8711
    # z:  delete pattern-space, NO restart
    clear
    add "this.patternSpace.setLenth(0); /* z */"
  block.end.8711:
  put
  clear
  add "action*"
  push
  jump parse
block.end.8762:
# M and I are modifiers to selectors (multiline and case insensitive)
# eg /apple/Ip; or /A/M,/b/I{p;p}
testis "M"
jumptrue 4
testis "I"
jumptrue 2 
jump block.end.8999
  testis "I"
  jumpfalse block.end.8919
    clear
    add "(?i)"
    put
  block.end.8919:
  testis "M"
  jumpfalse block.end.8956
    clear
    add "(?m)"
    put
  block.end.8956:
  clear
  add "mod*"
  push
  jump parse
block.end.8999:
# patterns - only execute commands if lines match 
# line numbers are also selectors
testclass [0-9]
jumpfalse block.end.9162
  while [0-9]
  put
  clear
  add "number*"
  push
  jump parse
block.end.9162:
# $ is the last line of the file
testis "$"
jumpfalse block.end.9255
  put
  clear
  add "number*"
  push
  jump parse
block.end.9255:
# patterns - only execute commands if lines match 
testis "/"
jumpfalse block.end.9962
  # save line/char number for error message 
  clear
  add "near line/char "
  ll
  add ":"
  cc
  put
  clear
  until "/"
  testends "/"
  jumptrue block.end.9556
    clear
    add "Missing '/' to terminate "
    get
    add "?\n"
    print
    quit
  block.end.9556:
  clip
  # java .matches method matches whole string not substring
  # so we need to add .* at beginning and end, but not if regex
  # begins with ^ or ends with $. complicated hey
  testends "$"
  jumptrue block.end.9772
    add ".*$"
  block.end.9772:
  testbegins "^"
  jumptrue block.end.9814
    put
    clear
    add "^.*"
    get
  block.end.9814:
  put
  clear
  # add any delimiter for pattern here, or none
  add "\""
  get
  add "\""
  put
  clear
  add "pattern*"
  push
  jump parse
block.end.9962:
# read transliteration commands
testis "y"
jumpfalse block.end.11395
  # save line/char number for error message 
  clear
  add "near line "
  ll
  add ", char "
  cc
  put
  clear
  # allow spaces between 'y' and '/' although gnu set doesn't
  until "/"
  testends "/"
  jumpfalse 4
  testclass [ /]
  jumpfalse 2 
  jump block.end.10390
    clear
    add "Missing '/' after 'y' transliterate command\n"
    add "Or trailing characters "
    get
    add "\n"
    print
    quit
  block.end.10390:
  # save line/char number for error message 
  clear
  add "near line "
  ll
  add ", char "
  cc
  put
  clear
  until "/"
  testends "/"
  jumptrue block.end.10667
    clear
    add "Missing 2nd '/' after 'y' transliterate command "
    get
    add "\n"
    print
    quit
  block.end.10667:
  testis "/"
  jumpfalse block.end.10833
    clear
    add "Sed syntax error? \n"
    add "  Empty regex after 'y' transliterate command "
    get
    add "\n"
    print
    quit
  block.end.10833:
  # replace pattern found
  clip
  put
  clear
  add "this.transliterate(\""
  get
  add "\", \""
  put
  clear
  # save line/char number for error message 
  add "near line "
  ll
  add ", char "
  cc
  ++
  put
  --
  clear
  until "/"
  testends "/"
  jumptrue block.end.11237
    clear
    add "Missing 3rd '/' after 'y' transliterate command "
    get
    add "\n"
    print
    quit
  block.end.11237:
  clip
  swap
  get
  add "\");   /* y */ "
  # y/// does not have modifiers (unlike s///)
  put
  clear
  add "action*"
  push
  jump parse
block.end.11395:
# this is an artificial block, created by the code below
# which reads multiline append/changes/inserts one char at a time
testbegins "a\\"
jumptrue 6
testbegins "c\\"
jumptrue 4
testbegins "i\\"
jumptrue 2 
jump block.end.12485
  # print; print; print;
  testends "\\\n"
  jumpfalse block.end.11740
    # turn multiline into java single line with \n
    # \ means continue text on next line. 
    clip
    clip
    add "\\n"
    jump start
  block.end.11740:
  # end of stream means we are finished, so add a dummy
  # \n
  testeof 
  jumpfalse block.end.11831
    add "\n"
  block.end.11831:
  testends "\n"
  jumpfalse 3
  testends "\\\n"
  jumpfalse 2 
  jump block.end.12468
    # finished! the !E"\\\n" above is unnecessary (already checked) 
    # but I will leave for clarity
    clip
    replace "\n" "\\n"
    testbegins "a\\"
    jumpfalse block.end.12118
      clop
      clop
      put
      clear
      add "this.patternSpace.append('\\n'+\""
      get
      add "\");"
    block.end.12118:
    testbegins "c\\"
    jumpfalse block.end.12281
      clop
      clop
      put
      clear
      add "this.patternSpace.setLength(0);\n"
      add "this.patternSpace.append(\""
      get
      add "\");"
    block.end.12281:
    testbegins "i\\"
    jumpfalse block.end.12406
      clop
      clop
      put
      clear
      add "this.patternSpace.insert(0, \""
      get
      add "\"+\'\\n\');"
    block.end.12406:
    put
    clear
    add "action*;*"
    push
    push
    jump parse
  block.end.12468:
  jump start
block.end.12485:
# the add/change/insert commands: have 2 forms
#   a text or a\ <multiline text>
testis "a"
jumptrue 6
testis "c"
jumptrue 4
testis "i"
jumptrue 2 
jump block.end.14674
  # ignore intervening space if any
  put
  clear
  while [ \t\f]
  clear
  testeof 
  jumpfalse block.end.12864
    clear
    add "Sed syntax error? (near line:char "
    ll
    add ":"
    cc
    add ")\n"
    add "  No argument for '"
    get
    add "' command.\n"
    print
    quit
  block.end.12864:
  # also handle the a\ multiline form here
  # The following are ok: 'a\ text' 'a  \ text ' 
  #   'a \ text \
      #      text'
  # So a\ can be terminated by eof, or \n without \\
  # strategy: read one char, check for \\, if so restart
  # and write a block "a\\","i\\" etc, and read one char
  # at a time until ends with \n but not \\\n
  # if the first not whitespace char is "\" then we need to read
  # the inputstream until it ends with \n but not \\\n. This 
  # is the a\ i\ c\ syntax  This is tricky with pep at the moment.
  # allowing logic syntax for 'until' would solve this. eg
  #  until "\n".!"\\\n";
  # or allow 2 args to until;
  read
  testbegins "\\"
  jumpfalse block.end.13720
    swap
    get
    #print; print; print;
    # now should be a\\ or c\\ or i\\
    # this will be handled by the block above.
    jump start
  block.end.13720:
  testeof 
  jumpfalse 3
  testis "\n"
  jumptrue 2 
  jump block.end.13925
    clear
    add "[Sed syntax error?] (near line:char "
    ll
    add ":"
    cc
    add ")\n"
    add "  No argument for '"
    get
    add "' command.\n"
    print
    quit
  block.end.13925:
  until "\n"
  testeof 
  jumpfalse block.end.14192
    testends "\n"
    jumpfalse block.end.13976
      clip
    block.end.13976:
    testis ""
    jumpfalse block.end.14186
      clear
      add "{Sed syntax error?] (near line:char "
      ll
      add ":"
      cc
      add ")\n"
      add "  No argument for '"
      get
      add "' command.\n"
      print
      quit
    block.end.14186:
  block.end.14192:
  replace "\n" "\\n"
  swap
  testis "a"
  jumpfalse block.end.14320
    clear
    add "this.patternSpace.append('\\n'+\""
    get
    add "\");"
  block.end.14320:
  testis "c"
  jumpfalse block.end.14454
    clear
    add "this.patternSpace.setLength(0);\n"
    add "this.patternSpace.append(\""
    get
    add "\");"
  block.end.14454:
  testis "i"
  jumpfalse block.end.14552
    clear
    add "this.patternSpace.insert(0, \""
    get
    add "\"+\'\\n\');"
  block.end.14552:
  # should work, because 'this' starts with 't' not a/c/i
  put
  clear
  add "action*;*"
  push
  push
  jump parse
block.end.14674:
# various commands that have an option word parameter 
# e has two variants
#  "e" { replace "e" "e;  # exec patt-space command and replace"; }
testis "b"
jumptrue 12
testis "e"
jumptrue 10
testis "q"
jumptrue 8
testis "Q"
jumptrue 6
testis "t"
jumptrue 4
testis "T"
jumptrue 2 
jump block.end.16921
  # ignore intervening space if any
  put
  clear
  while [ ]
  clear
  # A bit more permissive that gnu-sed which doesn't allow
  # read to end in ';'.
  whilenot [ ;}]
  # word parameters are optional to these commands
  # just add a space to separate command from parameter
  testis ""
  jumptrue block.end.15178
    swap
    add " "
    swap
  block.end.15178:
  swap
  get
  # hard to implement because java has no goto ?
  # or try to use labelled loops??
  testbegins "b"
  jumpfalse block.end.15427
    clear
    # todo: 'b'  branch to <label> or start";
    add "this.unsupported(\"b -branch \");\n"
    put
    clear
  block.end.15427:
  testbegins "e "
  jumpfalse block.end.15610
    clear
    # 'e <cmd>' exec <cmd> and insert into outputfk
    add "System.out.print(this.execute(\""
    get
    add "\"));  /* \"e <cmd>\" */"
    put
    clear
  block.end.15610:
  testis "e"
  jumpfalse block.end.15829
    clear
    add "temp = this.patternSpace.toString();\n"
    add "this.patternSpace.setLength(0);  /* 'e' */\n"
    add "this.patternSpace.append(this.execute(temp)); "
    put
    clear
  block.end.15829:
  testis "q"
  jumpfalse block.end.16001
    # q; print + quit
    clear
    add "this.output.write(this.patternSpace.toString()+'\\n');\n"
    add "System.exit(0);"
    put
    clear
  block.end.16001:
  testbegins "q "
  jumpfalse block.end.16219
    # q; print + quit with exit code
    clop
    clop
    put
    clear
    add "this.output.write(this.patternSpace.toString()+'\\n');\n"
    add "System.exit("
    get
    add ");"
    put
    clear
  block.end.16219:
  testis "Q"
  jumpfalse block.end.16319
    # Q; quit, dont print
    clear
    add "System.exit(0);"
    put
    clear
  block.end.16319:
  testbegins "Q "
  jumpfalse block.end.16471
    # Q; quit with exit code, dont print
    clop
    clop
    put
    clear
    add "System.exit("
    get
    add ");"
    put
    clear
  block.end.16471:
  testbegins "t"
  jumpfalse block.end.16676
    clear
    # 't' command not implemented yet! \n";
    # (branch to <label> if substitution made or start)"; 
    add "this.unsupported(\"t - branch \");\n"
    put
    clear
  block.end.16676:
  testbegins "T"
  jumpfalse block.end.16883
    clear
    # 'T' command not implemented yet! \n";
    # (branch to <label> if NO substitution made or start)"; 
    add "this.unsupported(\"T - branch \");\n"
    put
    clear
  block.end.16883:
  add "action*"
  push
  jump parse
block.end.16921:
# read 'read <filename>' and write commands
testis ":"
jumptrue 10
testis "r"
jumptrue 8
testis "R"
jumptrue 6
testis "w"
jumptrue 4
testis "W"
jumptrue 2 
jump block.end.18787
  # ignore intervening space if any
  put
  clear
  while [ ]
  clear
  # A bit more permissive that gnu-sed which doesn't allow
  # read to end in ';'. i.e. filename cant contain ; or } in
  # this version.
  whilenot [ ;}]
  testis ""
  jumpfalse block.end.17419
    clear
    add "Sed syntax error? (at line:char "
    ll
    add ":"
    cc
    add ")\n"
    add "  no filename for read 'r' command. \n"
    print
    quit
  block.end.17419:
  swap
  add " "
  get
  testbegins ": "
  jumpfalse block.end.17630
    clear
    # todo?: ':' branch to <label>\n"; 
    # might be hard without 'goto' !";
    add "this.unsupported(\": - branchlabel \");\n"
    put
    clear
  block.end.17630:
  testbegins "r "
  jumpfalse block.end.17964
    clear
    # r' read file into patt-space
    add "/* \"r\" */\n"
    add "Path path = Path.of(\""
    get
    add "\");\n"
    add "File f = new File(\""
    get
    add "\"); \n"
    add "if (f.isFile()) { \n"
    add "  this.patternSpace.append(Files.readString(path));\n"
    add "}"
    put
    clear
  block.end.17964:
  testbegins "R "
  jumpfalse block.end.18429
    clear
    # 'R' insert file into output before next line"; 
    # bug! inserts file immediately into output.
    add "/* \"R\" */\n"
    add "Path path = Path.of(\""
    get
    add "\");\n"
    add "File f = new File(\""
    get
    add "\"); \n"
    add "if (f.isFile()) { \n"
    add "  this.output.write(Files.readString(path)+'\\n');\n"
    #add '  System.out.println(Files.readString(path));\n';
    add "}"
    put
    clear
  block.end.18429:
  testbegins "w "
  jumpfalse block.end.18567
    clear
    # 'w' write patt-space to file"; 
    add "this.writeToFile(\""
    get
    add "\");"
    put
    clear
  block.end.18567:
  # mm.writeToFile(name)
  testbegins "W "
  jumpfalse block.end.18749
    clear
    # 'W' write 1st line of patt-space to file"; 
    add "this.writeFirstToFile(\""
    get
    add "\");"
    put
    clear
  block.end.18749:
  add "action*"
  push
  jump parse
block.end.18787:
# read substitution commands
testis "s"
jumpfalse block.end.21138
  # save line/char number for error message 
  clear
  add "near line/char "
  ll
  add ":"
  cc
  put
  clear
  # allow spaces between 's' and '/' ??? 
  until "/"
  testends "/"
  jumpfalse 4
  testclass [ /]
  jumpfalse 2 
  jump block.end.19187
    clear
    add "Missing '/' after 's' substitute command\n"
    add "Or trailing characters "
    get
    add "\n"
    print
    quit
  block.end.19187:
  # save line/char number for error message 
  clear
  add "near line "
  ll
  add ", char "
  cc
  put
  clear
  until "/"
  testends "/"
  jumptrue block.end.19498
    clear
    add "Sed syntax error? \n"
    add "  Missing 2nd '/' after 's' substitute command "
    get
    add "\n"
    print
    quit
  block.end.19498:
  testis "/"
  jumpfalse block.end.19661
    clear
    add "Sed syntax error? \n"
    add "  Empty regex after 's' substitute command "
    get
    add "\n"
    print
    quit
  block.end.19661:
  # replace pattern found
  # legal escape chars in java are \t \b \n \r \f \' \" \\
  # anything else will crash the compiler and needs to be eliminated
  # but may have to live with this
  clip
  replace "\\(" "("
  replace "\\)" ")"
  replace "\\'" "'"
  put
  clear
  add "this.substitute(\""
  get
  add "\", \""
  put
  clear
  # save line/char number for error message 
  add "near line/char "
  ll
  add ":"
  cc
  ++
  put
  --
  clear
  until "/"
  testends "/"
  jumptrue block.end.20298
    clear
    add "Missing 3rd '/' after 's' substitute command "
    get
    add "\n"
    print
    quit
  block.end.20298:
  clip
  # this is a hack
  replace "\\1" "$1"
  replace "\\2" "$2"
  replace "\\3" "$3"
  replace "\\4" "$4"
  replace "\\5" "$5"
  replace "\\6" "$6"
  replace "\\7" "$7"
  replace "\\8" "$8"
  replace "\\9" "$9"
  swap
  get
  add "\", \""
  # also need to read s/// modifiers, eg e/w/m/g/i/p/[0-9] etc
  # in gnu sed 'w filename' reads filename to end of line, so
  # no other commands on that line. 
  while [emgip0123456789]
  add "\", \""
  # now read filename given to 'w' switch (if any)
  while [w]
  testends "w"
  jumpfalse block.end.21059
    # gnu-sed allows ';' in filename, but I wont (for now)
    # will need to use substitute method to trim whitespace from
    # the filename and remove leading 'w'
    whilenot [;\n]
  block.end.21059:
  add "\");   /* s */ "
  put
  clear
  add "action*"
  push
  jump parse
block.end.21138:
testis "b"
jumptrue 6
testis "T"
jumptrue 4
testis "t"
jumptrue 2 
jump block.end.21367
  # branch 
  put
  clear
  add "Unimplemented command (near line:char "
  ll
  add ":"
  cc
  add ")\n"
  add "  The script does not recognise '"
  get
  add "' yet.\n"
  print
  quit
block.end.21367:
testis ""
jumptrue block.end.21547
  put
  clear
  add "Sed syntax error? (near line:char "
  ll
  add ":"
  cc
  add ")\n"
  add "  unrecognised command '"
  get
  add "'\n"
  print
  quit
block.end.21547:
# where token reduction begins
parse:
# To visualise token reduction uncomment this below:
add "// "
ll
add ":"
cc
add " "
print
clear
add "\n"
unstack
print
clip
stack
# commands do not have to be terminated with ';' at the end of a sed script.
testeof 
jumpfalse block.end.21899
  pop
  testis "action*"
  jumpfalse block.end.21885
    add ";*"
    push
    push
    jump parse
  block.end.21885:
  push
block.end.21899:
pop
pop
pop
pop
pop
pop
# ----------------
# 6 token reductions
# these must be done first, to take precedence over 
# eg pattern/{/commandset/}
testis "pattern*,*pattern*{*commandset*}*"
jumptrue 10
testis "pattern*,*number*{*commandset*}*"
jumptrue 8
testis "number*,*number*{*commandset*}*"
jumptrue 6
testis "number*~*number*{*commandset*}*"
jumptrue 4
testis "number*,*pattern*{*commandset*}*"
jumptrue 2 
jump block.end.25108
  # also, need to indent the command set.
  ++
  ++
  ++
  ++
  swap
  replace "\n" "\n  "
  # use a brace token as temporary storage, so that we can
  # indent the 1st line of the commandset
  # should add 2 spaces but 1st line is getting an extra one.
  # somewhere...
  --
  put
  clear
  add " "
  get
  ++
  swap
  --
  --
  --
  --
  # using an array of boolean states to remember if a 
  # pattern has been 'seen'
  testbegins "pattern*,*pattern*"
  jumpfalse block.end.23282
    clear
    add "if (this.line.toString().matches("
    get
    add ") && (this.states["
    count
    add "] == false))\n  {"
    add " this.states["
    count
    add "] = true; }\n"
    add "if (this.states["
    count
    add "] == true) {\n"
    # get commandset at tape+4
    ++
    ++
    ++
    ++
    get
    --
    --
    --
    --
    add "\n}\n"
    # comes after so last line is matched 
    add "if (this.line.toString().matches("
    ++
    ++
    get
    --
    --
    add ") && (this.states["
    count
    add "] == true))\n  {"
    add " this.states["
    count
    add "] = false; }\n"
    put
    a+
  block.end.23282:
  testbegins "pattern*,*number*"
  jumpfalse block.end.23890
    clear
    add "if (this.line.toString()..matches("
    get
    add ") && (this.states["
    count
    add "] == false))\n"
    add "  { this.states["
    count
    add "] = true; }\n"
    add "if (this.states["
    count
    add "] == true) {\n "
    # get commandset at tape+4
    ++
    ++
    ++
    ++
    get
    --
    --
    --
    --
    add "\n}\n"
    # put here to match last line in range 
    add "if ((this.linesRead > "
    ++
    ++
    get
    --
    --
    add ") && (this.states["
    count
    add "] == true))\n"
    add "  { this.states["
    count
    add "] = false; }\n"
    put
    a+
  block.end.23890:
  testbegins "number*,*pattern*"
  jumpfalse block.end.24541
    clear
    # but this logic doesn't include last line
    add "if ((this.linesRead == "
    get
    add ") && (this.states["
    count
    add "] == false))\n"
    add "  { this.states["
    count
    add "] = true; }\n"
    add "if (this.states["
    count
    add "] == true) {\n "
    # get commandset at tape+4
    ++
    ++
    ++
    ++
    get
    --
    --
    --
    --
    add "\n}\n"
    # after to match last line in range
    add "if (this.line.toString().matches("
    ++
    ++
    get
    --
    --
    add ") && (this.states["
    count
    add "] == true))\n"
    add "  { this.states["
    count
    add "] = false; }\n"
    put
    a+
  block.end.24541:
  testbegins "number*,*number*"
  jumpfalse block.end.24809
    clear
    add "if ((this.linesRead >= "
    get
    add ") && (this.linesRead <= "
    ++
    ++
    get
    --
    --
    add ")) {\n"
    # get commandset at tape+4
    ++
    ++
    ++
    ++
    get
    --
    --
    --
    --
    add "\n}"
    put
    #a+;
  block.end.24809:
  testbegins "number*~*number*"
  jumpfalse block.end.25064
    # 0~8 step syntax 
    clear
    add "if ((this.linesRead % "
    ++
    ++
    get
    --
    --
    add ") == "
    get
    add ") {\n"
    # get commandset at tape+4
    ++
    ++
    ++
    ++
    get
    --
    --
    --
    --
    add "\n}"
    put
  block.end.25064:
  clear
  add "command*"
  push
  jump parse
block.end.25108:
push
push
push
push
push
push
# ---------------------------
# priority 4 token reductions
pop
pop
pop
pop
# these must be done first, to take precedence over 
# eg pattern/command/} I forgot about this pattern.
# a cool trick! just convert this to {*commandset*}* and 
# reparse, so we dont have to rewrite all that code
testis "pattern*,*pattern*command*"
jumptrue 10
testis "pattern*,*number*command*"
jumptrue 8
testis "number*,*number*command*"
jumptrue 6
testis "number*~*number*command*"
jumptrue 4
testis "number*,*pattern*command*"
jumptrue 2 
jump block.end.25743
  # preserve 1st 3 tokens
  push
  push
  push
  clear
  get
  ++
  put
  --
  clear
  put
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.25743:
push
push
push
push
#---------------
# 2 tokens: 
pop
pop
# modifiers only come after /.../
testends "mod*"
jumpfalse 3
testbegins "pattern*"
jumpfalse 2 
jump block.end.26056
  clear
  add "[Sed syntax error?] near line:char "
  ll
  add ","
  cc
  add "\n"
  add "  Modifiers (I,M) can only come after line pattern selectors  \n"
  print
  quit
block.end.26056:
testis "pattern*mod*"
jumpfalse block.end.26285
  # remove quote from start of regex
  clear
  get
  clop
  put
  clear
  # add (?i) or (?m) at the beginning of the java pattern
  add "\""
  ++
  get
  --
  get
  put
  clear
  add "pattern*"
  push
  jump parse
block.end.26285:
#---------------
# 3 tokens: 
#   we have to do this first before the action*;* rule 
#   is reduced.
pop
# change to the equivalent eg: range*{*command*}*
# This avoids have to rewrite all the java code construction
testis "range*action*;*"
jumptrue 6
testis "number*action*;*"
jumptrue 4
testis "pattern*action*;*"
jumptrue 2 
jump block.end.27011
  # preserve range/number/pattern parse token
  push
  clear
  # transfer action/command code to the correct tapecell
  get
  ++
  put
  --
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
  # now we have on the stack, for example
  # range*{*commandset*}* which is already handled, and the 
  # code attributes should be in the right tape cells.
  # we could do: add "{*command*}*" but it doesnt matter....
block.end.27011:
# gnu sed allows empty braces, so we will too.
# Another trick: push an empty commandset onto the stack
# after a brace - that gets rid of this rule and also
# the : command/command/ -> commandset/ rule
testis "range*{*}*"
jumptrue 6
testis "number*{*}*"
jumptrue 4
testis "pattern*{*}*"
jumptrue 2 
jump block.end.27478
  # preserve 1st 2 tokens
  push
  push
  clear
  add "  // warning: empty braces {} - does nothing!"
  put
  # add a 'dummy' commandset and reparse.
  clear
  add "commandset*}*"
  push
  push
  jump parse
block.end.27478:
push
push
push
pop
pop
#---------------
# 2 token errors
testis "pattern*number*"
jumptrue 18
testis "pattern*pattern*"
jumptrue 16
testis "number*number*"
jumptrue 14
testis "number*pattern*"
jumptrue 12
testis "range*number*"
jumptrue 10
testis "range*pattern*"
jumptrue 8
testis "pattern*;*"
jumptrue 6
testis "number*;*"
jumptrue 4
testis "range*;*"
jumptrue 2 
jump block.end.27912
  clear
  add "Sed syntax error? (near line:char "
  ll
  add ":"
  cc
  add ")\n"
  add "  line selector/number/range with no action \n"
  add "  (missing ',' or misplaced ';' ?) \n"
  print
  quit
block.end.27912:
testis "action*action*"
jumptrue 12
testis "action*command*"
jumptrue 10
testis "action*number*"
jumptrue 8
testis "action*pattern*"
jumptrue 6
testis "action*range*"
jumptrue 4
testis "action*{*"
jumptrue 2 
jump block.end.28156
  clear
  add "Sed error (line "
  ll
  add ", chars "
  cc
  add "):\n"
  add "  Missing ';' after command?\n"
  print
  quit
block.end.28156:
testis ",*}*"
jumptrue 14
testis ",*{*"
jumptrue 12
testis ",*;*"
jumptrue 10
testis ",*,*"
jumptrue 8
testis ";*,*"
jumptrue 6
testis ";*{*"
jumptrue 4
testis "range*,*"
jumptrue 2 
jump block.end.28397
  clip
  clop
  clop
  put
  clear
  add "Sed error (line "
  ll
  add ", chars "
  cc
  add "):\n"
  add "  Unexpected character '"
  get
  add "' \n"
  print
  quit
block.end.28397:
#---------------
# 2 token reductions
# ignore empty commands (and multiple \n)
testis "command*;*"
jumptrue 6
testis "commandset*;*"
jumptrue 4
testis ";*;*"
jumptrue 2 
jump block.end.28551
  clip
  clip
  push
  jump parse
block.end.28551:
testis "action*;*"
jumpfalse block.end.28611
  clear
  add "command*"
  push
  jump parse
block.end.28611:
# maybe need a new token type for clarity here 
# eg: negated selector
testis "number*!*"
jumpfalse block.end.28776
  clear
  get
  ++
  get
  --
  put
  clear
  add "number*"
  push
  jump parse
block.end.28776:
testis "pattern*!*"
jumpfalse block.end.28869
  clear
  get
  ++
  get
  --
  put
  clear
  add "pattern*"
  push
  jump parse
block.end.28869:
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.29004
  clear
  get
  ++
  add "\n"
  get
  --
  put
  clear
  add "commandset*"
  push
  jump parse
block.end.29004:
pop
#---------------
# 3 token errors
# eg: '/a/,/bb/p;' or '/[0-3]/,20p;' etc
#---------------
# 3 token reductions
# commands dont need a ';' before a closing brace in gnu sed
# so transmogrify
testis "command*command*}*"
jumptrue 8
testis "command*action*}*"
jumptrue 6
testis "commandset*action*}*"
jumptrue 4
testis "commandset*command*}*"
jumptrue 2 
jump block.end.29403
  clear
  get
  ++
  add "\n"
  get
  --
  put
  clear
  add "commandset*}*"
  push
  push
  jump parse
block.end.29403:
testis "range*action*}*"
jumptrue 6
testis "number*action*}*"
jumptrue 4
testis "pattern*action*}*"
jumptrue 2 
jump block.end.29572
  clear
  get
  add "{\n  "
  ++
  get
  add "\n}"
  --
  put
  clear
  add "command*}*"
  push
  push
  jump parse
block.end.29572:
testis "{*action*}*"
jumpfalse block.end.29708
  # make commandset not command for grammar simplicity
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.29708:
# a single command in braces can be just treated like a 
# set of commands in braces, so lets change to make other
# grammar rules simpler
testis "{*command*}*"
jumpfalse block.end.29988
  # make commandset not command for grammar simplicity
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.29988:
pop
#---------------
# 4 token errors
#---------------
# 4 token reductions
testis "pattern*{*commandset*}*"
jumptrue 4
testis "number*{*commandset*}*"
jumptrue 2 
jump block.end.30667
  # indent brace commands in tapecell+2
  ++
  ++
  swap
  replace "\n" "\n  "
  # indent 1st line using { token as temporary storage
  --
  put
  clear
  add "  "
  get
  ++
  swap
  --
  --
  testis "pattern*{*commandset*}*"
  jumpfalse block.end.30477
    clear
    add "if (this.line.toString().matches("
    get
    add ")) {\n"
    ++
    ++
    get
    --
    --
    add "\n}"
    put
  block.end.30477:
  testis "number*{*commandset*}*"
  jumpfalse block.end.30621
    clear
    add "if (this.linesRead == "
    get
    add ") {\n"
    ++
    ++
    get
    --
    --
    add "\n}"
    put
  block.end.30621:
  clear
  add "command*"
  push
  jump parse
block.end.30667:
pop
pop
# ----------------
# 6 token reductions
# none because we have to do them first.
push
push
push
push
push
push
testeof 
jumpfalse block.end.42296
  # check for valid sed script
  add "/* The token parse-stack was: "
  print
  clear
  unstack
  add " */\n"
  print
  clip
  clip
  clip
  clip
  testis "commandset*"
  jumptrue 3
  testis "command*"
  jumpfalse 2 
  jump block.end.31227
    clear
    add "# [error] Sed syntax error? \n"
    add "# ----------------- \n"
    add "# Also, uncomment lines after parse> label in script\n"
    add "# to see how the sed script is being parsed. \n"
    print
    quit
  block.end.31227:
  testis "commandset*"
  jumptrue 4
  testis "command*"
  jumptrue 2 
  jump block.end.42283
    clear
    # indent the generated code
    add "\n"
    get
    replace "\n" "\n       "
    put
    clear
    # create the java preamble, with a 'sedmachine' having a 
    # holdspace and patternspace
    add "\n"
    add "\n"
    add " /* [ok] Sed syntax appears ok */\n"
    add " /* ---------------------      */\n"
    add " /* Java code generated by \"sed.tojava.pss\" */\n"
    add " import java.io.*;\n"
    add " import java.nio.file.*;\n"
    add " import java.nio.charset.*;\n"
    add " import java.util.regex.*;\n"
    add " import java.util.*;   // contains stack\n"
    add "\n"
    add " public class javased {\n"
    add "   public StringBuffer patternSpace;\n"
    add "   public StringBuffer holdSpace;\n"
    add "   public StringBuffer line;         /* current line unmodified */\n"
    add "   public int linesRead;\n"
    add "   private boolean[] states;         /* pattern-seen state */\n"
    add "   private Scanner input;            /* what script will read */\n"
    add "   public Writer output;             /* where script will send output */\n"
    add "   private boolean eof;              /* end of file reached? */\n"
    add "   private boolean hasSubstituted;   /* a sub on this cycle? */\n"
    add "   private boolean lastLine;         /* last line of input (for $) */\n"
    add "   private boolean readNext;         /* read next line or not */\n"
    add "   private boolean autoPrint;        /* autoprint pattern space? */\n"
    add "\n"
    add "   /** convenience: read stdin, write to stdout */\n"
    add "   public javased() {\n"
    add "     this(\n"
    add "       new Scanner(System.in), \n"
    add "       new BufferedWriter(new OutputStreamWriter(System.out)));\n"
    add "   }\n"
    add "\n"
    add "   /** convenience: read and write to strings */\n"
    add "   public javased(String in, StringWriter out) {\n"
    add "     this(new Scanner(in), out);\n"
    add "   }\n"
    add "\n"
    add "   /** make a new machine with a character stream reader */\n"
    add "   public javased(Scanner scanner, Writer writer) {\n"
    add "     this.patternSpace = new StringBuffer(\"\"); \n"
    add "     this.holdSpace = new StringBuffer(\"\"); \n"
    add "     this.line = new StringBuffer(\"\"); \n"
    add "     this.linesRead = 0;\n"
    add "     this.input = scanner;\n"
    add "     this.output = writer;\n"
    add "     this.eof = false;\n"
    add "     this.hasSubstituted = false;\n"
    add "     this.readNext = true;\n"
    add "     this.autoPrint = true;\n"
    add "     // assume that a sed script has no more than 1K range tests! */\n"
    add "     this.states = new boolean[1000];\n"
    add "     for (int ii = 0; ii < 1000; ii++) { this.states[ii] = false; }\n"
    add "   }\n"
    add "\n"
    add "   /** read one line from the input stream and update the machine. */\n"
    add "   public void readLine() {\n"
    add "     int iChar;\n"
    add "     if (this.eof) { System.exit(0); }\n"
    add "     // increment lines\n"
    add "     this.linesRead++;\n"
    add "     if (this.input.hasNext()) {\n"
    add "       this.line.setLength(0);\n"
    add "       this.line.append(this.input.nextLine());\n"
    add "       this.patternSpace.append(this.line);\n"
    add "     } \n"
    add "     if (!this.input.hasNext()) { this.eof = true; }\n"
    add "   }\n"
    add "\n"
    add "   /** command \"x\": swap the pattern-space with the hold-space */\n"
    add "   public void swap() {\n"
    add "     String s = new String(this.patternSpace);\n"
    add "     this.patternSpace.setLength(0);\n"
    add "     this.patternSpace.append(this.holdSpace.toString());\n"
    add "     this.holdSpace.setLength(0);\n"
    add "     this.holdSpace.append(s);\n"
    add "   }\n"
    add "\n"
    add "   /** command \"y/abc/xyz/\": transliterate */\n"
    add "   public void transliterate(String target, String replacement) {\n"
    add "     // javacode for translit\n"
    add "     //String target      = \"ab\";\n"
    add "     //String replacement = \"**\";\n"
    add "     //char[] array = \"abcde\".toString().toCharArray();\n"
    add "     int ii = 0;\n"
    add "     char[] array = this.patternSpace.toString().toCharArray();\n"
    add "     for (ii = 0; ii < array.length; ii++) {\n"
    add "       int index = target.indexOf(array[ii]);\n"
    add "       if (index != -1) {\n"
    add "         array[ii] = replacement.charAt(index);\n"
    add "       }\n"
    add "     }\n"
    add "     this.patternSpace.setLength(0);\n"
    add "     this.patternSpace.append(array);\n"
    add "   }\n"
    add "\n"
    add "   /** command \"s///x\": make substitutions on the pattern-space */\n"
    add "   public void substitute(\n"
    add "     String first, String second, String flags, String writeText) {\n"
    add "     // flags can be gip etc\n"
    add "     // gnu sed modifiers M,<num>,e,w filename \n"
    add "\n"
    add "     Process p;\n"
    add "     BufferedReader stdin;\n"
    add "     BufferedReader stderr;\n"
    add "     String ss = null;\n"
    add "     String temp = new String(\"\");\n"
    add "     String old = new String(this.patternSpace);\n"
    add "     String opsys = System.getProperty(\"os.name\").toLowerCase();\n"
    add " \n"
    add "     // here replace \1 \2 etc (gnu replace group syntax) with\n"
    add "     // $1 $2 etc (java syntax)\n"
    add "     //second = second.replaceAll(\"\\\\\\\\([0-9])\",\"X$1\");\n"
    add "     //System.out.println(\"sec = \" + second);\n"
    add "     // also \(\) gnu group syntax becomes () java group syntax\n"
    add "     // but this is already dealt with, in the parser\n"
    add "\n"
    add "     // case insensitive: add \"(?i)\" at beginning\n"
    add "     if ((flags.indexOf(\'i\') > -1) ||\n"
    add "         (flags.indexOf(\'I\') > -1)) { first = \"(?i)\" + first; }\n"
    add "\n"
    add "     // multiline matching, check!!\n"
    add "     if ((flags.indexOf(\'m\') > -1) ||\n"
    add "         (flags.indexOf(\'M\') > -1)) { first = \"(?m)\" + first; }\n"
    add "\n"
    add "     // <num>- replace only nth match\n"
    add "     // todo\n"
    add "\n"
    add "     // gnu sed considers a substitute has taken place even if the \n"
    add "     // pattern space is unchanged! i.e. if matches first pattern.\n"
    add "     if (this.patternSpace.toString().matches(\".*\" + first + \".*\")) {\n"
    add "       this.hasSubstituted = true;\n"
    add "     }\n"
    add "\n"
    add "     // syntax \"s/a/A/3;\" replace nth (3rd) occurence of match \n"
    add "     if (flags.matches(\".*[0-9]+.*\")) {\n"
    add "       String[] parts = flags.replaceAll(\"[^0-9]+\", \" \").trim().split(\" \");\n"
    add "       int nn = Integer.parseInt(parts[0]);\n"
    add "       //System.out.println(\"nn=\" + nn);\n"
    add "       int ii = 0;\n"
    add "       int index = -1;\n"
    add "       Pattern pp = Pattern.compile(first);\n"
    add "       Matcher m = pp.matcher(this.patternSpace.toString());\n"
    add "       temp = this.patternSpace.toString();\n"
    add "       nextMatch:\n"
    add "       while(m.find()) {\n"
    add "         ii++;\n"
    add "         //System.out.println(\"ii=\" + ii);\n"
    add "         if (ii >= nn) {\n"
    add "           index = m.start();\n"
    add "           temp = this.patternSpace.toString();\n"
    add "           this.patternSpace.setLength(0);\n"
    add "           this.patternSpace.append(temp.substring(0,index));\n"
    add "           this.patternSpace.append(\n"
    add "             temp.substring(index).replaceFirst(first, second));\n"
    add "           temp = this.patternSpace.toString();\n"
    add "           // trying to match gnu sed behavior where the \"g\" and \"nth\"\n"
    add "           // occurence are combined (i.e. replace all matches from \n"
    add "           // the nth occurence.\n"
    add "           if (flags.indexOf(\'g\') == -1) { break nextMatch; }\n"
    add "         }\n"
    add "       }\n"
    add "     } else if (flags.indexOf(\'g\') != -1) {\n"
    add "       // sed syntax \"s/a/A/g;\" g- global, replace all matches\n"
    add "       temp = this.patternSpace.toString().replaceAll(first, second);\n"
    add "     } else {\n"
    add "       // sed syntax \"s/a/A/;\" replace only 1st match\n"
    add "       temp = this.patternSpace.toString().replaceFirst(first, second);\n"
    add "     }\n"
    add "     this.patternSpace.setLength(0);\n"
    add "     this.patternSpace.append(temp);\n"
    add "     try {\n"
    add "       if  (this.hasSubstituted) {\n"
    add "         // only print if substitution made, (but pattern-space may be\n"
    add "         // unchanged, according to gnu sed).\n"
    add "         if (flags.indexOf(\'p\') != -1) {\n"
    add "           this.output.write(this.patternSpace.toString()+\'\\n\');\n"
    add "         }\n"
    add "         // execute pattern space, gnu ext\n"
    add "         if (flags.indexOf(\'e\') != -1) {\n"
    add "           this.output.write(this.execute(this.patternSpace.toString()));\n"
    add "           //System.out.print(this.execute(this.patternSpace.toString()));\n"
    add "         }\n"
    add "         // write pattern space to file, gnu extension, if sub occurred\n"
    add "         // The writeText parameter contains \'w\' switch plus possible \n"
    add "         // whitespace.\n"
    add "         if (writeText.length() > 0) {\n"
    add "           writeText = writeText.substring(1).trim();\n"
    add "           this.writeToFile(writeText);\n"
    add "         }\n"
    add "       }\n"
    add "     } catch (IOException e) {\n"
    add "       System.out.println(e.toString());\n"
    add "     }\n"
    add "\n"
    add "   }\n"
    add "\n"
    add "   /** execute command/pattspace for s///e or e <arg> or \"e\" */\n"
    add "   public String execute(String command) {\n"
    add "     Process p;\n"
    add "     BufferedReader stdin;\n"
    add "     BufferedReader stderr;\n"
    add "     String ss;\n"
    add "     StringBuffer output = new StringBuffer(\"\");\n"
    add "     try {\n"
    add "       if (System.getProperty(\"os.name\").toLowerCase().contains(\"win\")) {\n"
    add "         p = Runtime.getRuntime().exec(new String[]{\"cmd.exe\", \"/c\", command});\n"
    add "       } else {\n"
    add "         p = Runtime.getRuntime().exec(new String[]{\"bash\", \"-c\", command});\n"
    add "       }\n"
    add "       stdin = new BufferedReader(new InputStreamReader(p.getInputStream()));\n"
    add "       stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()));\n"
    add "       while ((ss = stdin.readLine()) != null) { output.append(ss + \'\\n\'); }  \n"
    add "       while ((ss = stderr.readLine()) != null) { output.append(ss + \'\\n\'); } \n"
    add "     } catch (IOException e) {\n"
    add "       System.out.println(\"sed exec \'e\' failed: \" + e);\n"
    add "     }\n"
    add "     return output.toString();\n"
    add "   }\n"
    add "\n"
    add "   /** command \"W\": save 1st line of patternspace to filename */\n"
    add "   public void writeFirstToFile(String fileName) {\n"
    add "     try {\n"
    add "       File file = new File(fileName);\n"
    add "       Writer out = new BufferedWriter(new OutputStreamWriter(\n"
    add "          new FileOutputStream(file), \"UTF8\"));\n"
    add "       // get first line of ps\n"
    add "       out.append(this.patternSpace.toString().split(\"\\\\R\",2)[0]);\n"
    add "       // yourString.split(\"\\R\", 2);\n"
    add "       out.flush(); out.close();\n"
    add "     } catch (Exception e) {\n"
    add "       System.out.println(e.getMessage());\n"
    add "     }\n"
    add "   }\n"
    add "\n"
    add "   /** command \"w\": save the patternspace to filename */\n"
    add "   public void writeToFile(String fileName) {\n"
    add "     try {\n"
    add "       File file = new File(fileName);\n"
    add "       Writer out = new BufferedWriter(new OutputStreamWriter(\n"
    add "          new FileOutputStream(file), \"UTF8\"));\n"
    add "       out.append(this.patternSpace.toString());\n"
    add "       out.flush(); out.close();\n"
    add "     } catch (Exception e) {\n"
    add "       System.out.println(e.getMessage());\n"
    add "     }\n"
    add "   }\n"
    add "\n"
    add "   /** handle an unsupported command (message + abort) */\n"
    add "   public void unsupported(String name) {\n"
    add "     String ss =\n"
    add "      \"The \" + name + \"command has not yet been implemented\\n\" +\n"
    add "      \"in this sed-to-java translator. Branching commands are hard in\\n\" +\n"
    add "      \"in a language that doesn\'t have \'goto\'. Your script will not \\n\" + \n"
    add "      \"execute properly. Exiting now... \\n\";\n"
    add "      System.out.println(ss); System.exit(0);\n"
    add "   }\n"
    add "\n"
    add "   /** run the script with reader and writer. This allows the code to\n"
    add "       be used from within another java program, and not just as a \n"
    add "       stream filter. */\n"
    add "   public void run() throws IOException {\n"
    add "     String temp = \"\";    \n"
    add "     while (!this.eof) {\n"
    add "       this.hasSubstituted = false;\n"
    add "       this.patternSpace.setLength(0);\n"
    add "       // some sed commands restart without reading a line...\n"
    add "       // hence the use of a flag.\n"
    add "       if (this.readNext) { this.readLine(); }\n"
    add "       this.readNext = true;\n"
    add ""
    get
    add "\n"
    add "       if (this.autoPrint) { \n"
    add "         this.output.write(this.patternSpace.toString() + \'\\n\');\n"
    add "         this.output.flush();\n"
    add "       }\n"
    add "     } \n"
    add "   } \n"
    add "\n"
    add "   /* run the script as a stream filter. remove this main method\n"
    add "      to embed the script in another java program */\n"
    add "   public static void main(String[] args) throws Exception { \n"
    add "\n"
    add "     // read and write to stdin/stdout\n"
    add "     javased mm = new javased();\n"
    add "     // new Scanner(System.in), \n"
    add "     // new BufferedWriter(new OutputStreamWriter(System.out)));\n"
    add "     mm.run();\n"
    add "\n"
    add "     // convert sedstring to java and write to string.\n"
    add "     // javased mm = new javased(\"/class/s/ass/ASS/g\", new StringWriter());\n"
    add "     // then use mm.output.toString() to get the result (java source code)\n"
    add "   }\n"
    add " }\n"
    add ""
    print
  block.end.42283:
  quit
block.end.42296:
jump start 
