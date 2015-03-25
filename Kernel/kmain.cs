using System;
using System.Runtime.CompilerServices;

class K_Std
{
    public static unsafe byte* _Znwj(int size)
    {
        return (byte*)0;
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

        //http://read.pudn.com/downloads156/sourcecode/os/694821/KERNEL.C__.htm
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

    public static VideoDriver Screen;
    public static unsafe int CSMain()
    {
        int i = 0;

        PrintChar('H', ref i);
        PrintChar('e', ref i);
        PrintChar('l', ref i);
        PrintChar('l', ref i);
        PrintChar('o', ref i);
        PrintChar(' ', ref i);
        PrintChar('C', ref i);
        PrintChar('#', ref i);

        return 0;
    }
}
