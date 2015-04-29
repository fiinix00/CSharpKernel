Root = $(CURDIR)

MSBuild = \Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe

Il2Bc = $(Root)\Compilers\IL2BC\IL2BC.exe
Il2BcC = /target:x86_64 /gc- /llvm34 /gctors- /roslyn /emscripten

OBJCOPY = $(Root)\Compilers\objcopy.exe

NASM = $(Root)\Compilers\NASM\nasm.exe

LD = $(Root)\Compilers\ld.exe
DISKWRITE = $(Root)\Compilers\diskutils\Release\disk_write.exe

#Used: Mingw64 x64-4.8.1-release-win32-seh-rev5 (x86_64-w64-mingw32)
GCC = C:\x64-4.8.1-release-win32-seh-rev5\mingw64\bin\gcc
GCCC = -ffreestanding -c -Wall -Wunused-value -mcmodel=small -mtune=generic -march=x86-64 -m64 -mabi=sysv

#

#Used: LLVM 3.4svn (Built Jun 5 2014, default target: x86_64-pc-win32)
LLVMLINK = llvm-link
LLC = llc
LLCC = --x86-asm-syntax=intel -code-model=small -mtriple=x86_64-unknown-unknown -filetype=obj -mcpu=athlon64

#-mtriple=x86_64-unknown-unknown -mcpu=athlon64 -mtriple=x86_64-pc-linux
# --x86-asm-syntax=intel -code-model=kernel -filetype=obj -march=x86-64 

OPT = opt

all: Compilers\diskutils\Release\disk_write.exe OSDev_CHS_50_16_63.img 
	
Compilers\diskutils\Release\disk_write.exe: 
	set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120
	$(MSBuild) Compilers\diskutils\diskutils.sln /m /p:Configuration=Release /verbosity:quiet /nologo


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
	$(GCC) $(GCCC) -Wl,--image-base=0x100000 -o Kernel\cmain.o Kernel\cmain.c

Kernel\keloader.o:
	$(NASM) -f elf64 -o Kernel\keloader.o Kernel\keloader.s

Kernel\keloader.exe: Kernel\cmain.o Kernel\keloader.o
	$(LD) -T Kernel\keloader.ld --image-base=0 --heap=0,0 --stack=0,0 --out-implib Kernel\keloader.exports.lib -static --export-all-symbols -Map Kernel\keloader.exports.map --output-def Kernel\keloader.exports.def -o Kernel\keloader.exe Kernel\keloader.o Kernel\cmain.o
	Compilers\grep.exe -i "^ \+\(0x[a-z0-9]\+\) \+\(\w\+\)" Kernel\keloader.exports.map | Compilers\awk.exe 'BEGIN{ print ";Generated file, do not modify\n[BITS 64]\n" }{print "global "$$2 "\n" $$2": \n push "$$1 "\n ret" }' > Kernel\keloader.exports.s
	$(NASM) -f elf64 -o Kernel\keloader.exports.s.o Kernel\keloader.exports.s

#$(GCC) -Wl,--image-base=0x100000 -ffreestanding -c -m64 -Wall -Wunused-value -o Kernel\keloader.exports.s.o Kernel\keloader.exports.s

Kernel\Keloader.os.bin: Kernel\keloader.exe
	$(OBJCOPY) --output-target=binary --image-base=0 --section-alignment=0 --stack=0 --heap=0 Kernel\keloader.exe Kernel\keloader.os.bin

Kernel\cskeloader.exe: Kernel\Combined.opt.o Kernel\pcitables.o
	$(NASM) -f elf64 -o Kernel\cskeloader.partial.s.o Kernel\cskeloader.partial.s
	$(LD) -T Kernel\cskeloader.ld --image-base=0 --heap=0,0 --stack=0,0 --out-implib Kernel\cskeloader.exports.lib --export-all-symbols -Map Kernel\cskeloader.exports.map --output-def Kernel\cskeloader.exports.def -o Kernel\cskeloader.exe Kernel\Combined.opt.o Kernel\keloader.exports.s.o Kernel\cskeloader.partial.s.o Kernel\pcitables.o

Kernel\csKeloader.os.bin: Kernel\cskeloader.exe
	$(OBJCOPY) --output-target=binary --image-base=0 --section-alignment=0 --stack=0 --heap=0 Kernel\cskeloader.exe Kernel\cskeloader.os.bin

Kernel\pcitables.o:
	$(GCC) $(GCCC) -Wl,--image-base=0x300000 -w -o Kernel\pcitables.o Kernel\pcitables.c

# C# kernel
Kernel\CSKernel.o: Kernel\CSKernel.ll
	$(LLC) $(LLCC) Kernel\CSKernel.ll
	
Kernel\CSKernel\bin\Debug\CSKernel.dll:
	set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120
	$(MSBuild) Kernel\CSKernel\CSKernel.sln /m /p:Configuration=Debug /verbosity:quiet /nologo

Kernel\CSKernel.ll: Kernel\CSKernel\bin\Debug\CSKernel.dll 
	$(Il2Bc) $(Il2BcC) /corelib:Kernel\CoreLib.dll Kernel\CSKernel\bin\Debug\CSKernel.dll
	copy CSKernel.ll Kernel\CSKernel.ll /Y 1> nul

Kernel\CoreLib.o: Kernel\CoreLib.ll
	$(LLC) $(LLCC) $(Root)\Kernel\CoreLib.ll

Kernel\CoreLib.ll:
	$(Il2Bc) $(Il2BcC) Kernel\CoreLib.dll
	copy CoreLib.ll Kernel\CoreLib.ll /Y 1> nul

Kernel\Combined.bc: Kernel\CSKernel.ll Kernel\CoreLib.ll
	$(LLVMLINK) Kernel\CSKernel.ll Kernel\CoreLib.ll -o Kernel\Combined.bc

#Kernel\llvm.ll
#Kernel\CoreLib.ll

Kernel\Combined.opt.bc: Kernel\Combined.bc
	copy Kernel\Combined.bc Kernel\Combined.opt.bc /Y 1> nul

#$(OPT) -O3 Kernel\Combined.bc -strip -o Kernel\Combined.opt.bc 

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
	del Kernel\CSKernel.ll 2> nul

	del Kernel\keloader.exe 2> nul
	del Kernel\keloader.os.bin 2> nul

	del OSDev_CHS_50_16_63.img 2> nul

	set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120
	$(MSBuild) Compilers\diskutils\diskutils.sln /p:Configuration=Release /target:clean
