using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers.Video
{
    public unsafe class VGAVideo : VideoDriver
    {
        public static byte* VideoPointer = (byte*)0xb8000;
        public const int Rows = 25;
        public const int Columns = 80;

        private int offset = 0;

        public int CursorX
        {
            get
            {
                return offset % Columns;
            }
        }

        public int CursorY
        {
            get
            {
                return (offset - (offset % Columns)) / Columns;
            }
        }

        public void HideCursor()
        {
            IO.outb(0x3d4, 0x0a);
            IO.outb(0x3d5, 1 << 5);
        }

        //https://github.com/guilleiguaran/xv6/blob/master/timer.c
        //http://read.pudn.com/downloads156/sourcecode/os/694821/KERNEL.C__.htm
        //http://www.ludd.ltu.se/~ams/djgpp/cvs/djgpp/src/mwdpmi/cpu.h
        //ftp://ftp.acer.pl/gpl/AS1800/linux-2.4.27/include/asm-i386/save_state.h
        //https://github.com/mvdnes/element76/blob/master/arch/x86/vga/mod.rs
        //http://www.lowlevel.eu/wiki/Machine-Specific_Register
        public override void SetData(int x, int y, int data)
        {
            var offset = (x + (y * 80)) * 2;
            VideoPointer[offset] = (byte)data;
            VideoPointer[offset + 1] = (byte)0x07;
        }

        public unsafe void PrintChar(char c)
        {
            VideoPointer[offset++] = (byte)c;
            VideoPointer[offset++] = 0x07;
        }

        public void PrintString(string str)
        {
            for (int i = 0; i < str.Length; i++)
            {
                PrintChar(str[i]);
            }
        }

        public void Scroll()
        {
            const ushort crtc_adr = 0x3D4; /* 0x3B4 for monochrome */

            /* the CRTC index is at crtc_adr + 0
            select register 12 */
            IO.outb(crtc_adr + 0, 12);
            /* the selected CRTC register appears at crtc_adr + 1 */
            IO.outb(crtc_adr + 1, (byte)(offset >> 8));
            IO.outb(crtc_adr + 0, 13);
            IO.outb(crtc_adr + 1, (byte)(offset & 0xFF));
        }
    }
}
