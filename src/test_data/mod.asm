;; module epxects inputs in r2 and r3, need to move r1 <- r2
ADD R1, R3, #0 ; only because of test bench
; expects inputs in R1 and R2
MOD_SR CONST R5 #0 ; erase state
CHKH R1               ; R1 zp
BRzp LBL_MOD
TCS R2
TCDH R1
CONST R5, #1  ; need to set flag to invert at the end, only one was neg
LBL_MOD SDL R1, R1, R2 ; split into 257 and 255
SLL R2, R2, #1
SRL R2, R2, #1 ; ^ and this clear out top bit
CONST R3, #0
ADD R0, R1, #0   ; R0 <- p
ADD R4, R1, #0   ; R4 <- p
ADD R4, R1, R2   ; {carry, R4} <- p + r
ADDc R3, R3      ; R3 = R3 + carry
SLL R1, R0, #4   ; R1 <- p[WORD_SIZE-5:0]
ADD R4, R1, R4   ; {carry, R4} <- R4 + p[WORD_SIZE-5:0]
ADDc R3, R3      ; R3 = R3 + carry
SLL R1, R0, #1   ; R1 <- p[WORD_SIZE-2:0]
ADD R4, R1, R4   ; {carry, R4} <- R4 + p[WORD_SIZE-1:0]
ADDc R3, R3      ; R3 = R3 + carry
SRL R1, R0, #14 ; R1 = p[WORD_SIZE-2:WORD_SIZE-5]
ADD R3, R1, R3   ; R3 = R3 + p[WORD_SIZE-2:WORD_SIZE-5]
SRL R1, R0, #15 ; R1 = p[WORD_SIZE-2]
ADD R3, R1, R3   ; R3 = R3 + p[WORD_SIZE-2]
ADD R2, R4, #0   ; R2 = R4
ADD R1, R3, #0   ; R1 = R3
BRnp LBL_MOD      ; If top bits aren't empty, then need to run mod again
ADD R0, R16, #0  ; move R16 to R0
SUB R4, R0, R2   ; Check if R16 > R2
BRnz LBL_MOD
ADD R0, R2, #0   ; Move result into R0
CHKL R5                 ; is R0 0 or 1
BRz LBL_END_MOD
ADD R2, R0, #0
ADD R1, R16, #0
SUB R0, R1, R2

LBL_END_MOD DONE  ; Result placed in R0 TODO need to add signed and 255 bit split