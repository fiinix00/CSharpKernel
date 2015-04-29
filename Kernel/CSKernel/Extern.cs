using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

namespace CSKernel
{
    public static class Marshal
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static Action AddressToFunction(void* method);
    }

    public static class Extern
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void k_cli();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void k_hlt();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void udelay(uint n);
    }

    public static class IO
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe byte inb(ushort port);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe uint inl(ushort port);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void outb(ushort port, byte value);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void outl(ushort port, uint value);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void bl_read(int drive, int numblock, int count, byte* buf);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void bl_write(int drive, int numblock, int count, byte* buf);
    }

    public static class CCtors
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void VGAVideo_cctor();


        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void corelib_cctors();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void cskernel_cctors();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void DateTime_cctor();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void BitConverter_cctor();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void Boolean_cctor();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void Math_cctor();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void String_cctor();

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public extern unsafe static void Number_cctor();
    }
}
