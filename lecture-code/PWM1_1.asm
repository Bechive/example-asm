 title  "Illsutration of PWM by Venkat Ramaswamy" 
; Memory Aid: 0 for output, 1 for input
; 
  
	list  P=PIC16F877a, R=DEC
	include "p16F877a.inc"
	__config (_CP_OFF &  _HS_OSC & _WDT_OFF & _LVP_OFF & _DEBUG_ON)
	errorlevel -302  

; ********  Equates ***************************************************

; ******** Variables **************************************************

; ******** Vectors ****************************************************
	org	H'000'
	goto	MainLine
	org	H'004'
	goto	IntService
Stop
	goto	Stop


; ******** Interrupt Service ******************************************

IntService
    retfie	
; ******** Initial subroutine *****************************************
Initial

	bcf		STATUS,RP0	; 
	bcf		STATUS, RP1	; Bank 0 selected
	clrf	PORTC
	clrf	PORTB
	bsf		STATUS,RP0	; Bank 1 selected
	movlw	H'00'		 ; All pins of PORTC outputs
	movwf	TRISC
	movlw	H'FF'
	movwf	TRISB		; All pins of PORTB inputs
	movlw	D'249'
	movwf	PR2
  	bcf		STATUS,RP0	; Bank 0 selected 
	movlw	D'125'
	movwf	CCPR1L
	movlw	H'0C'
    movwf	CCP1CON
	movlw	H'05'
    movwf	T2CON
	return

; ******** Mainline Program *****************************************************
MainLine
	call 	Initial
MainLoop
    nop
LoopOne
    btfss	PORTC,2		;	Check whether PORTC,2 is '1'
    goto    LoopOne     ;   Goto LoopOne while PORTC,2 = '0'.  
	nop					;   Count in TMR2 lies between D'126' and D'249'
LoopTwo
    btfsc	PORTC,2		;   Goto LoopTwo while PORTC,2 = '1'
    goto    LoopTwo     ;	TMR2 count lies between H'00' and D'125'
    nop
    goto  	MainLoop

	end
