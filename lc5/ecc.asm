; (X1, Y1, Z1, T1) = pt1
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


; Registers loaded by "Loader"
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

; (Y1 - X1) * (Y2 - X2)
ADD R0, R25, #0 ; R0 <- Y1, Need to do this move because of Proc
SUB R1, R0, R24 ; R1 <- Y1 - X1




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
