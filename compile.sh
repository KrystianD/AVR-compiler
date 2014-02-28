#!/bin/bash
bison -d kd.y && flex -i kd.l && g++ kd.tab.c lex.yy.c generator.cpp -lfl && ./a.out inp.asm out.bin && avr-objdump -D out.bin -m avr -b binary
