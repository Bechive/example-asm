     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
Bank0Ram	equ	H'20'
LBTMR1      equ	H'77'   ; 1 ms interrupt.
HBTMR1      equ	H'EC'   ;  

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
	movwf  	W_TEMP		 ; Copy W to W_TEMP
    swapf  	STATUS,W	 ; Move STATUS to STATUS_TEMP without affecting the Z bit
	movwf  	STATUS_TEMP    ; COPY to STATUS_TEMP afetr swapping nibbles
;;;
    bcf		PIR1,TMR1IF		; clear overflow interrupt flag bit
 
;RESUME
	movlw   LBTMR1		; re-assign LBTMR1 to TMR1L
	movwf	TMR1L		; and
	movlw   HBTMR1		; HBTMR1 to TMR1H
	movwf	TMR1H		; to make another interrupt after 1 ms
; Restore original values of STATUS and W regs
    swapf   STATUS_TEMP,W	; Restore STATUS (unswapping nibbles)
    movwf   STATUS
	swapf   W_TEMP,F	; Restore the contents to W register
    swapf   W_TEMP,W    ; without affecting the STATUS flags
    
	retfie	

; ******** Initial subroutine *****************************************************
Initial
	bcf		STATUS,RP0	; Bank 0 selected
	bcf		STATUS, RP1	; 
	movlw	LBTMR1		; Assign LBTMR1 to TMR1L
	movwf	TMR1L		; and
	movlw	HBTMR1		; LBTMR1 to TMR1L
	movwf	TMR1H		; to make an interrupt after 1 ms.
	movlw	H'01'		; Timer1 prescaler set to 1
	movwf	T1CON  		; Timer1 control register, Timer1 made ON
	bsf		STATUS, RP0	; Bank 1 selected
	bsf   	PIE1,TMR1IE	; Enable the Timer1 overflow interrupt
	bcf	    STATUS, RP0	; Bank 0 selected
	movlw	H'C0'
	movwf	INTCON		; Interrupt controller setting
	return

; ******** Mainline Program *****************************************************
MainLine
	call 	Initial
MainLoop
    nop
    nop
    goto  	MainLoop

 end
