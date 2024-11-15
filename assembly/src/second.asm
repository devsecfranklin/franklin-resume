//
//  Print Hello world
//
        .text
        .global _start

_start:
        mov  x8,64       // write system call
        mov  x0,1        // file (stdout)
        adr  x1,message
        mov  x2,14       // message length
