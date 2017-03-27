


;; POINT_ADD requirements
; R23 <- 2 * d
;; pt1
; R24 <- X1
; R25 <- Y1
; R26 <- Z1
; R27 <- T1
;; pt2
; R28 <- X2
; R29 <- Y2
; R30 <- Z2
; R31 <- T2

; R8 <- A = ((Y1-X1)*(Y2-X2)) % q
POINT_ADD_SR ADD R0, R25, #0 ; R0 <- Y1, Need to do this move because of Proc
ADD R22, R7, #0 ; Save PC of RET
SUB R2, R0, R24 ; R2 <- Y1 - X1
GCAR R4 		; Get carry from subtraction
CONST R1, #0	; 0 out R1
SUB R1, R1, R4 	; sign extend subtraction
JSR MOD_SR 		; mod subtraction
ADD R6, R0, #0  ; put result in R6
ADD R0, R29, #0 ; R0 <- Y2, Need to do this because of Proc
SUB R2, R0, R28 ; R2 <- Y2 - X2
GCAR R4 		; Get carry from subtraction
CONST R1, #0 	; 0 out R1
SUB R1, R1, R4 	; sign extend subtraction
JSR MOD_SR 		; mod subtraction
ADD R2, R0, #0 	; put result in R2
ADD R3, R6, #0  ; put first sub in R3
CONST R4, #0 	; 0 out R4
CONST R5, #0 	; 0 out R5
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R8, R0, #0  ; R8 <- A


; R9 <- B = ((Y1+X1)*(Y2+X2)) % q
ADD R0, R25, #0 ; R0 <- Y1, Need to do this move because of Proc
ADD R2, R0, R24 ; R2 <- Y1 + X1
GCAR R4
ADD R0, R29, #0 ; R0 <- Y2, Need to do this because of Proc
ADD R3, R0, R28 ; R3 <- Y2 + X2
GCAR R5
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R9, R0, #0  ; R9 <- B

; C = T1*(2*d)*T2 % q  # 255 bits
CONST R4, #0 ;
CONST R5 #0 ;
ADD R2, R27, #0 ; R2 <- T1
ADD R3, R23, #0 ; R3 <- 2*d
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R2, R0, #0  ; R2 <- R0
ADD R3, R31, #0 ; R3 <- T2
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R10, R0, #0 ; R10 <- C

; D = Z1*2*Z2 % q
SLL R2, R26, #1 ; R2 <- Z1 * 2 ;; BUG May not work with overflow
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R2, R0, #0  ; R2 <- mod result
ADD R3, R30, #0 ; R3 <- Z2
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R11, R0, #0 ; R11 <- D

; E = (B-A) % q
ADD R0, R9, #0  ; R0 <- B
SUB R2, R0, R8  ; R2 <- B - A
GCAR R4
CONST R1, #0    ; R1 <- 0 for mod
SUB R1, R1, R4 ;  Handles negative numbers for sub
JSR MOD_SR      ; Mod result in R0
ADD R12, R0, #0 ; R12 <- E

; F = (D-C) % q
ADD R0, R11, #0 ; R0 <- D
SUB R2, R0, R10 ; R2 <- D - C
GCAR R4
CONST R1, #0    ; R1 <- 0 for mod
SUB R1, R1, R4 ;  Handles negative numbers for sub
JSR MOD_SR      ; Mod result in R0
ADD R13, R0, #0 ; R13 <- F

; G = (D+C) % q
ADD R0, R11, #0 ; R0 <- D
ADD R2, R0, R10 ; R2 <- D + C
GCAR R1         ; putting carry in r1 for mod
JSR MOD_SR      ; Mod result in R0
ADD R14, R0, #0 ; R14 <- G

; H = (B+A) % q
ADD R0, R9, #0  ; R0 <- B
ADD R2, R0, R8  ; R2 <- B - A
GCAR R1         ;
JSR MOD_SR      ; Mod result in R0
ADD R15, R0, #0 ; R15 <- H

; X3 = (E*F) % q
ADD R2, R12, #0 ; R2 <- E
ADD R3, R13, #0 ; R2 <- F
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R24, R0, #0 ; X1 <- X3

; Y3 = (G*H) % q
ADD R2, R14, #0 ; R2 <- G
ADD R3, R15, #0 ; R2 <- H
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R25, R0, #0 ; Y1 <- Y3

; Z3 = (F*G) % q
ADD R2, R13, #0 ; R2 <- F
ADD R3, R14, #0 ; R2 <- G
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R26, R0, #0 ; Z1 <- Z3

; T3 = (E*H) % q
ADD R2, R12, #0 ; R2 <- E
ADD R3, R15, #0 ; R2 <- H
CONST R4, #0 ;
CONST R5 #0 ;
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R27, R0, #0 ; T1 <- T3

ADD R7, R22, #0 ; Rest PC of RET

ADD R24, R24, #0 ; printing for debuging
ADD R25, R25, #0 ; printing for debuging
ADD R26, R26, #0 ; printing for debuging
ADD R27, R27, #0 ; printing for debuging
DONE          ; Return



;; NOTE assumes that R2 and R3 are populated with the x and y
;; R4 is populated with top bits of R2
;; R5 is populated with carry outof R3
;; computes x * y and puts the result in R1(MSB) and R2(LSB)
;; BUG Check if top bits are cleared out if no overflow
;; reference: http://users.utcluj.ro/~baruch/book_ssce/SSCE-Shift-Mult.pdf
; Check signs
; CHKH R2
; if R2 is neg:
;   TCS R2, R2
;   CHKH R3
;   if R3 is neg:
;     TCS R3, R3
;     CONST R6, #0
;   else:
;     CONST R6, #1
; else:
;   CHKH R3
;   if R3 is neg:
;     TCS R3, R3
;     CONST R6, #1

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
LBL_END_MULT RTI        ; Return


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
SUB R4, R16, R2   ; Check if R16 > R2
BRnz LBL_MOD
ADD R0, R2, #0   ; Move result into R0
CHKL R5                 ; is R0 0 or 1
BRz LBL_END_MOD
ADD R2, R0, #0
ADD R1, R16, #0
SUB R0, R1, R2

LBL_END_MOD RTI  ; Result placed in R0 TODO need to add signed and 255 bit split
