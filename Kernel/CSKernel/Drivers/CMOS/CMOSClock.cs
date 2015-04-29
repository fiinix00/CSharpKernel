using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers
{
    //C:\Users\Steven\Documents\Sync\OSDev\Kernel\CSKernel\Drivers\PCI\Time.cs
    public class CMOSClock
    {
        private CMOS cmos = new CMOS();

        public class CMOSDate
        {
            public int Second, Minute, Hour, Weekday, Day, Month, Year;
        }

        public static int BCD_INT(byte bcd)
        {
            return (((bcd & 0xf0) >> 4) * 10 + (bcd & 0x0f));
        }

        public static byte INT_BCD(int i)
        {
            return (byte)(((i / 10) << 4) + (i % 10));
        }

        public bool IsUpdateInProgress()
        {
            return (cmos[CMOS.Fields.UIP] & CMOS.RTC_REG_A_UIP) != 0;
        }

        public CMOSDate Date
        {
            get
            {
                while (IsUpdateInProgress()) { Extern.udelay(1); };

                int second = BCD_INT(cmos[CMOS.Fields.Second]);
                int minute = BCD_INT(cmos[CMOS.Fields.Minute]);
                int hour = BCD_INT(cmos[CMOS.Fields.Hour]);
                int weekday = BCD_INT(cmos[CMOS.Fields.Weekday]);
                int day = BCD_INT(cmos[CMOS.Fields.Day]);
                int month = BCD_INT(cmos[CMOS.Fields.Month]);
                int year = BCD_INT(cmos[CMOS.Fields.Year]);

                year += (year > 80) ? 1900 : 2000;

                return new CMOSDate
                {
                    Second = second,
                    Minute = minute,
                    Hour = hour,
                    Weekday = weekday,
                    Day = day,
                    Month = month,
                    Year = year
                };
            }
            set
            {
                while (IsUpdateInProgress()) { Extern.udelay(1); };

                cmos[CMOS.Fields.Second] = INT_BCD(value.Second);
                cmos[CMOS.Fields.Minute] = INT_BCD(value.Minute);
                cmos[CMOS.Fields.Hour] = INT_BCD(value.Hour);
                cmos[CMOS.Fields.Weekday] = INT_BCD((int)value.Weekday);
                cmos[CMOS.Fields.Day] = INT_BCD(value.Day);
                cmos[CMOS.Fields.Month] = INT_BCD(value.Month);
                cmos[CMOS.Fields.Year] = INT_BCD(value.Year % 100);
            }
        }
    }
}
