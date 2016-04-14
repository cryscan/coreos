#include	"const.h"
#include	"pm.h"
#include	"proto.h"

extern void init()
{
	memcpy(&gdt, (void*)(*((int*)(&gdtptr[2]))), *((short*)(&gdtptr)));

	short *p_gdt_limit = (short*)(&gdtptr[0]);
	int *p_gdt_base = (int*)(&gdtptr[2]);
	*p_gdt_limit = GDT_SIZE*sizeof(DESC);
	*p_gdt_base = (int)&gdt;

	short *p_idt_limit = (short*)(&idtptr[0]);
	int *p_idt_base = (int*)(&idtptr[2]);
	*p_idt_limit = IDT_SIZE*sizeof(GATE);
	*p_idt_base = (int)&idt;

	clear();
	init_prot();
}

extern void main()
{
	static char str[] = "In protect mode now.^-^\naetnet core version 1.0.\n";
	int out = coutstr(str, 0x07);
}

void test()
{
	int i;
	for(i = 0;;i++)
	{
		if(i%(int)1e4 == 0)
			coutstr(".", 0x07);
	}
}
