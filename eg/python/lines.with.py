#!/usr/bin/env python3

# code generated by "translate.py.pss" a pep script
# bumble.sf.net/books/pars/
import sys, re    # for sys.read(), write() and regex
from unicodedata import category # for matching classes
# may use, which could make the char class code easier
# import regex
# regex.findall(r'[[:graph:]]', 'a 0 a b z') 

class Machine: 
  # make a new machine 
  def __init__(self):
    self.size = 300      # how many elements in stack/tape/marks
    self.eof = False     # end of stream reached?
    self.charsRead = 0   # how many chars already read
    self.linesRead = 1   # how many lines already read
    self.escape = "\\"
    self.delimiter = "*" # push/pop delimiter (default "*")
    self.counter = 0     # a counter for anything
    self.work = ""       # the workspace
    self.stack = []      # stack for parse tokens 
    self.cell = 0                # current tape cell
    self.tape = [""]*self.size   # a list of attribute for tokens 
    self.marks = [""]*self.size  # marked tape cells
    # or dont initialse peep until "parse()" calls "setInput()"
    self.peep = sys.stdin.read(1)

  def setInput(self, newInput): 
    print("to be implemented")

  # read one character from the input stream and 
  #    update the machine.
  def read(self): 
    if self.eof: System.exit(0)
    self.charsRead += 1;
    # increment lines
    if self.peep == "\n": self.linesRead += 1
    self.work += self.peep
    self.peep = sys.stdin.read(1) 
    if not self.peep: self.eof = True

  # increment the tape pointer (command ++) and increase the 
  # tape and marks array sizes if necessary
  def increment(self): 
    self.cell += 1
    if self.cell >= self.size: 
      self.tape.append("")
      self.marks.append("")
      self.size += 1

  # test if all chars in the text are in the unicode category
  # no! bug! because while checks mm.peep, but class test
  # checks mm.work. so have to adapt this function for either.
  def isInCategory(self, cat, text): 
    for ch in text:
      if not category(ch).startswith(cat): return False
    return True

  # def  
  # remove escape character: trivial method ?
  def unescapeChar(self, c):
    if len(self.work) > 0:
      self.work = self.work.replace("\\"+c, c)

  # add escape character : trivial
  def escapeChar(self, c):
    if len(self.work) > 0:
      self.work = self.work.replace(c, "\\"+c)

  # a helper function for the multiple escape char bug
  def countEscaped(self, suffix): 
    count = 0
    if self.work.endswith(suffix):
      # removesuffix not available in early python
      s = self.work.removesuffix(suffix)
    while s.endswith(self.escape):
      count += 1
      s = s.removesuffix(self.escape)
    return count

  # reads the input stream until the workspace end with text 
  def until(self, suffix): 
    # read at least one character
    if self.eof: return
    self.read()
    while True: 
      if self.eof: return
      # no. bug! count the trailing escape chars, odd=continue, even=stop
      if self.work.endswith(suffix):
        #and (not self.work.endswith(self.escape + suffix)): 
        if self.countEscaped(suffix) % 2 == 0: return
      self.read()
    
  # pop the first token from the stack into the workspace */
  def pop(self): 
    if len(self.stack) == 0: return False
    self.work = mm.stack.pop() + self.work
    if self.cell > 0: self.cell -= 1
    return True

  # push the first token from the workspace to the stack 
  def push(self): 
    # dont increment the tape pointer on an empty push
    if len(self.work) == 0: return False
    # need to get this from the delimiter.
    iFirst = self.work.find(self.delimiter);
    if iFirst == -1:
      self.stack.append(self.work)
      self.work = "" 
      return True
    self.stack.append(self.work[0:iFirst+1])
    self.work = self.work[iFirst+1:]
    self.increment()
    return True

  # this function is not used (the code is "inlined") 
  def swap(self): 
    s = self.work
    self.work = self.tape[self.cell]
    self.tape[self.cell] = s

  def goToMark(self, mark):
    markFound = False  
    length = len(self.marks)
    for ii in range(length): 
      if (mm.marks[ii] == mark):
        mm.cell = ii; markFound = True
    if (markFound == False):
      print("badmark '" + mark + "'!") 
      exit()

  def writeToFile(self): 
    f = open("sav.pp", "w")
    f.write(self.work) 
    f.close() 

  def printState(self): 
    print("Stack[" + ",".join(self.stack) + 
      "] Work[" + self.work + "] Peep[" + self.peep + "]");
    print("Acc:" + str(self.counter) + " Esc:" + self.escape +
          " Delim:" + self.delimiter + " Chars:" + str(self.charsRead) +
          " Lines:" + str(self.linesRead) + " Cell:" + str(self.cell));

  # this is where the actual parsing/compiling code should go
  # so that it can be used by other python classes/objects. Also
  # should have a stream argument.
  def parse(self, s): 
    # a reset or "setinput()" method would be useful to parse a 
    # different string/file/stream, without creating a new
    # machine object.
    # could use code like this to check if input is string or file
    if isinstance(s, file):
      print("")
      # self.reset(s)
      # self.reader = s
    elif isinstance(s, string):
      f = StringIO.StringIO("test")
      for line in f: print(line)
    else:
      f = sys.stdin
    sys.stdout.write("not implemented")


# end of Machine class definition

# will become:
# mm.parse(sys.stdin)  or 
# mm.parse("abcdef") or
# open f; mm.parse(f)

temp = ""    
mm = Machine() 
while (not mm.eof): 
  # print lines containing the text pep
  mm.read()           # read
  if (mm.work.endswith("\n")):
    mm.tape[mm.cell] = mm.work  # put 
    # replace 
    if len(mm.work) != 0:  
      mm.work = mm.work.replace("pep", "")
    
    if (mm.work != mm.tape[mm.cell]):
      mm.work, mm.tape[mm.cell] = mm.tape[mm.cell], mm.work   # swap 
      sys.stdout.write(mm.work) # print
    mm.work = ''              # clear

# end of code generated by tr/translate.py.pss 
