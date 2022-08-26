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
    GOTO POP
    BCF INTCON,2	    ; Borramos bandera T0IF
    
    MOVLW 100
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    
    INCF cont10ms, F
     
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
    BCF TRISA, 0	; Transistores
    BCF TRISA, 1
    
    
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    ; ConfiguraciÃ³n TMR0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 5	; T0CS: FOSC/4 COMO RELOJ (MODO TEMPORIZADOR)
    BCF OPTION_REG, 3	; PSA: ASIGNAMOS EL PRESCALER AL TMR0
    
    BCF OPTION_REG, 2
    BCF OPTION_REG, 1
    BSF OPTION_REG, 0	; PS2-0: PRESCALER 1:4 SELECIONADO 
    
    
    BANKSEL PORTC
    CLRF PORTC		; Se limpia el puerto B
    CLRF PORTA
    CLRF cont10ms	; Se limpia la variable cont50ms
    CLRF NL
    CLRF NH
    CLRF DIS
    CLRF CONTADOR
    
    MOVLW 100
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    CLRF INTCON		; borrar banderas de interrupciÃ³n
    
    BSF INTCON, 5	; Se habilita la interrupciÃ³n del TMR0 - T0IE
    BSF INTCON, 7	; Se habilitan todas las interrupciones por el GIE
    
LOOP:
    
    MOVF CONTADOR, W
    MOVWF PORTD
    MOVWF NL
    MOVWF NH
    
    MOVLW 0x0F
    ANDWF NL, F
    
    MOVLW 0xF0
    ANDWF NH, F
    SWAPF NH, F
    
    GOTO DIS0

    
DIS0:
    BSF TRISA, 0
    BCF TRISA, 1
    MOVF NL, W
    PAGESEL TABLA
    CALL TABLA
    PAGESEL DIS0
    MOVWF PORTD
    GOTO VERIFICACION
DIS1:
    BCF TRISA, 0
    BSF TRISA, 1
    INCF NH
    MOVF NH, W
    PAGESEL TABLA
    CALL TABLA
    PAGESEL DIS1
    MOVWF PORTD 
    GOTO VERIFICACION2
    
VERIFICACION:    
    MOVF cont10ms, W
    SUBLW 5
    BTFSS STATUS, 2	; verificamos bandera z
    GOTO VERIFICACION
    CLRF cont10ms
    INCF NL
    MOVF NL, W
    SUBLW  10
    BTFSS STATUS, 2
    GOTO DIS0
    CLRF NL
    GOTO DIS1		; Regresamos a la etiqueta LOOP  
    
VERIFICACION2:    
    MOVF cont10ms, W
    SUBLW 5
    BTFSS STATUS, 2	; verificamos bandera z
    GOTO VERIFICACION2
    CLRF cont10ms
    MOVF NH, W
    SUBLW  5
    BTFSS STATUS, 2
    GOTO DIS0
    CLRF NH
    GOTO DIS0		; Regresamos a la etiqueta LOOP 
    
    
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