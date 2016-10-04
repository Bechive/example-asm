     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
temp	equ		0x30

; ******** Variables **************************************************

; ******** Vectors *****************************************************
		org 	0x000 		; Set origin at memory address 000
		goto	Mainline
		org		0x004
IntService
		goto	IntService

; ******** Mainline Program *****************************************************
Mainline
		movlw 	0x20 	; put the starting address into W
		movwf 	FSR 	; ...then into the FSR
Next
	 	clrf 	INDF 	; clear the address pointed to by the FSR
		incf 	FSR,F 	; point to the next address
		btfss 	FSR,4 	; does the FSR now contain 30h? (is bit 4 set?)
		goto	Next	; not set, repeat
done 					; execution jumps to here when bit 4 is set
		clrf	temp
	End
