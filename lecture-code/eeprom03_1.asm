title "READIND FROM / WITING TO EEPROM"
;;;;;;; IDS Program 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Use 20 MHz crystal frequency.
; Created on 30 March 2004
; Testing EEPROM
;
;;;;;;; Program hierarchy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mainline
;   Initial
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	list  P=PIC16F877a,  F=INHX8M,  C=160, N=80,  ST=OFF, MM=OFF, R=DEC
	include "p16F877a.inc"
	__config (_CP_OFF & _DEBUG_ON   & _PWRTE_ON & _XT_OSC & _WDT_OFF & _BODEN_ON & _LVP_OFF)
	errorlevel -302   


;;;;;;; Equates;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BANKORAM	equ		H'20'
LP_ADR		equ	H'08'	; EEPROM Address First
HP_ADR		equ	H'09'	; EEPROM Address Seocnd


;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      cblock  BANKORAM	    ; Beginning of Access RAM
	  DATA_ADR				; Register to hold EEPROM add	
	  DATAHOLD	            ; Register to hold data to be written
	  TempReg				; Temporary Register
      endc

;;;;;;; Macro definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SELBZERO  macro
     bcf	STATUS,RP0
	 bcf	STATUS,RP1
	 endm

SELBEINS  macro
     bsf	STATUS,RP0
	 bcf	STATUS,RP1
	 endm

SELBZWEI  macro
     bcf	STATUS,RP0
	 bsf	STATUS,RP1
	 endm

SELBDREI  macro
     bsf	STATUS,RP0
	 bsf	STATUS,RP1
	 endm


MOVLF   macro  literal,dest
 	movlw  	literal
  	movwf  	dest
    endm

MOVFF   macro  source,dest
    movf   	source,W
   	movwf  	dest
   	endm



;;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  	org		0x0000
	  	goto	Mainline
	  	org		0x0004
	  	goto	IntService
Stop
		goto	Stop

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ;;;;;;;;;;Interrupt Service;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
IntService
 		retfie  
 
;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mainline
      	call  	Initial          ;Initialize everything
MainLoop
  		movlw   LP_ADR		; Address Location EEPROM
		movwf	DATA_ADR	; Load the address 
		movlw   D'100'       
		movwf   DATAHOLD 	; Specify value
		call    EEWrite    
		call    Wait25    
		clrf    DATAHOLD
		movlw   LP_ADR		; Address Location EEPROM
		movwf	DATA_ADR	; Load the address 	
		call    JustRead    ; Read the Low Pr setting 
 		call    Wait25    
	    movlw   HP_ADR		; Address Location EEPROM
		movwf	DATA_ADR	; Load the address 
		movlw   D'128'       
		movwf   DATAHOLD 	; Specify value
		call    EEWrite    
		call    Wait25    
		clrf    DATAHOLD
		movlw   HP_ADR		; Address Location EEPROM
		movwf	DATA_ADR	; Load the address 	
		call    JustRead    ; Read the Low Pr setting 
 		call    Wait25    
		goto    MainLoop

Wait25
		movlw	D'100'
        movwf	TempReg
Loop2
		decf    TempReg,F
		btfss	STATUS,Z
	    goto    Loop2
		return



;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine performs all initializations of variables and registers.

Initial
		bsf		INTCON, GIE	; Enable interrupts, GIE (global interrupt enable) bit
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;Read EEPROM;;;;;;;;;;;;;


JustRead
	movf	DATA_ADR,W
	SELBZWEI
	movwf	EEADR		; Data Address transferred.
	SELBDREI
	bcf		EECON1,EEPGD	; Point to DATA memory
	bsf		EECON1, RD  ; ; Enable Read
	SELBZWEI
    movf    EEDATA,W
	SELBZERO
    movwf	DATAHOLD
 	return          	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Write to EEPROM ;;;;;;;;;;;;;;;;;;;;;;
EEWrite
    SELBDREEI			;  Bank 3 selected
EEWRLoop
	btfsc  	EECON1,WR	
	goto	EEWRLoop
    SELBZERO
 	movf	DATA_ADR,W	; 
    SELBZWEI
	movwf	EEADR		; Data Address transferred.
	SELBZERO
 	movf	DATAHOLD,W
	SELBZWEI
 	movwf	EEDATA		; Data Held transferred.
	SELBDREI
	bcf		EECON1,EEPGD	; Point to DATA memory
    bsf		EECON1,WREN	; Enable Write
    bcf		INTCON, GIE	; Diasble interrupts
 	movlw	H'55'		; Start sequence
 	movwf	EECON2
 	movlw	H'AA'
 	movwf	EECON2
 	bsf		EECON1,WR	; Enable Write, end
    bsf		INTCON, GIE	; Enable interrupts	
	bcf		EECON1,WREN	; Disable Writes
	SELBZERO
    return	    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        end

