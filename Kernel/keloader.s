;[ORG 0x10200]
[BITS 64]

section .text

extern cmain ; ansi c main

global _start
_start: ; 12 kb code support
	mov rsp, 0x10200

	call Write64BitGDT
	call paging4GB

	;Enable PSE (4 MiB pages)
	;mov rax, cr4
	;or rax, 0x00000010
	;mov cr4, rax

	call cmain
	
	cli
	cld

	jmp $
	
[BITS 64]

paging4GB: ;identity map 4 GB
.setup:
	.cleartables:
		mov rbx, 0x150000	;location to put new tables

		mov rdi, rbx
		xor rax, rax
		mov rcx, 512*6 ;using 6 tables of 4096 length, divide by 8 for stosq
		rep stosq
		mov rdi, rbx
		
	.pml4:	;setup 4 gigabytes of identity paged memory using 0x6000 bytes of tables
		mov rsi, rdi
		or rsi, 3	;present | accessible
		add rsi, 0x1000
		mov [rdi], rsi	;PML4[0] points to PDPT
	.pdpt:
		add rdi, 0x1000
		add rsi, 0x1000
		mov [rdi], rsi	;PDPT[0] points to PDT0
		add rsi, 0x1000
		mov [rdi+8], rsi	;PDPT[1] points to PDT1
		add rsi, 0x1000
		mov [rdi+16], rsi ;PDPT[2] points to PDT2
		add rsi, 0x1000
		mov [rdi+24], rsi ;PDPT[3] points to PDT3
	.pdt:
		add rdi, 0x1000
		mov rsi, 0x83	;present | accessible | size
		mov rcx, 512*4	;using 4 tables for 4 GB total
	.setentries:
		mov [rdi], rsi
		add rsi, 0x200000	;add 2 megabytes
		add rdi, 8
		loop .setentries
		
		mov cr3, rbx	;reload tables
		ret

		;TODO
		;explanation:
		;The PML4, pointed to by cr3, has 512 64-bit pointers to PDPT's
			;This means that a single PML4 can address  256 TB, (0x1000000000000, 1 << 48)
		;The PDPT's have 512 64-bit pointers to PDT's
			;This means that a single PDPT can address 512 GB, (0x8000000000, 1 <<  39)
		;The PDT's have 512 64-bit pointers to PT's
		;The PT's have 512 64-bit pointers to physical addresses
		;all of these pointers must be 4096 byte aligned (0x1000, 1 << 12)
		;	.identity: ;location to page in in rsi, size in rcx
		;		mov rdi, rsi
		;	.virtual: ;virtual address in rdi, physical in rsi, size in rcx
						;destroys rax and rbx
						;rsi, rdi, and rcx must be page aligned, or else...
		;		shr rdi, 12
		;		shl rdi, 3
		;		and si, 0xF000
		;		and ch, 0xF0
		;		mov rbx, cr3
		;		mov rax, rsi
				;Get rsi divided by 512*1024*1024*1024 times 8 into eax
				;(
		
		;		mov r14, [rbx+MEM/512GB] ;get page directory pointer table from pml4
		;		mov cr3, rbx
		;		ret
		

extern gdtPointer
global gdtflush
gdtflush:
	mov eax, gdttimesP
    lgdt [eax]
    ret

global tssflush
tssflush:
	mov ax, 0x2B
	ltr ax
	ret

extern idtP;
global idtInit
idtInit:
	mov eax, idttimesP
	lidt [eax]
	ret

%macro GDT 4 
	dw %2 & 0xFFFF 
	dw %1 
	db %1 >> 16
	db %3 
	db (%2 >> 16) & 0x0F | (%4 << 4)
	db %1 >> 24 
%endmacro 

global Write64BitGDT
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

%macro PushAll 0
	push r15
	push r14
	push r13
	push r12
	push r11
	push r10
	push r9
	push r8
	push rdi
	push rsi
	push rbp
	push rdx
	push rcx
	push rbx
	push rax
%endmacro

%macro PopAll 0
	pop rax
	pop rbx
	pop rcx
	pop rdx
	pop rbp
	pop rsi
	pop rdi
	pop r8
	pop r9
	pop r10
	pop r11
	pop r12
	pop r13
	pop r14
	pop r15
%endmacro

extern isrHandler


%macro SAVE_REGS 0
	push rax
	push rcx
	push rdx
	push rbx
	push rsp
	push rbp
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
%endmacro

%macro RESTORE_REGS 0
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rbp
	pop rsp
	pop rbx
	pop rdx
	pop rcx
	pop rax
%endmacro


%macro SAVE_SEGMENTS 0
	mov rax, ds
	push rax
	
	mov rax, es
	push rax
	
	mov rax, fs
	push rax
	
	mov rax, gs
	push rax
%endmacro

%macro RESTORE_SEGMENTS 0
	pop rax
	mov gs, rax

	pop rax
	mov fs, rax

	pop rax
	mov es, rax

	pop rax
	mov ds, rax
%endmacro

isrCommon:
	PushAll
		;SAVE_SEGMENTS
			mov ax, 0x10
			mov ds, ax
			mov es, ax
			mov fs, ax
			mov gs, ax

			swapgs
				call isrHandler
			swapgs
		;RESTORE_SEGMENTS
	PopAll

	add rsp, 16

	sti
	iretq

	; PushAll
	; 	mov ax, ds
	; 	push rax
	; 		mov ax, 0x10		; use kernel data segment from the original user data selector
	; 		mov ds, ax
	; 		mov es, ax
	; 		mov fs, ax
	; 		mov gs, ax
	; 
	; 		mov rsp, rdi
	; 		call isrHandler
	; 	pop rax
	; 	mov ds, ax
	; 	mov es, ax
	; 	mov fs, ax
	; 	mov gs, ax
	; PopAll
	; 
	; add rsp, 8
	; 
	; sti
	;iretq

global idttimesP
idttimesP:
	dw 512+256
	dq idttimes

global gdttimesP
gdttimesP:
	dw (8*5)
	dq gdttimes

TIMES 512-($-$$) DB 0 

global idttimes
idttimes:
TIMES 1024 DB 0 ;0x10400

global gdttimes
gdttimes:
TIMES 512 DB 0 ;0x10800


%macro ISR_NOERRCODE 1
  global isr%1
  isr%1:
    cli
    push byte 0 
    push byte %1
    jmp isrCommon
%endmacro

%macro ISR_ERRCODE 1
  global isr%1
  isr%1:
    cli
    push byte %1
    jmp isrCommon
%endmacro

%macro IRQ 2
  global isr%2
  isr%2:
    cli
    push byte 0
    push byte %2
    jmp isrCommon
%endmacro

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10,42
IRQ 11,43
IRQ 12,44
IRQ 13,45
IRQ 14,46
IRQ 15,47

section .paging ;0x150000 

align 0x1000
global page_dir
page_dir:
TIMES (512 * 8) DB 0 ;0x150000

align 0x1000
global page_tab
page_tab:
TIMES (1024 * 8) DB 0 ;0x151000

align 0x20
global page_dir_ptr_tab
page_dir_ptr_tab:
TIMES (4 * 8) DB 0 ;0x153000

;function calculatedAlign(pointer, align) {
;    return (pointer + (pointer % align)).toString(16);
;}

;https://github.com/willscott/Porcupine/blob/master/BareMetal%20v0.5.2%20Source/os/interrupt.asm
;keyboard

; exc_string db 'Unknown Fatal Exception!', 0
; exc_string00 db 'Interrupt 00 - Divide Error Exception (#DE)        ', 0
; exc_string01 db 'Interrupt 01 - Debug Exception (#DB)               ', 0
; exc_string02 db 'Interrupt 02 - NMI Interrupt                       ', 0
; exc_string03 db 'Interrupt 03 - Breakpoint Exception (#BP)          ', 0
; exc_string04 db 'Interrupt 04 - Overflow Exception (#OF)            ', 0
; exc_string05 db 'Interrupt 05 - BOUND Range Exceeded Exception (#BR)', 0
; exc_string06 db 'Interrupt 06 - Invalid Opcode Exception (#UD)      ', 0
; exc_string07 db 'Interrupt 07 - Device Not Available Exception (#NM)', 0
; exc_string08 db 'Interrupt 08 - Double Fault Exception (#DF)        ', 0
; exc_string09 db 'Interrupt 09 - Coprocessor Segment Overrun         ', 0	; No longer generated on new CPU's
; exc_string10 db 'Interrupt 10 - Invalid TSS Exception (#TS)         ', 0
; exc_string11 db 'Interrupt 11 - Segment Not Present (#NP)           ', 0
; exc_string12 db 'Interrupt 12 - Stack Fault Exception (#SS)         ', 0
; exc_string13 db 'Interrupt 13 - General Protection Exception (#GP)  ', 0
; exc_string14 db 'Interrupt 14 - Page-Fault Exception (#PF)          ', 0
; exc_string15 db 'Interrupt 15 - Undefined                           ', 0
; exc_string16 db 'Interrupt 16 - x87 FPU Floating-Point Error (#MF)  ', 0
; exc_string17 db 'Interrupt 17 - Alignment Check Exception (#AC)     ', 0
; exc_string18 db 'Interrupt 18 - Machine-Check Exception (#MC)       ', 0
; exc_string19 db 'Interrupt 19 - SIMD Floating-Point Exception (#XM) ', 0