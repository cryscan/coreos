#ifndef	_0C0D7B68803F575A675B_H_
#define	_0C0D7B68803F575A675B_H_

int coutstr(char*, int);
void coutal();
void coutint(int);
void clear();
void memcpy(void*, void*, int);
void i8259a(int, int);

extern void init();
extern void main();
extern void init_prot();
extern void exception_handler(int, int, int, int, int);
extern void squrious_irq(int);

#endif
