     list p=16f877a                 ; list directive to define processor
     #include <p16f877a.inc>        ; processor specific variable definitions
     ; configuration fuse settings
     ;    code protect off  watch dog timer off, brown out enable , program write on ,   high speed oscillator on
     ;  write enable on , low voltage programming off and code protect data off
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; ********  Equates ***************************************************
TMRCNT      equ		D'249'  ; to be assigned to PR2 (4 ms interrupt)
Bank0Ram    equ 	0x20	;Equates mean the same as before!

; ******** Variables **************************************************
 	cblock Bank0Ram
		W_TEMP
		STATUS_TEMP
		BLNKCNT
	endc

; ******** Vectors *****************************************************
		org 	0x000 		; Set origin at memory address 000
		goto	Mainline
		org	0x004

; ******** Interrupt Service *****************************************************
IntService
; save values of STATUS and W registors in temp registors
	movwf	W_TEMP			; copy W to RAM
	swapf	STATUS, W		; move status to w without affecting Z bit
	movwf	STATUS_TEMP		; copy to RAM (with nibbles swapped);

;Execute polling routine
	btfss	PIR1, TMR2IF	; check for timer2 interrupt
	goto	source1			; if not, check source1
	bcf		PIR1, TMR2IF	; clear interrupt flag (bank 0)
	decf	BLNKCNT, F
	goto	RESUME
source1
;	btfsc	...				; check another interrupt source
;	call	...				; if ready, service it
;	btfsc	...				; check another interrupt source
;	call	...				; if ready, service it

RESUME
;Restore original values of STATUS and W and return from interrupt
	swapf 	STATUS_TEMP,W	; restore STATUS bits  (unwrapping nibbles)
	movwf	STATUS			; without affecting Z bit
	swapf 	W_TEMP, F		; swap W_TEMP
	swapf	W_TEMP, W		; and swap again into W without affecting Z bit

	retfie

; ******** Initial subroutine *****************************************************
Initial
;Initialize PORTB
	bcf	  	STATUS, RP1	; TRISB is in bank1, so select bank1 
	bsf	  	STATUS, RP0	; by setting RP1:RP0=01
	movlw   0xF8		; clear lower three bits
	andwf   TRISB, F	; set lower three bits as outputs
	bcf	  	STATUS, RP0	; Go to bank0
	andwf   PORTB, F	; clear PORTB bit 2,1,0

;Initialzation for Timer2
	bcf		STATUS, RP1		;select bank 0
	bcf		STATUS, RP0
	movlw	0x26			; B'00100110' set up T2CON, 
	movwf	T2CON			; 	prescaler and postscaler
	bsf		INTCON, PEIE	; enable Timer2 interrupt source
	
	bsf		STATUS, RP0		; select bank 1
	movlw	TMRCNT	
	movwf	PR2
	bsf		PIE1, TMR2IE	; Enable interrupt path
	
	bcf		STATUS, RP0		; set register access back to bank 0
	bsf		INTCON, GIE		; enable global interrupts

	return

; ******** Mainline Program *****************************************************
Mainline
	call 	Initial	     	; Initialize PORTB
MainLoop
	call	Blink	     	; Blink LED
	call	Five00ms		; Insert 500ms delay
	goto	MainLoop

;;;
Blink
	btfsc	PORTB, 0		; is it Green?
	goto 	toggle1			; yes, goto toggle1
	btfsc	PORTB, 1		; else is it Yellow?
	goto 	toggle2			; yes, goto toggle2
;toggle0
	bcf 	PORTB, 2		; otherwise, must be red, change to green
	bsf		PORTB, 0		; 100->001
	return
toggle1
	bcf		PORTB, 0		; change from green to yellow
	bsf		PORTB, 1		; 001->010
	return
toggle2
	bcf		PORTB, 1		; change from yellow to red
	bsf		PORTB, 2		; 010->100
	return

;;;
Five00ms
	movlw   D'124'	   		; initialize BLNKCNT to 124, why?
	movwf   BLNKCNT   	 	; BLNKCNT is a variable
wait500
	btfss	BLNKCNT, 7	 	; wait for 00000000 to 11111111 change
	goto	wait500	   	 	; to return. If not, keep waiting
	return		  	 		; 

;;;
	end
