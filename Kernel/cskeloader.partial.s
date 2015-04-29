[BITS 64]

extern _Znwj
extern _ctors
extern csmain

global kickstarter
global addressToFunction
global functionToAddress

kickstarter:
	call csmain
	ret

; rdi = function pointer
addressToFunction:
	push rdi
		mov rdi, 0x64
		call _Znwj
	pop rdi

	mov qword [rax], rax ; circular reference
	mov qword [rax+24], rdi
	mov qword [rax+64], rdi 
	
	ret
	
functionToAddress:
	mov qword rax, [rdi+64]
	ret
