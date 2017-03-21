;; module epxects inputs in r2 and r3, need to move r1 <- r2
ADD R1, R3, #0 ;
; Mod expects inputs in R1 and R2
; Mod Step
; TCS R2
; TCDH R1
MOD_SR SLL R0, R1, #4  ; R5 <- p << 4
SLL R6, R1, #1  ; R6 <- p << 1
ADD R0, R0, R6  ; R5 <- p << 4 + p << 1
ADD R3, R1, #0  ; R3 <- R1
ADD R0, R0, R3  ; R5 <- p << 4 + p << 1 + p
ADD R0, R0, R2  ; R5 <- p << 4 + p << 1 + p + r
; ADD R2, R0, #0
; ADD R1, R4, #0
; SUB R0, R1, R2
DONE             ; Result placed in R0 TODO need to add signed and 255 bit split
