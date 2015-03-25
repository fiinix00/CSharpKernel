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

static inline void udelay(unsigned long n)
{
	if (n) asm("1: dec %%eax; jne 1b;" : : "a" (n * 1000));
}

static inline void mdelay(unsigned long n)
{
	while (--n) udelay(1000);
}

static inline uchar inb(ushort port)
{
	uchar ret;
	asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

static inline void outb(ushort port, uchar val)
{
	asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline ushort inw(ushort port)
{
	ushort ret;
	asm volatile("inw %1, %0" : "=a" (ret) : "Nd" (port));
	return ret;
}

static inline void outw(ushort port, ushort val)
{
	asm volatile("outw %0, %1" : : "a" (val), "Nd" (port));
}

static inline void cpuid(int code, uint32_t* a, uint32_t* d)
{
	asm volatile ("cpuid" : "=a"(*a), "=d"(*d) : "0"(code) : "ebx", "ecx");
}

static inline ulong rdtsc()
{
	ulong ret;
	asm volatile ("rdtsc" : "=A"(ret));
	return ret;
}

static inline ulong read_cr0()
{
	ulong val;
	asm volatile ("mov %%cr0, %0" : "=r"(val));
	return val;
}

static inline void wrmsr(uint msr_id, ulong msr_value)
{
	asm volatile ("wrmsr" : : "c" (msr_id), "A" (msr_value));
}

static inline ulong rdmsr(uint msr_id)
{
	ulong msr_value;
	asm volatile ("rdmsr" : "=A" (msr_value) : "c" (msr_id));
	return msr_value;
}

static int k_read_disk(uint lba, void* buffer, uint sector_size)
{
	int i;
	int j;
	int k;
	unsigned int temp_lba; /* LBA */
	unsigned int temp_size;
	unsigned char status;

	/* 256 */
	for (i = 0; i < sector_size; i += 256)
	{
		temp_lba = lba + i;

		temp_size = sector_size - i;
		if (temp_size > 256)
		{
			temp_size = 256;
		}

		/* BSY DRQ 0 */
		while ((inb(REGISTER_STATUS) & (STATUS_BSY | STATUS_DRQ)) != 0);

		/* LBA high*/
		outb(REGISTER_DEVHEAD, 0x40 | ((temp_lba >> 24) & 0x0F));

		/* BSY DRQ 0 */

		while ((inb(REGISTER_STATUS) & (STATUS_BSY | STATUS_DRQ)) != 0);

		outb(REGISTER_SECCNT, (temp_size == 256) ? 0 : (temp_size & 0xFF));
		outb(REGISTER_SECNUM, temp_lba & 0xFF);
		outb(REGISTER_CYLLOW, (temp_lba >> 8) & 0xFF);
		outb(REGISTER_CYLHIGH, (temp_lba >> 16) & 0xFF);

		ata_intrq = 0;

		outb(REGISTER_COMMAND, COMMAND_READ);

		for (j = 0; j < temp_size; j++)
		{
			while (ata_intrq == 0)
			{
				//k_hlt();
			}

			ata_intrq = 0;

			/* BSY 0*/
			while (((status = inb(REGISTER_STATUS)) & STATUS_BSY) != 0);

			/* DRQ 1 */
			if ((status & STATUS_DRQ) != 0)
			{
				for (k = 0; k < 256; k++)
				{
					((unsigned short *)buffer)[i * 256 * 256 + j * 256 + k] = inw(REGISTER_DATA);
				}
				/* DRQ 0 */
			}
			else
			{
				return -1;
			}
		}
	}

	return 0;
}

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
	{ read_cr0, "ReadCr0" },

	{ k_read_disk, "ReadDisk" }
};

struct k_function* k_getkernelfunctions()
{
	return k_functions;
}

void loadAll()
{
	void* start = (void*)0x100000;

	int i;
	for (i = 1; i < 2048; i++)
	{
		k_read_disk(i, start, 1);

		start += 512;
	}
}

int cmain()
{
	loadAll();
	
	return 0;
}