%{
#include <math.h>
#include <ctype.h>
#include <stdio.h>
#include <map>
#include <string>

#define COMMA_ERROR "\",\" expected"
#define INSTR_ERROR "Instruction expected"
#define REGISTER_ERROR "Register expected"
#define EXPRESSION_ERROR "Expression expected"
#define COLON_ERROR "\":\" expected"
#define PLUS_ERROR "\"+\" expected"
#define EQUALS_ERROR "\"=\" expected"
#define IDENT_ERROR "Identifier expected"
#define STRING_ERROR "String expected"
#define REG_ST_LD_ERROR "Register (X,X+,-X,Y,Y+,-Y,Z,Z+,-Z) expected"
#define STD_LDD_ERROR "Register (Y+,Z+) expected"

using namespace std;

map<string,int> defines;
map<string,int> regDefs;

int yylex (void);
void yyerror (char const *);



%}

%code requires {
#include "generator.h"
}

%union {
  const char* str;
  int val;
  struct InstrInfo info;
}
%token <val> NUM
%token <str> INSTR
%token <str> LABEL
%token <str> DIRECTIVE
%token <val> REGISTER
%token <str> IDENT
%token ARITHM_SL
%token ARITHM_SR
%token <str> STRING

%token D_EQU D_DEVICE D_DEF D_INCLUDE

%token <str> ADD ADC BREAK ADIW SUB SUBI SBC SBCI SBIW AND ANDI OR ORI EOR COM NEG SBR CBR INC DEC TST CLR SER MUL MULS MULSU RJMP IJMP
%token <str> JMP RCALL ICALL CALL RET RETI CPSE CP CPC CPI SBRC SBRS SBIC SBIS BRBS BRBC BREQ BRNE BRCS BRCC BRSH BRLO BRMI BRPL
%token <str> BRGE BRLT BRHS BRHC BRTS BRTC BRVS BRVC BRIE BRID MOV LDI LDS LD LDD STS ST STD LPM IN OUT PUSH POP LSL LSR ROL ROR
%token <str> ASR SWAP BSET BCLR SBI CBI BST BLD SEC CLC SEN CLN SEZ CLZ SEI CLI SES CLS SEV CLV SET CLT SEH NOP CLH SLEEP WDR SPM
%token REG_X REG_XP REG_MX
%token REG_Y REG_YP REG_MY
%token REG_Z REG_ZP REG_MZ
%type <val> expr

%left '+' '-'
%left '*' '/'
%left '^' '&' '|'
%left ARITHM_SL ARITHM_SR

%%

input:
    /* empty */
  | input line
  ;
 
 line:
    '\n'
  | IDENT ':' '\n'                 { printf ("LABEL %s\n", $1); genSetLabel ($1); }
  | IDENT error                    { yyerror (COLON_ERROR); return -1; }
  | IDENT ':' statement '\n'       { printf ("LABEL %s\n", $1); genSetLabel ($1); }
  | statement '\n'
  | directive '\n'
  | error                          { yyerror ("label, statement or direcrive expected"); return -1; }
  ;
 
 directive:
    D_EQU IDENT '=' expr           { printf ("EQU %s=%d\n", $2, $4); defines[$2] = $4; }
  | D_EQU IDENT '=' error          { yyerror (EXPRESSION_ERROR); return -1; }
  | D_EQU IDENT error              { yyerror (EQUALS_ERROR); return -1; }
  | D_DEF IDENT '=' REGISTER       { printf ("DEF %s=r%d\n", $2, $4); regDefs[$2] = $4; }
  | D_DEF IDENT '=' error          { yyerror (REGISTER_ERROR); return -1; }
  | D_DEF IDENT error              { yyerror (EQUALS_ERROR); return -1; }
  | D_DEVICE IDENT                 { printf ("DEVICE %s\n", $2); }
  | D_DEVICE error                 { yyerror (IDENT_ERROR); return -1; }
  | D_INCLUDE STRING               { printf ("INCLUDE %s\n", $2); genIncludeFile ($2); }
  | D_INCLUDE error                { yyerror (STRING_ERROR); return -1; }
  ;
 
 statement:    
    BREAK            { outputInstr16 (0x9598); }
  | CLC              { outputInstr16 (0x9488); }
  | CLH              { outputInstr16 (0x94D8); }
  | CLI              { outputInstr16 (0x94F8); }
  | CLN              { outputInstr16 (0x94A8); }
  | CLS              { outputInstr16 (0x94C8); }
  | CLT              { outputInstr16 (0x94E8); }
  | CLV              { outputInstr16 (0x94B8); }
  | CLZ              { outputInstr16 (0x9498); }
  | ICALL            { outputInstr16 (0x9509); }
  | IJMP             { outputInstr16 (0x9409); }
  | NOP              { outputInstr16 (0x0000); }
  | RET              { outputInstr16 (0x9508); }
  | RETI             { outputInstr16 (0x9518); }
  | SEC              { outputInstr16 (0x9408); }
  | SEH              { outputInstr16 (0x9458); }
  | SEI              { outputInstr16 (0x9478); }
  | SEN              { outputInstr16 (0x9428); }
  | SES              { outputInstr16 (0x9448); }
  | SET              { outputInstr16 (0x9468); }
  | SEV              { outputInstr16 (0x9438); }
  | SEZ              { outputInstr16 (0x9418); }
  | SLEEP            { outputInstr16 (0x9588); }
  | WDR              { outputInstr16 (0x95A8); }
  | SPM              { outputInstr16 (0x95e8); }
  | SPM REG_Z '+'    { outputInstr16 (0x95f8); }
  // | EICALL   { outputInstr16 (0x9519); }
  // | EIJMP    { outputInstr16 (0x9419); }

  // 1num
  | ASR REGISTER     { outputInstr16 (0x9405 | ($2 << 4)); }
  | COM REGISTER     { outputInstr16 (0x9400 | ($2 << 4)); }
  | DEC REGISTER     { outputInstr16 (0x940A | ($2 << 4)); }
  | INC REGISTER     { outputInstr16 (0x9403 | ($2 << 4)); }
  | LSR REGISTER     { outputInstr16 (0x9406 | ($2 << 4)); }
  | NEG REGISTER     { outputInstr16 (0x9401 | ($2 << 4)); }
  | POP REGISTER     { outputInstr16 (0x900F | ($2 << 4)); }
  | PUSH REGISTER    { outputInstr16 (0x920F | ($2 << 4)); }
  | ROR REGISTER     { outputInstr16 (0x9407 | ($2 << 4)); }
  | SWAP REGISTER    { outputInstr16 (0x9402 | ($2 << 4)); }
  | CLR REGISTER     { outputInstr16 (0x2400 | packRdRr ($2, $2)); }
  | LSL REGISTER     { outputInstr16 (0x0C00 | packRdRr ($2, $2)); }
  | ROL REGISTER     { outputInstr16 (0x1C00 | packRdRr ($2, $2)); }
  | TST REGISTER     { outputInstr16 (0x2000 | packRdRr ($2, $2)); }
  | SER REGISTER     { outputInstr16 (0xEF0F | (($2-16) << 4)); }
  | BCLR expr        { outputInstr16 (0x9488 | ($2 << 4)); }
  | BSET expr        { outputInstr16 (0x9408 | ($2 << 4)); }
  | BRCC expr        { genAppendPending (0xF400, $2, 3, 7); }
  | BRCS expr        { genAppendPending (0xF000, $2, 3, 7); }
  | BREQ expr        { genAppendPending (0xF001, $2, 3, 7); }
  | BRGE expr        { genAppendPending (0xF404, $2, 3, 7); }
  | BRHC expr        { genAppendPending (0xF405, $2, 3, 7); }
  | BRHS expr        { genAppendPending (0xF005, $2, 3, 7); }
  | BRID expr        { genAppendPending (0xF407, $2, 3, 7); }
  | BRIE expr        { genAppendPending (0xF007, $2, 3, 7); }
  | BRLO expr        { genAppendPending (0xF000, $2, 3, 7); }
  | BRLT expr        { genAppendPending (0xF004, $2, 3, 7); }
  | BRMI expr        { genAppendPending (0xF002, $2, 3, 7); }
  | BRNE expr        { genAppendPending (0xF401, $2, 3, 7); }
  | BRPL expr        { genAppendPending (0xF402, $2, 3, 7); }
  | BRSH expr        { genAppendPending (0xF400, $2, 3, 7); }
  | BRTC expr        { genAppendPending (0xF406, $2, 3, 7); }
  | BRTS expr        { genAppendPending (0xF006, $2, 3, 7); }
  | BRVC expr        { genAppendPending (0xF403, $2, 3, 7); }
  | BRVS expr        { genAppendPending (0xF003, $2, 3, 7); }
  | RCALL expr       { genAppendPending (0xD000, $2, 0, 12); }
  | RJMP expr        { genAppendPending (0xC000, $2, 0, 12); }
  | CALL expr        { genAppendPending32 (0x940e, $2, 0, 16); }
  | JMP expr         { genAppendPending32 (0x940c, $2, 0, 16); }
  | ASR error        { yyerror (REGISTER_ERROR); return -1; }
  | COM error        { yyerror (REGISTER_ERROR); return -1; }
  | DEC error        { yyerror (REGISTER_ERROR); return -1; }
  | INC error        { yyerror (REGISTER_ERROR); return -1; }
  | LSR error        { yyerror (REGISTER_ERROR); return -1; }
  | NEG error        { yyerror (REGISTER_ERROR); return -1; }
  | POP error        { yyerror (REGISTER_ERROR); return -1; }
  | PUSH error       { yyerror (REGISTER_ERROR); return -1; }
  | ROR error        { yyerror (REGISTER_ERROR); return -1; }
  | SWAP error       { yyerror (REGISTER_ERROR); return -1; }
  | CLR error        { yyerror (REGISTER_ERROR); return -1; }
  | LSL error        { yyerror (REGISTER_ERROR); return -1; }
  | ROL error        { yyerror (REGISTER_ERROR); return -1; }
  | TST error        { yyerror (REGISTER_ERROR); return -1; }
  | SER error        { yyerror (REGISTER_ERROR); return -1; }
  | BCLR error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BSET error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRCC error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRCS error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BREQ error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRGE error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRHC error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRHS error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRID error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRIE error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRLO error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRLT error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRMI error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRNE error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRPL error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRSH error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRTC error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRTS error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRVC error       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRVS error       { yyerror (EXPRESSION_ERROR); return -1; }
  | RCALL error      { yyerror (EXPRESSION_ERROR); return -1; }
  | RJMP error       { yyerror (EXPRESSION_ERROR); return -1; }
  | CALL error       { yyerror (EXPRESSION_ERROR); return -1; }
  | JMP error        { yyerror (EXPRESSION_ERROR); return -1; }

  // 2reg
  | ADC REGISTER ',' REGISTER        { outputInstr16 (0x1C00 | packRdRr ($2, $4)); }
  | ADD REGISTER ',' REGISTER        { outputInstr16 (0x0C00 | packRdRr ($2, $4)); }
  | AND REGISTER ',' REGISTER        { outputInstr16 (0x2000 | packRdRr ($2, $4)); }
  | CPC REGISTER ',' REGISTER        { outputInstr16 (0x0400 | packRdRr ($2, $4)); }
  | CPSE REGISTER ',' REGISTER       { outputInstr16 (0x1000 | packRdRr ($2, $4)); }
  | EOR REGISTER ',' REGISTER        { outputInstr16 (0x2400 | packRdRr ($2, $4)); }
  | MOV REGISTER ',' REGISTER        { outputInstr16 (0x2C00 | packRdRr ($2, $4)); }
  | MUL REGISTER ',' REGISTER        { outputInstr16 (0x9C00 | packRdRr ($2, $4)); }
  | OR REGISTER ',' REGISTER         { outputInstr16 (0x2800 | packRdRr ($2, $4)); }
  | SBC REGISTER ',' REGISTER        { outputInstr16 (0x0800 | packRdRr ($2, $4)); }
  | SUB REGISTER ',' REGISTER        { outputInstr16 (0x1800 | packRdRr ($2, $4)); }
  | MULS REGISTER ',' REGISTER       { outputInstr16 (0x0200 | ((($2-16) & 0x0f) << 4) | (($4-16) & 0x0f)); }
  | MULSU REGISTER ',' REGISTER      { outputInstr16 (0x0300 | ((($2-16) & 0x07) << 4) | (($4-16) & 0x07)); }
  | CP REGISTER ',' REGISTER         { outputInstr16 (0x1400 | packRdRr ($2, $4)); }
  | ADC REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | ADD REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | AND REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | CPC REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | CPSE REGISTER ',' error          { yyerror (REGISTER_ERROR); return -1; }
  | EOR REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | MOV REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | MUL REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | OR REGISTER ',' error            { yyerror (REGISTER_ERROR); return -1; }
  | SBC REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | SUB REGISTER ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | MULS REGISTER ',' error          { yyerror (REGISTER_ERROR); return -1; }
  | MULSU REGISTER ',' error         { yyerror (REGISTER_ERROR); return -1; }
  | CP REGISTER ',' error            { yyerror (REGISTER_ERROR); return -1; }
  | ADC REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | ADD REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | AND REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | CPC REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | CPSE REGISTER error              { yyerror (COMMA_ERROR); return -1; }
  | EOR REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | MOV REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | MUL REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | OR REGISTER error                { yyerror (COMMA_ERROR); return -1; }
  | SBC REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | SUB REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | MULS REGISTER error              { yyerror (COMMA_ERROR); return -1; }
  | MULSU REGISTER error             { yyerror (COMMA_ERROR); return -1; }
  | CP REGISTER error                { yyerror (COMMA_ERROR); return -1; }
  | ADC error                        { yyerror (REGISTER_ERROR); return -1; }
  | ADD error                        { yyerror (REGISTER_ERROR); return -1; }
  | AND error                        { yyerror (REGISTER_ERROR); return -1; }
  | CPC error                        { yyerror (REGISTER_ERROR); return -1; }
  | CPSE error                       { yyerror (REGISTER_ERROR); return -1; }
  | EOR error                        { yyerror (REGISTER_ERROR); return -1; }
  | MOV error                        { yyerror (REGISTER_ERROR); return -1; }
  | MUL error                        { yyerror (REGISTER_ERROR); return -1; }
  | OR error                         { yyerror (REGISTER_ERROR); return -1; }
  | SBC error                        { yyerror (REGISTER_ERROR); return -1; }
  | SUB error                        { yyerror (REGISTER_ERROR); return -1; }
  | MULS error                       { yyerror (REGISTER_ERROR); return -1; }
  | MULSU error                      { yyerror (REGISTER_ERROR); return -1; }
  | CP error                         { yyerror (REGISTER_ERROR); return -1; }

  // regnum
  | ANDI REGISTER ',' expr           { outputInstr16 (0x7000 | packRd8K16 ($2, $4)); }
  | ADIW REGISTER ',' expr           { outputInstr16 (0x9600 | ((($2-24)/2) << 4) | (($4 & 0x30) << 2) | ($4 & 0x0f)); }
  | SBIW REGISTER ',' expr           { outputInstr16 (0x9700 | ((($2-24)/2) << 4) | (($4 & 0x30) << 2) | ($4 & 0x0f)); }
  | BLD REGISTER ',' expr            { outputInstr16 (0xF800 | ($2 << 4) | $4); }
  | BST REGISTER ',' expr            { outputInstr16 (0xFA00 | ($2 << 4) | $4); }
  | CBR REGISTER ',' expr            { outputInstr16 (0x7000 | packRd8K16 ($2, ~$4)); }
  | CPI REGISTER ',' expr            { outputInstr16 (0x3000 | packRd8K16 ($2, $4)); }
  | IN REGISTER ',' expr             { outputInstr16 (0xB000 | ($2 << 4) | (($4 & 0x30) << 5) | ($4 & 0x0f)); }
  | LDI REGISTER ',' expr            { outputInstr16 (0xE000 | packRd8K16 ($2, $4)); }
  | ORI REGISTER ',' expr            { outputInstr16 (0x6000 | packRd8K16 ($2, $4)); }
  | SBCI REGISTER ',' expr           { outputInstr16 (0x4000 | packRd8K16 ($2, $4)); }
  | SBR REGISTER ',' expr            { outputInstr16 (0x6000 | packRd8K16 ($2, $4)); }
  | SBRC REGISTER ',' expr           { outputInstr16 (0xFC00 | ($2 << 4) | $4); }
  | SBRS REGISTER ',' expr           { outputInstr16 (0xFE00 | ($2 << 4) | $4); }
  | SUBI REGISTER ',' expr           { outputInstr16 (0x5000 | packRd8K16 ($2, $4)); }
  | ANDI REGISTER ',' error          { yyerror (EXPRESSION_ERROR); return -1;}
  | BLD REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | BST REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | CBR REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | CPI REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | IN REGISTER ',' error            { yyerror (EXPRESSION_ERROR); return -1; }
  | LDI REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | ORI REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | SBCI REGISTER ',' error          { yyerror (EXPRESSION_ERROR); return -1; }
  | SBR REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | SBRC REGISTER ',' error          { yyerror (EXPRESSION_ERROR); return -1; }
  | SBRS REGISTER ',' error          { yyerror (EXPRESSION_ERROR); return -1; }
  | SUBI REGISTER ',' error          { yyerror (EXPRESSION_ERROR); return -1; }
  | ANDI REGISTER  error             { yyerror (COMMA_ERROR); return -1;}
  | BLD REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | BST REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | CBR REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | CPI REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | IN REGISTER  error               { yyerror (COMMA_ERROR); return -1; }
  | LDI REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | ORI REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | SBCI REGISTER  error             { yyerror (COMMA_ERROR); return -1; }
  | SBR REGISTER  error              { yyerror (COMMA_ERROR); return -1; }
  | SBRC REGISTER  error             { yyerror (COMMA_ERROR); return -1; }
  | SBRS REGISTER  error             { yyerror (COMMA_ERROR); return -1; }
  | SUBI REGISTER  error             { yyerror (COMMA_ERROR); return -1; }
  | ANDI error                       { yyerror (REGISTER_ERROR); return -1;}
  | BLD error                        { yyerror (REGISTER_ERROR); return -1; }
  | BST error                        { yyerror (REGISTER_ERROR); return -1; }
  | CBR error                        { yyerror (REGISTER_ERROR); return -1; }
  | CPI error                        { yyerror (REGISTER_ERROR); return -1; }
  | IN error                         { yyerror (REGISTER_ERROR); return -1; }
  | LDI error                        { yyerror (REGISTER_ERROR); return -1; }
  | ORI error                        { yyerror (REGISTER_ERROR); return -1; }
  | SBCI error                       { yyerror (REGISTER_ERROR); return -1; }
  | SBR error                        { yyerror (REGISTER_ERROR); return -1; }
  | SBRC error                       { yyerror (REGISTER_ERROR); return -1; }
  | SBRS error                       { yyerror (REGISTER_ERROR); return -1; }
  | SUBI error                       { yyerror (REGISTER_ERROR); return -1; }

  // 2num
  | BRBC expr ',' expr               { genAppendPending (0xF400 | $2, $4, 3, 7); }
  | BRBS expr ',' expr               { genAppendPending (0xF000 | $2, $4, 3, 7); }
  | CBI expr ',' expr                { outputInstr16 (0x9800 | ($2 << 3) | $4); }
  | SBI expr ',' expr                { outputInstr16 (0x9A00 | ($2 << 3) | $4); }
  | SBIC expr ',' expr               { outputInstr16 (0x9900 | ($2 << 3) | $4); }
  | SBIS expr ',' expr               { outputInstr16 (0x9B00 | ($2 << 3) | $4); }
  | BRBC expr ',' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | BRBS expr ',' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | CBI expr ',' error               { yyerror (EXPRESSION_ERROR); return -1; }
  | SBI expr ',' error               { yyerror (EXPRESSION_ERROR); return -1; }
  | SBIC expr ',' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | SBIS expr ',' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | BRBC expr  error                 { yyerror (COMMA_ERROR); return -1; }
  | BRBS expr  error                 { yyerror (COMMA_ERROR); return -1; }
  | CBI expr  error                  { yyerror (COMMA_ERROR); return -1; }
  | SBI expr  error                  { yyerror (COMMA_ERROR); return -1; }
  | SBIC expr  error                 { yyerror (COMMA_ERROR); return -1; }
  | SBIS expr  error                 { yyerror (COMMA_ERROR); return -1; }
  | BRBC error                       { yyerror (EXPRESSION_ERROR); return -1; }
  | BRBS error                       { yyerror (EXPRESSION_ERROR); return -1; }
  | CBI error                        { yyerror (EXPRESSION_ERROR); return -1; }
  | SBI error                        { yyerror (EXPRESSION_ERROR); return -1; }
  | SBIC error                       { yyerror (EXPRESSION_ERROR); return -1; }
  | SBIS error                       { yyerror (EXPRESSION_ERROR); return -1; }

  // numreg
  | OUT expr ',' REGISTER            { outputInstr16 (0xB800 | ($4 << 4) | (($2 & 0x30) << 5) | ($2 & 0x0f)); }
  | OUT expr ',' error               { yyerror (REGISTER_ERROR); return -1; }
  | OUT expr error                   { yyerror (COMMA_ERROR); return -1; }
  | OUT error                        { yyerror (EXPRESSION_ERROR); return -1; }
 
  // other   
  | ST error                         { yyerror (REG_ST_LD_ERROR); return -1; }
  | ST REG_X ',' REGISTER            { outputInstr16 (0x920c | ($4 << 4)); }
  | ST REG_X ',' error               { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_X error                   { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_XP ',' REGISTER           { outputInstr16 (0x920d | ($4 << 4)); }
  | ST REG_XP ',' error              { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_XP error                  { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_MX ',' REGISTER           { outputInstr16 (0x920e | ($4 << 4)); }
  | ST REG_MX ',' error              { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_MX error                  { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_Y ',' REGISTER            { outputInstr16 (0x8208 | ($4 << 4)); }
  | ST REG_Y ',' error               { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_Y error                   { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_Y '+' ',' REGISTER        { outputInstr16 (0x9209 | ($5 << 4)); }
  | ST REG_Y '+' ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_Y '+' error               { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_MY ',' REGISTER           { outputInstr16 (0x920a | ($4 << 4)); }
  | ST REG_MY ',' error              { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_MY error                  { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_Y '+' expr ',' REGISTER   { outputInstr16 (0x8208 | packRr6q ($6, $4)); }
  | ST REG_Y '+' expr ',' error      { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_Y '+' expr error          { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_Z ',' REGISTER            { outputInstr16 (0x8200 | ($4 << 4)); }
  | ST REG_Z ',' error               { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_Z error                   { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_Z '+' ',' REGISTER        { outputInstr16 (0x9201 | ($5 << 4)); }
  | ST REG_Z '+' ',' error           { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_Z '+' error               { yyerror (COMMA_ERROR); return -1; }
  
  | ST REG_MZ ',' REGISTER           { outputInstr16 (0x9202 | ($4 << 4)); }
  | ST REG_MZ ',' error              { yyerror (REGISTER_ERROR); return -1; }
  | ST REG_MZ error                  { yyerror (COMMA_ERROR); return -1; }
  
  | STD error                        { yyerror (STD_LDD_ERROR); return -1; }
  | STD REG_Y '+' expr ',' REGISTER  { outputInstr16 (0x8208 | packRr6q ($6, $4)); }
  | STD REG_Y '+' expr ',' error     { yyerror (REGISTER_ERROR); return -1; }
  | STD REG_Y '+' expr error         { yyerror (COMMA_ERROR); return -1; }
  | STD REG_Y '+' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | STD REG_Y error                  { yyerror (PLUS_ERROR); return -1; }
  
  | STD REG_Z '+' expr ',' REGISTER  { outputInstr16 (0x8200 | packRr6q ($6, $4)); }
  | STD REG_Z '+' expr ',' error     { yyerror (REGISTER_ERROR); return -1; }
  | STD REG_Z '+' expr error         { yyerror (COMMA_ERROR); return -1; }
  | STD REG_Z '+' error              { yyerror (EXPRESSION_ERROR); return -1; }
  | STD REG_Z error                  { yyerror (PLUS_ERROR); return -1; }

  | LD REGISTER ',' REG_X            { outputInstr16 (0x900c | ($2 << 4)); }
  | LD REGISTER ',' REG_XP           { outputInstr16 (0x900d | ($2 << 4)); }
  | LD REGISTER ',' REG_MX           { outputInstr16 (0x900e | ($2 << 4)); }
  | LD REGISTER ',' REG_Y            { outputInstr16 (0x8008 | ($2 << 4)); }
  | LD REGISTER ',' REG_MY           { outputInstr16 (0x900a | ($2 << 4)); }
  | LD REGISTER ',' REG_Z            { outputInstr16 (0x8000 | ($2 << 4)); }
  | LD REGISTER ',' REG_MZ           { outputInstr16 (0x9002 | ($2 << 4)); }
  | LD REGISTER ',' REG_Y '+'        { outputInstr16 (0x9009 | ($2 << 4)); }
  | LD REGISTER ',' REG_Z '+'        { outputInstr16 (0x9001 | ($2 << 4)); }
  | LD REGISTER ',' REG_Z '+' expr   { outputInstr16 (0x8000 | packRr6q ($2, $6)); }
  | LD REGISTER ',' REG_Z '+' error  { yyerror (EXPRESSION_ERROR); return -1; }
  | LD REGISTER ',' REG_Z error      { yyerror (PLUS_ERROR); return -1; }
  | LD REGISTER ',' error            { yyerror (REG_ST_LD_ERROR); return -1; }
  | LD REGISTER  error               { yyerror (COMMA_ERROR); return -1; }
  | LD error                         { yyerror (REGISTER_ERROR); return -1; }
  
  | LDD REGISTER ',' REG_Y '+' expr  { outputInstr16 (0x8008 | packRr6q ($2, $6)); }
  | LDD REGISTER ',' REG_Z '+' expr  { outputInstr16 (0x8000 | packRr6q ($2, $6)); }
  
  | LDD REGISTER ',' REG_Y '+' error { yyerror (EXPRESSION_ERROR); return -1; }
  | LDD REGISTER ',' REG_Y error     { yyerror (PLUS_ERROR); return -1; }
  | LDD REGISTER ',' error           { yyerror (STD_LDD_ERROR); return -1; }
  | LDD REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | LDD error                        { yyerror (REGISTER_ERROR); return -1; }
  
  | STS expr ',' REGISTER            { outputInstr16 (0x9200 | ($4 << 4)); outputInstr16 ($2); }
  | STS expr ',' error               { yyerror (REGISTER_ERROR); return -1; }
  | STS expr error                   { yyerror (COMMA_ERROR); return -1; }
  | STS error                        { yyerror(EXPRESSION_ERROR); return -1; }
  
  | LDS REGISTER ',' expr            { outputInstr16 (0x9000 | ($2 << 4)); outputInstr16 ($4); }
  | LDS REGISTER ',' error           { yyerror (EXPRESSION_ERROR); return -1; }
  | LDS REGISTER error               { yyerror (COMMA_ERROR); return -1; }
  | LDS error                        { yyerror (REGISTER_ERROR); return -1; }
  ;

 expr:
    NUM
  | '.'                   { $$ = genGetAddr () + 2; }
  |  IDENT                { if (defines.find ($1) != defines.end ())
                              $$ = defines[$1];
                            else
                              $$ = 0x80000000 | genGetLabelId ($1);
                          }
  | expr ARITHM_SL expr   { $$ = $1 << $3; }
  | expr ARITHM_SR expr   { $$ = $1 >> $3; }
  | expr '+' expr         { $$ = $1 + $3; }
  | expr '-' expr         { $$ = $1 - $3; }
  | '-' expr              { $$ = -$2; }
  | expr '*' expr         { $$ = $1 * $3; }
  | expr '/' expr         { $$ = $1 / $3; }
  | expr '|' expr         { $$ = $1 | $3; }
  | expr '&' expr         { $$ = $1 & $3; }
  | expr '^' expr         { $$ = $1 ^ $3; }
  | '(' expr ')'          { $$ = $2; }
  ;
%%

int main (int argc, char **argv)
{
	if (argc < 3)
	{
		printf ("Usage: %s input_file output_file\n", argv[0]);
		return 1;
	}

  genInit (argv[1], argv[2]);
  // while (yylex());
  int res = yyparse (); genClose (); return res;
}

void yyerror (char const *err)
{
  printf ("%s:%d: %s\n", genGetFilename ().c_str (), yylineno, err);
}
