#include<stdlib.h>
#include<stdio.h>
#include<stdint.h>

extern int64_t function(int64_t *argument);

void printArray(char* msg, int64_t* a) {
  for (; *a; ++a) {
    printf("%s%lld", msg, *a);
    msg = ", ";
  }
  printf("\n");
}

int main() {
  int64_t a[] = { 5, 3, 6, 8, 2, 10, 11, 9, 1, 4, 7, 0 };
  printArray("Input: ", a);
  printf("Output: %lld\n", function(a));

  int64_t b[] = { 45, 23, 66, 18, 21, 10, 31, 75, 0 };
  printArray("Input: ", b);
  printf("Output: %lld\n", function(b));

  int64_t c[] = { -45, 23, -21, 10, 75, -90, 0 };
  printArray("Input: ", c);
  printf("Output: %lld\n", function(c));

  printf("\n");
  return 0;
}
