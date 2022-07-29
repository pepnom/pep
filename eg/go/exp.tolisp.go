
// code generated by "translate.go.pss" a pep script
// http://bumble.sf.net/books/pars/tr/


// s.HasPrefix can be used instead of strings.HasPrefix
package main
import (
  "fmt"
  "bufio"  
  "strings"
  "strconv"
  "unicode"
  "io"  
  "os"
  "unicode/utf8"
)

// an alias for Println for brevity
var pr = fmt.Println

  /* a machine for parsing */
  type machine struct {
    SIZE int
    eof bool
    charsRead int
    linesRead int
    escape rune 
    delimiter rune
    counter int
    work string
    stack []string
    cell int
    tape []string
    marks []string
    peep rune
    reader *bufio.Reader
  }

  // there is no special init for structures
  func newMachine(size int) *machine { 
    mm := machine{SIZE: size}
    // mm.SIZE = 200      // how many elements in stack/tape/marks
    mm.eof = false     // end of stream reached?
    mm.charsRead = 0   // how many chars already read
    mm.linesRead = 1   // how many lines already read
    mm.escape = '\\'
    mm.delimiter = '*'    // push/pop delimiter (default "*")
    mm.counter = 0        // a counter for anything
    mm.work = ""          // the workspace
    mm.stack = make([]string, 0, mm.SIZE)   // stack for parse tokens 
    mm.cell = 0                             // current tape cell
    // slices not arrays
    mm.tape = make([]string, mm.SIZE, mm.SIZE)  // a list of attribute for tokens 
    mm.marks = make([]string, mm.SIZE, mm.SIZE) // marked tape cells
    // or dont initialse peep until "parse()" calls "setInput()"
    // check! this is not so simple
    mm.reader = bufio.NewReader(os.Stdin)
    var err error
    mm.peep, _, err = mm.reader.ReadRune()
    if err == io.EOF { 
      mm.eof = true 
    } else if err != nil {
      fmt.Fprintln(os.Stderr, "error:", err)
      os.Exit(1)
    }
    return &mm
  }

  // method syntax.
  // func (v * vertex) abs() float64 { ... }
  // multiline strings are ok ?

  func (mm *machine) printSizeError() {
    /*
    fmt.Println("Tape max size exceeded! " +
    "tape maximum size = (mm.size) 
" +
    "tape cell (current) = (mm.cell) 
" +
    " You can increase the array value in the go script " +
    " but normally this error indicates an error in your parsing " +
    " script. The only exception would be massively nested structures " +
    "  in the source data.");
    */
  }

  func (mm *machine) setInput(newInput string) {
    print("to be implemented")
  }

  // read one utf8 character from the input stream and 
  // update the machine.
  func (mm *machine) read() { 
    var err error
    if mm.eof { os.Exit(0) }
    mm.charsRead += 1
    // increment lines
    if mm.peep == '\n' { mm.linesRead += 1 }
    mm.work += string(mm.peep)
    // check!
    mm.peep, _, err = mm.reader.ReadRune()
    if err == io.EOF { 
      mm.eof = true 
    } else if err != nil {
      fmt.Fprintln(os.Stderr, "error:", err)
      os.Exit(1)
    }
  }

  // remove escape character: trivial method ?
  // check the python code for this, and the c code in machine.interp.c
  func (mm *machine) unescapeChar(c string) {
    // if mm.work = "" { return }
    mm.work = strings.Replace(mm.work, "\\"+c, c, -1)
  }

  // add escape character : trivial
  func (mm *machine) escapeChar(c string) {
    mm.work = strings.Replace(mm.work, c, "\\"+c, -1)
  }

  /** a helper function to count trailing escapes */
  func (mm *machine) countEscapes(suffix string) int {
    count := 0
    ss := ""
    if strings.HasSuffix(mm.work, suffix) {
      ss = strings.TrimSuffix(mm.work, suffix)
    }
    for (strings.HasSuffix(ss, string(mm.escape))) { 
      ss = strings.TrimSuffix(ss, string(mm.escape))
      count++
    }
    return count
  }

  // reads the input stream until the workspace ends with the
  // given character or text, ignoring escaped characters
  func (mm *machine) until(suffix string) {
    if mm.eof { return; }
    // read at least one character
    mm.read()
    for true { 
      if mm.eof { return; }
      // we need to count the mm.Escape chars preceding suffix
      // if odd, keep reading, if even, stop
      if strings.HasSuffix(mm.work, suffix) {
        if (mm.countEscapes(suffix) % 2 == 0) { return }
      }
      mm.read()
    }
  }  

  /* pop the last token from the stack into the workspace */
  func (mm *machine) pop() bool { 
    if len(mm.stack) == 0 { return false }
    // no, get last element of stack
    // a[len(a)-1]
    mm.work = mm.stack[len(mm.stack)-1] + mm.work
    // a = a[:len(a)-1]
    mm.stack = mm.stack[:len(mm.stack)-1]
    if mm.cell > 0 { mm.cell -= 1 }
    return true
  }

  // push the first token from the workspace to the stack 
  func (mm *machine) push() bool { 
    // dont increment the tape pointer on an empty push
    if mm.work == "" { return false }
    // push first token, or else whole string if no delimiter
    aa := strings.SplitN(mm.work, string(mm.delimiter), 2)
    if len(aa) == 1 {
      mm.stack = append(mm.stack, mm.work)
      mm.work = ""
    } else {
      mm.stack = append(mm.stack, aa[0]+string(mm.delimiter))
      mm.work = aa[1]
    }
    mm.cell++
    if mm.cell > mm.SIZE {
      // fix!
      mm.printState()
    }
    return true
  }

  // 
  func (mm *machine) printState() { 
    fmt.Printf("Stack %v Work[%s] Peep[%c] \n", mm.stack, mm.work, mm.peep)
    fmt.Printf("Acc:%v Esc:%c Delim:%c Chars:%v", 
      mm.counter, mm.escape, mm.delimiter, mm.charsRead)
    fmt.Printf(" Lines:%v Cell:%v EOF:%v \n", mm.linesRead, mm.cell, mm.eof)
    for ii, vv := range mm.tape {
      fmt.Printf("%v [%s] \n", ii, vv)
      if ii > 4 { return; }
    }
  } 

  // this is where the actual parsing/compiling code should go
  // so that it can be used by other go classes/objects. Also
  // should have a stream argument.
  func (mm *machine) parse(s string) {
  } 

  /* adapt for clop and clip */
  func trimLastChar(s string) string {
    r, size := utf8.DecodeLastRuneInString(s)
    if r == utf8.RuneError && (size == 0 || size == 1) {
        size = 0
    }
    return s[:len(s)-size]
  }

  func (mm *machine) clip() {
    cc, _ := utf8.DecodeLastRuneInString(mm.work)
    mm.work = strings.TrimSuffix(mm.work, string(cc))  
  }

  func (mm *machine) clop() {
    _, size := utf8.DecodeRuneInString(mm.work) 
    mm.work = mm.work[size:]  
  }

  type fn func(rune) bool
  // eg unicode.IsLetter('x')
  /* check whether the string s only contains runes of type
     determined by the typeFn function */

  func isInClass(typeFn fn, s string) bool {
    if s == "" { return false; }
    for _, rr := range s {
      //if !unicode.IsLetter(rr) {
      if !typeFn(rr) { return false }
    }
    return true
  }

  /* range in format 'a,z' */
  func isInRange(start rune, end rune, s string) bool {
    if s == "" { return false; }
    for _, rr := range s {
      if (rr < start) || (rr > end) { return false }
    }
    return true
  }

  /* list of runes (unicode chars ) */
  func isInList(list string, s string) bool {
    return strings.ContainsAny(s, list)
  }

func main() {
  var size = 200
  var mm = newMachine(size);
  var restart = false; 
  // the go compiler complains when modules are imported but
  // not used, also if vars are not used.
  if restart {}; unicode.IsDigit('0'); strconv.Itoa(0);
  for !mm.eof { 
    
    /* lex block */
    for true { 
      mm.read()             /* read */
      if (mm.work == "+" || mm.work == "-") {
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "opadd*"
        mm.push();
      }
      if (mm.work == "*" || mm.work == "/") {
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "opmul*"
        mm.push();
      }
      if (mm.work == "(" || mm.work == ")") {
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work += "*"
        mm.push();
      }
      if (isInRange('0','9', mm.work)) {
        /* while */
        for isInRange('0','9', string(mm.peep)) {
          if mm.eof { break }
          mm.read()
        }
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "number*"
        mm.push();
      }
      if (isInRange('a','z', mm.work)) {
        /* while */
        for isInRange('a','z', string(mm.peep)) {
          if mm.eof { break }
          mm.read()
        }
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "variable*"
        mm.push();
      }
      if (isInClass(unicode.IsSpace, mm.work)) {
        mm.work = ""          // clear
      }
      // a trick to catch bad characters. 
      // better would be a !"text" test
      if (mm.work == "") {
        break
      }
      mm.work += " << incorrect character (at character "
      mm.work += strconv.Itoa(mm.charsRead) /* chars */
      mm.work += " of input). \n"
      fmt.Printf("%s", mm.work)    // print
      os.Exit(0)
      break 
    }
    if restart { restart = false; continue; }
    // parse block 
    for true {
      // The parse/compile/translate/transform phase involves 
      // recognising series of tokens on the stack and "reducing" them
      // according to the required bnf grammar rules.
      mm.pop();
      // resolve numbers to expressions to simplify grammar rules
      // add a preceding space to numbers and variables.
      if (mm.work == "number*" || mm.work == "variable*") {
        mm.work = ""          // clear
        mm.work += " "
        mm.work += mm.tape[mm.cell] /* get */
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "exp*"
        mm.push();
        continue
      }
      //-----------------
      // 3 tokens
      mm.pop();
      mm.pop();
      // we dont need any look ahead here because * and / have 
      // precedence.
      if (mm.work == "exp*opmul*exp*") {
        mm.work = ""          // clear
        mm.work += " ("
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.work += mm.tape[mm.cell] /* get */
        mm.cell++                     /* ++ */
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        mm.work += ")"
        if mm.cell > 0 { mm.cell-- }  /* -- */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "exp*"
        mm.push();
        continue
      }
      if (mm.work == "(*exp*)*") {
        mm.work = ""          // clear
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "exp*"
        mm.push();
        continue
      }
      if (mm.eof) {
        if (mm.work == "exp*opadd*exp*") {
          mm.work = ""          // clear
          mm.work += " ("
          mm.cell++                     /* ++ */
          mm.work += mm.tape[mm.cell] /* get */
          if mm.cell > 0 { mm.cell-- }  /* -- */
          mm.work += mm.tape[mm.cell] /* get */
          mm.cell++                     /* ++ */
          mm.cell++                     /* ++ */
          mm.work += mm.tape[mm.cell] /* get */
          mm.work += ")"
          if mm.cell > 0 { mm.cell-- }  /* -- */
          if mm.cell > 0 { mm.cell-- }  /* -- */
          mm.tape[mm.cell] = mm.work  /* put */
          mm.work = ""          // clear
          mm.work += "exp*"
          mm.push();
          continue
        }
      }
      //-----------------
      // 4 tokens
      mm.pop();
      if (mm.work == "exp*opadd*exp*opadd*") {
        mm.work = ""          // clear
        mm.work += " ("
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.work += mm.tape[mm.cell] /* get */
        mm.cell++                     /* ++ */
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        mm.work += ")"
        if mm.cell > 0 { mm.cell-- }  /* -- */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "exp*opadd*"
        mm.push();
        mm.push();
        continue
      }
      if (mm.work == "exp*opadd*exp*)*") {
        mm.work = ""          // clear
        mm.work += " ("
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.work += mm.tape[mm.cell] /* get */
        mm.cell++                     /* ++ */
        mm.cell++                     /* ++ */
        mm.work += mm.tape[mm.cell] /* get */
        mm.work += ")"
        if mm.cell > 0 { mm.cell-- }  /* -- */
        if mm.cell > 0 { mm.cell-- }  /* -- */
        mm.tape[mm.cell] = mm.work  /* put */
        mm.work = ""          // clear
        mm.work += "exp*)*"
        mm.push();
        mm.push();
        continue
      }
      mm.push();
      mm.push();
      mm.push();
      mm.push();
      if (mm.eof) {
        mm.pop();
        mm.pop();
        if (mm.work == "exp*") {
          mm.work = ""          // clear
          // add "Yes, its an expression! \n";
          mm.work += "lisp format: "
          mm.work += mm.tape[mm.cell] /* get */
          mm.work += "\n"
          fmt.Printf("%s", mm.work)    // print
          mm.work = ""          // clear
          os.Exit(0)
        }
        mm.push();
        mm.push();
        mm.work += "No, it doesn't look like a valid 'in-fix' expression. \n"
        mm.work += "The parse stack was: "
        fmt.Printf("%s", mm.work)    // print
        mm.work = ""          // clear
        for mm.pop() {}   /* unstack */ 
        mm.work += "\n"
        fmt.Printf("%s", mm.work)    // print
        os.Exit(0)
      }
      break 
    } // parse
    
  }
}


// end of generated 'go' code
