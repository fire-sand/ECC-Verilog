;; NOTE assumes that R2 and R3 are populated with the x and y
;; computes x * y and puts the result in R1(MSB) and R2(LSB)
;; BUG Check if top bits are cleared out if no overflow
;; reference:


MULT_SR CONST R6, #0  ; R6 <- 0, Both P or Both N
CHKH R2               ; R2 zp
BRzp LBL_R3           ; if r2 is 0 or pos then branch
TCS R2, R2            ; R2 is negative so invert
CHKH R3               ; is R3 0 or pos
BRzp LBL_R2N          ; if R3 is 0 or pos then branch
TCS R3, R3            ; R3 is negative so invert
BRzp LBL_MULT         ; flipped both so can go straight to mult
LBL_R3 CHKH R3        ; R2 is pos, need to check R3
BRzp LBL_MULT         ; if r3 is also pos or 0
TCS R3, R3            ; r3 is negative so invert
LBL_R2N CONST R6, #1  ; need to set flag to invert at the end, only one was neg
; Do the actual Multiplication
LBL_MULT CONST R0, #255
ADD R0, R0, #1          ; N = 256
CONST R1, #0            ; A = 0;
CHECK_SR CHKL R2        ; Check lowest bit of Q
BRz LBL_F               ; Yes/No
ADD R1, R1, R3          ; A <- A + B
LBL_F SDRH R1, R1, R2   ; Shift A_Q right
SDRL R2, R1, R2         ; Shift A_Q right
ADD R0, R0, #-1         ; N <- N - 1
BRnp CHECK_SR           ; N == 0?
SDL R1, R1, R2          ; split into {257,255}
CHKL R6                 ; is R0 0 or 1
BRz LBL_END_MULT
TCS R2                  ; R2 is low bits
TCDH R1                 ; R1 is high bits
LBL_END_MULT DONE       ; Return
