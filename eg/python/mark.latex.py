#!/usr/bin/env python3

# code generated by "translate.py.pss" a pep script
# bumble.sf.net/books/pars/
import sys, re    # for sys.read(), write() and regex
from unicodedata import category # for matching classes

class Machine: 
  # make a new machine 
  def __init__(self):
    self.size = 100      # how many elements in stack/tape/marks
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

  # increment tape pointer by one: trivial method in python 
  def increment(self):
    self.cell += 1
  
  # test if all chars in workspace are in unicode category
  def isInCategory(self, cat): 
    for ch in self.work:
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

  # reads the input stream until the workspace end with text 
  def until(self, suffix): 
    # read at least one character
    if self.eof: return
    self.read()
    while True: 
      if self.eof: return
      if self.work.endswith(suffix) and (not self.work.endswith(self.escape + suffix)): return
      self.read()
    
  # pop the first token from the stack into the workspace */
  def pop(self): 
    if len(self.stack) == 0: return False
    self.work = mm.stack.pop() + self.work
    if self.cell > 0: self.cell -= 1
    return True

  # push the first token from the workspace to the stack 
  def push(self): 
    #String sItem;
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
    if self.cell < self.size: 
      self.cell += 1
    else:
      print("tape max size exceeded while pushing!"); 
      print("tape max size = " + str(self.size)); 
      print("tape cell = " + str(self.cell)); 
      exit()
    return True

  # maybe not required (can be inlined in python)
  def swap(self): 
    s = self.work
    self.work = self.tape[self.cell]
    self.tape[self.cell] = s

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
# create a dummy newline so that doc structures work even
# on the first line of the file/stream.
mm.work += "nl*"
mm.push();
while (not mm.eof): 
  
  # lex block 
  while True: 
    mm.read()           # read
    if (not re.match(r"^[\s]+$", mm.work)):
      # whilenot  
      while not re.match(r"^[\s]+$", mm.peep):
        if mm.eof:
          break
        mm.read()
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "word*"
      mm.push();
      break
    # keep leading space in newline token?
    if (re.match(r"^[\n]+$", mm.work)):
      # while  
      while re.match(r"^[ ]+$", mm.peep):
        if mm.eof:
          break
        mm.read()
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "nl*"
      mm.push();
      break
    if (re.match(r"^[\r\t ]+$", mm.work)):
      mm.work = ''              # clear
      continue
    break 
  
  # parse block 
  while True:  
    # for debugging
    #add "line "; lines; add " char "; chars; add ": "; print; clear; 
    #unstack; print; stack; add "\n"; print; clear;
    # -------------
    # 1 token
    mm.pop();
    if (mm.work == "nl*"):
      pass # nop: no-operation
    # here we classify words into other tokens
    if (mm.work == "word*"):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      # no numbers in headings!
      if (re.match(r"^[A-Z]+$", mm.work)):
        mm.work = ''              # clear
        mm.work += "uuword*"
        mm.push();
        continue
      # at least three --- on a newline marks a code block start
      if (mm.work.startswith("---") and re.match(r"^[\\-]+$", mm.work)):
        mm.work = ''              # clear
        mm.work += "---*"
        mm.push();
        continue
      # >> on a newline marks a code block start
      if (mm.work == ">>"):
        mm.work += "*"
        mm.push();
        continue
      # star on newline marks emphasis, list or code description 
      if (mm.work == "*"):
        mm.work = ''              # clear
        mm.work += "star*"
        mm.push();
        continue
      # subheading marker
      if (mm.work.startswith("....") and re.match(r"^[.]+$", mm.work)):
        mm.work = ''              # clear
        mm.work += "4dots*"
        mm.push();
        continue
      # urls, not so important for LaTex but anyway 
      # dont really need tokens because we can render immediately
      if (mm.work.startswith("http://") or mm.work.startswith("https://") or mm.work.startswith("www.") or mm.work.startswith("ftp://") or mm.work.startswith("sftp://")):
        # clear; add "url*"; push; .reparse
        # render as fixed pitch font
        mm.work = ''              # clear
        mm.work += "\\texttt{"
        mm.work += mm.tape[mm.cell] # get
        mm.work += "}"
        mm.tape[mm.cell] = mm.work  # put 
        mm.work = ''              # clear
      # filenames
      if (mm.work.endswith("/") or mm.work.endswith(".c") or mm.work.endswith(".txt") or mm.work.endswith(".html") or mm.work.endswith(".pss") or mm.work.endswith(".pp") or mm.work.endswith(".js") or mm.work.endswith(".java") or mm.work.endswith(".tcl") or mm.work.endswith(".py") or mm.work.endswith(".pl") or mm.work.endswith(".jpeg") or mm.work.endswith(".jpg") or mm.work.endswith(".png")):
        mm.work = ''              # clear
        mm.work += "\\texttt{"
        mm.work += mm.tape[mm.cell] # get
        mm.work += "}"
        mm.tape[mm.cell] = mm.work  # put 
        mm.work = ''              # clear
      # filenames 
      if (mm.work.startswith("../") and mm.work != "../"):
        mm.work = ''              # clear
        mm.work += "\\texttt{"
        mm.work += mm.tape[mm.cell] # get
        mm.work += "}"
        mm.tape[mm.cell] = mm.work  # put 
        mm.work = ''              # clear
      # filenames 
      # crude pattern checking.
      if (mm.work.startswith("/") and mm.work != "/"):
        # if len(mm.work) > 0:  # clip 
        mm.work = mm.work[:-1]  # clip
        if (mm.work.endswith(".")):
          mm.work = ''              # clear
          mm.work += "\\texttt{"
          mm.work += mm.tape[mm.cell] # get
          mm.work += "}"
          mm.tape[mm.cell] = mm.work  # put 
          mm.work = ''              # clear
        # if len(mm.work) > 0:  # clip 
        mm.work = mm.work[:-1]  # clip
        if (mm.work.endswith(".")):
          mm.work = ''              # clear
          mm.work += "\\texttt{"
          mm.work += mm.tape[mm.cell] # get
          mm.work += "}"
          mm.tape[mm.cell] = mm.work  # put 
          mm.work = ''              # clear
        # if len(mm.work) > 0:  # clip 
        mm.work = mm.work[:-1]  # clip
        if (mm.work.endswith(".")):
          mm.work = ''              # clear
          mm.work += "\\texttt{"
          mm.work += mm.tape[mm.cell] # get
          mm.work += "}"
          mm.tape[mm.cell] = mm.work  # put 
          mm.work = ''              # clear
      mm.work = ''              # clear
      mm.work += "word*"
    mm.pop();
    # -------------
    # 2 tokens
    # ellide text
    if (mm.work == "word*word*" or mm.work == "text*word*" or mm.work == "word*uuword*" or mm.work == "text*uuword*" or mm.work == "uutext*word*" or mm.work == "uuword*word*"):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant nl* newline tokens. This may need more thought
    # We are using a dummy nl* token at the start of the doc, so the 
    # codeblock* codeline* etc tokens are not able to be the first token
    # of the document. So we can remove the !"codeblock*". clause.
    # remove insignificant codeblock* tokens
    if (mm.work.endswith("codeblock*") and not mm.work.startswith("emline*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant codeline* tokens
    if (mm.work.endswith("codeline*") and not mm.work.startswith("emline*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant emline* tokens (not followed by codeblock/line)
    # the logic is slightly diffferent because emline* is significant before
    # other tokens, not after.
    # also, consider emline*text*nl*
    if (mm.work.startswith("emline*") and not mm.work.endswith("nl*") and not mm.work.endswith("codeline*") and not mm.work.endswith("codeblock*")):
      # clear; get; add " "; ++; get; --; put; clear;
      # replace 
      if len(mm.work) != 0:  
        mm.work = mm.work.replace("emline*", "text*")
      
      mm.push();
      mm.push();
      continue
    # remove insignificant 4dots* tokens
    if (mm.work.endswith("4dots*") and not mm.work.startswith("uutext*") and not mm.work.startswith("uuword*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant star* tokens
    if (mm.work.endswith("star*") and not mm.work.startswith("nl*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant ---* tokens
    if (mm.work.endswith("---*") and not mm.work.startswith("nl*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # remove insignificant >>* tokens
    # lets assume that codelines cant start a document? Or lets
    # generate a dummy nl* token at the start of the document to 
    # make parsing easier.
    # !">>*".E">>*".!B"nl*" {
    if (mm.work.endswith(">>*") and not mm.work.startswith("nl*")):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # ellide upper case text 
    if (mm.work == "uuword*uuword*" or mm.work == "uutext*uuword*"):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.work += " "
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "uutext*"
      mm.push();
      continue
    # ellide multiple newlines 
    if (mm.work == "nl*nl*"):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "nl*"
      mm.push();
      continue
    # emphasis line (starts with *) 
    if (mm.work == "nl*star*"):
      mm.work = ''              # clear
      # whilenot  
      while not re.match(r"^[\n]+$", mm.peep):
        if mm.eof:
          break
        mm.read()
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "\n \\emph{"
      mm.work += mm.tape[mm.cell] # get
      mm.work += "}"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "emline*"
      mm.push();
      continue
    # code line (starts with >>) 
    if (mm.work == "nl*>>*"):
      mm.work = ''              # clear
      # whilenot  
      while not re.match(r"^[\n]+$", mm.peep):
        if mm.eof:
          break
        mm.read()
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "\n \\begin{verbatim}"
      mm.work += mm.tape[mm.cell] # get
      mm.work += " \\end{verbatim} \n"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "codeline*"
      mm.push();
      continue
    # code block marker 
    if (mm.work == "nl*---*"):
      mm.work = ''              # clear
      mm.until(",,,");
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      mm.tape[mm.cell] = mm.work  # put 
      # while  
      while re.match(r"^[,]+$", mm.peep):
        if mm.eof:
          break
        mm.read()
      mm.work = ''              # clear
      mm.work += "\n \\begin{lstlisting}[breaklines] \n"
      mm.work += mm.tape[mm.cell] # get
      mm.work += "\n \\end{lstlisting} \n"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "codeblock*"
      mm.push();
      continue
    # a code block with its preceding description
    if (mm.work == "emline*codeblock*"):
      mm.work = ''              # clear
      mm.work += "\n \\begin{tabular}{}"
      mm.work += mm.tape[mm.cell] # get
      mm.work += " \\\\ \\hline"
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += " \\end{tabular} \n"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    # a code line with its preceding description
    # add some tabular LaTeX markup here.
    if (mm.work == "emline*codeline*"):
      mm.work = ''              # clear
      mm.work += "\n \\begin{tabular}{}"
      mm.work += mm.tape[mm.cell] # get
      mm.work += " \\\\ \\hline"
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += " \\end{tabular} \n"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.work += "text*"
      mm.push();
      continue
    mm.pop();
    # -------------
    # 3 tokens
    # top level headings, all upper case on the line in the source document
    # dont need a "heading" token because we dont parse the document as a 
    # heirarchy, we just render things as we find them in the stream.
    if (mm.work == "nl*uutext*nl*" or mm.work == "nl*uuword*nl*"):
      mm.work = ''              # clear
      # Check that heading is at least 4 chars
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      # if len(mm.work) > 0:  # clip 
      mm.work = mm.work[:-1]  # clip
      if (mm.work == ""):
        mm.work += "nl*text*nl*"
        mm.push();
        mm.push();
        mm.push();
        continue
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      # newline
      mm.work += "\\section{"
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += "}"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      # transfer nl value
      mm.cell += 1                  # ++
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += "text*nl*"
      mm.push();
      mm.push();
      continue
    # simple reductions 
    if (mm.work == "nl*text*nl*" or mm.work == "nl*word*nl*" or mm.work == "text*text*nl*" or mm.work == "emline*text*nl*"):
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      mm.cell += 1                  # ++
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work = ''              # clear
      # transfer newline value
      mm.work += "text*nl*"
      mm.push();
      mm.push();
      continue
    mm.pop();
    # -------------
    # 4 tokens
    # sub headings, 
    if (mm.work == "nl*uutext*4dots*nl*" or mm.work == "nl*uuword*4dots*nl*"):
      mm.work = ''              # clear
      # Check that sub heading text is at least 4 chars ?
      # yes but need to transfer 4dots and nl
      # ++; get; --; clip; clip; clip; 
      # "" { add "nl*text*nl*"; push; push; push; .reparse }
      mm.work = ''              # clear
      mm.work += mm.tape[mm.cell] # get
      # newline
      mm.work += "\\subsection{"
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += "}"
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      # transfer nl value
      mm.cell += 1                  # ++
      mm.cell += 1                  # ++
      mm.cell += 1                  # ++
      mm.work += mm.tape[mm.cell] # get
      if mm.cell > 0: mm.cell -= 1  # --
      if mm.cell > 0: mm.cell -= 1  # --
      mm.tape[mm.cell] = mm.work  # put 
      mm.work = ''              # clear
      if mm.cell > 0: mm.cell -= 1  # --
      mm.work += "text*nl*"
      mm.push();
      mm.push();
      continue
    mm.push();
    mm.push();
    mm.push();
    mm.push();
    if (mm.eof):
      mm.pop();
      mm.pop();
      mm.pop();
      if (mm.work == "text*nl*" or mm.work == "text*"):
        mm.work = ''              # clear
        # make a valid LaTeX document
        mm.work += "\\documentclass{article} \n"
        mm.work += "\\usepackage{listings} \n"
        mm.work += "\\usepackage[table]{xcolor} \n"
        # also, frame=shadowbox
        mm.work += "\\lstset{basicstyle=\\ttfamily,numbers=left,frameround=ftft,frame=single}\n"
        mm.work += "\\begin{document}\n"
        mm.work += mm.tape[mm.cell] # get
        mm.work += "\n\\end{document} \n"
        sys.stdout.write(mm.work) # print
        mm.work = ''              # clear
        mm.work += "\n\n Document parsed as text*!\n"
        sys.stdout.write(mm.work) # print
        exit()
      mm.push();
      mm.push();
      mm.work += "Document parsed unusually!\n"
      mm.work += "Stack at line "
      mm.work += str(mm.linesRead) # lines 
      mm.work += " char "
      mm.work += str(mm.charsRead) # chars 
      mm.work += ": "
      sys.stdout.write(mm.work) # print
      mm.work = ''              # clear
      while (mm.pop()):  continue    # unstack 
      sys.stdout.write(mm.work) # print
      while (mm.push()):  continue   # stack 
      mm.work += "\n"
      sys.stdout.write(mm.work) # print
      mm.work = ''              # clear
      exit()
    break # parse
  

# end of generated code
