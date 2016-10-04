 title"Serial Communication using RS232"
; By Andrew Brown
; This program is similified for PIC16F877
; It accepts a character from HyperTerminal and returns it back to Hyperterminal
; Set Baud rate as 9600, Parity bit none, stop bit one. 

		LIST      P=16F877a, F=INHX8M
		#include <P16F877a.inc>
	    	__config _CP_OFF & _DEBUG_OFF & _LVP_OFF & _BODEN_ON & _WDT_OFF & _HS_OSC & _PWRTE_ON  

; ********  Equates ***************************************************
Bank0Ram	equ	H'20'

; ******** Variables **************************************************
	cblock  Bank0Ram           ;Beginning of Access RAM
        W_TEMP
		STATUS_TEMP
		FlagsReg
		TempReg
	endc

; ******** Vectors *****************************************************
	ORG		0x0000				;Reset Vector
	GOTO	MainLine

	ORG		0x0004				;Interrupt vector
	GOTO	IntService

; ******** Interrupt Service ********************************************
IntService
	movwf 	W_TEMP					;Copy W to TEMP register
	swapf 	STATUS,W				;Swap status to be saved into W
	clrf 	STATUS					;bank 0, regardless of current bank, Clears IRP,RP1,RP0
	movwf 	STATUS_TEMP				;Save status to bank zero STATUS_TEMP register
    btfss	PIR1, RCIF
	goto	NoService

    btfss	RCSTA, FERR				;Is it a framming error?
	goto	USARTNoFramingError
	movf	RCREG, W				;Remove the framing error by reading FIFO
	goto	NoService

USARTNoFramingError
    btfss	RCSTA, OERR				;Is it an overrun error
	goto	USARTRecievedDataOK
    bcf		RCSTA, CREN				;Remove overrun error by resetting usart
	nop
	bsf		RCSTA, CREN				;Disable and then re-enable
	goto	NoService

USARTRecievedDataOK
	movf	RCREG, W				;Clears the RCIF flag, once the RCREG register is read 
    nop								;the data disappears as does the interrupt 
    nop								; if the FIFO is now empty
	movwf	TXREG					;Echo back data to PC
NoService
	swapf 	STATUS_TEMP,W 	  			;Swap STATUS_TEMP register into W
	movwf 	STATUS 		         	;sets bank to original state	
	swapf 	W_TEMP,F 	  			;Swap W_TEMP
	swapf 	W_TEMP,W 	  			;Swap W_TEMP into W
	retfie                  	  	; return from interrupt

; ******** Initial subroutine ******************************************
Initial
	;Initialisation for 16f877
	bcf		STATUS,RP0
	bcf		STATUS,RP1
	clrf	PIR1
	clrf 	PIR2				;Clear interrupt flags registers
	clrf 	PORTA
	clrf 	PORTB
	clrf 	PORTC
	clrf 	PORTD
	clrf 	PORTE				;Clear ports to output all 0's
	bsf 	STATUS, RP0			; Setlect Bank1
    movlw 	D'07'
	movwf 	ADCON1				;PortA and PortE all digital I/O
	movlw 	H'C8'				;Port C all outputs except for UART RX TX
	movwf 	TRISC
	clrf	TRISD				;Port D all outputs
	clrf 	TRISE				;Port E all outputs
	movlw 	H'24'				;TX On, Async mode, high speed 9600bps, 8 bit trasnmission
	movwf 	TXSTA
	movlw 	D'129'			     ;9600bps (FOSC = 20 Mhz)
	movwf 	SPBRG
	movlw 	H'20'
	movwf 	PIE1					;Enable USART recieve interrupt
	bcf 	STATUS, RP0				;Set RAM Bank 0
	clrf	ADCON0
	movlw 	H'90'
	movwf 	RCSTA					;RX On continous recieve
	clrf	RCREG			    	;Empty USART RX FIFO
	movlw	H'C0'
	movwf 	INTCON					;Set GIE and periferal interrupts
	return

; ******** Mainline Program *****************************************************
; Main loop
MainLine
	call    Initial
MainLoop
    nop 
	goto	MainLoop	; loop to self doing nothing

	END
