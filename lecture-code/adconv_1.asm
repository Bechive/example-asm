; Analog-to-Digital Conversion
; By Venkat Ramaswamy
	LIST      P=16F877a, F=INHX8M
    #include <P16F877a.inc>

	__config     _LVP_OFF & _HS_OSC 
	
; ********  Equates ***************************************************
Bank0Ram	equ		H'20'
LBTMR1      equ		H'95'   ;    Load the lowbyte count for 10 ms delay
HBTMR1      equ   	H'E7' 	;    Load the highbyte count for 10 ms delay
TenMsBit	equ     7    	;    Prescaler 8 
TempVal		equ     0

; ******** Variables **************************************************

	cblock  Bank0Ram          	; Beginning of Access RAM
        W_TEMP
		STATUS_TEMP
	    FlagsReg				; Register for holding the flag
		ADCount			; HighByte read on A/D conversion
    endc					

; ******** Vectors *****************************************************

	org		0x0000
	goto		Mainline
	org		0x0004
	goto		IntService
Stop
	goto	Stop


; ******** Initial subroutine ******************************************

; This subroutine performs all initializations of variables and registers.

Initial
    bcf     	STATUS, RP0  	; Select Bank0
    bcf     	STATUS, RP1  	; Select Bank0
	movlw   	LBTMR1
	movwf		TMR1L    		; Load Lowbyte Timer1
	movlw   	HBTMR1
	movwf		TMR1H 			; Load HighByte Timer1
	clrf		FlagsReg	 	; Clear all registers used	
	clrf		ADCount
	clrf		PORTA	 		; Clear PORTA & PORTC
    clrf		PORTC
	movlw       H'81'	 	; select Fosc/32 for 20 MHz crystal, &
	movwf		ADCON0		;    set AD ON bit. Load to ADCON0 Reg

    bsf     	STATUS, RP0  	; Select Bank1
    movlw  		H'0F'	 		; PA5, PA4 D I/O, PA3 =Vref+
    movwf	    ADCON1    		; PA2 Gnd, PA1 I/O, PA0 Analogue Input
;	Ensure that A/D Result is left justified.
	movlw       H'0D'      		; PA0, PA2,PA3 inputs
	movwf		TRISA	 		; PA1, PA4,PA5 outputs
    movlw		H'00' 			; All PORTC pins outputs
	movwf		TRISC 
    bsf  		PIE1,TMR1IE ; Enable Tmr1 Interrupt in PIE1 Reg
	bcf     	STATUS, RP0   	; Select Bank0
								
	movlw  		H'31'  			; Tmr1 Prescaler set to 8
	movwf		T1CON 			; Enable TMR1ON, T1CON Reg
  	movlw   	H'C0' 			; Enable GIE and PEIE in INTCON
	movwf		INTCON			; Interrupt controller setting
    return
					
Mainline
	call	Initial
MainLoop
	btfss	FlagsReg,TenMsBit
   	goto    MainLoop
  	bcf		FlagsReg,TenMsBit	; Routine for every 10 ms	
    bsf		ADCON0,GO_DONE		; ADC Routine
JustWait
	btfsc	ADCON0,GO_DONE  	; Check if conversion is over
    goto	JustWait			;  if not goto JustWait	
    movf	ADRESH,W 			; Move high byte to W
	movwf	ADCount    			; Save it in ADHighCnt
   	goto 	MainLoop

; ******** Interrupt Service ********************************************
IntService
; save values of STATUS and W registors in temp registors
	movwf  	W_TEMP		 	; Copy W to W_TEMP
    swapf  	STATUS,W	 	; Move STATUS to STATUS_TEMP without affecting the Z bit
	movwf  	STATUS_TEMP		; COPY to STATUS_TEMP afetr swapping nibbles

	movlw   LBTMR1
	movwf	TMR1L
	movlw	HBTMR1
	movwf	TMR1H
	bsf		FlagsReg,TenMsBit
	bcf		PIR1,TMR1IF   	; PIR1 Tmr1 Flag

; Restore original values of STATUS and W regs
    swapf   STATUS_TEMP,W	; Restore STATUS (unswapping nibbles)
    movwf   STATUS
	swapf   W_TEMP,F		; Restore the contents to W register
    swapf   W_TEMP,W    	; without affecting the STATUS flags
	retfie

    end

