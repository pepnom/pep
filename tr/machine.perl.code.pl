 #!/usr/bin/env perl

 # 
 # 

 use strict;
 use warnings;
 use utf8;
 # for unicode character properties.
 # use Unicode::UCD qw(charprop);
 # use IO::File;
 #use IO::BufReader;
 #use IO::BufWriter;
 use Getopt::Long;
 use Carp; # For croak and confess

 package Machine; 
   use constant { true => 1, false => 0 };

   sub new {
     # my ($class) = @_;
     my $class = shift;  # 

     my $self = {
       accumulator   => 0,       # counter for anything
       peep          => "",      # next char in input stream
       charsRead     => 0,       # No. of chars read so far init:0
       linesRead     => 1,       # No. of lines read so far init:1
       inputBuffer   => [],      # reversed array of input chars/graphemes
       outputBuffer  => "",      # where string output will go
       inputType    => "unset",  # reading from stdin/string/file etc
       sinkType      => "stdout",# 
       work          => "",      # text accumulator
       stack         => [],      # parse token stack
       tapeLength    => 100,     # tape initial length
       tape          => ["" x 100], # array of token attributes, growable
       marks         => ["" x 100], # tape marks
       cell          => 0,       # pointer to current cell
       input         => *STDIN,  # text input stream
       output        => *STDOUT, #
       eof           => false,       # end of stream reached? (boolean)
       escape        => '\\',    # char used to "escape" others: default "\\"
       delimiter     => '*',     # push/pop delimiter (default is "*")
     };
     bless $self, $class;
     return $self;
   }

   sub fillInputStringBuffer {
     my ($self, $text) = @_;
     my $revtext = reverse $text;
     # push onto the array
     push @{$self->{inputBuffer}}, split //, $revtext;
   }

   sub fillInputBuffer {
     my $self = shift;
     my $text = shift;
     # grapheme clusters regex is '\X' in perl
     # the grapheme cluster splitter is making an extra empty char 
     # in the array
     # my @charArray = reverse split(/(\X)/, $text);
     my @charArray = reverse split(//, $text);
     push (@{$self->{inputBuffer}}, @charArray);
     # display the input buffer array
     # print "[",join(", ", @{$self->{inputBuffer}}),"]";
   }

   # read one character from the input stream and
   #   update the machine. This reads though an inputBuffer/inputChars
   #   so as to handle unicode grapheme clusters (which can be more
   #   than one "character").
   # 
   sub readChar {
     my $self = shift;

     #  this exit code should never be called in a translated script
     #  because the Machine:parse() method will return just before
     #  a read() on self.eof But I should keep this here in case
     #  the machine methods are used outside of a parse() method?
     if ($self->{eof}) {
       # need to return from parse method (i.e break loop) when reading on eof.
       exit 0; # print("eof exit")
     }

     my $result = 0; my $line = "";
     $self->{charsRead} += 1;
     # increment lines
     if ($self->{peep} eq "\\n") { $self->{linesRead} += 1; }
     $self->{work} .= $self->{peep};

     # fix: it would be better not to have an if else here
     # stdin.all/string/file all read the whole input stream
     #    at once into a buffer.
     my $inputType = $self->{inputType};
     if ($inputType eq "stdin" || $inputType eq "string" || 
         $inputType eq "file") {
       if (!@{$self->{inputBuffer}}) {
         $self->{eof} = true;
         $self->{peep} = "";
       } else {
         $self->{peep} = "";
         # the inputBuffer is a reversed array. pop() returns the last element
         my $char = pop @{$self->{inputBuffer}};
         $self->{peep} .= $char if defined $char;
       }
       return;
     } elsif ($inputType eq "stdinstream") {
       # read from stdin one line at a time. 
       # 
     } elsif ($inputType eq "filestream") {
       # if (scalar(@{$self->{inputBuffer}}) == 0) {
       if (!@{$self->{inputBuffer}}) {
         my $bytes = $self->{input}->getline(\$line);
         if ($bytes > 0) {
           $self->fillInputBuffer($line);
         } else {
           $self->{eof} = true;
           $self->{peep} = "";
         }
       }
       if (scalar(@{$self->{inputBuffer}}) > 0) {
         $self->{peep} = "";
         my $char = pop @{$self->{inputBuffer}};
         $self->{peep} .= $char if defined $char;
       }
       return;
     } else {
       print STDERR "Machine.inputType error ", $inputType, " while trying to read input\n";
       exit 1;
     }
   } # read

   # function Machine:write(output)
   sub write {
     my ($self) = @_;
     my $sink_type = $self->{sinkType};
     if ($sink_type eq "stdout") {
       print $self->{work};
     } elsif ($sink_type eq "file") {
       print {$self->{output}} $self->{work} or die "Error writing to file: $!";
     } elsif ($sink_type eq "string") {
       $self->{outputBuffer} .= $self->{work};
     } else {
       print STDERR "Machine.sinkType error for type ", $sink_type, "\n";
     }
   }

   # increment tape pointer by one
   sub increment {
     my ($self) = @_;
     $self->{cell}++;
     if ($self->{cell} >= $self->{tapeLength}) {
       for (my $ii = 1; $ii <= 50; $ii++) {
         push @{$self->{tape}}, "";
         push @{$self->{marks}}, "";
       }
       $self->{tapeLength} += 50;
     }
   }

   # Machine.decrement() is usually compiled inline

   # remove escape char, the char should be a string because it could be
   # a unicode grapheme cluster (diacritics etc) 
   sub unescapeChar {
     my ($self, $c) = @_;
     # dont unescape chars that are not escaped!
     my $countEscapes = 0;
     my $s = "";
     # let nextChar = ;
     return if length($self->{work}) == 0;

     for my $nextChar (split //, $self->{work}) {
       if ($nextChar eq $c && ($countEscapes % 2 == 1)) {
         # assuming that the escape char is only one char?
         # remove last escape char
         substr($s, -1) = "";
       }
       if ($nextChar eq $self->{escape}) {
         $countEscapes++;
       } else {
         $countEscapes = 0;
       }
       $s .= $nextChar;
     }
     $self->{work} = $s;
   }

   # /* add escape character, dont escape chars that are already escaped!
   #    modify this for grapheme clusters.
   #   */
   sub escapeChar {
     my ($self, $c) = @_;
     my $countEscapes = 0;
     my $s = "";
     return if length($self->{work}) == 0;
     for my $nextChar (split //, $self->{work}) {
       if ($nextChar eq $c && ($countEscapes % 2 == 0)) {
         $s .= $self->{escape};
       }
       if ($nextChar eq $self->{escape}) {
         $countEscapes++;
       } else {
         $countEscapes = 0;
       }
       $s .= $nextChar;
     }
     $self->{work} = $s;
   }

   # /* a helper to see how many trailing escape chars */
   sub countEscaped {
     my ($self, $suffix) = @_;
     my $s = $self->{work};
     my $count = 0;
     if (substr($s, -length($suffix)) eq $suffix) {
       $s = substr($s, 0, length($s) - length($suffix));
     }
     while (substr($s, -length($self->{escape})) eq $self->{escape}) {
       $count++;
       $s = substr($s, 0, length($s) - length($self->{escape}));
     }
     return $count;
   }

   #  reads the input stream until the work end with text. It is
   #    better to call this readUntil instead of until because some
   #       languages dont like keywords as methods. Same for read()
   #       should be readChar() 
   sub readUntil {
     my ($self, $suffix) = @_;
     # read at least one character
     return if $self->{eof};
     $self->readChar();
     while (true) {
       return if $self->{eof};
       if (substr($self->{work}, -length($suffix)) eq $suffix) {
         return if $self->countEscaped($suffix) % 2 == 0;
       }
       $self->readChar();
     }
   }

   # pop the first token from the stack into the workspace
   sub popToken {
     my $self = shift;   # the machine, not local
     if (!@{$self->{"stack"}}) { return false; }
     $self->{"work"} = pop(@{$self->{"stack"}}) + $self->{"work"};
     if ($self->{"cell"} > 0) { $self->{"cell"} -= 1; }
     return 1;
   }

   # push the first token from the workspace to the stack
   sub pushToken {
     my ($self) = @_;
     # my $self = shift;   # 
     # dont increment the tape pointer on an empty push
     if (length($self->{work}) == 0) { return false; }

     # no, iterate chars.
     my $token = "";
     my $remainder = "";
     my @chars = split //, $self->{work};
     for (my $ii = 0; $ii < scalar(@chars); $ii++) {
       my $c = $chars[$ii];
       $token .= $c;
       if ($c eq $self->{delimiter}) {
         push @{$self->{stack}}, $token;
         $remainder = join "", @chars[$ii+1 .. $#chars];
         $self->{work} = "";
         $self->{work} .= $remainder;
         $self->increment();
         return 1;
       }
     }
     # push the whole workspace if there is no token delimiter
     push @{$self->{stack}}, $token;
     $self->{work} = "";
     $self->increment();
     return 1;
   }

   # push the first token from the workspace to the stack 
   sub pushTokenOld {
     my $self = shift;   # a pointer to the machine
     # dont increment the tape pointer on an empty push
     if ($self->{"work"} eq "") { return 0; }
     # need to get this from the delimiter.
     my $iFirst = index($self->{"work"}, $self->{"delimiter"});
     if ($iFirst == -1 ) {
       push(@{$self->{"stack"}}, $self->{"work"}); 
       $self->{"work"} = ""; return 1;
     }
     # s[i..j] means all chars from i to j
     # s[i,n] means n chars from i
     push(@{$self->{"stack"}}, substr($self->{"work"}, 0, $iFirst));
     $self->{"work"} = substr($self->{"work"}, $iFirst+1, -1);
     $self->increment();
     return 1;
   }


   # save the workspace to file "sav.pp"
   # we can put this inline?
   sub writeToFile {
     my ($self) = @_;
     my $filename = "sav.pp";
     open my $fh, '>', $filename or die "Could not open file '$filename' for writing: $!";
     print $fh $self->{work};
     close $fh;
   }

   sub goToMark {
     my ($self, $mark) = @_;
     for (my ($ii, $thismark) = (0, @{$self->{marks}})) {
       if ($thismark eq $mark) {
         $self->{cell} = $ii;
         return;
       }
     }
     print "badmark '$mark'!\n";
     exit 1;
   }

   # /* remove existing marks with the same name and add new mark */
   sub addMark {
     my ($self, $newMark) = @_;
     # remove existing marks with the same name.
     for my $mark (@{$self->{marks}}) {
       if ($mark eq $newMark) {
         $mark = "";
       }
     }
     $self->{marks}[$self->{cell}] = "";
     $self->{marks}[$self->{cell}] = $newMark;
   }

   # /* check if the workspace matches given list class eg [hjk]
   #    or a range class eg [a-p]. The class string will be "[a-p]" ie
   #    with brackets [:alpha:] may have already been made into something else by the
   #    compiler.
   #    fix: for grapheme clusters and more complete classes
   #   */
   sub matchClass {
     my ($self, $text, $class) = @_;
     # empty text should never match a class.
     return 0 if length($text) == 0;

     # a character type class like [:alpha:]
     if ($class =~ /^\[:(.+):\]$/ && $class ne "[:]" && $class ne "[::]") {
       my $charType = $1;
       my @chars = split //, $text;
       if ($charType eq "alnum") { return all { /\w/ } @chars; }
       if ($charType eq "alpha") { return all { /[[:alpha:]]/ } @chars; }
       if ($charType eq "ascii") { return all { /[[:ascii:]]/ } @chars; }
       if ($charType eq "word") { return all { /[\w_]/ } @chars; }
       if ($charType eq "blank") { return all { /[\s\t]/ } @chars; }
       if ($charType eq "control") { return all { /[[:cntrl:]]/ } @chars; }
       if ($charType eq "cntrl") { return all { /[[:cntrl:]]/ } @chars; }
       if ($charType eq "digit") { return all { /\d/ } @chars; }
       if ($charType eq "graph") { return all { /[[:graph:]]/ } @chars; }
       if ($charType eq "lower") { return all { /[[:lower:]]/ } @chars; }
       if ($charType eq "upper") { return all { /[[:upper:]]/ } @chars; }
       if ($charType eq "print") { return all { /[[:print:]]/ && $_ ne ' ' } @chars; }
       if ($charType eq "punct") { return all { /[[:punct:]]/ } @chars; }
       if ($charType eq "space") { return all { /\s/ } @chars; }
       if ($charType eq "xdigit") { return all { /[0-9a-fA-F]/ } @chars; }
       print STDERR "unrecognised char class in translated nom script\n";
       print STDERR "$charType\n";
       exit 1;
       return 0;
     }

     # get a vector of chars except the first and last which are [ and ]
     my @charList = split //, substr($class, 1, length($class) - 2);
     # is a range class like [a-z]
     if (scalar(@charList) == 3 && $charList[1] eq '-') {
       my ($start, undef, $end) = @charList;
       my @chars = split //, $text;
       return all { $_ ge $start && $_ le $end } @chars;
     }

     # list class like: [xyzabc]
     # check if all characters in text are in the class list
     my @textChars = split //, $text;
     return all { grep { $_ eq $textChars[$_] } @charList } 0 .. $#textChars;
     return 0;
     # also must handle eg [:alpha:] This can be done with char methods
   }

   # /* a plain text string replace function on the workspace */
   sub replace {
     my ($self, $old, $new) = @_;
     return if length($old) == 0;
     return if $old eq $new;

     my $text = $self->{work};
     $text =~ s/$old/$new/g;
     $self->{work} = $text;
   }

   #  make the workspace capital case 
   sub capitalise {
     my ($self) = @_;
     my $result = "";
     my $capitalize_next = 1;
     for my $c (split //, $self->{work}) {
       if ($c =~ /[[:alpha:]]/) {
         if ($capitalize_next) {
           $result .= uc $c;
           $capitalize_next = 0;
         } else {
           $result .= lc $c;
         }
       } else {
         $result .= $c;
         if ($c eq "\n" || $c eq " " || $c eq "." || $c eq "?" || $c eq "!") {
           $capitalize_next = 1;
         }
       }
     }
     $self->{work} = $result;
   }

   #  print the internal state of the pep/nom parsing machine. This
   #    is handy for debugging 
   sub printState {
     my $self = shift;
     print 
       "\n--------- Machine State ------------- \n",
       "(input buffer:", join(",", @{$self->{inputBuffer}}), ")\n",
       "Stack[", join(",", @{$self->{stack}}), "]", 
       " Work[", $self->{work}, "]",
       " Peep[", $self->{peep}, "]\n",
       "Acc:", $self->{accumulator},
       " EOF:", $self->{eof} eq true? "true":"false", 
       " Esc:", $self->{escape},
       " Delim:", $self->{delimiter}, 
       " Chars:", $self->{charsRead}, " ";
     print "Lines:", $self->{linesRead}, "\n";
     print "-------------- Tape ----------------- \n";
     print "Tape Size: ", $self->{tapeLength}, "\n";
     my $start = 0;
     if ($self->{cell} > 3) {
       $start = $self->{cell} - 4;
     }
     my $end = $self->{cell} + 4;
     for (my $ii = $start; $ii <= $end; $ii++) {
       print "    $ii";
       if ($ii == $self->{cell}) { print "> ["; }
       else { print "  ["; }
       if (defined $self->{tape}[$ii]) {
         print $self->{tape}[$ii], "]\n";
       } else {
         print "]\n";
       }
     }
   }

   # /* makes the machine read from a string also needs to prime
   #    the "peep" value. */
   sub setStringInput {
     my ($self, $text) = @_;
     $self->{inputType} = "string";
     $self->{inputBuffer} = [];
     $self->fillInputBuffer($text);
     # prime the "peep" with the 1st char
     $self->{peep} = ""; $self->readChar(); $self->{charsRead} = 0;
   }

   # /* makes the machine write to a string */
   sub setStringOutput {
     my ($self) = @_;
     $self->{sinkType} = "string";
   }

   # /* parse/translate from a string and return the translated
   #    string */
   sub parseString {
     my ($self, $input) = @_;
     $self->setStringInput($input);
     $self->{sinkType} = "string";
     $self->parse();
     return $self->{outputBuffer};
   }

   # /* makes the machine read from a file stream line by line,
   #    not from stdin */
   sub setFileStreamInput {
     my ($self, $filename) = @_;
     unless (checkTextFile($filename)) { exit 1; }
     open my $fh, '<', $filename or 
       die "Cannot open file '$filename' for reading: $!";
     $self->{input} = IO::BufReader->new($fh);
     $self->{inputType} = "filestream";
     # prime the peep, the read() method should refill the
     # inputChars or inputBuffer if it is empty.
     $self->{peep} = ""; $self->readChar(); $self->{charsRead} = 0;
   }

   # /* makes the machine read from a file line buffer array
   #    but this also needs to prime the "peep" value */
   sub setFileInput {
     my ($self, $filename) = @_;
     open my $fh, '<', $filename or 
       die "Could not open file '$filename' for reading: $!";
     my $text = do { local $/ = undef; <$fh> };
     close $fh;
     # there is an extra newline being added, I dont know where.
     if ($text =~ s/\n$//) {}
     $self->{inputType} = "file";
     $self->{inputBuffer} = [];
     $self->fillInputBuffer($text);
     # prime the "peep" with the 1st char
     $self->{peep} = ""; $self->readChar(); $self->{charsRead} = 0;
   }

   # /* makes the machine write to a file not to stdout (the default) */
   sub setFileOutput {
     my ($self, $filename) = @_;
     unless (checkTextFile($filename)) { exit 1; }
     open my $fh, '>', $filename or die "Cannot create file '$filename' for writing: $!";
     $self->{output} = IO::BufWriter->new($fh);
     $self->{sinkType} = "file";
   }

   # parse from a file and put result in file
   sub parseFile {
     my ($self, $inputFile, $outputFile) = @_;
     $self->setFileInput($inputFile);
     $self->setFileOutput($outputFile);
     $self->parse();
   }

   # /* parse from any stream, fix handle */
   # /*
   # sub parseStream {
   #   my ($self, $reader) = @_;
   #   # $self->{input} = $reader; # Needs proper handling of reader type
   #   $self->parse();
   # }
   # */

   # /* this is the default parsing mode. If no other is selected
   #    it will be activated when parse() is first called. I activate it when
   #    parse is 1st called because otherwise it will block if no stdin
   #    is availabel. It also sets stdout as output */
   sub setStandardInput {
     my $self = shift;
     $self->{inputType} = "stdin";
     $self->{sinkType} = "stdout";

     # unused because all input read at once
     # $self->{input} = \*STDIN;
     # $self->{output} = \*STDOUT;

     # read the whole of stdin into the inputBuffer
     $self->{inputBuffer} = [];
     my $buffer = "";
     #  my $stdin = join("", <STDIN>);
     while (<STDIN>) { $buffer .= $_; }
     $self->fillInputBuffer($buffer);
     # prime the "peep" with the 1st char, but this doesnt count as
     # a character read.
     $self->{peep} = ""; $self->readChar(); $self->{charsRead} = 0;
   }

   # /** parse and translate the input stdin/file/string */
   sub parse {
     my $self = shift;
     if ($self->{inputType} eq "unset") {
       $self->setStandardInput();
     }

     # test code
     while (true) {
       $self->readChar();
       $self->{"output"}->print($self->{"work"});
       $self->{"output"}->print($self->{"work"});
       $self->printState();
       $self->{'work'} = '';        # clear
     }
     # -----------
     # translated nom code goes here
     # -----------
     # close open files here? yes. use break, not return
     my $sink_type = $self->{sinkType};
     if ($sink_type eq "file") {
       $self->{output}->flush() or die "Error flushing output file: $!";
     } elsif ($sink_type eq "stdout") {
       # STDOUT is typically flushed automatically
     } elsif ($sink_type eq "string") {
       # Output is in the buffer
     } else {
       print STDERR "unsupported output type: ", $sink_type, "\n";
     }
   } # sub parse


 sub printHelp {
   print <<EOF;

   Nom script translated to perl by www.nomlang.org/tr/ script 
   usage:
         echo "..sometext.." | ./script
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

EOF

 }

 # display a message about a missing argument to the translated
 #    script 
 sub missingArgument {
   print "Missing argument.\n";
   printHelp();
   exit 1;
 }

 # display a message if an command line option is repeated
 sub duplicateSwitch {
   print "Duplicate switch found.\n";
   printHelp();
   exit 1;
 }

 sub checkTextFile {
   my ($filepath) = @_;
   eval {
     open my $fh, '<', $filepath;
     close $fh;
     return 1;
   };
   if ($@) {
     if ($@ =~ /No such file or directory/) {
       print "File [$filepath] not found.\n";
     } elsif ($@ =~ /Permission denied/) {
       print "Permission denied to read file [$filepath]\n";
     } else {
       print "Error opening file $filepath: $@";
     }
     return 0;
   }
   return 1;
 }

package main;

  my $mm = Machine->new();
  my $input = "";
  my $filename = "";

  GetOptions (
    'file|f=s'      => \$filename,
    'input|i=s'     => \$input,
    'filetest|F=s'  => sub {
      my ($opt_name, $value) = @_;
      if ($value) {
        if ($filename ne '') { duplicateSwitch(); }
        if (!checkTextFile($value)) { printHelp(); exit 1; }
        $mm->parseFile($value, "out.txt");
        my $output = do {
          local $/ = undef;
          open my $fh, '<', "out.txt" or die "Could not open out.txt: $!";
          <$fh>;
        };
        print $output;
        exit 0;
      } else {
        missingArgument();
      }
    },
    'filestream|S=s' => sub {
      my ($opt_name, $value) = @_;
      if ($value) {
        if ($filename ne '') { duplicateSwitch(); }
        if (!checkTextFile($value)) { printHelp(); exit 1; }
        $mm->setFileStreamInput($value);
      } else {
        missingArgument();
      }
    },
    'inputtest|I=s' => sub {
      my ($opt_name, $value) = @_;
      if ($value) {
        if ($input ne '') { duplicateSwitch(); }
        my $text = $mm->parseString($value);
        print $text;
        exit 0;
      } else {
        missingArgument();
      }
    },
    'help|h'        => sub { printHelp(); exit 0; },
  ) or die "Error in command line arguments\n";

  if ($input ne '' && $filename ne '') {
    print <<EOF;

    Either use the --file/--filetest options or the --input/--inputtest
    options, not both

EOF
    printHelp();
    exit 0;
  }

  $mm->parse();

  1;
