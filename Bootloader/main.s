[ORG 0x00007C00]
[BITS 16]
	 
boot_loader:
	cli

	;Set default state
	xor bx, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ds, bx
	mov ss, bx
	mov sp, 0x7C00

	;push ax
	;	mov	ax, 0x0003 ; set video mode 3 (80x25 color)
	;	int	0x10
	;pop ax

	;Parameter from BIOS: dl = boot drive
	mov [biosdrive], dl

	jmp 0:.clear_cs
	.clear_cs:
 
	;Enable A20 via port 92h
	in al, 92h
	or al, 02h
	out 92h, al
 
	call ResetDrives
	call LoadExtendedBootloader

	;Build page tables
	;The page tables will look like this:
	;PML4:
	;dq 0x000000000000b00f = 00000000 00000000 00000000 00000000 00000000 00000000 10010000 00001111
	;times 511 dq 0x0000000000000000
 
	;PDP(E):
	;dq 0x000000000000c00f = 00000000 00000000 00000000 00000000 00000000 00000000 10100000 00001111
	;times 511 dq 0x0000000000000000
 
	;PD(E):
	;dq 0x000000000000018f = 00000000 00000000 00000000 00000000 00000000 00000000 00000001 10001111
	;times 511 dq 0x0000000000000000
 
	;This defines one 2MB page at the start of memory, so we can access the first 2MBs as if paging was disabled
 
	; build the necessary tables
	xor bx, bx
	mov es, bx
	cld
	mov di, 0xa000
 		   
	mov ax, 0xb00f
	stosw

	xor ax, ax
	mov cx, 0x07ff
	rep stosw
 
	mov ax, 0xc00f
	stosw
 
	xor ax, ax
	mov cx, 0x07ff
	rep stosw
 
	mov ax, 0x018f
	stosw
 
	xor ax, ax
	mov cx, 0x07ff
	rep stosw

	;Enter long mode
 
	mov eax, 10100000b ; Set PAE and PGE
	mov cr4, eax
 
	mov edx, 0x0000a000	; Point CR3 at PML4
	mov cr3, edx
 
	mov ecx, 0xC0000080 ; Specify EFER MSR
	rdmsr ; Enable Long Mode
	or eax, 0x00000100
	wrmsr

	mov ebx, cr0 ; Activate long mode
	or ebx, 0x80000001 ; by enabling paging and protection simultaneously
	mov cr0, ebx ; skipping protected mode entirely
 
	lgdt [gdt.pointer] ; load 80-bit gdt.pointer below
 
	jmp gdt.code:startLongMode ; Load CS with 64 bit segment and flush the instruction cache
	 
ResetDrives:
	xor ah, ah ; reset Floppy0
		xor dl, dl
	int 0x13    
	
	xor ah, ah ; reset HDD0
		mov dl, 0x80
	int 0x13    

	ret

LoadExtendedBootloader:
	mov ah, 0x42 
		mov si, dap 
		mov dl, [biosdrive] 
	int 0x13 

	jc Error
	ret 

	dap db 16, 0            ; [2] sizeof(dap) 
		dw 24               ; [2] transfer 16 sectors (before PVB)
		dw 0x0, 0x1000      ; [4] to 0:10000
		dd 0, 0             ; [8] from LBA 0 

;Arguments [mov si]
Print_impl:
	loop: 
		lodsb 
		or al, al 
		jz done 
		mov ah, 0x0e 
		int 0x10 
		jmp loop 
	done: 
		ret

Error:
	mov si, .msg
	call Print_impl

	call Hang

	Error.msg db "An error occurred", 0 
	 
Hang:
	cli
	hang_loop:
		hlt
		jmp hang_loop
	; no ret needed, wont happen

[BITS 64]
startLongMode:
	cli ; Interupts are disabled because no IDT has been set up
	jmp 0x10200						


biosdrive db 0

;Global Descriptor Table
gdt:
dq 0x0000000000000000 ; Null Descriptor
 
.code equ $ - gdt
dq 0x0020980000000000                   
 
.data equ $ - gdt
dq 0x0000900000000000                   
 
.pointer:
dw $-gdt-1 ; 16-bit Size (Limit)
dq gdt ; 64-bit Base Address

TIMES 510-($-$$) DB 0
dw 0xAA55