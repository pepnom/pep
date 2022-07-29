

#include <stdio.h>

  //int main() {
  int main (int argc, char *argv[]) {

    char word[128];
    FILE * fp = stdin;
    while (fscanf(fp, "%127s", word) == 1) {
       printf("%s\n", word);
    }

  }

