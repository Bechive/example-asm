;***********************************************************
;	PIC16F877 EXAMPLE CODE FOR A PIC LCD DEMO
;
;	
;	FREQUENCY: 20MHz
;   Program by Andrew Brown 2004
;
;   modified by Alex Gibson  26/06/2004
;   changed to 16f877
;
;************************************************************
; This program demonstrates basic functionality of the LCD.
;
; Port D is hardwired to the LCD
; Port E is hardwired to the LCD
; When the PIC boots the LCD will display a welcome message 
; accross the top and bottom line, and the cursor will be 
; left flashing in the bottom corner
;
; Only works on the PIC 16F877 because the LCD is only on the new 2004 borads


	LIST      P=16F877a, F=INHX8M
	#include <P16F877a.inc>
	
	; code protect off  debug off   program memory write protection off
	; low voltage programming off brown out detection on , watch dog timer off
       	; High speed(>4MHz) xtal program write on
       	
	__config _CP_OFF & _DEBUG_OFF & _LVP_OFF & _BODEN_ON & _WDT_OFF & _HS_OSC & _PWRTE_ON      

;************************************************************
;DEFINES
;************************************************************

#define	RS PORTE, 0
#define RW PORTE, 1
#define E PORTE, 2

;************************************************************
; MEMORY EQUATES
;************************************************************

TempBuffer			EQU 0x20
DelayA				EQU 0x21
DelayB				EQU 0x22
DelayC				EQU 0x23

;************************************************************
; Reset and Interrupt Vectors

	ORG		0x0000				;Reset Vector
	GOTO	Start

	ORG		0x0004				;Interrupt vector
	GOTO	IntVector

;************************************************************
; Program begins here

	ORG		0x005
Start
	CLRF 	PIR1
	CLRF 	PIR2					;Clear interrupt flags registers
	CLRF 	PORTA
	CLRF 	PORTB
	CLRF 	PORTC
	CLRF 	PORTD
	CLRF 	PORTE					;Clear ports to output all 0's
	BSF 	STATUS, RP0				; Set RAM Bank 1
	MOVLW 	.7
	MOVWF 	ADCON1					;PortA and PortE all digital I/O
	CLRF 	TRISA					;Port A all outputs
	CLRF 	TRISB					;Port B all outputs
	CLRF 	TRISC					;Port C all outputs
	CLRF 	TRISD					;Port D all outputs
	CLRF 	TRISE					;Port E all outputs
	CLRF 	TXSTA					;Disable USART transmitter, as its not being used in this example
	CLRF 	PIE1					;Disable all interrupts
	BCF 	STATUS, RP0				;Set RAM Bank 0
	CLRF	ADCON0					;Disable A/D converter
	CLRF 	RCSTA					;Disable USART reciever, as its not being used in this example
	CLRF 	INTCON					;Ensure that all interrupts are turned off

;************************************************************
; Main loop

MainLoop							;Ready to run program
	;Initialise LCD Display
	BCF		PORTE, 1				;Set The LCD to Read only

	;The follwoing sequence is the recomemded power up sequence for an LCD as stated by the chipset manufacturer
	;Read page 6 of LCD Information.pdf available on UTSOnline (or at http://www.crowcroft.net/kitsrus/lcd16x2_nobl.zip) for more information
	BCF 	PORTE, 0			;Instruction register select
	MOVLW 	.25
	CALL 	Delay				;Delay for LCD PowerUp
	MOVLW 	.30
	CALL 	LCDWrite8			;Set LCD to 8 bits
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.30
	CALL 	LCDWrite8			;Set LCD to 8 bits
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.30
	CALL 	LCDWrite8			;Set LCD to 8 bits
	MOVLW 	.5	
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.56	
	CALL 	LCDWrite8			;8 bit interface 2 line, 5x7 character format
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.56
	CALL 	LCDWrite8			;8 bit interface 2 line, 5x7 character format
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 

	;Write user specific configuration data
	MOVLW 	.6
	CALL 	LCDWrite8			;Display shifting disabled, use cursor shifting instead
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.1
	CALL 	LCDWrite8			;Clear all DDRAM and set cursor to pos 1
	MOVLW 	.5
	CALL 	Delay				;Delay for LCD 
	MOVLW 	.15
	CALL 	LCDWrite8			;Display On & show cursor blinking with an underline
	BSF 	PORTE, 0			;Set to data register

	;Write data to the LCD " Welcome to IDS"
	MOVLW	' '
	CALL	LCDWrite8
	MOVLW	'W'
	CALL	LCDWrite8
	MOVLW	'e'
	CALL	LCDWrite8
	MOVLW	'l'
	CALL	LCDWrite8
	MOVLW	'c'
	CALL	LCDWrite8
	MOVLW	'o'
	CALL	LCDWrite8
	MOVLW	'm'
	CALL	LCDWrite8
	MOVLW	'e'
	CALL	LCDWrite8
	MOVLW	' '
	CALL	LCDWrite8
	MOVLW	't'
	CALL	LCDWrite8
	MOVLW	'o'
	CALL	LCDWrite8
	MOVLW	' '
	CALL	LCDWrite8
	MOVLW	'I'
	CALL	LCDWrite8
	MOVLW	'D'
	CALL	LCDWrite8
	MOVLW	'S'
	CALL	LCDWrite8

	;Move cursor to first position 2nd line of the LCD, otherwise the next character we send will be off the end of the top line of the display
	BCF		PORTE, 0			;Set instruction register
	MOVLW	.192
	CALL	LCDWrite8
	BSF		PORTE, 0			;Set data register

	;Write data to the second line of the LCD - "LCD Example Prog"
	MOVLW	'L'
	CALL	LCDWrite8
	MOVLW	'C'
	CALL	LCDWrite8
	MOVLW	'D'
	CALL	LCDWrite8
	MOVLW	' '
	CALL	LCDWrite8
	MOVLW	'E'
	CALL	LCDWrite8
	MOVLW	'x'
	CALL	LCDWrite8
	MOVLW	'a'
	CALL	LCDWrite8
	MOVLW	'm'
	CALL	LCDWrite8
	MOVLW	'p'
	CALL	LCDWrite8
	MOVLW	'l'
	CALL	LCDWrite8
	MOVLW	'e'
	CALL	LCDWrite8
	MOVLW	' '
	CALL	LCDWrite8
	MOVLW	'P'
	CALL	LCDWrite8
	MOVLW	'r'
	CALL	LCDWrite8
	MOVLW	'o'
	CALL	LCDWrite8
	MOVLW	'g'
	CALL	LCDWrite8

	;Set cursor to last position 2nd line of the LCD because it was incremented off the edge after the last character was printed
	BCF		PORTE, 0			;Set instruction register
	MOVLW	.207
	CALL	LCDWrite8
	BSF		PORTE, 0			;Set data register


	call	Delay
	call	Delay
	call	setbeginline2
	call	Delay
	call	Delay
	call	shiftcursor
	call	Delay
	call	Delay
	call	shiftcursor
	call	Delay
	call	Delay
	call	shiftcursor
	MOVLW	'&'
	CALL	LCDWrite8
	Call	setendline2

Waiting							;Finished writing data so loop forever
	GOTO	Waiting	; loop to self doing nothing

;************************************************************
;LCD Write Subs

LCDWrite8					;Write to the LCD in 8 bit mode
	MOVWF 	TempBuffer		;Temporily store data to be written to the LCD
	BCF 	PORTE, 2		;Clear the enable pin
	MOVLW 	.1	
	CALL 	Delay			;1ms Delay for LCD timing
	MOVF	TempBuffer, W
	MOVWF 	PORTD			;Write stored data to PORTD ie LCD data pins
	BSF 	PORTE, 2		;Pulse Enable pin
	NOP
	BCF 	PORTE, 2
	RETURN
					
					;To know how much of a delay you need, take a look at LCD Information.pdf page 5, 
					;you can view a list of commands and how long it takes to process.
Delay					;Delay a set amount of ms, counts cycles based on 20Mhz clock
	MOVWF	DelayA
OuterLoop
	MOVLW	.29
	MOVWF	DelayB
MiddleLoop
	MOVLW	.42
	MOVWF	DelayC
InnerLoop	
	NOP
	DECFSZ	DelayC, F
	GOTO	InnerLoop
	DECFSZ	DelayB, F
	GOTO	MiddleLoop
	DECFSZ	DelayA, F
	GOTO	OuterLoop
	RETURN

;************************************************************
cursorhome
	BCF		PORTE, 0			;Set instruction register
	MOVLW 	b'000000010'
	CALL 	LCDWrite8			;Clear all DDRAM and set cursor to pos 1
	call    Delay	
	bsf    	PORTE, 0
    	return
;**********************************************************    	
setbeginline1
   	BCF	RS			;Set instruction register
	MOVLW 	b'10000001'
	CALL 	LCDWrite8			;Clear all DDRAM and set cursor to pos 1
	call    Delay	
    	bsf    RS
    	return
;************************************************************
setendline1
   	BCF	RS			
	MOVLW 	b'10001111'
	CALL 	LCDWrite8			
	call    Delay
   	bsf    RS
    	return    	
;*************************************************************
setbeginline2
   	BCF	RS			;Set instruction register
	MOVLW	.192
	CALL	LCDWrite8
	BSF	RS			;Set data register
    	return
;*************************************************************
setendline2
    BCF	RS			;Set instruction register
	MOVLW	.207
	CALL	LCDWrite8
	BSF	RS			;Set data register
  	return
;*************************************************************
shiftcursor
    BCF	RS			;Set instruction register
	MOVLW	B'00010100'
	CALL	LCDWrite8
	BSF	RS			;Set data register
  	return
;*************************************************************  
clearlcd
	bcf  RS
	MOVLW 	.1
	CALL 	LCDWrite8
	call    Delay	
	return

;************************************************************
; Interrupt Service Routine

IntVector							;Empty routiene, just in case an interrupt occurs
	RETFIE                  	  	; return from interrupt

	END
