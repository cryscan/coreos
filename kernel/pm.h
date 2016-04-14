#ifndef	_5B444183433464E398_H_
#define	_5B444183433464E398_H_

typedef struct descriptor
{
	short	limit_low;
	short	base_low;
	char	base_mid;
	char	attr_low;
	char	limit_high_attr_high;
	char	base_high;
}	DESC;

typedef struct gate
{
	short	offset_low;
	short	selector;
	char	dcount;
	char	attr;
	short	offset_high;
}	GATE;

char gdtptr[6];
DESC gdt[GDT_SIZE];
char idtptr[6];
GATE idt[IDT_SIZE];

#define	INDEX_DUMMY		0
#define	INDEX_FLAT_C		1
#define	INDEX_FLAT_RW		2
#define	INDEX_VIDEO		3

#define	SELECTOR_DUMMY		0
#define	SELECTOR_FLAT_C		0x08
#define	SELECTOR_FLAT_RW	0x10
#define	SELECTOR_VIDEO		(0x18+3)

#define	SELECTOR_KERNEL_CS	SELECTOR_FLAT_C
#define	SELECTOR_KERNEL_DS	SELECTOR_FLAT_RW

#define	DA_32			0x4000
#define	DA_LIMIT_4K		0x8000
#define	DA_DPL0			0x00
#define	DA_DPL1			0x20
#define	DA_DPL2			0x40
#define	DA_DPL3			0x60
#define	DA_DR			0x90
#define	DA_DRW			0x92
#define	DA_DRWA			0x93
#define	DA_C			0x98
#define	DA_CR			0x9a
#define	DA_CCO			0x9c
#define	DA_CCOR			0x9e

#define	DA_LDT			0x82
#define	DA_TaskGate		0x85
#define	DA_386TSS		0x89
#define	DA_386CGate		0x8c
#define	DA_386IGate		0x8e
#define	DA_386TGate		0x8f

#define	INT_VECTOR_DIVIDE		0x0
#define	INT_VECTOR_DEBUG		0x1
#define	INT_VECTOR_NMI			0x2
#define	INT_VECTOR_BREAKPOINT		0x3
#define	INT_VECTOR_OVERFLOW		0x4
#define	INT_VECTOR_BOUNDS		0x5
#define	INT_VECTOR_INVAL_OP		0x6
#define	INT_VECTOR_COPROC_NOT		0x7
#define	INT_VECTOR_DOUBLE_FAULT		0x8
#define	INT_VECTOR_COPROC_SEG		0x9
#define	INT_VECTOR_INVAL_TSS		0xa
#define	INT_VECTOR_SEG_NOT		0xb
#define	INT_VECTOR_STACK_FAULT		0xc
#define	INT_VECTOR_PROTECTION		0xd
#define	INT_VECTOR_PAGE_FAULT		0xe
#define	INT_VECTOR_COPROC_ERR		0x10

#define	INT_VECTOR_IRQ0			0x20
#define	INT_VECTOR_IRQ8			0x28
#endif

