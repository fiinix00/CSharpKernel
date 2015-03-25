Il2Bc.exe /roslyn helloworld.cs /corelib:CoreLib.dll
Il2Bc.exe CoreLib.dll
llc -filetype=obj -mtriple=i686-w64-mingw32 CoreLib.ll
llc -filetype=obj -mtriple=i686-w64-mingw32 helloworld.ll
g++ -o helloworld.exe helloworld.obj CoreLib.obj -lstdc++ -lgc-lib -march=i686 -L .
helloworld.exe