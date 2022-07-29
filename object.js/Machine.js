/*

  == A Javascript Parsing Machine Object

 A Machine object which can parse and translate/compile 
 context-free languages. See http://bumble.sourceforge.net/books/pars/
 for more information about this system.

 I will try to maintain attributes and methods for this object in
 the same order as the attributes and commands in the c implementation.

 It is convenient to name the function names the same as the 
 command names, but sometimes this is not possible, because some 
 words are reserved words in the language (javascript).

HISTORY

  26 sept 2019

    Some debugging. The system is now compiling and running 
    many scripts correctly. For example:
    ----
      pep -f compile.javascript.pss eg/exp.tolisp.pss > object.js/test.js
      cd object.js; echo "a+b * c * (d+e)" | node test.js
    ,,,

    The code above converts the exp.tolisp.pss to javascript and 
    then runs it with node on the command line.

  22 sept 2019

    Simple script is working in conjunction with compile.javascript.pss
    Corrected an error in testClass() Still need to write until()

  17 sept 2019

    Will write a classToRegex() function to deal with ctype.h 
    char classes such as [:space:] [:punct:] This will be used in
    whilePeep, and whilenotPeep.

  14 Sept 2019
    
    Began this file as an attempt to write a parsing Machine 
    object in javascript. Once this is completed I can write a 
    script like compile.javascript.pss which will convert 
    scripts into javascript.

MACHINE STRUCTURE

  struct Machine {
    FILE * inputstream;   //source of characters
    int peep;             // next char in the stream, may have EOF
    struct Buffer buffer; //workspace & stack
    struct Tape tape;     
    int accumulator;      // used for counting
    long charsRead;       // how many characters read from input stream
    long lines;           // how many lines already read from input stream 
    enum Bool flag;     // used for tests
    char delimiter;     // eg *, to separate tokens on the stack
    char escape;             // escape character
    //no: struct Program program;  
    char version[64];        // machine version string (eg: "0.1 campania" etc) 
  };


  // workspace commands
  ADD=0, CLIP, CLOP, CLEAR, REPLACE, PRINT, 
  // stack commands
  POP, PUSH, POPALL, PUSHALL,
  // tape commands 
  PUT, GET, SWAP, INCREMENT, DECREMENT, MARK, GO, 
  // read commands
  READ, UNTIL, WHILE, WHILENOT, 
  // jumps
  JUMP, JUMPTRUE, JUMPFALSE,
  // tests
  TESTIS, TESTCLASS, TESTBEGINS, TESTENDS, TESTEOF, TESTTAPE,
  // accumulator commands
  COUNT, INCC, DECC, ZERO,
  // append character counter and newline counter
  CHARS, LINES,
  // escape commands 
  ESCAPE, UNESCAPE, DELIM,
  // system commands
  STATE, QUIT, BAIL,
  // write workspace to file
  WRITE,
  NOP, 
  // not a recognised command
  UNDEFINED

*/

  var fs = require('fs');

  function visible(text) {
    if (text == null) return "EOF=null";
    text = text.replace(/\n/g, '\\n');
    text = text.replace(/\t/g, '\\t');
    text = text.replace(/\r/g, '\\r');
    text = text.replace(/\f/g, '\\f');
    return text
  }

    // this returns 0 when end of stream reached!!!
    console.read = len => {
      var read;
      var buff = Buffer.alloc(len);
      read = fs.readSync(process.stdin.fd, buff, 0, len);
      if (read == 0) { return null; } 
      return buff.toString();
    };

  // this could be useful in the java version to convert to
  // unicode categories. inBlock, inScript etc
  function classToRegex(text) {
    // convert ctype.h character classes to javascript regex classes
    // These are only approximate conversions
    // [0-9]
    if (text == "[:digit:]") { text = "\\d"; }
    // [ \f\n\r\t\v]
    if (text == "[:space:]") { text = "\\s"; }
    // [A-Za-z0-9_]
    if (text == "[:alnum:]") { text = "\\w"; }
    // not implemented. just matches everthing.
    if (text == "[:cntrl:]") { text = "."; }
    // maybe not in ctype.h
    if (text == "[:blank:]") { text = "[ \\t]"; }
    // it would be nice to make this unicode-aware (i.e lower case
    // in any character set.
    if (text == "[:lower:]") { text = "[a-z]"; }
    if (text == "[:upper:]") { text = "[A-Z]"; }
    if (text == "[:xdigit:]") { text = "[A-Za-f0-9]"; }
    if (text == "[:punct:]") { 
      text = "[!\"#$%&\'()*+,-./:;<=>?@[\\\]^_`{|}~.]';";
    }
    return text;
  }

 // to make a module and include with "require" do this:
 module.exports = {

   Machine: function() {
    //FILE * inputstream;   //source of characters
    this.peep = "";         // next char in the stream, may have EOF
    this.stack = [];        // stack to hold parse tokens
    this.workspace = "";  // 
    this.tape = [];       // array of strings for token values 
    this.tape[0] = "";    // init first element of tape array 
    this.marks = [];      // array of marks on the tape (mark/go)
    this.tapePointer = 0; // integer pointer to current tape cell
    this.accumulator = 0; // used for counting
    this.charsRead = 0;   // how many characters read from input stream
    this.linesRead = 1;   // how many lines already read from input stream 
    this.flag = false;    // used for tests (not here).
    this.delimiter = "*"; // to separate tokens on the stack
    this.escape = "\\";   // escape character, default "\"
    this.version = "campania"; // machine version string (eg: "0.1 campania" etc) 
    this.peep = console.read(1);
    process.stdin.setEncoding('utf8');

    /*
     methods, which correspond to command (instructions) on the 
     virtual machine.

     many of the methods below may not be necessary because 
     they are so short as to be trivial. Also compilable.js.pss can
     just access the attributes directly.

    */

    // workspace commands
    this.add = function(text) {
      this.workspace += text;
    }

    this.clip = function() {
      if (this.workspace == "") return;
      this.workspace = 
        this.workspace.substring(0, this.workspace.length-1);
    }
    this.clop = function() {
      if (this.workspace == "") return;
      this.workspace = this.workspace.substring(1);
    }

    this.clear = function() {
      this.workspace = "";
    }

    this.replace = function(oldtext, newtext) {
      this.workspace = this.workspace.replace(oldtext, newtext);
    }

    this.print = function() {
      process.stdout.write(this.workspace); 
    }

    this.pop = function() {
      if (this.stack.length == 0) return;
      this.workspace = this.stack.pop() + this.workspace;
      if (this.tapePointer > 0) this.tapePointer--;
    }

    this.push = function() {
      if (this.workspace == '') return;
      var first = this.workspace.indexOf(this.delimiter);
      this.stack.push(this.workspace.slice(0, first+1));
      this.workspace = this.workspace.slice(first+1);
      this.tapePointer++;
      if (this.tape[this.tapePointer] == null) 
        this.tape[this.tapePointer] = '';
    }

    // the "unstack" command
    this.popall = function() {
      this.workspace = this.stack.join('') + this.workspace;
      this.stack = [];
      // also, update the tapePointer
    }

    // the "stack" command
    this.pushall = function() {
      this.stack.push(this.workspace.split(this.delimiter));
      this.workspace = "";
      // also, update the tapePointer
    }

    this.put = function() {
      this.tape[this.tapePointer] = this.workspace;
    }

    this.get = function() {
      this.workspace += this.tape[this.tapePointer];
    }

    this.swap = function() {
      //if (this.tape[this.tapePointer] == null) 
      //  this.tape[this.tapePointer] == '';
      var text = this.workspace;
      this.workspace = this.tape[this.tapePointer];
      this.tape[this.tapePointer] = text;
    }

    // increment tape pointer (++)
    this.increment = function() {
      this.tapePointer++;
      if (this.tape[this.tapePointer] == null) {
        this.tape[this.tapePointer] = '';
      }
    }

    // increment tape pointer (--)
    this.decrement = function() {
      if (this.tapePointer > 0) this.tapePointer--;
    }

    this.mark = function(text) {
      this.marks[this.tapePointer] = text;
    }

    this.go = function(text) {
      /*
      a simpler way?
      var found = this.marks.find(function(element) {
        return element === text;
      });
      */

      for (ii = 0; ii < this.marks.length; ii++) {
        if (this.marks[ii] == text) {
          this.tapePointer = ii;
          if (this.tape[ii] == null) this.tape[ii] = '';
        }
      }
    }

    this.read = function() {
      if (this.peep == null) return;          
      this.charsRead++;
      // increment lines
      if (this.peep == "\n") { this.lines++; }
      this.workspace += this.peep;
      // read next char from stream
      this.peep = console.read(1);
    }

    // read the inputstream until the workspace ends with the 
    // given text (but not the escaped text).
    this.until = function(text) {
      if (this.peep == null) return;          
      this.read();
      while (true) {
        if (this.workspace.endsWith(text) && 
           !this.workspace.endsWith(this.escape + text)) break;
        if (this.peep == null) break;
        this.read();
      }
    }

    // text is [a-c] or [abc] or [:space:] etc
    // need to translate classes like [:punct:] into 
    // javascript regex classes, eg: \W \w
    this.whilePeep = function(text) {
      text = classToRegex(text);
      var re = new RegExp(text);
      while (re.test(this.peep)) {
        this.read();
      }
    }

    this.whilenotPeep = function(text) {
      text = classToRegex(text);
      var re = new RegExp(text);
      while (!re.test(this.peep)) {
        this.read();
      }
    }

    // probably wont use all of these tests when compiling
    // with compilable.js.pss or compile.js.pss
    this.testIs = function(text) {
      if (this.workspace == text) return true;
      return false;
    }

    // determine if all characters in the machine workspace are 
    // in the given range/list/class.
    this.testClass = function(text) {
      text = classToRegex(text);
      //console.log("testClass text:" + text);
      var re = new RegExp("^" + text + "+$");
      return re.test(this.workspace);
    }

    this.testBegins = function(text) {
      if (this.workspace.startsWith(text)) return true;
      return false;
    }

    this.testEnds = function(text) {
      // should this regard the escape character?
      if (this.workspace.endsWith(text)) return true;
      return false;
    }

    this.testEof = function(text) {
      if (this.peep == null) { return true; }
      return false;
    }

    this.testTape = function(text) {
      if (this.workspace == this.tape[this.tapePointer]) return true;
      return false;
    }

    this.count = function() {
      this.workspace += this.accumulator;
    }

    this.incc = function() {
      this.accumulator++;
    }

    this.decc = function() {
      this.accumulator--;
    }

    this.zero = function() {
      this.accumulator = 0;
    }

    // append chars read to workspace
    // could call this "this.cc" 
    this.chars = function() {
      this.workspace += this.charsRead;
    }

    // 1 line functions like this can be emitted directly
    // by compile.javascript.pss 
    this.lines = function() {
      this.workspace += this.linesRead;
    }

    // replace char with \char (escape + char) 
    this.escapeChar = function(text) {
      c = text.charAt(0); 
      this.workspace = this.workspace.replace(c, "\\"+c);
    }

    // replace \char with char  
    this.unescapeChar = function(text) {
      c = text.charAt(0); 
      this.workspace = this.workspace.replace("\\"+c, c);
    }

    this.delim = function(text) {
      this.delimiter = text.charAt(0);
    }

    this.showTape = function(length) {
      var ii;
      var result = "";
      var cell = "";
      for (ii = 0; ii < length; ii++) {
        if (this.tape[ii] == null) cell = ""
        else cell = this.tape[ii];

        if (ii == this.tapePointer) {
          result += ii + "> [" + cell + "]\n";
        } else {
          result += ii + "  [" + cell + "]\n";
        }
      }
      process.stdout.write(result); 
    }

    this.state = function() {
      text = 
       "\n---------- Machine State -----------\n" +
       "Stack[" + visible(this.stack.join('')) + "] " +
       "Work[" + visible(this.workspace) + "] " +
       "Peep[" + visible(this.peep) + "] \n" +
       "Acc:" + this.accumulator + " Flag:N/A " +
       "Esc:" + this.escape + " Delim:" + this.delimiter + " " +
       "Chars:" + this.charsRead + " " + 
       "Lines:" + this.linesRead + "\n" +
       "---------- Tape ---------------\n";
      process.stdout.write(text); 
      this.showTape(10);
    }

    // this is implemented directly in compile.javascript.pss as
    // a "break script;" command which gets out of the script loop.
    this.quit = function() {}
    this.bail = function() {}

    // write workspace to file sav.pp but this is not possible
    // in some javascript environments 
    this.writeToFile = function() {}

    // no operation, does nothing.
    this.nop = function() {
    }

  } // Machine
} // exports

//process.stdin.setEncoding('utf8');

/*
  //console.log("workspace:" + mm.workspace); 
  console.log(Object.getPrototypeOf(mm)); 
  mm.add("token*");  
  console.log("workspace:" + mm.workspace); 
  mm.read();  
  console.log("workspace:" + mm.workspace); 
  mm.read();  
  console.log("workspace:" + mm.workspace); 
  mm.clip();  
  console.log("workspace:" + mm.workspace); 
  mm.push();
  console.log("stack:" + mm.stack); 
  mm.add("noun*verb*");  
  console.log("workspace:" + mm.workspace); 
  mm.push();
  console.log("stack:" + mm.stack); 
  mm.clip();
  console.log("clip:" + mm.workspace); 
  mm.clop();
  console.log("clop:" + mm.workspace); 
  text = "[:space:]";

*/
