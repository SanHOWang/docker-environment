#include <stdio.h>

int main() {
    printf("Size of char*: %lu bytes\n", sizeof(char*));
    printf("Size of int*: %lu bytes\n", sizeof(int*));
    printf("Size of float*: %lu bytes\n", sizeof(float*));
    printf("Size of double*: %lu bytes\n", sizeof(double*));
    printf("Size of void*: %lu bytes\n", sizeof(void*));
    printf("Size of int** (pointer to pointer): %lu bytes\n", sizeof(int**));
    printf("Size of function pointer: %lu bytes\n", sizeof(void (*)()));
    return 0;
}
