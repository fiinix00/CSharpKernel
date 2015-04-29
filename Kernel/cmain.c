//#define asmlinkage __attribte__((regparm(3)))

#define REGISTER_DATA           0x01F0          /* Data register */
#define REGISTER_SECCNT         0x01F2          /* Sector counter register */
#define REGISTER_SECNUM         0x01F3          /* Sector number register */
#define REGISTER_CYLLOW         0x01F4          /* Cylinder low register */
#define REGISTER_CYLHIGH        0x01F5          /* Cylinder high register */
#define REGISTER_DEVHEAD        0x01F6          /* Device/head register */
#define REGISTER_STATUS         0x01F7          /* Status register */
#define REGISTER_COMMAND        0x01F7          /* Command register */

#define STATUS_BSY      0x80            /* Busy bit */
#define STATUS_DRQ      0x08            /* Data request bit */

#define COMMAND_READ    0x20

volatile int ata_intrq;

#define USING_CPU_REGISTER(_register, _size, _as) \
	register ulong _register asm(#_register); \
	_size _as = _register;


#define k_asm_func(name) void k_##name() { asm(#name); } 
#define k_asm_funcname(name) k_##name

k_asm_func(cli);
k_asm_func(sti);
k_asm_func(clts);
k_asm_func(fninit);
k_asm_func(hlt);

typedef char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef uint8_t uchar;
typedef uint16_t ushort;
typedef uint32_t uint;
typedef uint64_t ulong;
typedef uint32_t size_t;
typedef int32_t ssize_t;

typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef int64_t intptr_t;
typedef uint64_t uintptr_t;

inline void udelay(uint n)
{
	if (n) asm("1: dec %%eax; jne 1b;" : : "a" (n * 1000));
}

inline void mdelay(uint n)
{
	while (--n) udelay(1000);
}

inline uchar inb(ushort port)
{
	uchar ret;
	asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

inline void outb(ushort port, uchar val)
{
	asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

inline ushort inw(ushort port)
{
	ushort ret;
	asm volatile("inw %1, %0" : "=a" (ret) : "Nd" (port));
	return ret;
}

inline uint inl(ushort port)
{
	uint data;
	asm volatile ("inl %w1, %0" : "=a" (data) : "Nd" (port));
	return data;
}

inline void outw(ushort port, ushort val)
{
	asm volatile("outw %0, %1" : : "a" (val), "Nd" (port));
}

inline void outl(ushort port, uint data)
{
	asm volatile ("outl %0, %w1" : : "a" (data), "Nd" (port));
}

inline void cpuid(int code, uint32_t* a, uint32_t* d)
{
	asm volatile ("cpuid" : "=a"(*a), "=d"(*d) : "0"(code) : "ebx", "ecx");
}

inline void set_trap_flag(int enable)
{
	asm("pushfq");
	asm("pop %rax");
	asm("mov %rax, %rcx");

	if (enable)
	{
		asm("or $0x100, %rax");
	}
	else
	{
		asm("xor $0x100, %rax");
	}
	
	asm("push %rax");
	asm("popfq");
}

inline ulong rdtsc()
{
	ulong ret;
	asm volatile ("rdtsc" : "=A"(ret));
	return ret;
}


#define ReadControlRegister(reg) \
	inline ulong Read##reg() { \
		uint64_t ret; \
		asm volatile ("mov %%" #reg ", %0" : "=r" (ret)); \
		return ret; \
	}

#define WriteControlRegister(reg) \
	inline void Write##reg(ulong value) { \
		asm volatile ("mov %0, %%" #reg "" :: "r" (value)); \
	}

#define ReadWriteControlRegister(reg) \
	ReadControlRegister(reg); \
	WriteControlRegister(reg);

ReadWriteControlRegister(cr0);
ReadWriteControlRegister(cr2);
ReadWriteControlRegister(cr3);
ReadWriteControlRegister(cr4);

inline void Bochs_debug_putc(char c)
{
	outb(0xe9, c);
}

void WriteCR4(uint64_t x) {
	asm volatile ("mov %0, %%cr4" : : "r" (x));
}

inline void wrmsr(uint msr_id, ulong msr_value)
{
	asm volatile ("wrmsr" : : "c" (msr_id), "A" (msr_value));
}

inline ulong rdmsr(uint msr_id)
{
	ulong msr_value;
	asm volatile ("rdmsr" : "=A" (msr_value) : "c" (msr_id));
	return msr_value;
}

inline void insl(int port, void *addr, int cnt)
{
	asm volatile("cld; rep insl" :
	"=D" (addr), "=c" (cnt) :
	"d" (port), "0" (addr), "1" (cnt) :
	"memory", "cc");
}

inline void breakpoint(void) {
	asm volatile ("int $3");
}

//inline uint xchg(volatile uint *addr, uint newval)
//{
//	uint result;
//
//	// The + in "+m" denotes a read-modify-write operand.
//	asm volatile("lock; xchgl %0, %1" :
//	"+m" (*addr), "=a" (result) :
//	"1" (newval) :
//	"cc");
//	return result;
//}

struct k_function
{
	void* address;
	char* name;
} k_functions[] = 
{
	{ k_asm_funcname(cli), "Cli" },
	{ k_asm_funcname(sti), "Sti" },
	{ k_asm_funcname(clts), "clts" },
	{ k_asm_funcname(fninit), "Fninit" },
	{ k_asm_funcname(hlt), "Hlt" },

	{ wrmsr, "Wrmsr" },
	{ rdmsr, "Rdmsr" },

	{ inb, "Inb" },
	{ outb, "Outb" },
	{ cpuid, "CpuId" },
	//{ read_cr0, "ReadCr0" },

	{ set_trap_flag, "SetTrapFlag" }

	//{ k_read_disk, "ReadDisk" }
};

struct k_function* k_getkernelfunctions()
{
	return k_functions;
}

/*
* Interrupt Descriptor Structure
*/
typedef struct {
	ushort   baseLow;
	ushort   selector;
	uchar   reservedIst;
	uchar   flags;
	ushort   baseMid;
	uint   baseHigh;
	uint   reserved;
} __attribute__((packed)) idtEntry;

/*
* Interrupt Descriptor Pointer
*/
typedef struct {
	ushort   limit;
	ulong   base;
} __attribute__((packed)) idtPointer;

/*
* Pushed Registers for ISR's
*/
#define REG(reg) ulong reg
#define TRAPDATA(data) ulong data

struct trapframe {
	ulong eax;      // rax
	ulong rbx;
	ulong rcx;
	ulong rdx;
	ulong rbp;
	ulong rsi;
	ulong rdi;
	ulong r8;
	ulong r9;
	ulong r10;
	ulong r11;
	ulong r12;
	ulong r13;
	ulong r14;
	ulong r15;

	ulong trapno;
	ulong err;

	ulong eip;     // rip
	ulong cs;
	ulong eflags;  // rflags
	ulong esp;     // rsp
	ulong ds;      // ss
};

/*
* Prototypes
*/
void idtStart();
void idtSet(uchar, ulong, ushort, uchar);
//void isrHandler(trapframe*);

extern void idtInit();

#define interupt(i) extern void isr##i()

interupt(0);
interupt(1);
interupt(2);
interupt(3);
interupt(4);
interupt(5);
interupt(6);
interupt(7);
interupt(8);
interupt(9);
interupt(10);
interupt(11);
interupt(12);
interupt(13);
interupt(14);
interupt(15);
interupt(16);
interupt(17);
interupt(18);
interupt(19);
interupt(20);
interupt(21);
interupt(22);
interupt(23);
interupt(24);
interupt(25);
interupt(26);
interupt(27);
interupt(28);
interupt(29);
interupt(30);
interupt(31);
interupt(32);
interupt(33);
interupt(34);
interupt(35);
interupt(36);
interupt(37);
interupt(38);
interupt(39);
interupt(40);
interupt(41);
interupt(42);
interupt(43);
interupt(44);
interupt(45);
interupt(46);
interupt(47);

/* Setup Table and Pointer */
//idtEntry idt[256];
//idtPointer idtP;

void *k_memset(void *Destination, int Value, int Count)
{
  uchar* Ptr = Destination;

  while (Count--)
          *Ptr++ = Value;

  return Destination;
}

//http://wiki.osdev.org/Exceptions
void idtStart(void) {
	
	/* IDT, 0..31 */
	idtSet(0x0, (ulong)isr0, 0x08, 0x8E); //Division by zero
	idtSet(0x1, (ulong)isr1, 0x08, 0x8E); //Debug single step
	idtSet(0x2, (ulong)isr2, 0x08, 0x8E); //Non-maskable interupt
	idtSet(0x3, (ulong)isr3, 0x08, 0x8E); //Breakpoint
	idtSet(0x4, (ulong)isr4, 0x08, 0x8E); //Overflow
	idtSet(0x5, (ulong)isr5, 0x08, 0x8E); //Bounds check
	idtSet(0x6, (ulong)isr6, 0x08, 0x8E); //Invalid opcode
	idtSet(0x7, (ulong)isr7, 0x08, 0x8E); //Device not available (The EM bit of the CR0 register can be cleared to disable this exception)
	idtSet(0x8, (ulong)isr8, 0x08, 0x8E); //Double fault
	idtSet(0x9, (ulong)isr9, 0x08, 0x8E); //Coprocessor Segment Overrun (GPF in newer processors)
	idtSet(0xA, (ulong)isr10, 0x08, 0x8E); //Invalid Task State Segment (Invalid TSS)
	idtSet(0xB, (ulong)isr11, 0x08, 0x8E); //Segment Not Present
	idtSet(0xC, (ulong)isr12, 0x08, 0x8E); //Stack exception (Stack-Segment Fault)
	idtSet(0xD, (ulong)isr13, 0x08, 0x8E); //CS, DS, ES, FS, GS Segment Overrun (General Protection Fault)
	idtSet(0xE, (ulong)isr14, 0x08, 0x8E); //Page fault
	idtSet(0xF, (ulong)isr15, 0x08, 0x8E); //Reserved
	idtSet(0x10, (ulong)isr16, 0x08, 0x8E); //x87 Floating-Point Exception
	idtSet(0x11, (ulong)isr17, 0x08, 0x8E); //Alignment Check
	idtSet(0x12, (ulong)isr18, 0x08, 0x8E); //Machine Check
	idtSet(0x13, (ulong)isr19, 0x08, 0x8E); //SIMD Floating-Point Exception
	idtSet(0x14, (ulong)isr20, 0x08, 0x8E); //Virtualization Exception
	idtSet(0x15, (ulong)isr21, 0x08, 0x8E); //Reserved
	idtSet(0x16, (ulong)isr22, 0x08, 0x8E); //Reserved
	idtSet(0x17, (ulong)isr23, 0x08, 0x8E); //Reserved
	idtSet(0x18, (ulong)isr24, 0x08, 0x8E); //Reserved
	idtSet(0x19, (ulong)isr25, 0x08, 0x8E); //Reserved
	idtSet(0x1A, (ulong)isr26, 0x08, 0x8E); //Reserved
	idtSet(0x1B, (ulong)isr27, 0x08, 0x8E); //Reserved
	idtSet(0x1C, (ulong)isr28, 0x08, 0x8E); //Reserved
	idtSet(0x1D, (ulong)isr29, 0x08, 0x8E); //Reserved
	idtSet(0x1E, (ulong)isr30, 0x08, 0x8E); //Security Exception
	idtSet(0x1F, (ulong)isr31, 0x08, 0x8E); //Reserved

	/* IRQ, 0..15 */
	idtSet(0x20, (ulong)isr32, 0x08, 0x8E); //Programmable Interrupt Timer Interrup
	idtSet(0x21, (ulong)isr33, 0x08, 0x8E); //Keyboard Interrupt
	idtSet(0x22, (ulong)isr34, 0x08, 0x8E); //Cascade (used internally by the two PICs. never raised)
	idtSet(0x23, (ulong)isr35, 0x08, 0x8E); //COM2 (if enabled)
	idtSet(0x24, (ulong)isr36, 0x08, 0x8E); //COM1 (if enabled)
	idtSet(0x25, (ulong)isr37, 0x08, 0x8E); //LPT2 (if enabled)
	idtSet(0x26, (ulong)isr38, 0x08, 0x8E); //Floppy Disk
	idtSet(0x27, (ulong)isr39, 0x08, 0x8E); //LPT1
	idtSet(0x28, (ulong)isr40, 0x08, 0x8E); //CMOS real-time clock (if enabled)
	idtSet(0x29, (ulong)isr41, 0x08, 0x8E); //Free for peripherals / legacy SCSI / NIC
	idtSet(0x2A, (ulong)isr42, 0x08, 0x8E); //Free for peripherals / SCSI / NIC
	idtSet(0x2B, (ulong)isr43, 0x08, 0x8E); //Free for peripherals / SCSI / NIC
	idtSet(0x2C, (ulong)isr44, 0x08, 0x8E); //PS2 Mouse
	idtSet(0x2D, (ulong)isr45, 0x08, 0x8E); //FPU / Coprocessor / Inter-processor
	idtSet(0x2E, (ulong)isr46, 0x08, 0x8E); //Primary ATA Hard Disk
	idtSet(0x2F, (ulong)isr47, 0x08, 0x8E); //Secondary ATA Hard Disk

	/* Load IDT Table */
	idtInit();
}

void idtSet(uchar number, ulong base, ushort selector, uchar flags) {
	idtEntry* idttimes = (idtEntry*)0x10400;

	/* Set Base Address */
	idttimes[number].baseLow = base & 0xFFFF;
	idttimes[number].baseMid = (base >> 16) & 0xFFFF;
	idttimes[number].baseHigh = (base >> 32) & 0xFFFFFFFF;

	/* Set Selector */
	idttimes[number].selector = selector;
	idttimes[number].flags = flags;

	/* Set Reserved Areas to Zero */
	idttimes[number].reservedIst = 0;
	idttimes[number].reserved = 0;
}

//void isrHandler(trapframe* frame) {
//	
//}

typedef struct {
	ushort limitLow;
	ushort baseLow;
	uchar baseMiddle;
	uchar access;
	uchar granularity;
	uchar baseHigh;
} __attribute__((packed)) gdtEntry;

typedef struct {
	ushort limit;
	ulong base;
} __attribute__((packed)) gdtPtr;

extern void gdtflush();
extern void tssflush();

static void gdtSet(uint num, uint base, uint limit, uchar access, uchar gran) {
	gdtEntry* gdtEntries = (gdtEntry*)0x10800;
	
	gdtEntries[num].baseLow = (base & 0xFFFF);
	gdtEntries[num].baseMiddle = (base >> 16) & 0xFF;
	gdtEntries[num].baseHigh = (base >> 24) & 0xFF;

	gdtEntries[num].limitLow = (limit & 0xFFFF);
	gdtEntries[num].granularity = (limit >> 16) & 0x0f;

	gdtEntries[num].granularity |= gran & 0xF0;
	gdtEntries[num].access = access;
}

static void initGdt() {
	gdtSet(0, 0, 0, 0, 0);
	gdtSet(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
	gdtSet(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
	gdtSet(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
	gdtSet(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);
	//tss here 

	gdtflush();

	//tssflush(); no tss yet
}

//Maps the 16 IRQs (0-15) to ISR locations 32-47
void irq_remap()
{
	outb(0x20, 0x11); /* write ICW1 to PICM, we are gonna write commands to PICM */
	outb(0xA0, 0x11); /* write ICW1 to PICS, we are gonna write commands to PICS */

	outb(0x21, 0x20); /* remap PICM to 0x20 (32 decimal) */
	outb(0xA1, 0x28); /* remap PICS to 0x28 (40 decimal) */

	outb(0x21, 0x04); /* remap PICS to 0x28 (40 decimal) */
	outb(0xA1, 0x02);

	outb(0x21, 0x01); /* write ICW4 to PICM, we are gonna write commands to PICM */
	outb(0xA1, 0x01); /* write ICW4 to PICS, we are gonna write commands to PICS */

	outb(0x21, 0x0); /* enable all IRQs on PICM */
	outb(0xA1, 0x0); /* enable all IRQs on PICS */
}

static void itoa(char *buf, unsigned long int n, int base)
{
	unsigned long int tmp;
	int i, j;

	tmp = n;
	i = 0;

	do {
		tmp = n % base;
		buf[i++] = (tmp < 10) ? (tmp + '0') : (tmp + 'a' - 10);
	} while (n /= base);

	buf[i--] = 0;

	for (j = 0; j < i; j++, i--) {
		tmp = buf[j];
		buf[j] = buf[i];
		buf[i] = tmp;
	}
}

static void write_string(int colour, const char *string)
{
	volatile char *video = (volatile char*)0xB8000;
	while (*string != 0)
	{
		*video++ = *string++;
		*video++ = colour;
	}
}

/*

int 0x20

stack before register saving

0x00000000:0x00000020 ; interupt id
0x00000000:0x00000000 ; error code
0x00000000:0x0001020d ; return address (@op int 0x20 + sizeof(int 0x20))
0x00000000:0x00000008 ; code sector
0x00000000:0x00000206
0x00000000:0x00007c00
0x00000000:0x00000000

stack after register saving

0x00000000:0x0001028e ;call isrHandler, return address
0x00000000:0x00000000 ;rax
0x00000000:0xe0000011 ;rbx
0x00000000:0x00000000 ;rcx
0x00000000:0x000001f0 ;rdx
0x00000000:0x00000000 ;rbp
0x00000000:0x000e7ca9 ;rsi
0x00000000:0x0000d000 ;rdi
0x00000000:0x00200000 ;r8
0x00000000:0x000000f2 ;r9
0x00000000:0x00000000 ;r10
0x00000000:0x00000000 ;r11
0x00000000:0x00000000 ;r12 
0x00000000:0x00000000 ;r13
0x00000000:0x00000000 ;r14
0x00000000:0x00000000 ;r15
-- same
0x00000000:0x00000020
0x00000000:0x00000000
0x00000000:0x0001020d
0x00000000:0x00000008
0x00000000:0x00000206
0x00000000:0x00007c00
0x00000000:0x00000000

*/

ulong picCounter = 0;

void* getMessage()
{
	return "KKKKKKKKKKKKKKKKKLLLLLLLLL";
}

void isrHandler(struct trapframe* frame)
{
	if (frame->trapno == 0x20)
	{
		picCounter++;
	}
	else
	{
		char buffer[10];
		buffer[0] = 0;
		buffer[1] = 0;
		buffer[2] = 0;
		buffer[3] = 0;
		buffer[4] = 0;
		buffer[5] = 0;
		buffer[6] = 0;
		buffer[7] = 0;
		buffer[8] = 0;
		buffer[9] = 0;

		itoa(buffer, frame->trapno, 16);

		write_string(0x07, buffer); //itoa(value, buffer, 10));
	}
	//uchar* vidmem = (uchar*)0xb8000;

	//vidmem[0]++;
	//vidmem[1] = 0x07;


	outb(0x20, 0x20); /* End Of Interrput - master PIC */
}


void WriteFPUCW(uint16_t cw) {
	asm volatile ("fldcw %0" : : "m" (cw));
}

#define CR0_NE                  (1<<5)
#define CR0_TS                  (1<<3)
#define CR0_EM                  (1<<2)
#define CR0_MP                  (1<<1)

void InitialiseFPU() {
	/* We're on x86_64 - we can assume SSE3 + FPU. */

	/* Set the OSFXSR bit. */
	Writecr4(Readcr4() | 0x200);

	Writecr0((Readcr0() | CR0_NE | CR0_MP) & ~(CR0_EM | CR0_TS));

	/* Initialise the FPU. */
	asm volatile("finit");

	WriteFPUCW(0x37F);
}

void Reboot() {
	/* Short code taken from http://wiki.osdev.org/Reboot */
	/* Just performs an 8042 reset. */
	unsigned char good = 0x02;
	while ((good & 0x02) != 0) {
		good = inb(0x64);
	}
	outb(0x64, 0xFE);

	/* If that didn't work, perform a triple fault. */
	asm volatile("xor %eax,%eax; lidt (%eax); int $100;");
}


inline void invlpg(ulong rax)
{
	asm volatile("\n" "mov %0, %%rax;\n" "invlpg (%%rax);\n" :: "g"(rax) : "rax");
}

uint32_t placement_address;

uint32_t kmalloc_int(uint32_t sz, int align, uint32_t *phys)
{
	// This will eventually call malloc() on the kernel heap.
	// For now, though, we just assign memory at placement_address
	// and increment it by sz. Even when we've coded our kernel
	// heap, this will be useful for use before the heap is initialised.
	if (align == 1 && (placement_address & 0xFFFFF000))
	{
		// Align the placement address;
		placement_address &= 0xFFFFF000;
		placement_address += 0x1000;
	}
	if (phys)
	{
		*phys = placement_address;
	}
	uint32_t tmp = placement_address;
	placement_address += sz;
	return tmp;
}

uint32_t kmalloc_a(uint32_t sz)
{
	return kmalloc_int(sz, 1, 0);
}

uint32_t kmalloc_p(uint32_t sz, uint32_t *phys)
{
	return kmalloc_int(sz, 0, phys);
}

uint32_t kmalloc_ap(uint32_t sz, uint32_t *phys)
{
	return kmalloc_int(sz, 1, phys);
}

uint32_t kmalloc(uint32_t sz)
{
	return kmalloc_int(sz, 0, 0);
}

ulong test_maloc_addr = 0x600000;
uint32_t test_maloc()
{
	register ulong rdi asm("rdi");
	//c# sends sz in register rdi

	ulong _new = test_maloc_addr;

	test_maloc_addr += rdi;

	return _new;
}

void set_4kb_pages()
{
	ulong cr4 = Readcr4();
	cr4 &= ~(0x00000010);
	Writecr4(cr4);
}

void set_paging()
{
	ulong cr0 = Readcr0();
	cr0 |= 0x80000000;
	Writecr0(cr0);
}

int bl_common(int drive, int numblock, int count)
{
	outb(0x1F1, 0x00);	/* NULL byte to port 0x1F1 */
	outb(0x1F2, count);	/* Sector count */
	outb(0x1F3, (unsigned char) numblock);	/* Low 8 bits of the block address */
	outb(0x1F4, (unsigned char) (numblock >> 8));	/* Next 8 bits of the block address */
	outb(0x1F5, (unsigned char) (numblock >> 16));	/* Next 8 bits of the block address */

	/* Drive indicator, magic bits, and highest 4 bits of the block address */
	outb(0x1F6, 0xE0 | (drive << 4) | ((numblock >> 24) & 0x0F));

	return 0;
}

int bl_read(int drive, int numblock, int count, char *buf)
{
	uint16 tmpword;
	int idx;

	bl_common(drive, numblock, count);
	outb(0x1F7, 0x20);

	/* Wait for the drive to signal that it's ready: */
	while (!(inb(0x1F7) & 0x08));

	for (idx = 0; idx < 256 * count; idx++) {
		tmpword = inw(0x1F0);
		buf[idx * 2] = (unsigned char) tmpword;
		buf[idx * 2 + 1] = (unsigned char) (tmpword >> 8);
	}

	return count;
}

int bl_write(int drive, int numblock, int count, char *buf)
{
	uint16 tmpword;
	int idx;

	bl_common(drive, numblock, count);
	outb(0x1F7, 0x30);

	/* Wait for the drive to signal that it's ready: */
	while (!(inb(0x1F7) & 0x08));

	for (idx = 0; idx < 256 * count; idx++) {
		tmpword = (buf[idx * 2 + 1] << 8) | buf[idx * 2];
		outw(0x1F0, tmpword);
	}

	return count;
}

//http://a.michelizza.free.fr/Pepin/Disk/advmemory_to_disk.diff
//http://www.news.cs.nyu.edu/~jinyang/sp09/notes/l3.html
//https://code.google.com/p/uberos/source/browse/trunk/source/?r=26#source%253Fstate%253Dclosed
//http://www.jamesmolloy.co.uk/tutorial_html/6.-Paging.html
//http://bochs.sourceforge.net/doc/docbook/user/bochsrc.html
void loadIt()
{
	int i;
	for (i = 0; i < 2048 * 4; i++)
	{
		bl_read(0, i + (0x300000 / 512), 1, (char*)(0x300000 + (i * 512)));
	}
}

void k_memcpy(void* dest, const void* src, int size)
{
	int i;
	char* pDest = (char*)dest;
	char* pSrc = (char*)src;
	for (i = 0; i < size; i++)
	{
		*pDest++ = *pSrc++;
	}
}

int cmain()
{
	loadIt();

	placement_address = 0x600000;
	
	//for (void(**f)(void) = (void(**)(void))ctors_start; f != ctors_end; f++)
	//	(**f)();

	//https://github.com/AdamRi/scummvm-pink/blob/master/backends/platform/dc/dcloader.cpp

	//Call CSMain
	return ((int(*)())0x300000)();
}

//void name1() __attribute__((alias("name2")));


/*

struct task
{
struct task *next;
struct page_context context;
uint32_t pid;
struct cpu_state *cpu;
};

*/