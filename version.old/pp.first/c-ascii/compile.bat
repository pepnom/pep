
@echo off
rem This batch script compiles the c source file
rem file.c using the tinyc compiler
                                          
\tinycc\tcc\tcc -I\tinycc\include -L\tinycc\lib %1
