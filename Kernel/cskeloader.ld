ENTRY(csmain)

SECTIONS
{
	.text 0x300000:
	{
		QUAD(csmain);
	}

	.text . : 
	{
		csmain = "Int32 Program.CSMain()" - 8;
		
		cscode = .; _cscode = .; __cscode = .;
			Kernel\Combined.opt.o(.text*)
		cscode_end = .; _cscode_end = .; __cscode_end = .;
	}
	
	nop = "Int32 Program.NOP()";

	_Znwj = "Int32 Program.operator_new(Int32)";
	_ZdlPv = "Void Program.operator_delete(Int32)";
	
	__cxa_allocate_exception = nop;
	__cxa_throw = nop;
	__cxa_rethrow = nop;
	
	__cxa_pure_virtual = nop;
	__cxa_call_unexpected = nop;
	
	__cxa_begin_catch = nop;
	__cxa_end_catch = nop;

	__gxx_personality_v0 = nop;

	__dynamic_cast = nop;
	_Unwind_Resume = nop;
	
	/*RTTI externals - http://www.scs.stanford.edu/histar/src/lib/cppsup/cxxabi.h*/
	_ZTVN10__cxxabiv116__enum_type_infoE = nop;
	_ZTVN10__cxxabiv117__array_type_infoE = nop;
	_ZTVN10__cxxabiv117__class_type_infoE = nop;
	_ZTVN10__cxxabiv119__pointer_type_infoE = nop;
	_ZTVN10__cxxabiv120__si_class_type_infoE = nop;
	_ZTVN10__cxxabiv120__function_type_infoE = nop;
	_ZTVN10__cxxabiv121__vmi_class_type_infoE = nop;
	_ZTVN10__cxxabiv123__fundamental_type_infoE = nop;
	_ZTVN10__cxxabiv129__pointer_to_member_type_infoE = nop;
	new = nop;
	
	memset = nop;
	memcpy = nop;
	
	gettimeofday = nop;
	clock_gettime = nop;

	acos = nop;
	asin = nop;
	atan = nop;
	atan2 = nop;
	ceil = nop;
	cos = nop;
	cosh = nop;
	floor = nop;
	fabs = nop;
	sin = nop;
	tan = nop;
	sinh = nop;
	tanh = nop;
	fmod = nop;
	sqrt = nop;
	log = nop;
	log10 = nop;
	exp = nop;
	pow = nop;
	modf = nop;
	fabsf = nop;
	
	remove = nop; /*`Void System.IO.File.InternalDelete(System.String, Boolean)'*/
	access = nop; /*`Boolean System.IO.File.InternalExists(System.String)'*/

	fopen = nop;
	fflush = nop;
	fread = nop;
	fwrite = nop;
	fseek = nop;
	ftell = nop;
	fclose = nop;

	wprintf = nop; /*`Void System.IO.__DebugOutputTextWriter.WriteLine(Char[])'*/

	copysign = nop;

	.ctors . : { *(.ctors*) }

	.rel.text . : { *(.rel.text*) }
	.rela.text . : { *(.rela.text*) }
	.rel.data . : { *(.rel.data*) }
	.rela.data . : { *(.rela.data*) }
	.rel.rodata . : { *(.rel.rodata*) }
	.rela.rodata . : { *(.rela.rodata*) }
	.rel.eh_frame . : { *(.rel.eh_frame*) }
	.rela.eh_frame . : { *(.rela.eh_frame*) }

	.group . : { *(.group*) }

	.gcc_exc . : { *(.gcc_exc*) }
	.rodata . : { *(.rodata*) }
	.data . : { *(.data*) }
	.bss . : { *(.bss*) }

	.note.GNU-stack . : { *(.note.GNU-stack*) }
	
	.eh_frame . : { *(.eh_frame) }
	.shstrtab . : { *(.shstrtab*) }
	.symtab . : { *(.strtab*) }
	.strtab . : { *(.strtab*) }
}