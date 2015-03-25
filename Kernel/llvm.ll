target triple = "x86_64"

declare i32 @"Int32 Program.CSMain()"() #0
;declare i8* @"Byte* K_Std._Znwj(Int32)"(i32 %"arg.0.size")

define i32 @llvmmain() #2 {
    %.r1 = call i32 @"Int32 Program.CSMain()"()
    ret i32 %.r1
}

;define noalias i8* @_Znwj(i32 %arg1) {
;	%.r1 = call i8* @"Byte* K_Std._Znwj(Int32)"(i32 %arg1)
;	ret i8* %.r1
;}
