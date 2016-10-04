; TenMs subroutine and its call inserts a delay of exactly 10ms
; into the execution of code.
; It assumes a 20 MHz crystal clock.
; TenMsH	equ  d'65'	; Initial value of TenMs Subroutine's counter
; TenMsL	equ  d'237'
; COUNTH and COUNTL are two variables 

     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
TenMsH		equ  	d'65'	; Initial value of TenMs Subroutine's counter
TenMsL		equ  	d'237'
Bank0Ram    equ 	0x20		;Equates mean the same as before!

; ******** Variables **************************************************
 	cblock Bank0Ram
		COUNTL			; 0x20 locations used for variables
		COUNTH			; 0x21
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
	call	TenMs
	nop

TenMs
	movlw	TenMsH		; Initialize COUNT
	movwf	COUNTH
	movlw	TenMsL
	movwf	COUNTL
Ten_1
	decfsz	COUNTL,F		; Inner loop
	goto	Ten_1
	decfsz	COUNTH,F		; Outer loop
	goto 	Ten_1
	return
end
