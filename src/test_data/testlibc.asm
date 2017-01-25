USER_STACK_ADDR .UCONST x7FFF
USER_STACK_SIZE .UCONST x1000
USER_HEAP_SIZE .UCONST x3000	
;;; Reserve space for heap and stack so that assembler will not try to
;;; place data in these regions
	
.DATA
.ADDR x4000
USER_HEAP	.BLKW x3000
.ADDR x7000			
USER_STACK	.BLKW x1000

.CODE
.ADDR x0000
.FALIGN
__start
	LC R6, USER_STACK_ADDR
	LC R0, USER_HEAP_SIZE	
	STR R0, R6, #-1
	LEA R0, USER_HEAP
	STR R0, R6, #-2
	ADD R6, R6, #-2
	JSR lc4_sbrk
	ADD R6, R6, #2
	LEA R7, main
	JSRR R7
	TRAP x25		; HALT

;;; Wrappers for the traps.  Marshall the arguments from stack to 
;;; registers and return value from register to stack

.FALIGN		
lc4_draw_1
	;; prologue
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1
	;; marshall arguments
	LDR R0, R6, #2
	LDR R1, R6, #3
	LDR R2, R6, #4
	TRAP x00
	;; epilogue
	LDR R7, R6, #1
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET

.FALIGN	
lc4_draw_4x4
	;; prologue
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1
	;; marshall arguments
	LDR R0, R6, #2
	LDR R1, R6, #3
	LDR R2, R6, #4
	LDR R3, R6, #5
	TRAP x00
	;; epilogue
	LDR R7, R6, #1
	LDR R0, R6, #0
	ADD R6, R6, #2
	RET

.FALIGN	
lc4_draw_4x4_wrapped
	;; prologue
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1
	;; marshall arguments
	LDR R0, R6, #2
	LDR R1, R6, #3
	LDR R2, R6, #4
	LDR R3, R6, #5
	TRAP x00
	;; epilogue
	LDR R7, R6, #1
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET

.FALIGN
lc4_puts
	;; prologue
	ADD R6, R6, #-2
	STR R5, R6, #0
	STR R7, R6, #1
	;; marshall arguments
	LDR R0, R6, #2
	TRAP x60
	;; epilogue
	LDR R7, R6, #1
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET
	
.FALIGN
lc4_get_event 
	;; R5 is the base pointer as well as the 
	;; TRAP return register.  If the trap returns
	;; a value, we have to save and restore the user's
	;; base-pointer
	ADD R6, R6, #-2	
	STR R5, R6, #0
	STR R7, R6, #1
	TRAP x50
	LDR R7, R6, #1
	;; save TRAP return value on stack
	STR R5, R6, #1
	;; restore user base-pointer
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET

.FALIGN	
lc4_halt
	;; prologue
	ADD R6, R6, #-2
	LDR R5, R6, #0
	STR R7, R6, #1
	;; no arguments
	TRAP x25
	;; epilogue
	LDR R7, R6, #1
	LDR R5, R6, #0
	ADD R6, R6, #2
	RET			

.FALIGN
lc4_reset_vmem
	;; prologue
	ADD R6, R6, #-2
	STR R5, R6, #0
	STR R7, R6, #1
	;; no arguments
	TRAP x4E
	;; epilogue
	LDR R5, R6, #0
	LDR R7, R6, #1
	ADD R6, R6, #2
	RET

.FALIGN
lc4_blt_vmem
	;; prologue
	ADD R6, R6, #-2
	STR R5, R6, #0
	STR R7, R6, #1
	;; no arguments
	TRAP x4F
	;; epilogue
	LDR R5, R6, #0
	LDR R7, R6, #1
	ADD R6, R6, #2
	RET

.FALIGN
lc4_junk_call
	;; Store R7 into R3
	ADD R3, R7, #0
	TRAP x00
	;; Restore R7
	ADD R7, R3, #0
	RET
	
;;; Other library data will start at x2000
.DATA
.ADDR x2000
		.FILE "lc4libc.c"
		.DATA
L2_lc4libc 		.FILL #17767
		.FILL #9158
		.FILL #39017
		.FILL #18547
		.FILL #56401
		.FILL #23807
		.FILL #37962
		.FILL #22764
		.FILL #7977
		.FILL #31949
		.FILL #22714
		.FILL #55211
		.FILL #16882
		.FILL #7931
		.FILL #43491
		.FILL #57670
		.FILL #124
		.FILL #25282
		.FILL #2132
		.FILL #10232
		.FILL #8987
		.FILL #59880
		.FILL #52711
		.FILL #17293
		.FILL #3958
		.FILL #9562
		.FILL #63790
		.FILL #29283
		.FILL #49715
		.FILL #55199
		.FILL #50377
		.FILL #1946
		.FILL #64358
		.FILL #23858
		.FILL #20493
		.FILL #55223
		.FILL #47665
		.FILL #58456
		.FILL #12451
		.FILL #55642
		.FILL #24869
		.FILL #35165
		.FILL #45317
		.FILL #41751
		.FILL #43096
		.FILL #23273
		.FILL #33886
		.FILL #43220
		.FILL #48555
		.FILL #36018
		.FILL #53453
		.FILL #57542
		.FILL #30363
		.FILL #40628
		.FILL #9300
		.FILL #34321
		.FILL #50190
		.FILL #7554
		.FILL #63604
		.FILL #34369
		.FILL #62753
		.FILL #48445
		.FILL #36316
		.FILL #61575
		.FILL #6768
		.FILL #56809
		.FILL #51262
		.FILL #54433
		.FILL #49729
		.FILL #63713
		.FILL #44540
		.FILL #9063
		.FILL #33342
		.FILL #24321
		.FILL #50814
		.FILL #10903
		.FILL #47594
		.FILL #19164
		.FILL #54123
		.FILL #30614
		.FILL #55183
		.FILL #42040
		.FILL #22620
		.FILL #20010
		.FILL #17132
		.FILL #31920
		.FILL #54331
		.FILL #1787
		.FILL #39474
		.FILL #52399
		.FILL #36156
		.FILL #36692
		.FILL #35308
		.FILL #6936
		.FILL #32731
		.FILL #42076
		.FILL #63746
		.FILL #18458
		.FILL #30974
		.FILL #47939
		.FILL #16635
		.FILL #9978
		.FILL #57002
		.FILL #49978
		.FILL #34299
		.FILL #42281
		.FILL #60881
		.FILL #16358
		.FILL #61445
		.FILL #49468
		.FILL #46972
		.FILL #51092
		.FILL #25973
		.FILL #4056
		.FILL #5566
		.FILL #43105
		.FILL #35977
		.FILL #59897
		.FILL #44892
		.FILL #9915
		.FILL #46760
		.FILL #15513
		.FILL #46607
		.FILL #16533
		.FILL #22449
		.FILL #13803
		.FILL #58609
		.FILL #20659
		.FILL #32261
		.FILL #24047
		.FILL #3063
		.FILL #48896
		.FILL #34025
		.FILL #60065
		.FILL #33338
		.FILL #2789
		.FILL #36810
		.FILL #28683
		.FILL #19147
		.FILL #32720
		.FILL #12616
		.FILL #583
		.FILL #18276
		.FILL #38589
		.FILL #4639
		.FILL #23843
		.FILL #16158
		.FILL #40616
		.FILL #18204
		.FILL #61051
		.FILL #50532
		.FILL #64965
		.FILL #11028
		.FILL #31603
		.FILL #15962
		.FILL #33477
		.FILL #45406
		.FILL #9035
		.FILL #54137
		.FILL #12131
		.FILL #33083
		.FILL #57200
		.FILL #61028
		.FILL #1572
		.FILL #51729
		.FILL #28830
		.FILL #4361
		.FILL #23004
		.FILL #57514
		.FILL #23508
		.FILL #55724
		.FILL #4594
		.FILL #24091
		.FILL #8464
		.FILL #43183
		.FILL #28731
		.FILL #32307
		.FILL #59341
		.FILL #3811
		.FILL #50512
		.FILL #54856
		.FILL #54343
		.FILL #49941
		.FILL #348
		.FILL #20411
		.FILL #367
		.FILL #33826
		.FILL #281
		.FILL #9402
		.FILL #22427
		.FILL #12413
		.FILL #42485
		.FILL #14091
		.FILL #7905
		.FILL #44058
		.FILL #284
		.FILL #36735
		.FILL #48419
		.FILL #23288
		.FILL #28713
		.FILL #6392
		.FILL #13476
		.FILL #33307
		.FILL #30483
		.FILL #21941
		.FILL #10954
		.FILL #59214
		.FILL #54248
		.FILL #4760
		.FILL #63026
		.FILL #39224
		.FILL #59616
		.FILL #51833
		.FILL #23629
		.FILL #59965
		.FILL #6708
		.FILL #23996
		.FILL #28255
		.FILL #6990
		.FILL #33399
		.FILL #50682
		.FILL #19403
		.FILL #10348
		.FILL #64773
		.FILL #27308
		.FILL #54406
		.FILL #65057
		.FILL #64043
		.FILL #37290
		.FILL #22810
		.FILL #27221
		.FILL #43682
		.FILL #36286
		.FILL #60528
		.FILL #8629
		.FILL #58227
		.FILL #5947
		.FILL #2308
		.FILL #46940
		.FILL #10707
		.FILL #65334
		.FILL #20628
		.FILL #4787
		.FILL #51631
		.FILL #44258
		.FILL #64752
		.FILL #58340
		.FILL #2718
		.FILL #27471
		.FILL #65330
		.FILL #36117
		.FILL #12617
		.FILL #19197
		.FILL #46466
		.FILL #11854
		.FILL #46505
		.DATA
L3_lc4libc 		.FILL #0
		.LOC 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;lc4_rand_power2;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
lc4_rand_power2
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
		.LOC 8
		.LOC 15
	LDR R7, R5, #3
	ADD R3, R7, #-1
	LEA R2, L3_lc4libc
	LDR R2, R2, #0
	LEA R1, L2_lc4libc
	ADD R2, R2, R1
	LDR R2, R2, #0
	AND R2, R2, R3
	ADD R7, R2, R7
	AND R7, R7, R3
	STR R7, R5, #-1
		.LOC 16
	LEA R7, L3_lc4libc
	LDR R3, R7, #0
	ADD R3, R3, #1
	CONST R2, #255
	AND R3, R3, R2
	STR R3, R7, #0
		.LOC 17
	LDR R7, R5, #-1
L1_lc4libc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.LOC 44
;;;;;;;;;;;;;;;;;;;;;;;;;;;;lc4_sbrk;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
lc4_sbrk
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
		.LOC 45
		.LOC 46
	LEA R7, flist
	LDR R3, R5, #3
	STR R3, R7, #0
		.LOC 47
	LEA R7, flist
	LDR R7, R7, #0
	CONST R3, #0
	STR R3, R7, #0
		.LOC 48
	LEA R7, flist
	LDR R7, R7, #0
	CONST R3, #0
	STR R3, R7, #1
		.LOC 49
	LEA R7, flist
	LDR R7, R7, #0
	LDR R3, R5, #4
	ADD R3, R3, #-3
	STR R3, R7, #2
		.LOC 50
	LEA R7, heap_size
	LDR R3, R5, #4
	STR R3, R7, #0
		.LOC 51
L4_lc4libc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.LOC 53
;;;;;;;;;;;;;;;;;;;;;;;;;;;;lc4_malloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
lc4_malloc
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-3	;; allocate stack space for local variables
	;; function body
		.LOC 54
		.LOC 59
	CONST R7, #0
	STR R7, R5, #-2
	LEA R7, flist
	LDR R7, R7, #0
	STR R7, R5, #-1
	JMP L9_lc4libc
L6_lc4libc
		.LOC 60
		.LOC 67
	LDR R7, R5, #-1
	LDR R7, R7, #2
	LDR R3, R5, #3
	CMP R7, R3
	BRzp L10_lc4libc
		.LOC 68
	JMP L7_lc4libc
L10_lc4libc
		.LOC 71
	LDR R7, R5, #-1
	LDR R7, R7, #2
	LDR R3, R5, #3
	SLL R3, R3, #1
	ADD R3, R3, #3
	CMPU R7, R3
	BRnz L12_lc4libc
		.LOC 72
		.LOC 73
	LDR R7, R5, #3
	LDR R3, R5, #-1
	ADD R3, R3, #3
	ADD R7, R7, R3
	STR R7, R5, #-3
		.LOC 74
	LDR R7, R5, #-3
	LDR R3, R5, #-1
	LDR R3, R3, #0
	STR R3, R7, #0
		.LOC 75
	LDR R7, R5, #-3
	CONST R3, #0
	STR R3, R7, #1
		.LOC 76
	LDR R7, R5, #-3
	LDR R3, R5, #-1
	LDR R3, R3, #2
	ADD R3, R3, #-3
	LDR R2, R5, #3
	SUB R3, R3, R2
	STR R3, R7, #2
		.LOC 78
	LDR R7, R5, #-2
	CONST R3, #0
	CMP R7, R3
	BRz L14_lc4libc
		.LOC 79
	LDR R7, R5, #-2
	LDR R3, R5, #-3
	STR R3, R7, #0
	JMP L15_lc4libc
L14_lc4libc
		.LOC 81
	LEA R7, flist
	LDR R3, R5, #-3
	STR R3, R7, #0
L15_lc4libc
		.LOC 83
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #0
		.LOC 84
	LDR R7, R5, #-1
	CONST R3, #1
	STR R3, R7, #1
		.LOC 85
	LDR R7, R5, #-1
	LDR R3, R5, #3
	STR R3, R7, #2
		.LOC 86
	JMP L8_lc4libc
L12_lc4libc
		.LOC 90
		.LOC 91
	LDR R7, R5, #-2
	CONST R3, #0
	CMP R7, R3
	BRz L16_lc4libc
		.LOC 92
	LDR R7, R5, #-2
	LDR R3, R5, #-1
	LDR R3, R3, #0
	STR R3, R7, #0
	JMP L17_lc4libc
L16_lc4libc
		.LOC 94
	LEA R7, flist
	LDR R3, R5, #-1
	LDR R3, R3, #0
	STR R3, R7, #0
L17_lc4libc
		.LOC 96
	LDR R7, R5, #-1
	CONST R3, #1
	STR R3, R7, #1
		.LOC 97
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #0
		.LOC 98
	JMP L8_lc4libc
L7_lc4libc
		.LOC 59
	LDR R7, R5, #-1
	STR R7, R5, #-2
	LDR R7, R7, #0
	STR R7, R5, #-1
L9_lc4libc
		.LOC 59
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L6_lc4libc
L8_lc4libc
		.LOC 105
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRz L19_lc4libc
	LDR R7, R5, #-1
	ADD R7, R7, #3
	STR R7, R5, #-3
	JMP L20_lc4libc
L19_lc4libc
	CONST R7, #0
	STR R7, R5, #-3
L20_lc4libc
	LDR R7, R5, #-3
L5_lc4libc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.LOC 109
;;;;;;;;;;;;;;;;;;;;;;;;;;;;lc4_free;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
lc4_free
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
		.LOC 110
		.LOC 111
	LDR R7, R5, #3
	ADD R7, R7, #-3
	STR R7, R5, #-2
		.LOC 113
	CONST R7, #0
	STR R7, R5, #-4
		.LOC 121
	CONST R7, #0
	STR R7, R5, #-3
	LEA R7, flist
	LDR R7, R7, #0
	STR R7, R5, #-1
	JMP L25_lc4libc
L22_lc4libc
		.LOC 122
	LDR R7, R5, #-1
	LDR R3, R5, #-2
	CMPU R7, R3
	BRnz L26_lc4libc
		.LOC 123
	JMP L24_lc4libc
L26_lc4libc
L23_lc4libc
		.LOC 121
	LDR R7, R5, #-1
	STR R7, R5, #-3
	LDR R7, R7, #0
	STR R7, R5, #-1
L25_lc4libc
		.LOC 121
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L22_lc4libc
L24_lc4libc
		.LOC 126
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRz L28_lc4libc
	LDR R3, R5, #-2
	LDR R2, R3, #2
	ADD R3, R3, #3
	ADD R3, R2, R3
	CMP R7, R3
	BRnp L28_lc4libc
		.LOC 127
		.LOC 128
	LDR R7, R5, #-3
	CONST R3, #0
	CMP R7, R3
	BRz L30_lc4libc
		.LOC 129
	LDR R7, R5, #-3
	LDR R3, R5, #-2
	STR R3, R7, #0
	JMP L31_lc4libc
L30_lc4libc
		.LOC 131
	LEA R7, flist
	LDR R3, R5, #-2
	STR R3, R7, #0
L31_lc4libc
		.LOC 133
	LDR R7, R5, #-2
	LDR R3, R5, #-1
	LDR R3, R3, #0
	STR R3, R7, #0
		.LOC 134
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #1
		.LOC 135
	LDR R7, R5, #-2
	ADD R7, R7, #2
	LDR R3, R7, #0
	LDR R2, R5, #-1
	LDR R2, R2, #2
	ADD R2, R2, #3
	ADD R3, R3, R2
	STR R3, R7, #0
		.LOC 137
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #0
		.LOC 138
	LDR R7, R5, #-1
	CONST R3, #0
	STR R3, R7, #2
		.LOC 139
	CONST R7, #1
	STR R7, R5, #-4
		.LOC 140
L28_lc4libc
		.LOC 142
	LDR R7, R5, #-3
	ADD R3, R7, #0
	CONST R2, #0
	CMP R3, R2
	BRz L32_lc4libc
	LDR R3, R7, #2
	ADD R7, R7, #3
	ADD R7, R3, R7
	LDR R3, R5, #-2
	CMP R7, R3
	BRnp L32_lc4libc
		.LOC 143
		.LOC 144
	LDR R7, R5, #-3
	ADD R7, R7, #2
	LDR R3, R7, #0
	LDR R2, R5, #-2
	LDR R2, R2, #2
	ADD R2, R2, #3
	ADD R3, R3, R2
	STR R3, R7, #0
		.LOC 146
	LDR R7, R5, #-4
	CONST R3, #0
	CMP R7, R3
	BRz L34_lc4libc
		.LOC 147
	LDR R7, R5, #-3
	LDR R3, R5, #-2
	LDR R3, R3, #0
	STR R3, R7, #0
L34_lc4libc
		.LOC 149
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #0
		.LOC 150
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #1
		.LOC 151
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #2
		.LOC 152
	CONST R7, #1
	STR R7, R5, #-4
		.LOC 153
L32_lc4libc
		.LOC 155
	LDR R7, R5, #-4
	CONST R3, #0
	CMP R7, R3
	BRnp L36_lc4libc
		.LOC 156
		.LOC 157
	LDR R7, R5, #-2
	LDR R3, R5, #-1
	STR R3, R7, #0
		.LOC 158
	LDR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #1
		.LOC 159
	LDR R7, R5, #-3
	CONST R3, #0
	CMP R7, R3
	BRz L38_lc4libc
		.LOC 160
	LDR R7, R5, #-3
	LDR R3, R5, #-2
	STR R3, R7, #0
	JMP L39_lc4libc
L38_lc4libc
		.LOC 162
	LEA R7, flist
	LDR R3, R5, #-2
	STR R3, R7, #0
L39_lc4libc
		.LOC 163
L36_lc4libc
		.LOC 168
L21_lc4libc
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.DATA
heap_size 		.BLKW 1
		.DATA
flist 		.BLKW 1
