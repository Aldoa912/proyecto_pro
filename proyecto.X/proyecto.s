; Universidad del Valle de Guatemala
; IE2023 ProgramaciOn de Microcontroladores
; Autor: ALDO AVILA
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: PROYECTO
; Hardware: PIC16F887
; Creado: 23/08/22
;******************************************************************************* 
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuraciÃ³n    
;******************************************************************************* 
 ; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator
				; : I/O function on RA6/OSC2/CLKOUT pin, I/O 
				; function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and 
				; can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
;******************************************************************************* 
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
 cont10ms:
    DS 1
 NL:
    DS 1
 NH:
    DS 1
 MH:
    DS 1
 ML:
    DS 1
 HL:
    DS 1
 HH:
    DS 1
 DL:
    DS 1
 DH:
    DS 1
 AL:
    DS 1
 AH:
    DS 1
 DIS:
    DS 1
 CONTADOR:
    DS 3 
 CONT_DIS:
    DS 1
 CONTADOR_F:
    DS 2
 CONTADOR_M:
    DS 1
 estado:
    DS 1
 W_TEMP:
    DS 1
 STATUS_TEMP:
    DS 1
;******************************************************************************* 
; Vector Reset    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
 PUSH:
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP


    
 ISR:
    ;BCF INTCON, 0
    BTFSS INTCON,2	   ; T0IF = 1 ?
    GOTO ISRTMR1
    BCF INTCON,2	    ; Borramos bandera T0IF 
    MOVLW 100
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    INCF CONT_DIS, F
    ;GOTO ISRRBIF
    
 ISRTMR1:
    ;BANKSEL INTCON
    ;BCF INTCON, 0
    BTFSS PIR1, 0	    ; TMR1IF = 1?
    GOTO ISRRBIF
    BCF PIR1, 0		    ; Borramos la bandera del TMR1IF
    MOVLW 0xEE
    MOVWF TMR1L
    MOVLW 0x85
    MOVWF TMR1H
    INCF NL, F
    
    
ISRRBIF:
    BTFSS INTCON, 0	    ; RBIF = 1 ?
    GOTO POP
    BCF INTCON, 0
    
 POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
;******************************************************************************* 
; CÃ³digo Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0100
 ;******************************************************************************* 
; Tabla para obtener el valor del puerto a mostrar para el display 7 Seg  
;*******************************************************************************     

MAIN:
    BANKSEL OSCCON
    
    BCF OSCCON, 6	; IRCF2 SelecciÃ³n de 250 kHz
    BSF OSCCON, 5	; IRCF1
    BCF OSCCON, 4	; IRCF0
    
    bsf OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL TRISC
    CLRF TRISC		; Limpiar el registro TRISB
    CLRF TRISD		; Puerto para el display 7 segmentos
    CLRF TRISA
    CLRF TRISB
    BSF TRISB, 0
    BSF TRISB, 1	; Entradas para los botones
    BSF TRISB, 2
    BSF TRISB, 3	; Entradas para los botones

    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL IOCB
    
    BSF IOCB, 0
    BSF IOCB, 1		; Habilitando RB0 y RB1 para las ISR de RBIE
    BSF IOCB, 2
    BSF IOCB, 3
    
    BANKSEL WPUB
    BSF WPUB, 0
    BSF WPUB, 1		; Habilitando los Pullups en RB0 y RB1
    BSF WPUB, 2		; Habilitando los Pullups en RB0 y RB1
    BSF WPUB, 3		; Habilitando los Pullups en RB0 y RB1
    

    ; ConfiguraciÃ³n TMR0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7
    
    BCF OPTION_REG, 5	; T0CS: FOSC/4 COMO RELOJ (MODO TEMPORIZADOR)
    BCF OPTION_REG, 3	; PSA: ASIGNAMOS EL PRESCALER AL TMR0
    
    BCF OPTION_REG, 2
    BCF OPTION_REG, 1
    BSF OPTION_REG, 0	; PS2-0: PRESCALER 1:4 SELECIONADO 
    
    
    BANKSEL T1CON
    BSF T1CON, 5
    BSF T1CON, 4	; Prescaler de 1:8  
    BCF T1CON, 1	; TMR1CS Fosc/4 reloj interno
    BSF T1CON, 0	; TMR1ON enable
    
    BANKSEL TMR1L
    MOVLW 0xEE
    MOVWF TMR1L
    MOVLW 0x85
    MOVWF TMR1H

    BANKSEL PORTC
    CLRF PORTC		; Se limpia el puerto B
    CLRF PORTA
    CLRF PORTB
    CLRF cont10ms	; Se limpia la variable cont50ms
    CLRF NL
    CLRF NH
    CLRF ML
    CLRF MH
    CLRF HL
    CLRF HH
    CLRF DIS
    CLRF CONTADOR
    CLRF CONT_DIS
    
    MOVLW 100
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    CLRF INTCON		; borrar banderas de interrupciÃ³n
    BCF PIR1, 0
    BSF PIE1, 0
    BSF INTCON, 6
    BSF INTCON, 5	; Se habilita la interrupciÃ³n del TMR0 - T0IE
    BSF INTCON, 7	; Se habilitan todas las interrupciones por el GIE
    BSF INTCON, 3
    BCF INTCON, 2
    BCF INTCON, 0
    
SETCONTADOR:
    
    MOVF CONTADOR, W
    MOVWF PORTD
    
    MOVWF NL
    MOVWF NH
    MOVWF ML
    MOVWF MH
    MOVWF HL
    MOVWF HH

    MOVLW 0x0F
    ANDWF NL, F
    
    MOVLW 0xF0
    ANDWF NH, F
    SWAPF NH, F
    
    MOVLW 0x0F
    ANDWF ML, F
    
    MOVLW 0xF0
    ANDWF MH, F
    SWAPF MH, F

    MOVLW 0x0F
    ANDWF HL, F
    
    MOVLW 0xF0
    ANDWF HH, F
    SWAPF HH, F
;******************************************************************************* 
; MUX DE FECHA
;*******************************************************************************     
    MOVF CONTADOR_F, W
    MOVWF PORTD
    
    MOVWF DL
    MOVWF DH
    MOVWF AL
    MOVWF AH

    MOVLW 0x0F
    ANDWF DL, F
    
    MOVLW 0xF0
    ANDWF DH, F
    SWAPF DH, F
    
    MOVLW 0x0F
    ANDWF AL, F
    
    MOVLW 0xF0
    ANDWF AH, F
    SWAPF AH, F
    
    INCF DL,F
    INCF AH,F
    
LOOP:
    
    
    
;DIS0:
    MOVF CONT_DIS, W
    ;SUBLW 0		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS1
    MOVLW 0b00000001
    MOVWF PORTA
    MOVF NL, W		; MOVEMOS LO QUE ESTE EN CONTADOR A W
    PAGESEL TABLA	; NOS UBICAMOS EN LA PAGINA DONDE SE ENCUENTRA LA TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTC
    ;INCF CONT_DIS, F
    GOTO LOOP
    
DIS1:
    MOVF CONT_DIS, W
    SUBLW 1		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS2
    
    MOVLW 0b00000010
    MOVWF PORTA
    MOVF NH, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    ;INCF CONT_DIS, F
    GOTO LOOP

DIS2:
    MOVF CONT_DIS, W
    SUBLW 2		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS3
    
    MOVLW 0b00000100
    MOVWF PORTA
    MOVF ML, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    ;INCF CONT_DIS, F
    GOTO LOOP
DIS3:
    MOVF CONT_DIS, W
    SUBLW 3		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS4
    MOVLW 0b00001000
    MOVWF PORTA
    MOVF MH, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    ;INCF CONT_DIS, F
    GOTO LOOP
    
DIS4:
    MOVF CONT_DIS, W
    SUBLW 4		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS5
    MOVLW 0b00010000
    MOVWF PORTA
    MOVF HL, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    ;INCF CONT_DIS, F
    GOTO LOOP
    
DIS5:
    MOVLW 0b00100000
    MOVWF PORTA
    MOVF HH, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS1
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    CLRF CONT_DIS
    
    GOTO LOOP

    
    

VERIFICACION2:
    MOVF NL, W		; MOVEMOS LOS DATOS DE CONTADOR A W
    SUBLW 10		; SE LO RESTAMOS A 10
    BTFSS STATUS, 2	; SI EL RESULTADO ES 0 NOS SALTAMOS GOTO VERIFICACION
    GOTO LOOP	; CAMOS A VERIFICACION
    CLRF NL		; CARGAMOS UN 0 A W
    INCF NH, F
    GOTO VERIFICACION3	; VAMOS A DISPLAY

VERIFICACION3:
    MOVF NH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 6		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    CLRF NH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF ML, F
    GOTO VERIFICACION4	; VAMOS A VERIFICACION
    
VERIFICACION4:
    MOVF ML, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF ML
    INCF MH, F
    GOTO VERIFICACION5

VERIFICACION5:
    MOVF MH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 6		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    CLRF MH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF HL
    GOTO VERIFICACION6	; VAMOS A VERIFICACION
    
VERIFICACION6:
    MOVF HL, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF HL
    INCF HH, F
    GOTO VERIFICACION7
    
VERIFICACION7:
    MOVF HH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 2		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF HL, W
    SUBLW 4
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF HH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF DL, F
    GOTO VERIFICACION8	; VAMOS A VERIFICACION
    
VERIFICACION8:
    MOVF DL, W
    SUBLW 10
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DL
    INCF DH, F
    GOTO ENERO
    
ENERO:
    MOVF CONTADOR_M
    SUBLW 0
    BTFSS STATUS, 2
    GOTO FEBRERO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION

FEBRERO:
    MOVF CONTADOR_M
    SUBLW 1
    BTFSS STATUS, 2
    GOTO MARZO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 2		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 9
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
MARZO:
    MOVF CONTADOR_M
    SUBLW 2
    BTFSS STATUS, 2
    GOTO ABRIL
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION

ABRIL:
    MOVF CONTADOR_M
    SUBLW 3
    BTFSS STATUS, 2
    GOTO MAYO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
   
MAYO:
    MOVF CONTADOR_M
    SUBLW 4
    BTFSS STATUS, 2
    GOTO JUNIO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
JUNIO:
    MOVF CONTADOR_M
    SUBLW 5
    BTFSS STATUS, 2
    GOTO JULIO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
JULIO:
    MOVF CONTADOR_M
    SUBLW 6
    BTFSS STATUS, 2
    GOTO AGOSTO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
AGOSTO:
    MOVF CONTADOR_M
    SUBLW 7
    BTFSS STATUS, 2
    GOTO SEPTIEMBRE
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
SEPTIEMBRE:
    MOVF CONTADOR_M
    SUBLW 8
    BTFSS STATUS, 2
    GOTO FEBRERO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
OCTUBRE:
    MOVF CONTADOR_M
    SUBLW 9
    BTFSS STATUS, 2
    GOTO FEBRERO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
NOVIEMBRE:
    MOVF CONTADOR_M
    SUBLW 10
    BTFSS STATUS, 2
    GOTO FEBRERO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 1
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    
DICIEMBRE:
    MOVF CONTADOR_M
    SUBLW 11
    BTFSS STATUS, 2
    GOTO FEBRERO
    MOVF DH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 3		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVF DL, W
    SUBLW 2
    BTFSS STATUS, 2
    GOTO LOOP
    CLRF DH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
    INCF AL
    INCF CONTADOR_M
    GOTO LOOP	; VAMOS A VERIFICACION
    

 
    
    
PSECT CODE, ABS, DELTA=2
 ORG 0x1800
 TABLA:
    ADDWF PCL, F
    RETLW 0b00111111	; 0
    RETLW 0b00000110	; 1
    RETLW 0b01011011	; 2
    RETLW 0b01001111	; 3
    RETLW 0b01100110	; 4
    RETLW 0b01101101	; 5
    RETLW 0b01111101
    RETLW 0b00000111
    RETLW 0b01111111
    RETLW 0b01101111
    RETLW 0b01110111
    RETLW 0b01111100
    RETLW 0b00111001
    RETLW 0b01011110
    RETLW 0b01111001
    RETLW 0b01110001
;******************************************************************************* 
; Fin de CÃ³digo    
;******************************************************************************* 
END   