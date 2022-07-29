@echo off


if "%2"=="" goto END
echo cd /home/groups/b/bu/bumble/htdocs/ > junk.txt
echo cd %3 >> junk.txt
echo put %2 >> junk.txt
echo quit >> junk.txt

@echo on
psftp -b junk.txt -pw %1 matth3wbishop@bumble.sf.net
@echo off

:END

 echo .
 echo usage: ub [password] [file] [subdir]
 echo .
 echo where
 echo  [password] is the password for the bumble.sf.net server
 echo  [file] is the file to upload
 echo  [subdir] is the subdirectory on the server to place the file in
 echo .
 echo notes:
 echo  by default the file is uploaded the web directory
 echo  of the bumble server. A subdirectory of this directory of
 echo  this web directory can be specified in the 3rd parameter
 echo  
