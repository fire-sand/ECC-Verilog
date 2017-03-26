;; NOTE assumes that R2 and R3 are populated with the x and y
;; computes x * y and puts the result in R1(MSB) and R2(LSB)
;; BUG Check if top bits are cleared out if no overflow
;; reference:



MULT_SR CONST R6, #0  ; R6 <- 0, Both P or Both N
;ADD R0, R30, #0
;ADD R2, R0, R31
;GCAR R4
;ADD R3, R0, R31
;GCAR R5
CHKH R4                  ; R2 zp
BRz LBL_R3           ; if r2 is 0 or pos then branch
TCS R2, R2            ; R2 is negative so invert
CHKH R5               ; is R3 0 or pos
BRz LBL_R2N          ; if R3 is 0 then branch
TCS R3, R3            ; R3 is negative so invert
BRzp LBL_MULT         ; flipped both so can go straight to mult
LBL_R3 CHKH R5        ; R2 is 0 or pos, need to check R3
BRz LBL_MULT         ; if r3 is also 0 or pos
TCS R3, R3            ; r3 is negative so invert
LBL_R2N CONST R6, #1  ; need to set flag to invert at the end, only one was neg

; Do the actual Multiplication
LBL_MULT CONST R0, #255
ADD R0, R0, #1          ; N = 256
ADD R1, R1, #0
ADD R2, R2, #0
CONST R1, #0            ; A = 0;
CHECK_SR CONST R4, #0
CHKL R2        ; Check lowest bit of Q
BRz LBL_F               ; Yes/No
ADD R1, R1, R3          ; A <- A + B
GCAR R4
LBL_F SDRL R2, R1, R2   ; Shift A_Q right
SDRL R1, R4, R1         ; Shift A_Q right
ADD R0, R0, #-1         ; N <- N - 1
BRnp CHECK_SR           ; N == 0?

CHKH R6                 ; is R0 0 or 1
BRz LBL_END_MULT
TCS R2                  ; R2 is low bits
TCDH R1                 ; R1 is high bits
LBL_END_MULT ADD R1, R1, R2          ;TODO delte me
DONE       ; Return









;
; MULT_SR CONST R6, #0  ; R6 <- 0, Both P or Both N
; ADD R0, R30, #0
; ADD R2, R0, R31
; GCAR R4
; ADD R3, R0, R31
; GCAR R5
; CHKH R4                  ; R2 zp
; BRz LBL_R3           ; if r2 is 0 or pos then branch
; TCS R2, R2            ; R2 is negative so invert
; CHKH R5               ; is R3 0 or pos
; BRz LBL_R2N          ; if R3 is 0 then branch
; TCS R3, R3            ; R3 is negative so invert
; BRzp LBL_MULT         ; flipped both so can go straight to mult
; LBL_R3 CHKH R5        ; R2 is 0 or pos, need to check R3
; BRz LBL_MULT         ; if r3 is also 0 or pos
; TCS R3, R3            ; r3 is negative so invert
; LBL_R2N CONST R6, #1  ; need to set flag to invert at the end, only one was neg
;
; ; Do the actual Multiplication
; LBL_MULT CONST R0, #255
; ADD R0, R0, #1          ; N = 256
; ADD R1, R1, #0
; ADD R2, R2, #0
; CONST R1, #0            ; A = 0;
; CHECK_SR CONST R4, #0
; CHKL R2        ; Check lowest bit of Q
; BRz LBL_F               ; Yes/No
; ADD R1, R1, R3          ; A <- A + B
; GCAR R4
; LBL_F SDRL R2, R1, R2   ; Shift A_Q right
; SDRL R1, R4, R1         ; Shift A_Q right
; ADD R0, R0, #-1         ; N <- N - 1
; BRnp CHECK_SR           ; N == 0?
;
; CHKH R6                 ; is R0 0 or 1
; BRz LBL_END_MULT
; TCS R2                  ; R2 is low bits
; TCDH R1                 ; R1 is high bits
; LBL_END_MULT ADD R0, R1, R2          ; check the values
; DONE       ; Return
