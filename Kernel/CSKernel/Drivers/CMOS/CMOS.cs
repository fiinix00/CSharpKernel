using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers
{
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
                IO.outb(0x70, (byte)field);
                return IO.inb(0x71);
            }
            set
            {
                IO.outb(0x70, (byte)field);
                IO.outb(0x71, value);
            }
        }
    }
}
