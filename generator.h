#ifndef __GENERATOR_H__
#define __GENERATOR_H__

#include <string>
#include <stdint.h>

using namespace std;

struct InstrInfo
{
	const char* instr;
	int Rd, Rr;
};

extern int yylineno;
extern string filename;

string genGetFilename ();
int genGetAddr ();

int genGetLabelId (const string& label);
void genSetLabel (const string& label);

void genInit (const char* infile, const char* outfile);
void genClose ();
void genIncludeFile (string path);
int genGetChar (char *buf);
void genWritePending ();

int genGetAddrOffset (int dest, int base, int bits);

void outputInstr16 (uint16_t val);
void outputInstr16offset (uint16_t offset, uint16_t val);
void genAppendPending (uint16_t opcode, uint32_t addr, uint8_t addrStart, uint8_t addrLen);
void genAppendPending32 (uint16_t opcode, uint32_t addr, uint8_t addrStart, uint8_t addrLen);

uint16_t packRdRr (uint8_t Rd, uint8_t Rr);
uint16_t packRd8K16 (uint8_t Rd, uint8_t K);
uint16_t packRr6q (uint8_t Rr, uint8_t q);

#endif
