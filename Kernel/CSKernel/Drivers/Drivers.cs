using CSKernel.Drivers;
using CSKernel.Drivers.Video;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.CompilerServices;
using System.Text;

namespace CSKernel.Drivers
{
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
    
            Drivers.Add("Display\\VGA", new Driver
            {
                Name = "VGA Display",
                DriverObject = new VGAVideo(),
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
}
