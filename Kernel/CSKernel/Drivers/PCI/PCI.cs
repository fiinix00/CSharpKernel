using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace CSKernel.Drivers.PCI
{
    public struct PCIDevice
    {
        public ushort VendorID;
        public ushort DeviceID;
        public ushort CommandReg;
        public ushort StatusReg;
        public byte RevisionID;
        public byte ProgIF;
        public byte SubClass;
        public byte ClassCode;
        public byte CachelineSize;
        public byte Latency;
        public byte HeaderType;
        public byte BIST;

        public uint BAR0; //Base Address Register
        public uint BAR1;
        public uint BAR2;
        public uint BAR3;
        public uint BAR4;
        public uint BAR5;
        public uint CardbusCISPtr;
        public ushort SubVendorID; //Subsystem
        public ushort SubDeviceID;
        public uint ExRomAddress; //Expansion ROM
        public uint Reserved1;
        public uint Reserved2;
        public byte IRQ; //IRQ number
        public byte PIN; //IRQ PIN number
        public byte MinGrant;
        public byte MaxLatency;
    }

    //https://github.com/versidyne/vexis-os/blob/master/src/drivers/pci.c
    public class PCI
    {
        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        private struct PCI_BIOS
        {
            public uint Magic;
            public uint EntryPoint;
            public byte Version;
            public byte Pages;
            public byte CRC;
        }

        private struct PCIArgs
        {
            public ushort VendorID;
            public ushort DeviceID;
            public uint BAR0;
            public uint BAR1;
            public uint BAR2;
            public uint BAR3;
            public uint BAR4;
            public uint BAR5;
            public byte IRQ;
        }

        public static unsafe bool Existant(out uint address)
        {
            uint addr;
            byte crc;
            int i;

            for (addr = 0xE0000; addr < 0xFFFFF; addr += 0x10)
            {
                PCI_BIOS* pci_bios = (PCI_BIOS*)addr;
                if (pci_bios->Magic == 0x5F32335F)
                {
                    for (i = 0, crc = 0; i < (pci_bios->Pages * 16); i++)
                        crc += *((byte*)(addr + i));
                    if (crc == 0)
                    {
                        address = addr;
                        return true;
                    }
                }
            }


            address = 0;
            return false;
        }

        public static uint Read(uint bus, uint dev, uint func, uint reg)
        {
            IO.outl(0xCF8, (uint)0x80000000 | (bus << 16) | (dev << 11) | (func << 8) | reg);
            return IO.inl(0xCFC);
        }

        public static unsafe PCIDevice ReadDevice(uint bus, uint dev, uint func)
        {
            PCIDevice ret = default(PCIDevice);

            uint place, total = (uint)(sizeof(PCIDevice) / sizeof(uint));

            for (place = 0; place < total; place++)
                ((uint*)&ret)[place] = Read(bus, dev, func, (place * sizeof(uint)));

            return ret;
        }

        public static List<PCIDevice> GetDevices()
        {
            var list = new List<PCIDevice>();

            for (uint bus = 0; bus <= 0xFF; bus++)
            {
                for (uint device = 0; device < 32; device++)
                {
                    for (uint function = 0; function < 8; function++)
                    {
                        var current = ReadDevice(bus, device, function);

                        var invalid = (current.VendorID == 0) || (current.VendorID == 0xFFFF) || (current.DeviceID == 0xFFFF);

                        if (!invalid)
                        {
                            list.Add(current);
                        }
                    }
                }
            }

            return list;
        }
    }
}
