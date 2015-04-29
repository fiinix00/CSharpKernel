using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers
{
    public class HDD
    {
        public unsafe byte[] ReadSector(int sector)
        {
            var buffer = new byte[512];

            fixed (byte* bufferPtr = buffer)
            {
                IO.bl_read(0, sector, 1, bufferPtr);
            }

            return buffer;
        }

        public unsafe void WriteSector(int sector, byte[] buffer)
        {
            fixed (byte* bufferPtr = buffer)
            {
                IO.bl_write(0, sector, 1, bufferPtr);
            }
        }
    }
}
