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
 DIS:
    DS 1
 CONTADOR:
    DS 2 
 CONT_DIS:
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
    BTFSS INTCON,2	   ; T0IF = 1 ?
    GOTO ISRTMR1
    BCF INTCON,2	    ; Borramos bandera T0IF 
    MOVLW 100
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    INCF cont10ms, F
    ;GOTO POP
ISRTMR1:
    BTFSS PIR1, 0	    ; TMR1IF = 1?
    GOTO ISRRBIF
    BCF PIR1, 0		    ; Borramos la bandera del TMR1IF
    
    MOVLW 0x8F
    MOVWF TMR1L
    MOVLW 0xFD
    MOVWF TMR1H
    GOTO DIS0
    
DIS0:
    MOVF CONT_DIS, W
    SUBLW 0		    ; REALIZAMOS UNA COMPARACION DEL VALOR DE CONTADOR
			    ; SI ESTA ES 0 SEGUIMOS EN ESTA SUBRUTINA, SINO
			    ; PASAMOS A ESTADO01_ISR
    BTFSS STATUS, 2
    GOTO DIS1
    BSF PORTA, 0
    BCF PORTA, 1
    MOVF NL, W		; MOVEMOS LO QUE ESTE EN CONTADOR A W
    PAGESEL TABLA	; NOS UBICAMOS EN LA PAGINA DONDE SE ENCUENTRA LA TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS0
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTC
    INCF CONT_DIS
    GOTO POP
    
DIS1:
    BCF PORTA, 0
    BSF PORTA, 1
    MOVF NH, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS0
    MOVWF PORTD		; MOVEMOS LOS DATOS DE W AL PORTD
    CLRF CONT_DIS
    GOTO POP
    
ISRRBIF:
    BTFSS INTCON, 0	    ; RBIF = 1 ?
    GOTO POP

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
    
    BANKSEL WPUB
    BSF WPUB, 0
    BSF WPUB, 1		; Habilitando los Pullups en RB0 y RB1

    ; ConfiguraciÃ³n TMR0
    BANKSEL OPTION_REG
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
    MOVLW 0x8F
    MOVWF TMR1L
    MOVLW 0xFD
    MOVWF TMR1H

    BANKSEL PORTC
    CLRF PORTC		; Se limpia el puerto B
    CLRF PORTA
    CLRF cont10ms	; Se limpia la variable cont50ms
    CLRF NL
    CLRF NH
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
    
SETCONTADOR:
    
    MOVF CONTADOR, W
    MOVWF PORTD
    
    MOVWF NL
    MOVWF NH
    
    MOVLW 0x000F
    ANDWF NL, F
    
    MOVLW 0x00F0
    ANDWF NH, F
    SWAPF NH, F
LOOP:
    GOTO VERIFICACION2

    
    
VERIFICACION:    
    MOVF cont10ms, W
    SUBLW 100
    BTFSS STATUS, 2	; verificamos bandera z
    GOTO VERIFICACION	; REGRESAMOS A VERIFICACION HASTA QUE LA RESTA DE 0
    CLRF cont10ms	; LIMPIAMOS EL CONT20MS
    INCF NL, F		; Incrementamos el CONTADOR
    GOTO LOOP		; Regresamos a la etiqueta LOOP
VERIFICACION2:
    MOVF NL, W		; MOVEMOS LOS DATOS DE CONTADOR A W
    SUBLW 10		; SE LO RESTAMOS A 10
    BTFSS STATUS, 2	; SI EL RESULTADO ES 0 NOS SALTAMOS GOTO VERIFICACION
    GOTO VERIFICACION	; CAMOS A VERIFICACION
    CLRF NL		; CARGAMOS UN 0 A W
    INCF NH, F
    GOTO VERIFICACION3	; VAMOS A DISPLAY

VERIFICACION3:
    MOVF NH, W		; MOVEMOS LOS DATOS DEL CONTADOR2 A W
    SUBLW 6		; LE RESTAMOS 6
    BTFSS STATUS, 2	; SI LA RESTA ES 0 NOS SALTAMOS EL GOTO VERIFICACION
    GOTO LOOP		; VAMOS A 
    MOVLW 0		; CARGAMOS UN 0 A W
    MOVWF NH		
    MOVF NH, W		; MOVEMOS LO QUE ESTE EN CONTADOR2 A W
    PAGESEL TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    PAGESEL DIS0
    MOVWF PORTD
    CLRF NH		; LIMPIAMOS LA VARIABLE DE CONTADOR2
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