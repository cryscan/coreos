#include	"const.h"
#include	"pm.h"
#include	"proto.h"

void init_idt_desc(char, char, void*, char);

void divide_error();
void single_step_exception();
void nmi();
void breakpoint_exception();
void overflow();
void bounds_check();
void inval_opcode();
void copr_not_available();
void double_fault();
void copr_seg_overrun();
void inval_tss();
void segment_not_present();
void stack_exception();
void general_protection();
void page_fault();
void copr_error();
void hwint00();
void hwint01();
void hwint02();
void hwint03();
void hwint04();
void hwint05();
void hwint06();
void hwint07();
void hwint08();
void hwint09();
void hwint10();
void hwint11();
void hwint12();
void hwint13();
void hwint14();
void hwint15();

extern void init_prot()
{
	i8259a(0xfd, 0xff);

	init_idt_desc(INT_VECTOR_DIVIDE,	DA_386IGate, divide_error,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_DEBUG,		DA_386IGate, single_step_exception,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_NMI,		DA_386IGate, nmi,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_BREAKPOINT,	DA_386IGate, breakpoint_exception,	PRIVILEGE_USER);
	init_idt_desc(INT_VECTOR_OVERFLOW,	DA_386IGate, overflow,			PRIVILEGE_USER);
	init_idt_desc(INT_VECTOR_BOUNDS,	DA_386IGate, bounds_check,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_INVAL_OP,	DA_386IGate, inval_opcode,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_NOT,	DA_386IGate, copr_not_available,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_DOUBLE_FAULT,	DA_386IGate, double_fault,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_SEG,	DA_386IGate, copr_seg_overrun,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_INVAL_TSS,	DA_386IGate, inval_tss,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_SEG_NOT,	DA_386IGate, segment_not_present,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_STACK_FAULT,	DA_386IGate, stack_exception,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_PROTECTION,	DA_386IGate, general_protection,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_PAGE_FAULT,	DA_386IGate, page_fault,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_ERR,	DA_386IGate, copr_error,		PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 0,	DA_386IGate, hwint00,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 1,	DA_386IGate, hwint01,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 2,	DA_386IGate, hwint02,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 3,	DA_386IGate, hwint03,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 4,	DA_386IGate, hwint04,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 5,	DA_386IGate, hwint05,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 6,	DA_386IGate, hwint06,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 7,	DA_386IGate, hwint07,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 0,	DA_386IGate, hwint08,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 1,	DA_386IGate, hwint09,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 2,	DA_386IGate, hwint10,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 3,	DA_386IGate, hwint11,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 4,	DA_386IGate, hwint12,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 5,	DA_386IGate, hwint13,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 6,	DA_386IGate, hwint14,			PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 7,	DA_386IGate, hwint15,			PRIVILEGE_KRNL);
}

void init_idt_desc(char vector, char desc_type, void* handler, char privilege)
{
	GATE* p_gate	= &idt[vector];
	int base	= (int)handler;
	p_gate->offset_low	= base & 0xFFFF;
	p_gate->selector	= SELECTOR_KERNEL_CS;
	p_gate->dcount		= 0;
	p_gate->attr		= desc_type | (privilege << 5);
	p_gate->offset_high	= (base >> 16) & 0xFFFF;
}

extern void exception_handler(int vec_no, int err_code, int eip, int cs, int eflags)
{
	int i;
	int text_color = 0x74;
	char err_description[][64] = {	"#DE Divide Error",
					"#DB RESERVED",
					"—  NMI Interrupt",
					"#BP Breakpoint",
					"#OF Overflow",
					"#BR BOUND Range Exceeded",
					"#UD Invalid Opcode (Undefined Opcode)",
					"#NM Device Not Available (No Math Coprocessor)",
					"#DF Double Fault",
					"    Coprocessor Segment Overrun (reserved)",
					"#TS Invalid TSS",
					"#NP Segment Not Present",
					"#SS Stack-Segment Fault",
					"#GP General Protection",
					"#PF Page Fault",
					"—  (Intel reserved. Do not use.)",
					"#MF x87 FPU Floating-Point Error (Math Fault)",
					"#AC Alignment Check",
					"#MC Machine Check",
					"#XF SIMD Floating-Point Exception"
				};

	coutstr("Exception!\n", text_color);
	coutstr(err_description[vec_no], text_color);
	coutstr("EFLAGS:", text_color);
	coutint(eflags);
	coutstr("\nCS:", text_color);
	coutint(cs);
	coutstr("\nEIP:", text_color);
	coutint(eip);
	coutstr("\n", text_color);

	if(err_code != 0xFFFFFFFF){
		coutstr("\nError code:", text_color);
		coutint(err_code);
	}
}

extern void squrious_irq(int irq)
{
	coutstr("squrios_irq:", 0x07);
	coutint(irq);
	coutstr("\n", 0x07);
}
