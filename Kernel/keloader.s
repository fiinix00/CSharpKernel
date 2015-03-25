;[ORG 0x10200]
[BITS 64]

section .text

extern cmain ; ansi c main
extern llvmmain ; c# main

global _start
_start: ; 12 kb code support
	call cmain
	call Write64BitGDT
	call llvmmain

	jmp $

%macro GDT 4 
	dw %2 & 0xFFFF 
	dw %1 
	db %1 >> 16
	db %3 
	db (%2 >> 16) & 0x0F | (%4 << 4)
	db %1 >> 24 
%endmacro 

global Write64BitGDT
[BITS 32]
Write64BitGDT:
	cli
	lgdt [gdt64_d]
	ret

gdt64_d: 
	dw end_gdt64 - gdt64 - 1 
	dd gdt64 

gdt64: 
	GDT 0, 0, 0, 0 
	GDT 0, 0xfffff, 10011010b, 1010b ; ring0 cs (all mem) 
	GDT 0, 0xfffff, 10010010b, 1010b ; ring0 ds (all mem) 
	GDT 0, 0xfffff, 11111010b, 1010b ; ring3 cs (all mem), sz=0, L=1 for 64-bit 
	GDT 0, 0xfffff, 11110010b, 1010b ; ring3 ds (all mem), sz=0, L=1 for 64-bit 
end_gdt64: 

global __cxa_allocate_exception
__cxa_allocate_exception: ret

global __cxa_throw
__cxa_throw: ret

global _Znwj ;c++ `operator new(unsigned int)'
_Znwj: ret

global _ZdlPv ;c++ `operator delete(unsigned int)'
_ZdlPv: ret

global __cxa_pure_virtual
__cxa_pure_virtual: ret

global __gxx_personality_v0
__gxx_personality_v0: ret

;http://www.scs.stanford.edu/histar/src/lib/cppsup/cxxabi.h
;__si_class_type_info

; RTTI externals
global _ZTVN10__cxxabiv116__enum_type_infoE
_ZTVN10__cxxabiv116__enum_type_infoE:  ret

global _ZTVN10__cxxabiv117__array_type_infoE
_ZTVN10__cxxabiv117__array_type_infoE: ret

global _ZTVN10__cxxabiv117__class_type_infoE
_ZTVN10__cxxabiv117__class_type_infoE: ret

global _ZTVN10__cxxabiv119__pointer_type_infoE
_ZTVN10__cxxabiv119__pointer_type_infoE: ret

global _ZTVN10__cxxabiv120__si_class_type_infoE
_ZTVN10__cxxabiv120__si_class_type_infoE: ret

global _ZTVN10__cxxabiv120__function_type_infoE
_ZTVN10__cxxabiv120__function_type_infoE: ret

global _ZTVN10__cxxabiv121__vmi_class_type_infoE
_ZTVN10__cxxabiv121__vmi_class_type_infoE ret

global _ZTVN10__cxxabiv123__fundamental_type_infoE
_ZTVN10__cxxabiv123__fundamental_type_infoE: ret

global _ZTVN10__cxxabiv129__pointer_to_member_type_infoE
_ZTVN10__cxxabiv129__pointer_to_member_type_infoE: ret

global new
new: ret

global __cxa_begin_catch
__cxa_begin_catch: ret

global __dynamic_cast
__dynamic_cast: ret

global memset
memset: ret

global memcpy
memcpy: ret

global __cxa_rethrow
__cxa_rethrow: ret

global __cxa_call_unexpected
__cxa_call_unexpected: ret

global __cxa_end_catch
__cxa_end_catch: ret

global gettimeofday
gettimeofday: ret

global clock_gettime
clock_gettime: ret

global _Unwind_Resume
_Unwind_Resume: ret

global acos 
acos: ret

global asin
asin: ret

global atan
atan: ret

global atan2
atan2: ret

global ceil
ceil: ret

global cos
cos: ret

global cosh
cosh: ret

global floor
floor: ret

global fabs
fabs: ret

global sin
sin: ret

global tan
tan: ret

global sinh
sinh: ret

global tanh
tanh: ret

global fmod
fmod: ret

global sqrt
sqrt: ret

global log
log: ret

global log10
log10: ret

global exp
exp: ret

global pow
pow: ret

global modf
modf: ret

global fabsf
fabsf: ret

;`Void System.IO.File.InternalDelete(System.String, Boolean)'
global remove
remove: ret

;`Boolean System.IO.File.InternalExists(System.String)'
global access
access: ret

global fopen
fopen: ret

global fflush
fflush: ret

global fread
fread: ret

global fwrite
fwrite: ret

global fseek
fseek: ret

global ftell
ftell: ret

;`Void System.IO.__DebugOutputTextWriter.WriteLine(Char[])'
global wprintf
wprintf: ret

global fclose
fclose: ret

global copysign
copysign: ret

TIMES 512-($-$$) DB 0