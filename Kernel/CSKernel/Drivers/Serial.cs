using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers
{
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
            IO.outb((ushort)(port + 1), 0x00); // Disable all interrupts
            IO.outb((ushort)(port + 3), 0x80); // Enable DLAB (set baud rate divisor)
            IO.outb((ushort)(port + 0), 0x03); // Set divisor to 3 (lo byte) 38400 baud
            IO.outb((ushort)(port + 1), 0x00); //                  (hi byte)
            IO.outb((ushort)(port + 3), 0x03); // 8 bits, no parity, one stop bit
            IO.outb((ushort)(port + 2), 0xC7); // Enable FIFO, clear them, with 14-byte threshold
            IO.outb((ushort)(port + 4), 0x0B); // IRQs enabled, RTS/DSR set
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

            IO.outb(port, data);
        }
    }
}
