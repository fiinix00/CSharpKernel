using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

namespace kmain.vs
{
    public static class IO
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe byte inb(ushort port);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe byte outb(byte value, ushort port);

        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        public static extern unsafe void udelay(uint n);
    }
    //http://wiki.osdev.org/Serial_Ports
    public class Serial
    {
        /*

        COM1	3F8h
        COM2	2F8h
        COM3	3E8h
        COM4	2E8h
        
        */

        private ushort port;
        public Serial(ushort port)
        {
            this.port = port;
        }

        public void Start()
        {
            IO.outb(0x00, (ushort)(port + 1)); // Disable all interrupts
            IO.outb(0x80, (ushort)(port + 3)); // Enable DLAB (set baud rate divisor)
            IO.outb(0x03, (ushort)(port + 0)); // Set divisor to 3 (lo byte) 38400 baud
            IO.outb(0x00, (ushort)(port + 1)); //                  (hi byte)
            IO.outb(0x03, (ushort)(port + 3)); // 8 bits, no parity, one stop bit
            IO.outb(0xC7, (ushort)(port + 2)); // Enable FIFO, clear them, with 14-byte threshold
            IO.outb(0x0B, (ushort)(port + 4)); // IRQs enabled, RTS/DSR set
        }

        public bool Recieved()
        {
            return (IO.inb((ushort)(port + 5)) & 1) == 1;
        }

        public byte Read()
        {
            while (!Recieved()) { }

            return IO.inb(port);
        }

        public int ReadDirect()
        {
            if (Recieved()) 
            {
                return IO.inb(port);
            }

            return -1;
        }

        public bool IsTransmitEmpty()
        {
            return (IO.inb((ushort)(port + 5)) & 0x20) == 0x20;
        }

        public void Write(byte data)
        {
            while (!IsTransmitEmpty()) { }

            IO.outb(data, port);
        }
    }

    public class EverythingFileDictionary<T>
    {
        Dictionary<string, T> Enties = new Dictionary<string, T>();

        Dictionary<string, EverythingFileDictionary<T>> Children = new Dictionary<string, EverythingFileDictionary<T>>();

        //public void Add(string path, T item)
        //{
        //    var index = path.IndexOf('\\');
        //
        //    if (index > 0)
        //    {
        //        var before = path.Substring(0, index);
        //        var parts = path.Substring(index);
        //
        //    }
        //    else
        //    {
        //        if (Enties.ContainsKey(path))
        //        {
        //            Enties[path] = item;
        //        }
        //        else
        //        {
        //            Enties.Add(path, item);
        //        }
        //    }
        //}
    }

    public class Driver
    {
        public static Dictionary<string, Driver> Drivers = new Dictionary<string, Driver>();

        public static T DriversFindByType<T>() where T : class
        {
            foreach (var driver in Drivers)
            {
                var driverObject = driver.Value.DriverObject as T;

                if (driverObject != null)
                {
                    return driverObject;
                }
            }

            return null;
        }

        private static void addSerial(string name, ushort port)
        {
            Drivers.Add(name, new Driver
            {
                Name = "SerialPort" + name,
                DriverObject = new Serial(port),
                Type = DriverType.Hardware,
                Interface = InterfaceType.IO,
                Flags = 0
            });
        }

        static Driver()
        {
            addSerial("Serial\\COM1", 0x3F8);
            addSerial("Serial\\COM2", 0x2F8);
            addSerial("Serial\\COM3", 0x3E8);
            addSerial("Serial\\COM4", 0x2E8);

            Drivers.Add("Storage\\HDD1", new Driver
            {
                Name = "HDD1", 
                DriverObject = new HDD(),
                Type = DriverType.Hardware,
                Interface = InterfaceType.IO,
                Flags = 0
            });

            Drivers.Add("CMOS", new Driver
            {
                Name = "CMOS",
                DriverObject = new CMOS(),
                Type = DriverType.Hardware,
                Interface = InterfaceType.IO,
                Flags = 0
            });

            Drivers.Add("CMOS\\Clock", new Driver
            {
                Name = "CMOSClock",
                DriverObject = new CMOSClock(),
                Type = DriverType.Hardware,
                Interface = InterfaceType.IO,
                Flags = 0
            });
        }

        public enum DriverType
        {
            Hardware, 
            Virtual
        }

        public enum InterfaceType
        {
            IO
        }

        public string Name;
        public DriverType Type;
        public uint Flags;
        public InterfaceType Interface;
        public Object DriverObject;
    }

    public class CMOS
    {
        public const byte RTC_REGISTER_A = 0x0A;
        public const byte RTC_REG_A_UIP = 0x80;

        public enum Fields : byte
        {
            Second = 0,
            Minute = 2,
            Hour = 4,
            Weekday = 6,
            Day = 7,
            Month = 8,
            Year = 9,

            UIP = RTC_REGISTER_A
        }

        public byte this[Fields field]
        {
            get
            {
                IO.outb((byte)field, 0x70);
                return IO.inb(0x71);
            }
            set
            {
                IO.outb((byte)field, 0x70);
                IO.outb(value, 0x71);
            }
        }
    }

    public class CMOSClock
    {
        private CMOS cmos = Driver.DriversFindByType<CMOS>();

        private int BCD_INT(byte bcd)
        {
            return (((bcd & 0xf0) >> 4) * 10 + (bcd & 0x0f));
        }

        private byte INT_BCD(int i)
        {
            return (byte)(((i / 10) << 4) + (i % 10));
        }

        public bool IsUpdateInProgress()
        {
            return (cmos[CMOS.Fields.UIP] & CMOS.RTC_REG_A_UIP) != 0;
        }

        public DateTime Date
        {
            get
            {
                while (IsUpdateInProgress()) { IO.udelay(1); };

                int second = BCD_INT(cmos[CMOS.Fields.Second]);
                int minute = BCD_INT(cmos[CMOS.Fields.Minute]);
                int hour = BCD_INT(cmos[CMOS.Fields.Hour]);
                int weekday = BCD_INT(cmos[CMOS.Fields.Weekday]);
                int day = BCD_INT(cmos[CMOS.Fields.Day]);
                int month = BCD_INT(cmos[CMOS.Fields.Month]);
                int year = BCD_INT(cmos[CMOS.Fields.Year]);
                
                IO.udelay(1);

                year += (year > 80) ? 1900 : 2000;

                return new DateTime(year, month, day, hour, minute, second);
            }
            set
            {
                while (IsUpdateInProgress()) { IO.udelay(1); };

                cmos[CMOS.Fields.Second] = INT_BCD(value.Second);
                cmos[CMOS.Fields.Minute] = INT_BCD(value.Minute);
                cmos[CMOS.Fields.Hour] = INT_BCD(value.Hour);
                cmos[CMOS.Fields.Weekday] = INT_BCD((int)value.DayOfWeek);
                cmos[CMOS.Fields.Day] = INT_BCD(value.Day);
                cmos[CMOS.Fields.Month] = INT_BCD(value.Month);
                cmos[CMOS.Fields.Year] = INT_BCD(value.Year % 100);
            }
        }
    }

    public class HDD
    {
        [MethodImplAttribute(MethodImplOptions.Unmanaged)]
        private extern unsafe static void read_ide_sector(uint sector, byte* buffer);

        public unsafe byte[] ReadSector(uint sector)
        {
            var buffer = new byte[512];

            fixed (byte* bufferPtr = buffer)
            {
                read_ide_sector(sector, bufferPtr);
            }
            
            return buffer;
        }
    }
}
