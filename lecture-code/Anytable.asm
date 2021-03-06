	LIST      P=16F877, F=INHX8M
    #include <P16F877.inc>

	__config     _LVP_OFF & _HS_OSC 
	
;;;;;;;Equates;;;;;;;;;;;;;;;;;;;

STARTRAM	equ		H'20'


;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cblock  STARTRAM          	; Beginning of Access RAM
    TempAddr		        	;  Offsets into the Table
	TempReg
    endc	

;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org		0x0000
	goto		Mainline
	org		0x0004
	goto		INTSERVICE
Stop
	goto	Stop

;;;;;;;;;;;;;;;;IntService;;;;;;;;;;;;;
INTSERVICE
	retfie


;;;;;;;;Main Program;;;;;;;;;;;;;;;

Mainline
    clrf	TempAddr
    movlw  	H'FF'
    movwf  	TempReg
    nop

    call   	ConvTable
	movwf	TempAddr
	goto	Mainline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;org		0xEF0
ConvTable
	movlw	HIGH ConvTable
    movwf	PCLATH
    movlw	LOW  ConvTable
    addwf	TempReg,W
    btfsc   STATUS,C
    incf	PCLATH,F
    addlw   D'11'
    btfsc   STATUS,C
    incf	PCLATH,F     
   	movf    TempReg,W
   	addwf	PCL,F
	retlw	D'0'
    retlw	D'0'
	retlw	D'0'
	retlw	D'1'
	retlw	D'1'
	retlw	D'1'
	retlw	D'2'
	retlw	D'2'
	retlw	D'3'
	retlw	D'3'
	retlw	D'3'
	retlw	D'4'
	retlw	D'4'
	retlw	D'5'
	retlw	D'5'
	retlw	D'5'
	retlw	D'6'
	retlw	D'6'
	retlw	D'7'
	retlw	D'7'
	retlw	D'7'
	retlw	D'8'
	retlw	D'8'
	retlw	D'9'
	retlw	D'9'
	retlw	D'9'
	retlw	D'10'
	retlw	D'10'
	retlw	D'10'
	retlw	D'11'
	retlw	D'11'
	retlw	D'12'
	retlw	D'12'
	retlw	D'12'
	retlw	D'13'
	retlw	D'13'
	retlw	D'14'
	retlw	D'14'
	retlw	D'14'
	retlw	D'15'
	retlw	D'15'
	retlw	D'16'
	retlw	D'16'
	retlw	D'16'
	retlw	D'17'
	retlw	D'17'
	retlw	D'18'
	retlw	D'18'
	retlw	D'18'
	retlw	D'19'
	retlw	D'19'
	retlw	D'20'
	retlw	D'20'
	retlw	D'20'
	retlw	D'21'
	retlw	D'21'
	retlw	D'21'
	retlw	D'22'
	retlw	D'22'
	retlw	D'23'
	retlw	D'23'
	retlw	D'23'
	retlw	D'24'
	retlw	D'24'
	retlw	D'25'
	retlw	D'25'
	retlw	D'25'
	retlw	D'26'
	retlw	D'26'
	retlw	D'27'
	retlw	D'27'
	retlw	D'27'
	retlw	D'28'
	retlw	D'28'
	retlw	D'29'
	retlw	D'29'
	retlw	D'29'
	retlw	D'30'
	retlw	D'30'
	retlw	D'30'
	retlw	D'31'
	retlw	D'31'
	retlw	D'32'
	retlw	D'32'
	retlw	D'32'
	retlw	D'33'
	retlw	D'33'
	retlw	D'34'
	retlw	D'34'
	retlw	D'34'
	retlw	D'35'
	retlw	D'35'
	retlw	D'36'
	retlw	D'36'
	retlw	D'36'
	retlw	D'37'
	retlw	D'37'
	retlw	D'38'
	retlw	D'38'
	retlw	D'38'
	retlw	D'39'
	retlw	D'39'
	retlw	D'40'
	retlw	D'40'
	retlw	D'40'
	retlw	D'41'
	retlw	D'41'
	retlw	D'41'
	retlw	D'42'
	retlw	D'42'
	retlw	D'43'
	retlw	D'43'
	retlw	D'43'
	retlw	D'44'
	retlw	D'44'
	retlw	D'45'
	retlw	D'45'
	retlw	D'45'
	retlw	D'46'
	retlw	D'46'
	retlw	D'47'
	retlw	D'47'
	retlw	D'47'
	retlw	D'48'
	retlw	D'48'
	retlw	D'49'
	retlw	D'49'
	retlw	D'49'
	retlw	D'50'
	retlw	D'50'
	retlw	D'50'
	retlw	D'51'
	retlw	D'51'
	retlw	D'52'
	retlw	D'52'
	retlw	D'52'
	retlw	D'53'
	retlw	D'53'
	retlw	D'54'
	retlw	D'54'	
	retlw	D'54'
	retlw	D'55'
	retlw	D'55'
	retlw	D'56'
	retlw	D'56'
	retlw	D'56'
	retlw	D'57'
	retlw	D'57'
	retlw	D'58'
	retlw	D'58'
	retlw	D'58'
	retlw	D'59'
	retlw	D'59'
	retlw	D'60'
	retlw	D'60'
	retlw	D'60'
	retlw	D'61'
	retlw	D'61'
	retlw	D'61'
	retlw	D'62'
	retlw	D'62'
	retlw	D'63'
	retlw	D'63'
	retlw	D'63'
	retlw	D'64'
	retlw	D'64'
	retlw	D'65'
	retlw	D'65'
	retlw	D'65'
	retlw	D'66'
	retlw	D'66'
	retlw	D'67'
	retlw	D'67'
	retlw	D'67'
	retlw	D'68'
	retlw	D'68'
	retlw	D'69'
	retlw	D'69'
	retlw	D'69'
	retlw	D'70'
	retlw	D'70'
	retlw	D'70'
	retlw	D'71'
	retlw	D'71'
	retlw	D'72'
	retlw	D'72'
	retlw	D'72'
	retlw	D'73'
	retlw	D'73'
	retlw	D'74'
	retlw	D'74'
	retlw	D'74'
	retlw	D'75'
	retlw	D'75'
	retlw	D'76'
	retlw	D'76'
	retlw	D'76'
	retlw	D'77'
	retlw	D'77'
	retlw	D'78'
	retlw	D'78'
	retlw	D'78'
	retlw	D'79'
	retlw	D'79'
	retlw	D'80'
	retlw	D'80'
	retlw	D'80'
	retlw	D'81'
	retlw	D'81'
	retlw	D'81'
	retlw	D'82'
	retlw	D'82'
	retlw	D'83'
	retlw	D'83'
	retlw	D'83'
	retlw	D'84'
	retlw	D'84'
	retlw	D'85'
	retlw	D'85'
	retlw	D'85'
	retlw	D'86'
	retlw	D'86'
	retlw	D'87'
	retlw	D'87'
	retlw	D'87'
	retlw	D'88'
	retlw	D'88'
	retlw	D'89'
	retlw	D'89'
	retlw	D'89'
	retlw	D'90'
	retlw	D'90'
	retlw	D'90'
	retlw	D'91'
	retlw	D'91'
	retlw	D'92'
	retlw	D'92'
	retlw	D'92'
	retlw	D'93'
	retlw	D'93'
	retlw	D'94'
	retlw	D'94'
	retlw	D'94'
	retlw	D'95'
	retlw	D'95'
	retlw	D'96'
	retlw	D'96'
	retlw	D'96'
	retlw	D'97'
	retlw	D'97'
	retlw	D'98'
	retlw	D'98'
	retlw	D'98'
	retlw	D'99'
	retlw	D'99'
	retlw	D'100'


	end
