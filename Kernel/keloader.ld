ENTRY(_start)

SECTIONS
{
	.text 0x10200: 
	{ 
		Kernel\keloader.o(.text*)
	}

	.text 0x100000:
	{ 
		Kernel\cmain.o(.text*)
		Kernel\Combined.opt.o(.text*)
	}
	
	.ctors : { *(.ctors*) }

	.rel.text : { *(.rel.text*) }
	.rela.text : { *(.rela.text*) }
	.rel.data : { *(.rel.data*) }
	.rela.data : { *(.rela.data*) }
	.rel.rodata : { *(.rel.rodata*) }
	.rela.rodata : { *(.rela.rodata*) }
	.rel.eh_frame : { *(.rel.eh_frame*) }
	.rela.eh_frame : { *(.rela.eh_frame*) }

	.group : { *(.group*) }

	.gcc_exc : { *(.gcc_exc*) }
	.rodata : { *(.rodata*) }
	.data : { *(.data*) }
	.bss : { *(.bss*) }

	.note.GNU-stack : { *(.note.GNU-stack*) }
	
	.eh_frame : { *(.eh_frame) }
	.shstrtab : { *(.shstrtab*) }
	.symtab : { *(.strtab*) }
	.strtab : { *(.strtab*) }

	/DISCARD/ : {
		*(.note*);
		*(.iplt*);
		*(.igot*);
		
		*(.comment);
	}
}

/* *(.rel*); */