+; (X1, Y1, Z1, T1) = pt1
; (X2, Y2, Z2, T2) = pt2
; A = ((Y1-X1)*(Y2-X2)) % q  # 255 bits
; B = ((Y1+X1)*(Y2+X2)) % q  # 255 bits
; C = T1*(2*d)*T2 % q  # 255 bits
; D = Z1*2*Z2 % q  # 255 bits
; E = (B-A) % q
; F = (D-C) % q
; G = (D+C) % q
; H = (B+A) % q
; X3 = (E*F) % q
; Y3 = (G*H) % q
; T3 = (E*H) % q
; Z3 = (F*G) % q

; c mod q
; p = floor(c / 2^255) = c >> 255
; r = c mod 2^255 = c & 255
; c mod q = p << 4 + p << 1 + p + r

; Assume points are in order in memory starting at address 0


; R7 -- used to store PC for ret
; Loader will place data in the top 8 register slots. R24-R31

;; Free Registers
; R16

; def ed(n, pt):
; R17 <- n Reversed!!! and mod L
; R18 <- X
; R19 <- Y
; R20 <- Z
; R21 <- T

;     (X, Y, Z, T) = pt ;This is passed in my loader into R24-R27
;     Q = (0, 1, 1, 0)  ; Need to set this for POINT_ADD_SR
ED_SR CONST R24, #0
CONST R25, #1
CONST R26, #1
CONST R27, #0
;     for i in bin(n)[2:]:
ADD R17, R17, #0 ; Check if R17 is 0
BRz END_LABEL
;         Q = add_elements(Q, Q)
ED_LOOP ADD R28, R24, #0
ADD R29, R25, #0
ADD R30, R26, #0
ADD R31, R27, #0
JSR POINT_ADD_SR
;         if i == '1':
AND R0, R17, #1
BRnz SHIFT_N
;             Q = add_elements(Q, pt)
ADD R28, R18, #0
ADD R29, R19, #0
ADD R30, R20, #0
ADD R31, R21, #0
JSR POINT_ADD_SR
SHIFT_N SRL R17, R17, #1
BRnp ED_LOOP
;     return Q
END_LABEL DONE ; end of prog
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
ADD R0, R29, #0 ; R0 <- Y2, Need to do this because of Proc
SUB R3, R0, R28 ; R3 <- Y2 - X2
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R8, R0, #0  ; R8 <- A


; R9 <- B = ((Y1+X1)*(Y2+X2)) % q
ADD R0, R25, #0 ; R0 <- Y1, Need to do this move because of Proc
ADD R2, R0, R24 ; R2 <- Y1 - X1
ADD R0, R29, #0 ; R0 <- Y2, Need to do this because of Proc
ADD R3, R0, R28 ; R3 <- Y2 - X2
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R9, R0, #0  ; R9 <- B

; C = T1*(2*d)*T2 % q  # 255 bits
ADD R2, R27, #0 ; R2 <- T1
ADD R3, R23, #0 ; R3 <- 2*d
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R2, R0, #0  ; R2 <- R0
ADD R3, R21, #0 ; R3 <- T2
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R10, R0, #0 ; R10 <- C

; D = Z1*2*Z2 % q
SRL R2, R26, 1  ; R2 <- Z1 * 2 ;; BUG May not work with overflow
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R2, R0      ; R2 <- mod result
ADD R3, R30, #0 ; R3 <- Z2
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R11, R0, #0 ; R11 <- D

; E = (B-A) % q
ADD R0, R9, #0  ; R0 <- B
SUB R2, R0, R8  ; R2 <- B - A
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R12, R0, #0 ; R12 <- E

; F = (D-C) % q
ADD R0, R11, #0 ; R0 <- D
SUB R2, R0, R10 ; R2 <- D - C
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R13, R0, #0 ; R13 <- F

; G = (D+C) % q
ADD R0, R11, #0 ; R0 <- D
ADD R2, R0, R10 ; R2 <- D + C
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R14, R0, #0 ; R14 <- G

; H = (B+A) % q
ADD R0, R9, #0  ; R0 <- B
ADD R2, R0, R8  ; R2 <- B - A
CONST R1, #0    ; R1 <- 0 for mod
JSR MOD_SR      ; Mod result in R0
ADD R15, R0, #0 ; R15 <- H

; X3 = (E*F) % q
ADD R2, R12, #0 ; R2 <- E
ADD R3, R13, #0 ; R2 <- F
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R24, R0, #0 ; X1 <- X3

; Y3 = (G*H) % q
ADD R2, R14, #0 ; R2 <- G
ADD R3, R15, #0 ; R2 <- H
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R25, R0, #0 ; Y1 <- Y3

; Z3 = (F*G) % q
ADD R2, R13, #0 ; R2 <- F
ADD R3, R14, #0 ; R2 <- G
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R26, R0, #0 ; Z1 <- Z3

; T3 = (E*H) % q
ADD R2, R12, #0 ; R2 <- E
ADD R3, R15, #0 ; R2 <- H
JSR MULT_SR     ; Mult result in R1, R2
JSR MOD_SR      ; Mod result in R0
ADD R27, R0, #0 ; T1 <- T3

ADD R7, R22, #0 ; Rest PC of RET
RTI             ; Return



;; NOTE assumes that R2 and R3 are populated with the x and y
;; computes x * y and puts the result in R1(MSB) and R2(LSB)
;; BUG Check if top bits are cleared out if no overflow
MULT_SR CONST R0, #255   ; 0000 90FF
ADD R0, R0, #1           ; 0001 1021
CONST R1, #0             ; 0002 9200
; ADD R2, Q, #0
; ADD R3, B, #0
CHECK_SR CHK R6, R0, R2  ; 0003 1E0A
BRz LBL_F                ; 0004 0401
ADD R1, R1, R3           ; 0005 1243
LBL_F SDRH R1, R1, R2     ; 0006 125A
SDRL R2, R1, R2           ; 0007 A47A
ADD R0, R0, #-1          ; 0008 103F
BRnp CHECK_SR            ; 0009 0BF9
; ADD R4, R1, R2         ; 000a 1842 Multiplication result in R1, R2
RTI                      ; 000b 0000


; Mod Step
MOD_SR SLL R0, R1, #4  ; R5 <- p << 4
SLL R6, R1, #1  ; R6 <- p << 1
ADD R0, R0, R6  ; R5 <- p << 4 + p << 1
ADD R3, R1, #0  ; R3 <- R1
ADD R0, R0, R3  ; R5 <- p << 4 + p << 1 + p
ADD R0, R0, R2  ; R5 <- p << 4 + p << 1 + p + r
RTI             ; Result placed in R0 TODO need to add signed and 255 bit split


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reference code below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Load point data from memory
LDR R1, R0, #0  ; R1 <- X1
LDR R2, R0, #1  ; R2 <- Y1
LDR R3, R0, #4  ; R3 <- X2
LDR R4, R0, #5  ; R4 <- Y2

; (Y1 - X1) * (Y2 - X2)
SUB R1, R3, R2  ; R1 <- Y1 - X1
SUB R2, R5, R4  ; R2 <- Y2 - X2
MUL R4, R1, R2  ; R4 <- r = (Y1 - X1) * (Y2 - X2) & 255 lower **255** bits
SRA R3, R1, R2  ; R3 <- p = (Y1 - X1) * (Y2 - X2) >> 255 multiply and get upper **257** bits

; Mod Step
SLL R5, R3, #4  ; R5 <- p << 4
SLL R6, R3, #1  ; R6 <- p << 1
ADD R5, R5, R6  ; R5 <- p << 4 + p << 1
ADD R5, R5, R3  ; R5 <- p << 4 + p << 1 + p
ADD R5, R5, R4  ; R5 <- p << 4 + p << 1 + p + r

; Load point data from memory
LDR R1, R0, #0  ; R1 <- X1
LDR R2, R0, #1  ; R2 <- Y1
LDR R3, R0, #4  ; R3 <- X2
LDR R4, R0, #5  ; R4 <- Y2

; (Y1 + X1) * (Y2 + X2)
ADD R1, R3, R2  ; R1 <- Y1 + X1
ADD R2, R5, R4  ; R2 <- Y2 + X2
MUL R4, R1, R2  ; R4 <- r = (Y1 + X1) * (Y2 + X2) & 255 lower **255** bits
SRA R3, R1, R2  ; R3 <- p = (Y1 + X1) * (Y2 + X2) >> 255 multiply and get upper **257** bits

; Mod Step
SLL R5, R3, #4  ; R5 <- p << 4
SLL R6, R3, #1  ; R6 <- p << 1
ADD R5, R5, R6  ; R5 <- p << 4 + p << 1
ADD R5, R5, R3  ; R5 <- p << 4 + p << 1 + p
ADD R5, R5, R4  ; R5 <- p << 4 + p << 1 + p + r



; MULTIPLIER SUBROUTINE
; MUL_SR CONST R0, #256
; CONST R1, #0
; ADD R2, Q, #0
; ADD R3, B, #0
; CHECK_SR CHK R2 ; MUL R7, R0, R2
; BRz LBL_F
; ADD R1, R1, R3
; LBL_F SDR R1, R2
; ADD R0, R0, #-1
; BRz CHECK_SR
; RTI



;; NOTE assumes that R2 and R3 are populated with the x and y
;; computes x * y and puts the result in R1(MSB) and R2(LSB)

MULT_SR CONST R0, #255   ; 0000 90FF
ADD R0, R0, #1           ; 0001 1021
CONST R1, #0             ; 0002 9200
; ADD R2, Q, #0
; ADD R3, B, #0
CHECK_SR MUL R7, R0, R2  ; 0003 1E0A
BRz LBL_F                ; 0004 0401
ADD R1, R1, R3           ; 0005 1243
LBL_F DIV R1, R1, R2     ; 0006 125A
MOD R2, R1, R2           ; 0007 A47A
ADD R0, R0, #-1          ; 0008 103F
BRnp CHECK_SR            ; 0009 0BF9
ADD R4, R1, R2           ; 000a 1842
END_LABEL NOP            ; 000b 0000

; 90FF
; 1021
; 9200
; 1E0A
; 0401
; 1243
; 125A
; A47A
; 103F
; 0BF9
; 1842

; .OS
; .CODE
; .ADDR x8200
; LBL_8200 CONST R0, #1
; CONST R2, #1
; ADD R2, R0, R2
; ADD R3, R0, R2
; BRzp LBL_HERE
; NOP
; NOP
; LBL_HERE CONST R3, #9
; ADD R4, R0, R3
; END_LABEL NOP
