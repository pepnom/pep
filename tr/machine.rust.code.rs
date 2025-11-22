
 /* 
   This code can be used to do automatic translations of nom using 
   some AI engine to other languages.
 */

 use std::io;
 use std::io::Stdin;
 use std::io::stdin;
 use std::io::Stdout;
 use std::io::StdoutLock;
 use std::io::stdout;
 use std::io::Read;
 use std::io::Write;
 use std::io::{BufWriter, BufReader, BufRead};
 use std::process;
 use std::fs;
 use std::fs::File;
 use std::str::Chars;  // for the char iterator
 use std::env;  // for command line arguments

 #[derive(Debug)]
 enum InputType {
   Unset,    // no input type has been set
   Stdin,    // read all of stdin at once into buffer
   StdinStream,  // read stdin as a stream (line by line?)
   File,         // read all of file at once into buffer
   FileStream,   // read a file as a stream
   String        // read from a string
 }
 #[derive(Debug)]
 enum OutputType {
   Unset,
   Stdout,
   File,
   String
 }

 pub struct Machine {
   accumulator: i32,  // counter for anything
   peep: String,      // next char in input stream. It is better to
                      // make this a String because a grapheme cluster will
                      // consist of multible unicode char points.
   charsRead: u32,    // No. of chars read so far init:0
   linesRead: u32,    // No. of lines read so far init:1

   /* a reversed array of strings where each string represents one
      grapheme cluster or character in the input stream. By reversing
      we can process this one char at a time with Vec.pop() 
      This is a better alternative to a simple inputBuffer string */
   // inputBuffer: String,   
   inputBuffer: Vec<String>, // the nom read command will read from this 
                           // this also helps with grapheme clusters.
                           // this is reversed!! 
   outputBuffer: String,   // where string output will go. 
   sourceType: InputType,  // enum: reading from stdin/string/file etc
   sinkType: OutputType,   // should be enum?
   work: String,         // text accumulator
   stack: Vec<String>,   // parse token stack
   tapeLength: usize,    // tape initial length
   tape: Vec<String>,    // array of token attributes, growable
   marks: Vec<String>,   // tape marks
   cell: usize,          // pointer to current cell
   input: BufReader<File>,   // text input stream
   output: BufWriter<File>,  // 
   eof: bool,       // end of stream reached?
   escape: char,    // char used to "escape" others: default "\\"
   delimiter: char  // push/pop delimiter (default is "*"). This can only be 
                    // 1 unicode code-point not a grapheme cluster because its
                    // not necessary.
 }

 impl Machine {

   /** make a new machine. I am creating
       a temp file because I dont know how to just create a file object. */
   pub fn new() -> Self {
     Machine {
       tapeLength: 100,
       input: BufReader::new(File::create("temp.xyz.123.txt").unwrap()),
       output: BufWriter::new(File::create("temp.xyz.123.txt").unwrap()),
       eof: false,
       charsRead: 0, 
       linesRead: 1, 
       // inputBuffer: String::new(),
       inputBuffer: Vec::with_capacity(1000),
       outputBuffer: String::new(),
       sourceType: InputType::Unset,  // set this at parse() if unset
       sinkType: OutputType::Stdout,
       escape: \'\\\\\',
       delimiter: \'*\',
       accumulator: 0,
       work: String::new(),
       stack: Vec::with_capacity(100),
       cell: 0,
       tape: vec!["".to_string();100],
       marks: vec!["".to_string();100],
       peep: String::new(),  // could be grapheme cluster
     } // self
   }

   /* this is useful for creating the internal representation of 
      the input, which could be a char iterator, a vector, array 
      of chars or grapheme clusters (strings) or just a plain string.
      At the moment the rust code uses a reversed string/vector.
      See Machine.fillInputBuffer() for a method that fills a reversed
      vector with strings (chars or grapheme clusters).
    */
   pub fn fillInputStringBuffer(&mut self, text: &str) {
     // is a non-empty input buffer an error here?
     let revtext: String = text.chars().rev().collect();
     //self.inputBuffer.push_str(&revtext); 
   }

   pub fn fillInputBuffer(&mut self, text: &str) {
     // change to text.graphemes().rev for grapheme clusters.
     for c in text.chars().rev() {
       self.inputBuffer.push(c.to_string());
     }
   }

   /*  read one character from the input stream and 
       update the machine. This reads though an inputBuffer/inputChars
       so as to handle unicode grapheme clusters (which can be more 
       than one "character").
   */ 
   pub fn read(&mut self) { 
     /* this exit code should never be called in a translated script
      because the Machine:parse() method will return just before 
      a read() on self.eof But I should keep this here in case 
      the machine methods are used outside of a parse() method? */
     if (self.eof) { 
       // need to return from parse method (i.e break loop) when reading on eof.
       process::exit(0) // print("eof exit") 
     } 

     let mut result = 0;
     let mut line = String::new();
     self.charsRead += 1;
     // increment lines
     if self.peep == "\\n" { self.linesRead += 1; }
     self.work.push_str(&self.peep);

     // fix: it would be better not to have a switch match here.
     /* stdin.all/string/file all read the whole input stream 
        at once into a buffer. */
     match self.sourceType {
       InputType::Stdin|InputType::String|InputType::File => {
         if (self.inputBuffer.is_empty()) {
           self.eof = true;
           self.peep.clear();
         } else {
           self.peep.clear();
           // the inputBuffer is a reversed vector. pop() returns an option type
           self.peep.push_str(&self.inputBuffer.pop().unwrap());
         }
         return;
       },
       InputType::StdinStream => {
         // read from stdin one line at a time. But self.input is 
         // a BufReader<File> which is incompatible with BufReader<Stdin>
       },
       InputType::FileStream => {
         if (self.inputBuffer.is_empty()) {
           if self.input.read_line(&mut line).unwrap() > 0 {
             self.fillInputBuffer(&line);
           } else {
             self.eof = true;
             self.peep.clear();
           }
         }
         if !self.inputBuffer.is_empty() {
           self.peep.clear();
           self.peep.push_str(&self.inputBuffer.pop().unwrap());
         }
         return;
       },
       _ => {
         println!(
           "Machine.sourceType error {:?} while trying to read input", 
           self.sourceType); 
         process::exit(1);
       }
     } 
   } // read

   /*
     write to current machine destination (stdout/string/file) 
     no filestream or filelines types for file output because not
     required
   */

   // function Machine:write(output)
   pub fn write(&mut self) {
     match self.sinkType {
       OutputType::Stdout => {
         print!("{}",&self.work);
       }
       OutputType::File => { 
         write!(self.output, "{}", &self.work).unwrap()
       }
       OutputType::String => {
         self.outputBuffer.push_str(&self.work);
       }
       _ => {
         println!("Machine.sinkType error for type {:?}", self.sinkType);
       }
     }
   }

   /** increment tape pointer by one */
   pub fn increment(&mut self) {
     self.cell += 1;
     if self.cell >= self.tapeLength {
       for ii in 1..50 {
         self.tape.push(String::from(""));
         self.marks.push(String::from(""));
       }
       self.tapeLength += 50;
     }
   }


   // Machine.decrement() is usually compiled inline

   /** remove escape char, the char should be a string because it could be 
       a unicode grapheme cluster (diacritics etc) */
   pub fn unescapeChar(&mut self, c: char) {
     // dont unescape chars that are not escaped!
     let mut countEscapes = 0;
     let mut s = String::from(""); 
     //let nextChar = ;
     if self.work.is_empty() { return; }

     for nextChar in self.work.chars() {
       if (nextChar == c) && (countEscapes % 2 == 1) {
         // assuming that the escape char is only one char?
         // remove last escape char
         s.pop();
       } 
       if nextChar == self.escape {
         countEscapes += 1;
       } else { countEscapes = 0; }
       s.push(nextChar);
     } 
     self.work.clear(); self.work.push_str(&s);
   } 

   /* add escape character, dont escape chars that are already escaped! 
      modify this for grapheme clusters.
     */
   pub fn escapeChar(&mut self, c: char) {
     let mut countEscapes = 0;
     let mut s = String::from(""); 
     if self.work.is_empty() { return; }
     for nextChar in self.work.chars() {
       if (nextChar == c ) && (countEscapes % 2 == 0) {
         s.push(self.escape);
       } 
       if nextChar == self.escape {
         countEscapes += 1;
       } else { countEscapes = 0; }
       s.push(nextChar);
     } 
     self.work.clear();
     self.work.push_str(&s);
   } 

   /* a helper to see how many trailing escape chars */
   pub fn countEscaped(&mut self, suffix: &str) -> usize {
     let mut s = self.work.clone();
     let mut count = 0;
     if s.ends_with(suffix) {
       s.truncate(s.len() - suffix.len());
     }
     while s.ends_with(self.escape) {
       count += 1; s.pop();
     }
     return count;
   }

   /** reads the input stream until the work end with text. It is 
       better to call this readUntil instead of until because some 
       languages dont like keywords as methods. Same for read()
       should be readChar() */
   pub fn readUntil(&mut self, suffix: &str) {
     // read at least one character
     if self.eof { return; }
     self.read();
     loop {
       if self.eof { return; }
       if self.work.ends_with(suffix) {
         if self.countEscaped(suffix) % 2 == 0 { return; }
       }
       self.read();
     }
   }

   /** pop the first token from the stack into the workspace */
   pub fn pop(&mut self) -> bool {
     if self.stack.len() == 0 { return false; }
     self.work.insert_str(0, self.stack.pop().unwrap().as_str());     
     if self.cell > 0 { self.cell -= 1; }
     return true;
   }

   
   // push the first token from the workspace to the stack 
   pub fn push(&mut self) -> bool {
     // dont increment the tape pointer on an empty push
     if self.work.is_empty() { return false; }

     // no iterate chars.
     let mut token = String::new();
     let mut remainder = String::new();
     for (ii,c) in self.work.chars().enumerate() {
       token.push(c); 
       if c == self.delimiter {
         self.stack.push(token);
         let remainder: String = self.work.chars().skip(ii+1).collect();
         self.work.clear();
         self.work.push_str(&remainder);  
         self.increment();
         return true;
       }

     }
     // push the whole workspace if there is no token delimiter
     self.stack.push(token);
     self.work.clear();
     self.increment();
     return true;
   }

   /** swap current tape cell with the workspace */
   // swap not required, use mem::swap ??


   /* swap current tape cell with the workspace */
   /*
   fn swap(&mut self) {
     let s = self.work;
     self.work = self.tape[self.cell].clone(); 
     self.tape[self.cell] = s;
   }
   */
 
    /* code to read a line from BufReader */
    /*
    while reader.read_line(&mut line)? > 0 {
      if line.trim() == "STOP" {
          break;
      }
      println!("Read line: {}", line.trim());
      line.clear(); // Clear the buffer for the next read
    }
    */


   // save the workspace to file "sav.pp" 
   // we can put this inline?
   pub fn writeToFile(&mut self) {
     fs::write("sav.pp", self.work.clone()).expect("Unable to write file");
   }

   pub fn goToMark(&mut self, mark: &str) {
     for (ii, thismark) in self.marks.iter().enumerate() {
       if thismark.eq(&mark) { self.cell = ii; return; }
     }
     print!("badmark \'{}\'!", mark); 
     process::exit(1);
   }

   /* remove existing marks with the same name and add new mark */
   pub fn addMark(&mut self, newMark: &str) {
     // remove existing marks with the same name.
     for mark in self.marks.iter_mut() {
       if mark == newMark { mark.clear(); }
     }
     self.marks[self.cell].clear();
     self.marks[self.cell].push_str(newMark);
   }

   /* check if the workspace matches given list class eg [hjk]
    or a range class eg [a-p]. The class string will be "[a-p]" ie
    with brackets [:alpha:] may have already been made into something else by the
    compiler. 
    fix: for grapheme clusters and more complete classes  
   */

   pub fn matchClass(&mut self, text: &str, class: &str) -> bool {
     // empty text should never match a class.
     if text.is_empty() { return false; }

     // a character type class like [:alpha:]
     if class.starts_with("[:") && class.ends_with(":]") && 
        (class != "[:]") && (class != "[::]") {
       let mut charType: String = class.chars().skip(2).collect();
       charType.pop(); charType.pop();
       // \'京\'.is_alphabetic()

       // these functions are unicode aware for code-points (not graphemes)
       match charType.as_str() {
         "alnum" => return text.chars().all(|c| c.is_alphanumeric()),
         "alpha" => return text.chars().all(|c| c.is_alphabetic()),
         "ascii" => return text.chars().all(|c| c.is_ascii()),
         "word" => return text.chars().all(|c| c.is_alphanumeric()||c == \'_\'),
         "blank" => return text.chars().all(|c| c==\' \'||c==\'\\t\'),
         "control" => return text.chars().all(|c| c.is_control()),
         "cntrl" => return text.chars().all(|c| c.is_control()),
         "digit" => return text.chars().all(|c| c.is_digit(10)),
         "graph" => return text.chars().all(|c| c.is_ascii_graphic()),
         "lower" => return text.chars().all(|c| c.is_lowercase()),
         "upper" => return text.chars().all(|c| c.is_uppercase()),
         "print" => return text.chars().all(|c| c.is_control() && c != \' \'),
         "punct" => return text.chars().all(|c| c.is_ascii_punctuation()),
         "space" => return text.chars().all(|c| c.is_whitespace()),
         "xdigit" => return text.chars().all(|c| c.is_digit(16)),
         _ => {
           println!("unrecognised char class in translated nom script");
           println!("{}", charType);
           process::exit(1);
         }
       }
       return false;
     }

     // get a vector of chars except the first and last which are [ and ]
     let mut charList: Vec<char> = class.chars().skip(1).collect();
     charList.pop();
     // is a range class like [a-z]
     if (charList.len() == 3) && (charList[1] == \'-\') {
       for char in text.chars() { 
         if (char < charList[0]) || (char > charList[2]) { return false; } 
       } 
       return true;
     }

     // list class like: [xyzabc]
     // check if all characters in text are in the class list
     if text.chars().all(|c| charList.contains(&c)) { return true; }
     return false;
     // also must handle eg [:alpha:] This can be done with char methods
   } 

   /* a plain text string replace function on the workspace */
   pub fn replace(&mut self, old: &str, new: &str) {
     if old.is_empty() { return; }
     if old == new { return; }

     let mut text = String::new();
     for cc in self.work.chars() {
       text.push(cc);
       if text.ends_with(old) {
         text.truncate(text.len()-old.len());
         text.push_str(new);
       } 
     }
     self.work.clear();
     self.work.push_str(&text);
   } 

   /* make the workspace capital case */
   pub fn capitalise(&mut self) {
     let mut result = String::new();
     let mut capitalize_next = true;
     for c in self.work.chars() {
       if c.is_alphabetic() {
         if capitalize_next {
           result.push(c.to_uppercase().next().unwrap());
           capitalize_next = false;
         } else {
           result.push(c.to_lowercase().next().unwrap());
         }
       } else {
         result.push(c);
         if c==\'\\n\' || c==\' \' || c==\'.\' || c==\'?\' || c==\'!\' {
           capitalize_next = true;
         }
       }
     }
     self.work.clear(); self.work.push_str(&result);
   } 

   /* print the internal state of the pep/nom parsing machine. This 
      is handy for debugging */
   pub fn printState(&self) {
      println!("\\n--------- Machine State ------------- ");
      println!("(input buffer:{:?})", self.inputBuffer);
      print!("Stack[");
      for token in &self.stack {
        print!("{},", token);
      }
      print!("] Work[{}] ", self.work);
      print!("Peep[{}]\\n", self.peep.escape_default());
      print!("Acc:{} ", self.accumulator);
      print!("EOF:{} ", self.eof);
      print!("Esc:{} ", self.escape);
      print!("Delim:{} ", self.delimiter);
      print!("Chars:{} ", self.charsRead);
      print!("Lines:{}\\n", self.linesRead);
      println!("-------------- Tape ----------------- ");
      println!("Tape Size: {}", self.tapeLength);
      let mut start = 0;
      if self.cell > 3 {
        start = self.cell - 4; 
      } 
      let end = self.cell + 4; 
      for ii in start..end {
        print!("   {ii}");
        if ii == self.cell { print!("> ["); }
        else { print!("  ["); }
        print!("{}]\\n", self.tape.get(ii as usize).unwrap());
      }
   }

   /* just sets the Machine.inputBuffer to the given text
      but in this implementation, also reverses it.
      */

   /*
   pub fn setInputBuffer(&mut self, text: &str) {
     // fix: for grapheme clusters
     self.inputBuffer.clear(); 
     let revtext: String = text.chars().rev().collect();
     self.inputBuffer.push_str(&revtext); 
   } 
   */

   /* makes the machine read from a string also needs to prime 
      the "peep" value. */
   pub fn setStringInput(&mut self, text: &str) {
     self.sourceType = InputType::String; 
     self.inputBuffer.clear();
     self.fillInputBuffer(text);
     // prime the "peep" with the 1st char
     self.peep.clear(); self.read(); self.charsRead = 0;
   } 

   /* makes the machine write to a string */
   pub fn setStringOutput(&mut self) {
     self.sinkType = OutputType::String;
   } 

   /* parse/translate from a string and return the translated
      string */
   pub fn parseString(&mut self, input: &str) -> &str {
     self.setStringInput(input);
     self.sinkType = OutputType::String;
     self.parse();
     return &self.outputBuffer;
   } 

   /* makes the machine read from a file stream line by line, 
      not from stdin */
   pub fn setFileStreamInput(&mut self, filename: &str) {
     if !checkTextFile(filename) { process::exit(1); }
     let file = File::open(filename).unwrap();
     self.input = BufReader::new(file);
     self.sourceType = InputType::FileStream;
     // prime the peep, the read() method should refill the 
     // inputChars or inputBuffer if it is empty.
     self.peep.clear(); self.read(); self.charsRead = 0;
   } 
 
   /* makes the machine read from a file line buffer array
      but this also needs to prime the "peep" value */
   pub fn setFileInput(&mut self, filename: &str) {

     let mut file = BufReader::new(File::open(filename)
       .expect("Could not open file for reading."));
     // reads a file all at once into the Machine.inputBuffer
     let mut text = String::new();
     file.read_to_string(&mut text);
     // there is an extra newline being added, I dont know where.
     if text.ends_with("\n") { text.pop(); }
     self.sourceType = InputType::File;
     self.inputBuffer.clear();
     self.fillInputBuffer(&text);
     // prime the "peep" with the 1st char
     self.peep.clear(); self.read(); self.charsRead = 0;
   } 

   /* makes the machine write to a file not to stdout (the default) */
   pub fn setFileOutput(&mut self, filename: &str) {
     if !checkTextFile(filename) {
       process::exit(1);
     }
     let file = File::create(filename).unwrap(); 
     self.output = BufWriter::new(file);
     self.sinkType = OutputType::File;
   } 

   // parse from a file and put result in file 
   pub fn parseFile(&mut self, inputFile: &str, outputFile: &str) {
     self.setFileInput(inputFile);
     self.setFileOutput(outputFile);
     self.parse()
   } 

   /* parse from any stream, fix handle */
   /*
   pub fn parseStream(&mut self, reader: Read) {
     //self.input = handle;
     self.parse();
   } 
   */

   /* this is the default parsing mode. If no other is selected 
      it will be activated when parse() is first called. I activate it when
      parse is 1st called because otherwise it will block if no stdin
      is availabel. It also sets stdout as output */
   pub fn setStandardInput(&mut self) {
     self.sourceType = InputType::Stdin;  
     self.sinkType = OutputType::Stdout; 
     
     // unused because all input read at oncej
     //self.input = io.stdin 
     //self.output = io.stdout

     // read the whole of stdin into the inputBuffer 
     self.inputBuffer.clear();
     let mut reader = BufReader::new(stdin());
     let mut buffer = String::new();
     match reader.read_to_string(&mut buffer) {
       Err(why) => {
         // panic!("couldnt read : {}", why),
         return;
       }
       Ok(_) => {
         // print!("input:{}", buffer),
         // fix: change to graphemes
         self.fillInputBuffer(&buffer)
       }
     }

     // prime the "peep" with the 1st char, but this doesnt count as 
     // a character read.
     self.peep.clear(); self.read(); self.charsRead = 0;
   } 

   /** parse and translate the input stdin/file/string */
   pub fn parse(&mut self) {
     match self.sourceType {
       InputType::Unset => self.setStandardInput(),
       _ => (), 
     } 
     // -----------
     // translated nom code goes here
     // -----------
     // close open files here? yes. use break, not return
     match self.sinkType {
       OutputType::File => { self.output.flush().unwrap(); }
       OutputType::Stdout => { }
       OutputType::String => { }
       _ => {
         println!("unsupported output type: {:?}", self.sinkType);
       }
     }
   } // 
 } // Machine impl

  fn printHelp() {
    println!("
    Nom script translated to rust by www.nomlang.org/tr/nom.torust.pss
    usage: 
       echo \\"..sometext..\\" | ./script 
       cat somefile.txt | ./script 
       ./script -f <file>
       ./script -i <text>
    options:
     --file -f <file>
        run the script with <file> as input (not stdin)
     --input -i <text>
        run the script with <text> as input 
     --filetest -F <filename>
        test the translated script with file input and output 
     --filestream -S <filename>
        test the translated script with file-stream input
     --inputtest -I <text>
        test the translated script with string input and output 
     --help -h 
        show this help
        ");
  }

  /* display a message about a missing argument to the translated
     script */
  fn missingArgument() {
    println!("Missing argument.");
    printHelp();
    process::exit(1);
  }

  /* display a message if an command line option is repeated */
  fn duplicateSwitch() {
    println!("Duplicate switch found.");
    printHelp();
    process::exit(1);
  }

  fn checkTextFile(filepath: &str) -> bool {
    match File::open(filepath) {
      Ok(_) => true,
      Err(e) => {
        match e.kind() {
          io::ErrorKind::NotFound => {
            println!("File [{}] not found.", filepath);
          }
          io::ErrorKind::PermissionDenied => {
            println!("Permission denied to read file [{}] ", filepath);
          }
          _ => {
            println!("Error opening file {}: {:?}", filepath, e);
          }
        }
        return false;
      }
    }
  }

  fn main() { 

    /* add switches for file to file and string to string parsing 
       the -F and -I switch are mainly to allow file/string input/output
       to be easily tested by scripts */

    let mut mm: Machine = Machine::new();
    let mut input = ""; 
    let mut filename = "";

    let args: Vec<String> = env::args().collect();
    for (pos, e) in args.iter().enumerate() {
      if (e == "-f") || (e == "--file") { 
        if !filename.is_empty() { duplicateSwitch(); }
        if pos>=args.len()-1 { missingArgument(); }
        filename = &args[pos+1];
        if !checkTextFile(filename) { 
          printHelp();
          process::exit(1); 
        }
        mm.setFileInput(filename);
        // print output file here
      }
      if (e == "-F") || (e == "--filetest") { 
        if pos>=args.len()-1 { missingArgument(); }
        if !filename.is_empty() { duplicateSwitch(); }
        filename = &args[pos+1];
        if !checkTextFile(filename) { 
          printHelp();
          process::exit(1);
        }
        mm.parseFile(filename, "out.txt");
        let mut output = fs::read_to_string("out.txt").unwrap();
        print!("{}", output);
        process::exit(0)
      }
      // test the filestream input type (reads line by line through
      // with a BufReader 
      if (e == "-S") || (e == "--filestream") { 
        if pos>=args.len()-1 { missingArgument(); }
        if !filename.is_empty() { duplicateSwitch(); }
        filename = &args[pos+1];
        if !checkTextFile(filename) { 
          printHelp();
          process::exit(1);
        }
        mm.setFileStreamInput(filename);
      }
      if (e == "-i") || (e == "--input") { 
        if pos>=args.len()-1 { missingArgument(); }
        if !input.is_empty() { duplicateSwitch(); }
        input = &args[pos+1];
        mm.setStringInput(input);
      }
      if (e == "-I") || (e == "--inputtest") { 
        if pos>=args.len()-1 { missingArgument(); }
        if !input.is_empty() { duplicateSwitch(); }
        input = &args[pos+1];
        let text = mm.parseString(input);
        print!("{}",text);
        process::exit(0)
      }
      if (e == "-h") || (e == "--help") { 
        printHelp(); process::exit(0);
      }
    
      if !input.is_empty() && !filename.is_empty() {
        print!("
     Either use the --file/--filetest options or the --input/--inputtest
     options, not both
        ");
        printHelp(); process::exit(0);
      }
    }

    mm.parse();
  }

