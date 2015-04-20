ENTRY(_start)

SECTIONS
{
	start = 0; _start = start; __start = start;
	.text 0x10200: 
	{ 
		kcode = .; _kcode = .; __kcode = .;
			Kernel\keloader.o(.text*)
		kcode_end = .; _kcode_end = .; __kcode_end = .;	
	}

	. = ALIGN(4096);

	.data . :
	{
		kdata = .; _kdata = .; __kdata = .;
			Kernel\keloader.o(.data)
			Kernel\keloader.o(.rodata)
		kdata_end = .; _kdata_end = .; __kdata_end = .;
	}

	. = ALIGN(4096);

	.bss . :
    {
        kbss = .; _kbss = .; __kbss = .;
			Kernel\keloader.o(.bss)
		kbss_end = .; _kbss_end = .; __kbss_end = .;    
    }

	. = ALIGN(4096);

	.text . :
	{
		code = .; _code = .; __code = .;
			Kernel\cmain.o(.text*)	
		code_end = .; _code_end = .; __code_end = .;
	}

	. = ALIGN(4096);

	end = .; _end = .; __end = .;

	/DISCARD/ : {
		*(.note*);
		*(.iplt*);
		*(.igot*);
		
		*(.comment);
	}
}
