     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
Bank0Ram    equ 	0x20		;Equates mean the same as before!

; ******** Variables **************************************************
 	cblock Bank0Ram
		NUM1			; 0x20 locations used for variables
		NUM2			; 0x21
		COUNTL			; 0x22
		COUNTH			; 0x23
		Reg				; 0x24
		tempA			
		tempB
	endc

; ******** Vectors *****************************************************
		org 	0x000 		; Set origin at memory address 000
		goto	Mainline
		org	0x004
IntService	
		goto	IntService

; ******** Mainline Program *****************************************************
Mainline
	nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple operation (1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movf	NUM2, W	  	; NUM2->W
	subwf	NUM1, W	  	; NUM1 - W -> W
	btfss	STATUS, C   ; C==1 indicates no borrow, NUM1 >= NUM2
	goto	Below	  	; C==0 indicates borrow, NUM1<NUM2
Above
	nop
	goto	Op1Done
Below	
	nop
Op1Done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple operation (2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decrement a 16-bit counter
		movf	COUNTL, F	 	; Set Z if lower byte == 0
		btfsc	STATUS, Z		;
		decf	COUNTH, F	 	; if so, decrement COUNTH
		decf	COUNTL, F	 	; in either case decrement COUNTL

; Test a 16-bit variable for zero
		movf	COUNTL, F	 	; Set Z if lower byte == 0
		btfsc	STATUS, Z		; If not, then done testing
		movf	COUNTH, F	 	; Set Z if upper byte == 0
		btfsc	STATUS, Z		; if not, then done
		goto	BothZero		; branch if 16-bit variable == 0
		nop
BothZero
		nop
Op2Done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple operation (4)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Swap W and Reg
; First routine
		movwf	tempA		; move W => tempA
		movf	Reg, W		; move Reg => W
		movwf	tempB		; move W => tempB (i.e Reg => tempB)
		movf	tempA,W		; move tempA => W (i.e orig(W) => W)
		movwf	Reg			; move W => Reg (i.e orig(W) => Reg)
		movf	tempB,W		; move tempB => W (i.e Reg => W)
; Second routine
		xorwf	Reg, W		; xor(Reg, W) => W
		xorwf	Reg, F		; xor(xor(Reg,W),Reg) => Reg (i.e orig(W) => Reg)
		xorwf	Reg, W		; xor(xor(Reg,W),orig(W)) => W (i.e Reg => W)
Op3Done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple operation (3)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Table lookup
Table 	addwf	PCL, F		; add W to PCL and store it in PCL
		retlw	H'01'		; return 1 in W if W == 0
		retlw	H'03'		; return 3 in W if W == 1
		retlw	H'06'		; return 6 in W if W == 2
		retlw	H'02'		; return 2 in W if W == 3
Op4Done
		nop

	End
