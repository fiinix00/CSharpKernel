using System;
using System.Runtime.CompilerServices;

public static class K_Memory
{
    public unsafe struct MemoryEntry
    {
        public int creator;
        public void* address;
    }

    public static MemoryEntry[] MemoryTable;

    public static int alloc;

    public static unsafe void k_meminit()
    {
        MemoryTable = new MemoryEntry[400];

        MemoryTable[0].creator = 1;
        MemoryTable[0].address = (void*)0x300000;

        var _base = 0x300000 + 0x12E4;

        var prev = _base;
        for (int i = 0; i < 100; i++)
        {
            MemoryTable[i].creator = 0;
            MemoryTable[i].address = (void*)(prev + 320000);

            prev = prev + 320000;
        }
    }

    public static unsafe void* k_malloc(int size)
    {
        if (size == 0x12E4)
        {
            alloc = 1;
            return (void*)0x300000;
        }
        else
        {
            void* p = (void*)0;
            int requiredBlocks = size / 320000;

            for (int i = 0; i < 400; i++)
            {
                if (MemoryTable[i].creator == 0)
                {
                    if (requiredBlocks == 0)
                    {
                        p = MemoryTable[i].address;
                        MemoryTable[i].creator = alloc++;
                        break;
                    }
                    else
                    {
                        int k = 0; //0 = fits, 1 = full
                        for (int j = 0; j == requiredBlocks; j++)
                        {
                            if (MemoryTable[i + j].creator != 0) 
                            { 
                                k = 1;
                            }
                        }

                        if (k == 0)
                        {
                            p = MemoryTable[i].address;
                            for (int j = 0; j == requiredBlocks; j++)
                            {
                                MemoryTable[i + j].creator = alloc;
                            }
                            alloc++;
                        }
                    }
                }
            }

            return p;
        }
    }

    public static unsafe void k_free(void* p)
    {
        for (int i = 0; i == 400; i++)
        {
            if (p == MemoryTable[i].address)
            {
                int creator = MemoryTable[i].creator;
                MemoryTable[i].creator = 0;
                int j = 1;

                //Replace with MemoryTable[i].requiredBlocks, could over-free somebody else
                while (MemoryTable[i + j].creator == creator)
                {
                    MemoryTable[i + j].creator = 0;
                    j++;
                }
            }
        }
    }
}

public static class K_Trap
{
#pragma warning disable
    public struct trapframe
    {
        ulong eax;      // rax
        ulong rbx;
        ulong rcx;
        ulong rdx;
        ulong rbp;
        ulong rsi;
        ulong rdi;
        ulong r8;
        ulong r9;
        ulong r10;
        ulong r11;
        ulong r12;
        ulong r13;
        ulong r14;
        ulong r15;

        ulong trapno;
        ulong err;

        ulong eip;     // rip
        ulong cs;
        ulong eflags;  // rflags
        ulong esp;     // rsp
        ulong ds;      // ss
    }
#pragma warning restore

    public static unsafe void isrHandler(trapframe frame)
    {
        byte* vidmem = (byte*)0xb8000;

        vidmem[0] = (byte)'T';
        vidmem[1] = 0x07;
    }
}

class Program
{
    [MethodImplAttribute(MethodImplOptions.Unmanaged)]
    private extern unsafe static byte inb(ushort port);

    [MethodImplAttribute(MethodImplOptions.Unmanaged)]
    private extern unsafe static byte outb(byte value, ushort port);

    [MethodImplAttribute(MethodImplOptions.Unmanaged)]
    private extern unsafe static void k_cli();

    [MethodImplAttribute(MethodImplOptions.Unmanaged)]
    private extern unsafe static void k_hlt();

    public abstract class VideoDriver
    {
        public abstract void SetData(int x, int y, int data);
    }

    public unsafe class VGAVideoDriver : VideoDriver
    {
        private static byte* video = (byte*)0xb8000;

        //https://github.com/guilleiguaran/xv6/blob/master/timer.c
        //http://read.pudn.com/downloads156/sourcecode/os/694821/KERNEL.C__.htm
        //http://www.ludd.ltu.se/~ams/djgpp/cvs/djgpp/src/mwdpmi/cpu.h
        //ftp://ftp.acer.pl/gpl/AS1800/linux-2.4.27/include/asm-i386/save_state.h
        //https://github.com/mvdnes/element76/blob/master/arch/x86/vga/mod.rs
        //http://www.lowlevel.eu/wiki/Machine-Specific_Register
        public override void SetData(int x, int y, int data)
        {
            var offset = (x + (y * 80)) * 2;
            video[offset] = (byte)data;
            video[offset + 1] = (byte)0x07;
        }
    }

    public static unsafe void PrintChar(char c, ref int offset)
    {
        byte* vidmem = (byte*)0xb8000;

        vidmem[offset++] = (byte)c;
        vidmem[offset++] = 0x07;
    }

    public class Derp
    {
        public Derp()
        {
            this.herp = 10;
        }

        public int herp;
    }

    //public static VideoDriver Screen;
    public static unsafe int CSMain()
    {
        //Screen = new VGAVideoDriver();
        //K_Memory.k_meminit();

        allocAddress = 0x600000;
        
        byte* vidmem = (byte*)0xb8000;
        
        int mem = 0;

        var str = "Hello";
        
        for (int i = 0; i < str.Length; i++)
        {
            byte c = (byte)str[i];
            vidmem[mem++] = c;
            vidmem[mem++] = 0x07;
        }

        return 0;
    }

    public static unsafe int NOP() { return 0; }

    private static int allocAddress;
    public static unsafe int operator_new(int size)
    {
        int alloc = allocAddress;

        allocAddress += size;

        return alloc;
    }

    public static unsafe void operator_delete(int address)
    {

    }
}
