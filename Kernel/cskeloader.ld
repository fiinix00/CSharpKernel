ENTRY(csmain)

SECTIONS
{
	.text 0x300000: 
	{
		cscode = .; _cscode = .; __cscode = .;
			Kernel\cskeloader.partial.s.o(.text*)
			Kernel\Combined.opt.o(.text*)
		cscode_end = .; _cscode_end = .; __cscode_end = .;
	}
	
	corelib_cctors = "Global Ctors for CoreLib";
	cskernel_cctors = "Global Ctors for CSKernel";

	csmain = "Int32 CSKernel.Program.CSMain()";

	VGAVideo_cctor = "Void CSKernel.Drivers.Video.VGAVideo..cctor()";

	AttributeUsageAttribute_cctor = "Void System.AttributeUsageAttribute..cctor()";
	BitConverter_cctor = "Void System.BitConverter..cctor()";
	Boolean_cctor = "Void System.Boolean..cctor()";
	Console_cctor = "Void System.Console..cctor()";
	DateTime_cctor = "Void System.DateTime..cctor()";
	DBNull_cctor = "Void System.DBNull..cctor()";
	Decimal_cctor = "Void System.Decimal..cctor()";
	Double_cctor = "Void System.Double..cctor()";
	Empty_cctor = "Void System.Empty..cctor()";
	Environment_cctor = "Void System.Environment..cctor()";
	EventArgs_cctor = "Void System.EventArgs..cctor()";
	Guid_cctor = "Void System.Guid..cctor()";
	Math_cctor = "Void System.Math..cctor()";
	Number_cctor = "Void System.Number..cctor()";
	StringComparer_cctor = "Void System.StringComparer..cctor()";
	String_cctor = "Void System.String..cctor()";
	TimeSpan_cctor = "Void System.TimeSpan..cctor()";
	EmptyArray_Char_cctor = "Void System.EmptyArray<System.Char>..cctor()";
	EmptyArray_Byte_cctor = "Void System.EmptyArray<System.Byte>..cctor()";
	Comparer_cctor = "Void System.Collections.Comparer..cctor()";
	ArrayList_cctor = "Void System.Collections.ArrayList..cctor()";
	ArrayListEnumeratorSimple_cctor = "Void System.Collections.ArrayList.ArrayListEnumeratorSimple..cctor()";
	HashHelpers_cctor = "Void System.Collections.HashHelpers..cctor()";
	List_String_cctor = "Void System.Collections.Generic.List<System.String>..cctor()";
	Stream_cctor = "Void System.IO.Stream..cctor()";
	FileStream_cctor = "Void System.IO.FileStream..cctor()";
	TextReader_cctor = "Void System.IO.TextReader..cctor()";
	TextWriter_cctor = "Void System.IO.TextWriter..cctor()";
	StringWriter_cctor = "Void System.IO.StringWriter..cctor()";
	__DebugOutputTextWriter_cctor = "Void System.IO.__DebugOutputTextWriter..cctor()";
	Thread_cctor = "Void System.Threading.Thread..cctor()";
	Convert_cctor = "Void System.Convert..cctor()";
	BinaryWriter_cctor = "Void System.IO.BinaryWriter..cctor()";
	StreamReader_cctor = "Void System.IO.StreamReader..cctor()";
	StreamWriter_cctor = "Void System.IO.StreamWriter..cctor()";

	nop = "Int32 CSKernel.Program.NOP()";

	_Znwj = "Int32 CSKernel.Program.operator_new(Int32)";
	_ZdlPv = "Void CSKernel.Program.operator_delete(Int32)";

	__gxx_personality_v0 = nop;
		
	__cxa_allocate_exception = nop;
	__cxa_throw = nop;
	__cxa_rethrow = nop;
	
	__cxa_begin_catch = nop;
	__cxa_end_catch = nop;

	__cxa_pure_virtual = nop;
	__cxa_call_unexpected = nop;
	
	
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

	/*statictest = "Void StaticTest..cctor()";
	driver = "Void CSKernel.Driver..cctor()";

	.ctors . : 
	{ 
		_ctors = .;
			
		_ctors_end = .;
	}*/

	/*	*(.ctors*)*/

	.rel.text . : { *(.rel.text*) }
	.rela.text . : { *(.rela.text*) }
	.rel.data . : { *(.rel.data*) }
	.rela.data . : { *(.rela.data*) }
	.rel.rodata . : { *(.rel.rodata*) }
	.rela.rodata . : { *(.rela.rodata*) }
	.rel.eh_frame . : { *(.rel.eh_frame*) }
	.rela.eh_frame . : { *(.rela.eh_frame*) }

	/* .group . : { *(.group*) } */

	.gcc_exc . : { *(.gcc_exc*) }
	.rodata . : { *(.rodata*) }
	.data . : { *(.data*) }
	.bss . : { *(.bss*) }

	.note.GNU-stack . : { *(.note.GNU-stack*) }
	
	.eh_frame . : { *(.eh_frame) }
	.shstrtab . : { *(.shstrtab*) }
	.symtab . : { *(.strtab*) }
	.strtab . : { *(.strtab*) }

	.idata$2 . : { SORT(*)(.idata$2) }
	.idata$3 . : { SORT(*)(.idata$3) }
	.idata$4 . : { SORT(*)(.idata$4) }
	.idata$5 . : { SORT(*)(.idata$5) }
	.idata$6 . : { SORT(*)(.idata$6) }
	.idata$7 . : { SORT(*)(.idata$7) }
	
	.edata . : { *(.edata*) }

	/*.idata . : { *(.idata*) }*/

	/DISCARD/ : {
		*(.group*);
		*(.note*);
		*(.iplt*);
		*(.igot*);
		
		*(.comment);
	}
}