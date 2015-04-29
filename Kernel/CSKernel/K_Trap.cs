using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel
{
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
}
