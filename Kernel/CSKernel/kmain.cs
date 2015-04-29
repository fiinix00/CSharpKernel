using CSKernel;
using CSKernel.Drivers.PCI;
using System;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("CSKernel")]
[assembly: AssemblyDescription("CSKernel")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("")]
[assembly: AssemblyProduct("CSKernel")]
[assembly: AssemblyCopyright("CSKernel")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: ComVisible(false)]

[assembly: AssemblyVersion("0.1.0.0")]
[assembly: AssemblyFileVersion("0.1.0.0")]

namespace CSKernel
{
    public class Program
    {
        private static int allocAddress;

        private static void pre()
        {
            allocAddress = 0x600000;

            CCtors.VGAVideo_cctor();
            CCtors.BitConverter_cctor();
            CCtors.Boolean_cctor();
            CCtors.Math_cctor();
            CCtors.String_cctor();
            CCtors.Number_cctor();
            CCtors.DateTime_cctor();
        }

        public static unsafe int CSMain()
        {
            pre();

            return 0;
        }

        public static unsafe int NOP() { return 0; }

        public static unsafe int operator_new(int size)
        {
            int alloc = allocAddress;

            allocAddress += size;

            return alloc;
        }

        public static unsafe void operator_delete(int address) { }
    }
}