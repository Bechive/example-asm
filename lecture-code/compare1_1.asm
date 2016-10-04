 title  "Compare.asm: Timer 1 By Venkat Ramaswamy"

; Memory Aid: 0 for output, 1 for input
  
	list  P=PIC16F877a,   R=DEC
	include "p16F877a.inc"
	__config (_CP_OFF & _HS_OSC & _WDT_OFF & _LVP_OFF & _DEBUG_ON)
	errorlevel -302  

; ******** Vectors *****************************************************
	org	H'000'
	goto	MainLine
	org	H'004'
	goto	IntService

; ******** Interrupt Service *******************************************
IntService
    retfie	

; ******** Initial subroutine ******************************************
Initial
	bcf		STATUS,RP0	; 
	bcf		STATUS, RP1	; Bank 0 selected
	clrf	PORTC
	bsf		STATUS,RP0	; Bank 1 selected
	movlw	H'00'		 ; All pins of PORTC outputs
	movwf	TRISC
  	bcf		STATUS,RP0	; Bank 0 selected 
	movlw	H'01'
	movwf	T1CON		; enable Timer1
	movlw	H'09'
	movwf	CCP1CON		; select compare mode "clear output on match"
	return

; ******** Mainline Program ********************************************
MainLine
	call 	Initial
MainLoop
	nop
    call	SetPeriod
Wait
	nop
	nop
    btfsc   PORTC,2
    goto    Wait
	nop   					; (set Brakepoint here)
    goto    MainLoop

SetPeriod
	bcf		T1CON,TMR1ON    ; stop the clocking of TMR1
	clrf	TMR1H			; TMR1 <= H'0000'
	clrf	TMR1L  
	clrf	CCPR1H          ; CCPR1 <= H'0001'
	movlw	H'01'
	movwf	CCPR1L
	bcf		CCP1CON,0   	; Set RC2/CCP1 pin on compare
	
Pulse1
    bcf		INTCON,GIE		; Disable interrupts momentarily
	bsf		T1CON,TMR1ON   	; Begin clocking of TMR1 (set Brakepoint here)
	movlw	D'201'			; Set up second compare
	movwf	CCPR1L
	bsf		CCP1CON,0   	; Clear RC2/CCP1 pin on second compare (set Brakepoint here)
    bsf		INTCON,GIE		; Re-enable interrupts
	return

	end
