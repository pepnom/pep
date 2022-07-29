
# Using a string for header comments.


#  == A TCL Parsing Machine Object
#
# A Machine object which can parse and translate/compile 
# context-free languages. See http://bumble.sourceforge.net/books/pars/
# for more information about this system.
#
# I will try to maintain attributes and methods for this object in
# the same order as the attributes and commands in the c implementation.
#
# It is convenient to name the function names the same as the 
# command names, but sometimes this is not possible, because some 
# words are reserved words in the target language (tcl)
#
#HISTORY
#
#  1 October 2019
#
#    Started this tcl version adapting from the javascript version.
#
#MACHINE STRUCTURE
#
#  Code extracted from the c object for reference purposes
#  struct Machine {
#    FILE * inputstream;   //source of characters
#    int peep;             // next char in the stream, may have EOF
#    struct Buffer buffer; //workspace & stack
#    struct Tape tape;     
#    int accumulator;      // used for counting
#    long charsRead;       // how many characters read from input stream
#    long lines;           // how many lines already read from input stream 
#    enum Bool flag;     // used for tests
#    char delimiter;     // eg *, to separate tokens on the stack
#    char escape;             // escape character
#    //no: struct Program program;  
#    char version[64];        // machine version string (eg: "0.1 campania" etc) 
#  };


#  // workspace commands
#  ADD=0, CLIP, CLOP, CLEAR, REPLACE, PRINT, 
#  // stack commands
#  POP, PUSH, POPALL, PUSHALL,
#  // tape commands 
#  PUT, GET, SWAP, INCREMENT, DECREMENT, MARK, GO, 
#  // read commands
#  READ, UNTIL, WHILE, WHILENOT, 
#  // jumps
#  JUMP, JUMPTRUE, JUMPFALSE,
#  // tests
#  TESTIS, TESTCLASS, TESTBEGINS, TESTENDS, TESTEOF, TESTTAPE,
#  // accumulator commands
#  COUNT, INCC, DECC, ZERO,
#  // append character counter and newline counter
#  CHARS, LINES,
#  // escape commands 
##  ESCAPE, UNESCAPE, DELIM,
#  // system commands
#  STATE, QUIT, BAIL,
#  // write workspace to file
#  WRITE,
#  NOP, 
#  // not a recognised command
#  UNDEFINED
#
# ";

  proc visible { $text } {
    #if { $text == null } return "EOF";
    string map { "\n" "\\n" "\t" "\\t" } $text
    return $text
  }

  # this could be useful in the java version to convert to
  # unicode categories. inBlock, inScript etc
  proc ClassToRegex { $text } {
    # But tcl has character classes so no need to convert.
    # [0-9]
    if  { $text eq "[:digit:]" } { set text "\\d"; }
    # [ \f\n\r\t\v]
    if  { $text eq "[:space:]" } { set text "\\s"; }
    # [A-Za-z0-9_]
    #if  { text == "[:alnum:]" } { text = "\\w"; }
    # not implemented. just matches everthing.
    #if  { text == "[:cntrl:]" } { text = "."; }
    # maybe not in ctype.h
    #if  { text == "[:blank:]" } { text = "[ \\t]"; }
    # it would be nice to make this unicode-aware (i.e lower case
    # in any character set.
    #if  { text == "[:lower:]" } { text = "[a-z]"; }
    #if  { text == "[:upper:]" } { text = "[A-Z]"; }
    #if  { text == "[:xdigit:]" } { text = "[A-Za-f0-9]"; }
    #if  { text == "[:punct:]" } { 
    #  text = "[!\"#$%&\'()*+,-./:;<=>?@[\\\]^_`{|}~.]';";
    #}
    return text;
  }

  array set machine {};
  #FILE * inputstream;   #source of characters
  set machine(peep) "";       # next char in the stream, may have EOF
  set machine(end) false;     # if end of stream reached 
  set machine(stack) "";      # stack to hold parse tokens
  set machine(workspace) "";  # 
  set machine(tape) "";       # tcl list of strings for token values 
  set machine(marks) "";      # array of marks on the tape (mark/go)
  set machine(tapePointer) 0; # integer pointer to current tape cell
  set machine(accumulator) 0; # used for counting
  set machine(charsRead) 0;   # how many characters read from input stream
  set machine(linesRead) 1;   # how many lines already read from input stream 
  set machine(flag) false;    # used for tests (not here).
  set machine(delimiter) "*"; # to separate tokens on the stack
  set machine(escape) "\\";   # escape character, default "\"
  set machine(version) "campania"; # machine version string (eg: "0.1 campania" etc) 

  #  peep = console.read(1);

  #  process.stdin.setEncoding('utf8');

  #   methods, which correspond to command (instructions) on the 
  #   virtual machine.
  #
  #   many of the methods below may not be necessary because 
  #   they are so short as to be trivial. Also translate.tcl.pss can
  #   just access the attributes directly.


    # workspace commands
    proc add { text } {
      append machine(workspace) $text
    }

    proc clip {} {
      if  { $machine(workspace) eq "" } { return } 
      set machine(workspace) [string range $machine(workspace) 0 end-1]
    }

    proc clop {} {
      if  { $machine(workspace) eq "" } { return } 
      set machine(workspace) [string range $machine(workspace) 1 end]
    }

    proc clear {} {
      set machine(workspace) ""
    }

    proc replace { oldtext, newtext } {
      set machine(workspace) 
        [ string map { $oldtext $newtext } $machine(workspace) ]
    }

    proc print {} { puts $machine(workspace) }

    # write proc stackPop
    proc pop {} {
      if  { $machine(stack) eq "" } { return }
      set machine(workspace) this.stack.pop() + machine(workspace;
      if  { tapePointer > 0 } this.tapePointer--;
    }

    proc push {} {
      if  { $machine(workspace) eq "" } { return }
      set first $machine(workspace).indexOf(this.delimiter);
      stack.push(machine(workspace.slice(0, first+1));
      set machine(workspace) $machine(workspace.slice(first+1);
      incr machine(tapePointer);
    }

    # the "unstack" command
    proc popall {} {
      append machine(stack) $machine(workspace)
      set machine(workspace) $machine(stack)
      set machine(stack) "";
      # also, update the tapePointer
    }

    # the "stack" command
    proc pushall {} {
      append machine(stack) $machine(workspace)
      set machine(workspace) "";
      # also, update the tapePointer
    }

    proc put {} {
      set machine(tape) 
        [lreplace $machine(tape) $machine(tapePointer) $machine(workspace)]
    }

    proc get {} {
      append machine(workspace) [lindex $machine(tape) $machine(tapePointer)]
    }

    proc swap {} {
      set ss $machine(workspace;
      set machine(workspace) [lindex $machine(tape) $machine(tapePointer)]
      set machine(tape) 
        [lreplace $machine(tape) $machine(tapePointer) $ss]
    }

    # increment tape pointer (++)
    proc increment {} { incr machine(tapePointer) } 

    # increment tape pointer (--)
    proc decrement {} {
      if { $machine(tapePointer) > 0 } { decr machine(tapePointer) }
    }

    proc mark { text } {
      set machine(marks) 
        [lreplace $machine(marks) $machine(tapePointer) $text]
    }

    proc go { text } {
      # also check if not found
      set ii [lsearch $machine(marks) $text]
      set machine(tapePointer) $ii
    }

    proc read {} {
      if  { $machine(peep) < 0 } { return }
      incr machine(charsRead)
      # increment lines
      if  { $machine(peep) eq "\n" } { incr machine(linesRead) }
      append machine(workspace) $machine(peep)
      # read next char from stream
      set machine(peep) [read stdin 1]
    }

    # read the inputst8ream until the workspace ends with the 
    # given text (but not the escaped text).
    proc until { text } {
      if { $machine(peep) < 0 } { return } 
      read
      while { true } {
        if {[string match *$text $machine(workspace)] && 
            ![string match *$text "!$machine(workspace)"]}  {break }
        if { $machine(peep) < 0 } break;
        read
      }
    }

    # text is [a-c] or [abc] or [:space:] etc
    # need to translate classes like [:punct:] into 
    # javascript regex classes, eg: \W \w
    proc whilePeep { text } {
      #text = classToRegex { $text);
      #var re = new RegExp(text);
      while { [regexp $text $machine(peep)] } { read }
    }

    proc whilenotPeep { text } {
      #text = classToRegex { $text);
      while { ![regexp $text $machine(peep)] } { read }
    }

    # probably wont use all of these tests when compiling
    # with compilable.js.pss or compile.js.pss
    proc testIs { text } {
      if { $machine(workspace) eq $text } { return true } 
      return false;
    }

    # determine if all characters in the machine workspace are 
    # in the given range/list/class.
    proc testClass { text } {
      #set text classToRegex { $text }
      return [regexp {^$text+$} $machine(workspace)]
    }

    proc testBegins { text } {
      if {[string match $text* $machine(workspace)]} { return true }
      return false;
    }

    proc testEnds { text } {
      # should this regard the escape character?
      if {[string match *$text $machine(workspace)]} { return true }
      return false;
    }

    proc testEof { $text } {
      if { $machine(peep) < 0 } { return true }
      return false;
    }

    proc testTape { text } {
      if { $machine(workspace) eq 
           [lindex $machine(tape) $machine(tapePointer)] }  { 
        return true
      } 
      return false
    }

    proc count {} {
      append machine(workspace) $machine(accumulator)
    }

    proc incc {} {
      incr machine(accumulator)
    }

    proc decc {} {
      decr machine(accumulator)
    }

    proc zero {} {
      set machine(accumulator) 0
    }

    # append chars read to workspace
    # could call this "cc" 
    proc chars {} {
      append machine(workspace) $machine(charsRead)
    }

    # 1 line functions like this can be emitted directly
    # by compile.javascript.pss 
    proc lines {} {
      append machine(workspace) $machine(linesRead)
    }

    # replace char with \char (escape + char) 
    proc escapeChar { text ) {
      set c [string index $text 0]
      set machine(workspace) 
        [string map { $c "\\$c" } $machine(workspace) ]
    }

    # replace \char with char  
    proc unescapeChar { text ) {
      set c [ string index $text 0]
      set machine(workspace) [string map {"\\$c" $c} $machine(workspace)]
    }

    proc delim { text ) {
      set machine(delimiter) [string index $text 0]
    }

    proc showTape { length } {
      # incomplete...
      set result ""; set cell "";
      for {set ii 0} {$ii < $length} {incr ii} {
        set cell [lindex $machine(tape) $machine(tapePointer)] 

        if {$ii eq $machine(tapePointer) } {
          append result "$ii> [$cell]\n";
        } else {
          append result "$ii  [$cell]\n";
        }
      }
      puts $result
    }

    proc state {} {
      set text "\n---------- Machine State -----------\n" +
       "Stack[" + visible(stack.join('')) + "] " +
       "Work[" + visible(workspace) + "] " +
       "Peep[" + visible(peep) + "] \n" +
       "Acc:" + accumulator + " Flag:N/A " +
       "Esc:" + escape + " Delim:" + this.delimiter + " " +
       "Chars:" + charsRead + " " + 
       "Lines:" + linesRead + "\n" +
       "---------- Tape ---------------\n";
      puts $text 
      showTape 10
    }

    # this is implemented directly in compile.javascript.pss as
    # a "break script;" command which gets out of the script loop.
    proc quit {} {}
    proc bail {} {}

    # write workspace to file sav.pp but this is not possible
    # in some javascript environments 
    proc writeToFile {} {}

    # no operation, does nothing.
    proc nop {} {
    }


#process.stdin.setEncoding('utf8');

