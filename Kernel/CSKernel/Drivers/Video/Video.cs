using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel.Drivers.Video
{
    public abstract class VideoDriver
    {
        public abstract void SetData(int x, int y, int data);
    }
}
