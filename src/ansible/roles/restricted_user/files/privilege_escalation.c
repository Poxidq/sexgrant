#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void read_flag() {
    FILE *f = fopen("/root/flag.txt", "r");
    if (f) {
        char flag[100];
        fgets(flag, sizeof(flag), f);
        printf("Congratulations! Flag: %s\n", flag);
        fclose(f);
    }
}

int main(int argc, char *argv[]) {
    if (geteuid() == 0) {
        read_flag();
    } else {
        printf("Not running as root!\n");
    }
    return 0;
}