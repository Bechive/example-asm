; Debounce Example by Venkat Ramaswamy

  
	list  P=PIC16F877a,  R=DEC
	include "p16F877a.inc"
	__config (_CP_OFF & _PWRTE_ON & _HS_OSC & _WDT_OFF & _BODEN_ON & _LVP_OFF)
	errorlevel -302  

;;;;;;; Equates;;;

BANKORAM	equ	H'20'
KNTTMR      equ	H'64'     ;   10 ms interrupt.
PB			equ 4		; Bit 4, PortB pushbutton Input
LED			equ 0		; Bit 0, PORTB output for LED, 1 for on
DelayKnt	equ D'20'
OneMsBit	equ	7

;;;;;;;;Variables ;;
		 
	cblock BANKORAM 	
	WT_Eins
	StatTemp
	Counter	
	FlagsReg
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
	movwf  	WT_Eins		; Copy W to WT_Eins
    swapf  	STATUS,W	; Move STATUS to StatTemp without affecting the Z bit
    movwf  	StatTemp    ; COPY to StatTemp afetr swapping nibbles
	bsf		FlagsReg,OneMsBit
    bcf		INTCON,T0IF
 
RESUME
	movlw	KNTTMR 		; indicate 10 ms
   	movwf	TMR0		; has passed
    swapf   StatTemp,W	; Restore STATUS (unswapping nibbles)
    movwf   STATUS
	swapf   WT_Eins,F	; Restore the contents to W register
    swapf   WT_Eins,W   ; without affecting the STATUS flags
    retfie	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; Initial Subroutine;;;;
Initial

	bsf		STATUS,RP0	; 
	bcf		STATUS, RP1	; Bank 1 selected
	movlw	H'04'		; Load H'05, Prescaler to Timer0
	movwf	OPTION_REG	; watch dog timer
    movlw   H'F0'
    movwf   TRISB       ; High Nibble input, low outputs
    bcf	    STATUS, RP0 ; Bank 0 selected
    clrf    PORTB       ; All outputs of Port B reset
	clrf	Counter
	clrf	FlagsReg
	movlw	KNTTMR
   	movwf	TMR0
	movlw   H'A0'		; Enable GIE, Timer0 Int.
	movwf   INTCON   
	return

MainLine
	call 	Initial
MainLoop
    btfss	FlagsReg,OneMsBit
   	goto    MainLoop
   	nop
	bcf		FlagsReg,OneMsBit

	movf	Counter,F	; Check whether Counter is zero
	btfss	STATUS,Z
    goto    NonZero		; goto NonZero if Z is clear/Counter >0

    btfss	PORTB,PB
    goto    TurnOff

	btfsc	FlagsReg,PB
	goto    TurnOn

	movlw	DelayKnt
	movwf	Counter
	goto    TurnOff

TurnOn
	bsf		PORTB,LED
	goto    MainLoop
NonZero
	btfss	PORTB,PB
	goto    CntrZero
	decf	Counter,F
    btfss   STATUS,Z
	goto    TurnOff
	bsf		FlagsReg,PB
	goto    TurnOn
CntrZero
	clrf	Counter
TurnOff
	bcf		FlagsReg,PB
	bcf		PORTB,LED
    goto  	MainLoop




 end
