using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;

namespace CSKernel.Drivers.PCI
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public unsafe struct PCI_VENTABLE
    {
        public ushort VenId;
        public char* VenShort;
        public char* VenFull;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public unsafe struct PCI_DEVTABLE
    {
        public ushort VenId;
        public ushort DevId;
        public char* Chip;
        public char* ChipDesc;
    }
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public unsafe struct PCI_CLASSCODETABLE
    {
        public byte BaseClass;
        public byte SubClass;
        public byte ProgIf;
        public char* BaseDesc;
        public char* SubDesc;
        public char* ProgDesc;
    }

    public static unsafe class PCIDB
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        private extern unsafe static PCI_VENTABLE* getPCIVendors(out uint size);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        private extern unsafe static PCI_DEVTABLE* getPCIDevices(out uint size);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        private extern unsafe static PCI_CLASSCODETABLE* getPCIClasses(out uint size);

        private static readonly PCI_VENTABLE* PciVendorTable;
        private static readonly uint PciVendorTableSize;

        private static readonly PCI_DEVTABLE* PciDeviceTable;
        private static readonly uint PciDeviceTableSize;

        private static readonly PCI_CLASSCODETABLE* PciClassCodeTable;
        private static readonly uint PciClassCodeTableSize;

        static PCIDB()
        {
            PciVendorTable = getPCIVendors(out PciVendorTableSize);
            PciDeviceTable = getPCIDevices(out PciDeviceTableSize);
            PciClassCodeTable = getPCIClasses(out PciClassCodeTableSize);
        }

        public static bool FindVendor(ushort venId, out PCI_VENTABLE vendor)
        {
            for (int i = 0; i < PciVendorTableSize; i++)
            {
                var current = PciVendorTable[i];
                if (current.VenId == venId)
                {
                    vendor = current;
                }
            }

            vendor = default(PCI_VENTABLE);
            return false;
        }

        public static bool FindDevice(ushort venId, ushort devId, out PCI_DEVTABLE device)
        {
            for (int i = 0; i < PciDeviceTableSize; i++)
            {
                var current = PciDeviceTable[i];
                if (current.VenId == venId && current.DevId == devId)
                {
                    device = current;
                }
            }

            device = default(PCI_DEVTABLE);
            return false;
        }

        public static bool FindClass(byte baseClass, byte subClass, byte progIf, out PCI_CLASSCODETABLE _class)
        {
            for (int i = 0; i < PciClassCodeTableSize; i++)
            {
                var current = PciClassCodeTable[i];
                if (current.BaseClass == baseClass && current.SubClass  == subClass && current.ProgIf == progIf)
                {
                    _class = current;
                }
            }

            _class = default(PCI_CLASSCODETABLE);
            return false;
        }
    }
}
