;; module epxects inputs in r2 and r3, need to move r1 <- r2
ADD R1, R3, #0 ; only because of test bench
MOD_SR CHKH R1               ; R1 zp
BRzp LBL_MOD
TCS R2
TCDH R1
CONST R4, #1  ; need to set flag to invert at the end, only one was neg
LBL_MOD SLL R2, R2, #1   
SRL R2, R2, #1 ; ^ and this clear out top bit
SLL R0, R1, #4  ; R5 <- p << 4
SLL R6, R1, #1  ; R6 <- p << 1
ADD R0, R0, R6  ; R0 <- p << 4 + p << 1
ADD R3, R1, #0  ; R3 <- R1
ADD R0, R0, R3  ; R5 <- p << 4 + p << 1 + p
ADD R0, R0, R2  ; R5 <- p << 4 + p << 1 + p + r
CHKL R4                 ; is R0 0 or 1
BRz LBL_END_MOD
ADD R2, R0, #0
ADD R1, R16, #0
SUB R0, R1, R2
LBL_END_MOD DONE             ; Result placed in R0 TODO need to add signed and 255 bit split
