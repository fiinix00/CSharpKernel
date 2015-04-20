Root = $(CURDIR)

MSBuild = \Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe

Il2Bc = $(Root)\Compilers\IL2BC\IL2BC.exe
Il2BcC = /target:x86_64 /gc- /llvm34

OBJCOPY = $(Root)\Compilers\objcopy.exe

NASM = $(Root)\Compilers\NASM\nasm.exe

LD = $(Root)\Compilers\ld.exe
DISKWRITE = $(Root)\Compilers\diskutils\Release\disk_write.exe

#Used: Mingw64 x64-4.8.1-release-win32-seh-rev5 (x86_64-w64-mingw32)
GCC = C:\x64-4.8.1-release-win32-seh-rev5\mingw64\bin\gcc

#Used: LLVM 3.4svn (Built Jun 5 2014, default target: x86_64-pc-win32)
LLVMLINK = llvm-link
LLC = llc
LLCC = --x86-asm-syntax=intel -code-model=kernel -filetype=obj -mtriple=x86_64-unknown-unknown -mcpu=athlon64

# --x86-asm-syntax=intel -code-model=kernel -filetype=obj -march=x86-64 

OPT = opt

all: Compilers\diskutils\Release\disk_write.exe OSDev_CHS_50_16_63.img 
	
Compilers\diskutils\Release\disk_write.exe: 
	set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120
	$(MSBuild) Compilers\diskutils\diskutils.sln /m /p:Configuration=Release  /verbosity:quiet /nologo

OSDev_CHS_50_16_63.img: Bootloader\main.bin Kernel\Keloader.os.bin Kernel\csKeloader.os.bin
	del OSDev_CHS_50_16_63.img
	fsutil file createnew OSDev_CHS_50_16_63.img 25804800
	$(DISKWRITE) Bootloader\main.bin OSDev_CHS_50_16_63.img 0 512
	$(DISKWRITE) Kernel\Keloader.os.bin OSDev_CHS_50_16_63.img 512
	$(DISKWRITE) Kernel\csKeloader.os.bin OSDev_CHS_50_16_63.img 3145728

bootloader: Bootloader\main.bin
kernel: Kernel\cmain.o Kernel\keloader.o
llvm: Kernel\Combined.opt.o
link: Kernel\keloader.exe
bin: Kernel\Keloader.os.bin

# BOOTSTRAP (ASM + C)
Bootloader\main.bin: Bootloader\main.s
	$(NASM) -f bin -o Bootloader\main.bin Bootloader\main.s

Kernel\cmain.o:
	$(GCC) -Wl,--image-base=0x100000 -ffreestanding -c -m64 -Wall -Wunused-value -o Kernel\cmain.o Kernel\cmain.c

Kernel\keloader.o:
	$(NASM) -f elf64 -o Kernel\keloader.o Kernel\keloader.s

Kernel\keloader.exe:  Kernel\cmain.o Kernel\keloader.o
	$(LD) -T Kernel\keloader.ld --image-base=0x100 --heap=0,0 --stack=0,0 -o Kernel\keloader.exe Kernel\keloader.o Kernel\cmain.o

Kernel\Keloader.os.bin: Kernel\keloader.exe
	$(OBJCOPY) --output-target=binary --image-base=0x100 --section-alignment=0 --stack=0 --heap=0 Kernel\keloader.exe Kernel\keloader.os.bin

Kernel\cskeloader.exe: Kernel\Combined.opt.o
	$(LD) -T Kernel\cskeloader.ld --image-base=0 --heap=0,0 --stack=0,0 -o Kernel\cskeloader.exe Kernel\Combined.opt.o

Kernel\csKeloader.os.bin: Kernel\cskeloader.exe
	$(OBJCOPY) --output-target=binary --image-base=0 --section-alignment=0 --stack=0 --heap=0 Kernel\cskeloader.exe Kernel\cskeloader.os.bin


# C# kernel
Kernel\kmain.o: Kernel\kmain.ll
	$(LLC) $(LLCC) Kernel\kmain.ll
	
Kernel\kmain.ll:
	$(Il2Bc) $(Il2BcC) /corelib:Kernel\CoreLib.dll Kernel\kmain.cs
	copy kmain.ll Kernel\kmain.ll /Y 1> nul

Kernel\CoreLib.o: Kernel\CoreLib.ll
	$(LLC) $(LLCC) $(Root)\Kernel\CoreLib.ll

Kernel\CoreLib.ll:
	$(Il2Bc) $(Il2BcC) Kernel\CoreLib.dll
	copy CoreLib.ll Kernel\CoreLib.ll /Y 1> nul

Kernel\Combined.bc: Kernel\kmain.ll 
	$(LLVMLINK) Kernel\kmain.ll Kernel\CoreLib.ll -o Kernel\Combined.bc

#Kernel\llvm.ll
#Kernel\CoreLib.ll

Kernel\Combined.opt.bc: Kernel\Combined.bc
	$(OPT) -O3 Kernel\Combined.bc -strip -o Kernel\Combined.opt.bc 

Kernel\Combined.opt.o: Kernel\Combined.opt.bc
	$(LLC) $(LLCC) Kernel\Combined.opt.bc

#$(LLC) --x86-asm-syntax=intel -filetype=asm -mtriple=x86_64-unknown-unknown -mcpu=athlon64 Kernel\Combined.opt.bc
#$(LLC) --x86-asm-syntax=intel -filetype=obj -march=x86-64 Kernel\Combined.opt.bc
#$(LLC) --x86-asm-syntax=intel -filetype=asm -march=x86-64 Kernel\Combined.opt.bc

clean: 
	del Bootloader\main.bin 2> nul
	del Bootloader\*.o 2> nul
	
	del Kernel\*.o 2> nul
	del Kernel\*.bc 2> nul

	del Kernel\CoreLib.ll 2> nul
	del Kernel\kmain.ll 2> nul

	del Kernel\keloader.exe 2> nul
	del Kernel\keloader.os.bin 2> nul

	del OSDev_CHS_50_16_63.img 2> nul

	set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120
	$(MSBuild) Compilers\diskutils\diskutils.sln /p:Configuration=Release /target:clean
