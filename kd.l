%option yylineno

%{
#include <stdio.h>

#include "kd.tab.h"

#define YY_DECL int yylex()

#define myprintf printf

void printReg (int num) { printf (">>> REG r%d\n", num); }
void printInstr (const char* instr) { printf (">>> INSTR %s\n", instr); }

#define YY_INPUT(buf,result,max_size) { result = genGetChar (buf); }

%}

DIGIT    [0-9]
ID			 [a-zA-Z_][a-zA-Z0-9_]*

%%

[ \t\r]          ;
\n               { return '\n'; }
","              { return ','; }
":"              { return ':'; }
"."              { return '.'; }

;.* ;
#.* ;

{DIGIT}+         { yylval.val = strtol (yytext, 0, 10); myprintf (">>> NUM %d\n", yylval.val); return NUM; }
0b[01]+          { yylval.val = strtol (yytext + 2, 0, 2); myprintf (">>> NUM %d\n", yylval.val); return NUM; }
0x[0-9a-f]+      { yylval.val = strtol (yytext + 2, 0, 16); myprintf (">>> NUM %d\n", yylval.val); return NUM; }

"\""[^\"]*"\""   { yylval.str = (char*)malloc (strlen (yytext) - 1);
									 yytext[strlen (yytext) - 1] = 0;
									 strcpy ((char*)yylval.str, yytext + 1);
									 printf (">>> STRING |%s|\n", yylval.str);
									 return STRING; }

"X"      { printInstr (yytext); return REG_X; }
"X+"     { printInstr (yytext); return REG_XP; }
"-X"     { printInstr (yytext); return REG_MX; }
"Y"      { printInstr (yytext); return REG_Y; }
"-Y"     { printInstr (yytext); return REG_MY; }
"Z"      { printInstr (yytext); return REG_Z; }
"-Z"     { printInstr (yytext); return REG_MZ; }

"BREAK"  { yylval.str = strdup (yytext); printInstr (yytext); return BREAK; }
"SPM"    { yylval.str = strdup (yytext); printInstr (yytext); return SPM; }
"ADD"    { yylval.str = strdup (yytext); printInstr (yytext); return ADD; }
"ADC"    { yylval.str = strdup (yytext); printInstr (yytext); return ADC; }
"ADIW"   { yylval.str = strdup (yytext); printInstr (yytext); return ADIW; }
"SUB"    { yylval.str = strdup (yytext); printInstr (yytext); return SUB; }
"SUBI"   { yylval.str = strdup (yytext); printInstr (yytext); return SUBI; }
"SBC"    { yylval.str = strdup (yytext); printInstr (yytext); return SBC; }
"SBCI"   { yylval.str = strdup (yytext); printInstr (yytext); return SBCI; }
"SBIW"   { yylval.str = strdup (yytext); printInstr (yytext); return SBIW; }
"AND"    { yylval.str = strdup (yytext); printInstr (yytext); return AND; }
"ANDI"   { yylval.str = strdup (yytext); printInstr (yytext); return ANDI; }
"OR"     { yylval.str = strdup (yytext); printInstr (yytext); return OR; }
"ORI"    { yylval.str = strdup (yytext); printInstr (yytext); return ORI; }
"EOR"    { yylval.str = strdup (yytext); printInstr (yytext); return EOR; }
"COM"    { yylval.str = strdup (yytext); printInstr (yytext); return COM; }
"NEG"    { yylval.str = strdup (yytext); printInstr (yytext); return NEG; }
"SBR"    { yylval.str = strdup (yytext); printInstr (yytext); return SBR; }
"CBR"    { yylval.str = strdup (yytext); printInstr (yytext); return CBR; }
"INC"    { yylval.str = strdup (yytext); printInstr (yytext); return INC; }
"DEC"    { yylval.str = strdup (yytext); printInstr (yytext); return DEC; }
"TST"    { yylval.str = strdup (yytext); printInstr (yytext); return TST; }
"CLR"    { yylval.str = strdup (yytext); printInstr (yytext); return CLR; }
"SER"    { yylval.str = strdup (yytext); printInstr (yytext); return SER; }
"MUL"    { yylval.str = strdup (yytext); printInstr (yytext); return MUL; }
"MULS"   { yylval.str = strdup (yytext); printInstr (yytext); return MULS; }
"MULSU"  { yylval.str = strdup (yytext); printInstr (yytext); return MULSU; }
"RJMP"   { yylval.str = strdup (yytext); printInstr (yytext); return RJMP; }
"IJMP"   { yylval.str = strdup (yytext); printInstr (yytext); return IJMP; }
"JMP"    { yylval.str = strdup (yytext); printInstr (yytext); return JMP; }
"RCALL"  { yylval.str = strdup (yytext); printInstr (yytext); return RCALL; }
"ICALL"  { yylval.str = strdup (yytext); printInstr (yytext); return ICALL; }
"CALL"   { yylval.str = strdup (yytext); printInstr (yytext); return CALL; }
"RET"    { yylval.str = strdup (yytext); printInstr (yytext); return RET; }
"RETI"   { yylval.str = strdup (yytext); printInstr (yytext); return RETI; }
"CPSE"   { yylval.str = strdup (yytext); printInstr (yytext); return CPSE; }
"CP"     { yylval.str = strdup (yytext); printInstr (yytext); return CP; }
"CPC"    { yylval.str = strdup (yytext); printInstr (yytext); return CPC; }
"CPI"    { yylval.str = strdup (yytext); printInstr (yytext); return CPI; }
"SBRC"   { yylval.str = strdup (yytext); printInstr (yytext); return SBRC; }
"SBRS"   { yylval.str = strdup (yytext); printInstr (yytext); return SBRS; }
"SBIC"   { yylval.str = strdup (yytext); printInstr (yytext); return SBIC; }
"SBIS"   { yylval.str = strdup (yytext); printInstr (yytext); return SBIS; }
"BRBS"   { yylval.str = strdup (yytext); printInstr (yytext); return BRBS; }
"BRBC"   { yylval.str = strdup (yytext); printInstr (yytext); return BRBC; }
"BREQ"   { yylval.str = strdup (yytext); printInstr (yytext); return BREQ; }
"BRNE"   { yylval.str = strdup (yytext); printInstr (yytext); return BRNE; }
"BRCS"   { yylval.str = strdup (yytext); printInstr (yytext); return BRCS; }
"BRCC"   { yylval.str = strdup (yytext); printInstr (yytext); return BRCC; }
"BRSH"   { yylval.str = strdup (yytext); printInstr (yytext); return BRSH; }
"BRLO"   { yylval.str = strdup (yytext); printInstr (yytext); return BRLO; }
"BRMI"   { yylval.str = strdup (yytext); printInstr (yytext); return BRMI; }
"BRPL"   { yylval.str = strdup (yytext); printInstr (yytext); return BRPL; }
"BRGE"   { yylval.str = strdup (yytext); printInstr (yytext); return BRGE; }
"BRLT"   { yylval.str = strdup (yytext); printInstr (yytext); return BRLT; }
"BRHS"   { yylval.str = strdup (yytext); printInstr (yytext); return BRHS; }
"BRHC"   { yylval.str = strdup (yytext); printInstr (yytext); return BRHC; }
"BRTS"   { yylval.str = strdup (yytext); printInstr (yytext); return BRTS; }
"BRTC"   { yylval.str = strdup (yytext); printInstr (yytext); return BRTC; }
"BRVS"   { yylval.str = strdup (yytext); printInstr (yytext); return BRVS; }
"BRVC"   { yylval.str = strdup (yytext); printInstr (yytext); return BRVC; }
"BRIE"   { yylval.str = strdup (yytext); printInstr (yytext); return BRIE; }
"BRID"   { yylval.str = strdup (yytext); printInstr (yytext); return BRID; }
"MOV"    { yylval.str = strdup (yytext); printInstr (yytext); return MOV; }
"LDI"    { yylval.str = strdup (yytext); printInstr (yytext); return LDI; }
"LDS"    { yylval.str = strdup (yytext); printInstr (yytext); return LDS; }
"LD"     { yylval.str = strdup (yytext); printInstr (yytext); return LD; }
"LDD"    { yylval.str = strdup (yytext); printInstr (yytext); return LDD; }
"STS"    { yylval.str = strdup (yytext); printInstr (yytext); return STS; }
"ST"     { yylval.str = strdup (yytext); printInstr (yytext); return ST; }
"STD"    { yylval.str = strdup (yytext); printInstr (yytext); return STD; }
"LPM"    { yylval.str = strdup (yytext); printInstr (yytext); return LPM; }
"IN"     { yylval.str = strdup (yytext); printInstr (yytext); return IN; }
"OUT"    { yylval.str = strdup (yytext); printInstr (yytext); return OUT; }
"PUSH"   { yylval.str = strdup (yytext); printInstr (yytext); return PUSH; }
"POP"    { yylval.str = strdup (yytext); printInstr (yytext); return POP; }
"LSL"    { yylval.str = strdup (yytext); printInstr (yytext); return LSL; }
"LSR"    { yylval.str = strdup (yytext); printInstr (yytext); return LSR; }
"ROL"    { yylval.str = strdup (yytext); printInstr (yytext); return ROL; }
"ROR"    { yylval.str = strdup (yytext); printInstr (yytext); return ROR; }
"ASR"    { yylval.str = strdup (yytext); printInstr (yytext); return ASR; }
"SWAP"   { yylval.str = strdup (yytext); printInstr (yytext); return SWAP; }
"BSET"   { yylval.str = strdup (yytext); printInstr (yytext); return BSET; }
"BCLR"   { yylval.str = strdup (yytext); printInstr (yytext); return BCLR; }
"SBI"    { yylval.str = strdup (yytext); printInstr (yytext); return SBI; }
"CBI"    { yylval.str = strdup (yytext); printInstr (yytext); return CBI; }
"BST"    { yylval.str = strdup (yytext); printInstr (yytext); return BST; }
"BLD"    { yylval.str = strdup (yytext); printInstr (yytext); return BLD; }
"SEC"    { yylval.str = strdup (yytext); printInstr (yytext); return SEC; }
"CLC"    { yylval.str = strdup (yytext); printInstr (yytext); return CLC; }
"SEN"    { yylval.str = strdup (yytext); printInstr (yytext); return SEN; }
"CLN"    { yylval.str = strdup (yytext); printInstr (yytext); return CLN; }
"SEZ"    { yylval.str = strdup (yytext); printInstr (yytext); return SEZ; }
"CLZ"    { yylval.str = strdup (yytext); printInstr (yytext); return CLZ; }
"SEI"    { yylval.str = strdup (yytext); printInstr (yytext); return SEI; }
"CLI"    { yylval.str = strdup (yytext); printInstr (yytext); return CLI; }
"SES"    { yylval.str = strdup (yytext); printInstr (yytext); return SES; }
"CLS"    { yylval.str = strdup (yytext); printInstr (yytext); return CLS; }
"SEV"    { yylval.str = strdup (yytext); printInstr (yytext); return SEV; }
"CLV"    { yylval.str = strdup (yytext); printInstr (yytext); return CLV; }
"SET"    { yylval.str = strdup (yytext); printInstr (yytext); return SET; }
"CLT"    { yylval.str = strdup (yytext); printInstr (yytext); return CLT; }
"SEH"    { yylval.str = strdup (yytext); printInstr (yytext); return SEH; }
"NOP"    { yylval.str = strdup (yytext); printInstr (yytext); return NOP; }
"CLH"    { yylval.str = strdup (yytext); printInstr (yytext); return CLH; }
"SLEEP"  { yylval.str = strdup (yytext); printInstr (yytext); return SLEEP; }
"WDR"    { yylval.str = strdup (yytext); printInstr (yytext); return WDR; }

"r"[0-9]     { yylval.val = strtol (yytext + 1, 0, 10); printReg (yylval.val); return REGISTER; }
"r"[12][0-9] { yylval.val = strtol (yytext + 1, 0, 10); printReg (yylval.val); return REGISTER; }
"r3"[01]     { yylval.val = strtol (yytext + 1, 0, 10); printReg (yylval.val); return REGISTER; }

".equ"       { printf (">>> EQU\n"); return D_EQU; }
".device"    { printf (">>> DEVICE\n"); return D_DEVICE; }
".def"       { printf (">>> DEF\n"); return D_DEF; }
".include"   { printf (">>> INCLUDE\n"); return D_INCLUDE; }

{ID}+        { yylval.str = strdup (yytext); myprintf (">>> IDENT %s\n", yylval.str); return IDENT; }

"="          { myprintf (">>> =\n"); return '='; }
"+"          { myprintf (">>> +\n"); return '+'; }
"-"          { myprintf (">>> -\n"); return '-'; }
"*"          { myprintf (">>> *\n"); return '*'; }
"/"          { myprintf (">>> /\n"); return '/'; }

"("          { myprintf (">>> (\n"); return '('; }
")"          { myprintf (">>> )\n"); return ')'; }
"<<"         { myprintf (">>> <<\n"); return ARITHM_SL; }
">>"         { myprintf (">>> >>\n"); return ARITHM_SR; }
"|"          { myprintf (">>> |\n"); return '|'; }
"&"          { myprintf (">>> &\n"); return '&'; }
"^"          { myprintf (">>> ^\n"); return '^'; }

<<EOF>>      { static int once = 0; return once++ ? 0 : '\n'; }

.            { return yytext[0]; }

%%
