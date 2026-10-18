#include <stdlib.h>
#include <unistd.h>
int main(){volatile char *p=malloc(32*1024*1024);if(!p)return 1;for(size_t i=0;i<32*1024*1024;i+=4096)p[i]=1;usleep(20000);return p[0]!=1;}
