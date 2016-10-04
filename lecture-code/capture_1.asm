 title  "capture using Timer1"

; Memory Aid: 0 for output, 1 for input
  
	list  P=PIC16F877a,   R=DEC
	include "p16F877a.inc"
	__config (_CP_OFF & _HS_OSC & _WDT_OFF & _LVP_OFF & _DEBUG_ON)
	errorlevel -302  

;;;;;;; Equates;;;

STARTRAM	equ	H'20'
LEADEDGE	equ 0


;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cblock  STARTRAM           ;Beginning of Access RAM
		FlagsReg
		TempReg
        CountL
		CountH
        Knt2Low
        Knt2High
        endc



;;;;;;;;Vectors  ;;
	org	H'000'
	goto	MainLine
	org	H'004'
	goto	IntService
Stop
	goto	Stop


;;;Interrupt Service;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntService
	bcf		PIR1,CCP1IF
	bsf		FlagsReg,LEADEDGE
    retfie	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; Initial Subroutine;;;;
Initial

	bcf		STATUS,RP0	; 
	bcf		STATUS, RP1	; Bank 0 selected
	clrf	PORTC
	clrf	PORTB
	clrf	FlagsReg
	clrf	CountL
	clrf	CountH
	clrf	Knt2Low
	clrf	Knt2High
	clrf	CCPR1L
    clrf	CCPR1H
	bsf		STATUS,RP0	; Bank 1 selected
	movlw	H'04'		 ; All pins of PORTC, except RC2, outputs
	movwf	TRISC
	movlw	H'FF'
	movwf	TRISB		; All pins of PORTB inputs
  	bcf		STATUS,RP0	; Bank 0 selected 
	movlw	H'01'
	movwf	T1CON		; Enable count input to TMR1
	movlw	H'C0' 		; Enable GIE,PEIE of Intcon
    movwf	INTCON
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainLine
	call 	Initial
MainLoop
	nop
	movlw	H'05'
	movwf	CCP1CON
    bsf	    STATUS,RP0
	bsf		PIE1,CCP1IE
	bcf	    STATUS,RP0
	bcf		PIR1,CCP1IF
    nop						; Set Breakpoint to make RC2 high
	nop
LoopOne
	btfss   FlagsReg,LEADEDGE
    goto	LoopOne
	bcf	    FlagsReg,LEADEDGE
	bcf		CCP1CON,0

	movf	CCPR1L,W
	movwf	CountL
		
   	movf	CCPR1H,W
	movwf	CountH
    movlw	D'10'
	movwf	TempReg

LoopTwo
	decf	TempReg,F
    btfss	STATUS,Z
	goto    LoopTwo

LoopDrei
	nop							;Set Breakpoint to make RC2 low
	btfss   FlagsReg,LEADEDGE
    goto	LoopDrei
	movf	CCPR1L,W
	movwf	Knt2Low
		
   	movf	CCPR1H,W
	movwf	Knt2High
    nop
    bsf	    STATUS,RP0
	bcf		PIE1,CCP1IE
	bcf	    STATUS,RP0
    goto    MainLoop





	end
