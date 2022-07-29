#include <stdio.h>
#include <string.h>


typedef struct
{
  int type;
  char value[100];
} Token;


void printToken(Token t);

void main()
{
  Token tt;
  strcpy(tt.value, "cadaques");
  printToken(tt);
  int c, nc;
  nc = 0;
  c = getchar();
  while (c != EOF)
  {
    nc++;
    c = getchar();
  }
  printf("number of chars in is %d", nc);
}

void printToken(Token t)
{
  printf("token.value = %s", t.value);
}
