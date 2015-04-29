using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers
{
    //https://github.com/versidyne/vexis-os/blob/master/src/drivers/sound.c
    public static class Sound
    {
        public static void Play(uint nFrequence)
        {
            uint Div = 1193180 / nFrequence;

            IO.outb(0x43, 0xb6);
            IO.outb(0x42, (byte)(Div));
            IO.outb(0x42, (byte)(Div >> 8));

            byte tmp = IO.inb(0x61);

            if (tmp != (tmp | 3))
            {
                IO.outb(0x61, (byte)(tmp | 3));
            }
        }

        public static void Stop()
        {
            byte tmp = (byte)(IO.inb(0x61) & 0xFC);
            IO.outb(0x61, tmp);
        }

        public static void PlayNote(uint nFrequence, uint nDuration)
        {
            // Play note
            Play(nFrequence);

            // Wait for duration
            //timer_wait(nDuration);
            Extern.udelay(nDuration);

            // Stop sound
            Stop();
        }
    }
}
