#include "generator.h"

#include <vector>
#include <stack>
#include <stdio.h>
#include <stdint.h>

struct TPendingInstr
{
	uint16_t offset;
	uint16_t opcode;
	uint32_t labelAddr;
	uint8_t addrStart, addrLen;
	uint8_t addrRelative;
};
struct TLabel
{
	string name;
	uint16_t addr;
};

FILE *of;
int addr;
vector<TPendingInstr> pending;
vector<TLabel> labels;

stack<FILE*> files;
stack<int> lineno;
stack<string> filenames;

bool passNL = false;

string genGetFilename ()
{
	return filenames.top ();
}
int genGetAddr ()
{
	return addr;
}

void genSetLabel (const string& label)
{
	for (int i = 0; i < labels.size (); i++)
	{
		if (labels[i].name == label)
		{
			labels[i].addr = genGetAddr ();
			return;
		}
	}
	TLabel lab;
	lab.name = label;
	lab.addr = genGetAddr ();
	labels.push_back (lab);
}
int genGetLabelId (const string& label)
{
	for (int i = 0; i < labels.size (); i++)
		if (labels[i].name == label)
			return i;
	TLabel lab;
	lab.name = label;
	lab.addr = 0;
	labels.push_back (lab);
	return labels.size () - 1;
}

void genInit (const char* infile, const char* outfile)
{
	FILE* inf = fopen (infile, "rb");
	of = fopen (outfile, "wb");
	addr = 0;
	yylineno = 1;
	files.push (inf);
	filenames.push (infile);
}
void genClose ()
{
	genWritePending ();
	fclose (of);
}
void genIncludeFile (string path)
{
	FILE *f = fopen (path.c_str (), "rb");
	files.push (f);
	passNL = true;
	lineno.push (yylineno);
	yylineno = 0;
	filenames.push (path);
}
int genGetChar (char *buf)
{
	if (passNL)
	{
		buf[0] = '\n';
		passNL = false;
		return 1;
	}
	int c = fgetc (files.top ());
	if (c == EOF)
	{
		if (files.size () > 1)
		{
			fclose (files.top ());
			files.pop ();
			yylineno = lineno.top ();
			lineno.pop ();
			filenames.pop ();
			c = fgetc (files.top ());
		}
	}
  return (c == EOF) ? 0 : (buf[0] = c, 1); 
}
void genWritePending ()
{
	for (int i = 0; i < pending.size (); i++)
	{
		uint16_t base = pending[i].offset;
		uint16_t opcode = pending[i].opcode;

		printf ("base: %02x opcode %04x la: %08x\n", base, opcode, pending[i].labelAddr);

		uint16_t addr;
		if ((pending[i].labelAddr & 0x80000000) && !(pending[i].labelAddr & 0x40000000))
		{
			addr = labels[pending[i].labelAddr & ~0x80000000].addr;
			printf ("label addr: %04x\n", addr);
			opcode |= genGetAddrOffset (addr, base, pending[i].addrLen) << pending[i].addrStart;
		}
		else
		{
			addr = pending[i].labelAddr;
			printf ("label r addr: %04x\n", addr);
			opcode |= genGetAddrOffset (addr, base, pending[i].addrLen) << pending[i].addrStart;
			printf ("label r opcode: %04x\n", opcode);
		}

		if (pending[i].addrLen >= 16)
		{
			outputInstr16offset (base, pending[i].opcode);
			outputInstr16offset (base + 2, genGetAddrOffset (addr+2, 0, pending[i].addrLen));
		}
		else
		{
			printf ("QWEWE\n");
			outputInstr16offset (base, opcode);
		}
	}
}

int genGetAddrOffset (int dest, int base, int bits)
{
	return (((dest-base)/2-1) & ((1 << bits) - 1));
}

void outputInstr16 (uint16_t val)
{
	fwrite ((uint8_t*)&val, 2, 1, of);
	addr += 2;
}
void outputInstr16offset (uint16_t offset, uint16_t val)
{
	fseek (of, offset, SEEK_SET);
	fwrite ((uint8_t*)&val, 2, 1, of);
}
void genAppendPending (uint16_t opcode, uint32_t addr, uint8_t addrStart, uint8_t addrLen)
{
	TPendingInstr pend;
	pend.offset = genGetAddr ();
	pend.opcode = opcode;
	pend.addrStart = addrStart;
	pend.addrLen = addrLen;
	pend.addrRelative = 1;
	pend.labelAddr = addr;
	pending.push_back (pend);
	outputInstr16 (0xffff);
}
void genAppendPending32 (uint16_t opcode, uint32_t addr, uint8_t addrStart, uint8_t addrLen)
{
	TPendingInstr pend;
	pend.offset = genGetAddr ();
	pend.opcode = opcode;
	pend.addrStart = addrStart;
	pend.addrLen = addrLen;
	pend.addrRelative = 0;
	pend.labelAddr = addr;
	pending.push_back (pend);
	outputInstr16 (0xffff);
	outputInstr16 (0xffff);
}

uint16_t packRdRr (uint8_t Rd, uint8_t Rr)
{
	return (Rd << 4) | ((Rr & 0x10) << 5) | (Rr & 0x0f);
}
uint16_t packRd8K16 (uint8_t Rd, uint8_t K)
{
	return ((Rd-16) << 4) | ((K & 0xf0) << 4) | (K & 0x0f);
}
uint16_t packRr6q (uint8_t Rr, uint8_t q)
{
	return (Rr << 4) | ((q & 0x20) << 8) | ((q & 0x18) << 7) | (q & 0x07);
}

