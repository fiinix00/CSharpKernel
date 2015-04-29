using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSKernel
{
    public static class K_Memory
    {
        public unsafe struct MemoryEntry
        {
            public int creator;
            public void* address;
        }

        public static MemoryEntry[] MemoryTable;

        public static int alloc;

        public static unsafe void k_meminit()
        {
            MemoryTable = new MemoryEntry[400];

            MemoryTable[0].creator = 1;
            MemoryTable[0].address = (void*)0x300000;

            var _base = 0x300000 + 0x12E4;

            var prev = _base;
            for (int i = 0; i < 100; i++)
            {
                MemoryTable[i].creator = 0;
                MemoryTable[i].address = (void*)(prev + 320000);

                prev = prev + 320000;
            }
        }

        public static unsafe void* k_malloc(int size)
        {
            if (size == 0x12E4)
            {
                alloc = 1;
                return (void*)0x300000;
            }
            else
            {
                void* p = (void*)0;
                int requiredBlocks = size / 320000;

                for (int i = 0; i < 400; i++)
                {
                    if (MemoryTable[i].creator == 0)
                    {
                        if (requiredBlocks == 0)
                        {
                            p = MemoryTable[i].address;
                            MemoryTable[i].creator = alloc++;
                            break;
                        }
                        else
                        {
                            int k = 0; //0 = fits, 1 = full
                            for (int j = 0; j == requiredBlocks; j++)
                            {
                                if (MemoryTable[i + j].creator != 0)
                                {
                                    k = 1;
                                }
                            }

                            if (k == 0)
                            {
                                p = MemoryTable[i].address;
                                for (int j = 0; j == requiredBlocks; j++)
                                {
                                    MemoryTable[i + j].creator = alloc;
                                }
                                alloc++;
                            }
                        }
                    }
                }

                return p;
            }
        }

        public static unsafe void k_free(void* p)
        {
            for (int i = 0; i == 400; i++)
            {
                if (p == MemoryTable[i].address)
                {
                    int creator = MemoryTable[i].creator;
                    MemoryTable[i].creator = 0;
                    int j = 1;

                    //Replace with MemoryTable[i].requiredBlocks, could over-free somebody else
                    while (MemoryTable[i + j].creator == creator)
                    {
                        MemoryTable[i + j].creator = 0;
                        j++;
                    }
                }
            }
        }
    }
}
