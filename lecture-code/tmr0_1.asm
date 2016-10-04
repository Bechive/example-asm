     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
Bank0Ram	equ	H'20'
TMRCNT      equ	H'64'     ;   1 ms interrupt.

; ******** Variables **************************************************
	cblock Bank0Ram 	
		W_TEMP
		STATUS_TEMP
	endc

; ******** Vectors *****************************************************
	org	H'000'
	goto	MainLine
	org	H'004'
	goto	IntService
Stop
	goto	Stop

; ******** Interrupt Service *****************************************************
IntService
; save values of STATUS and W registors in temp registors
	movwf  	W_TEMP		 	; Copy W to W_TEMP
    swapf  	STATUS,W	 	; Move STATUS to STATUS_TEMP without affecting the Z bit
	movwf  	STATUS_TEMP		; COPY to STATUS_TEMP afetr swapping nibbles

    bcf		INTCON,T0IF		; Clear TMR0 overflow interrupt flag bit
 
RESUME
	movlw	TMRCNT 			; indicate 1 ms
   	movwf	TMR0			; has passed
; Restore original values of STATUS and W regs
    swapf   STATUS_TEMP,W	; Restore STATUS (unswapping nibbles)
    movwf   STATUS
	swapf   W_TEMP,F		; Restore the contents to W register
    swapf   W_TEMP,W    	; without affecting the STATUS flags
    retfie	

; ******** Initial subroutine *****************************************************
Initial
	bsf		STATUS,RP0		; Bank 1 selected
	bcf		STATUS, RP1		; 
	movlw	H'04'			; H'04=>OPTION_REG (Prescaler 32)
	movwf	OPTION_REG		; 
	bcf	    STATUS, RP0 	; Bank 0 selected
	movlw	TMRCNT			; Load appropriate value in TMR0 reg.
   	movwf	TMR0			;
	movlw   H'A0'			; Enable GIE, Timer0 Int.
	movwf   INTCON   
	return

; ******** Mainline Program *****************************************************
MainLine
	call 	Initial
MainLoop
    nop
    nop
    goto  	MainLoop

;;;
	end
