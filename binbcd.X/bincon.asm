    ;JHONATAN REINALDO GOMEZ PESCA
    ;FABIAN STEVEN ZEA GONZALEZ
    ;CONTADOR
    ;05/03/2012
    list p=16F887				;definir controlador a  trabajar
    _CONFIG1         EQU  H'2007'	;configuracion de los fused registro que los usuarios no puede acceder, lo modifica el pic
    _CONFIG2         EQU  H'2008'    ;
    _FOSC_HS         EQU  H'3FFA'
    _WDT_OFF         EQU  H'3FF7'
    _PWRTE_OFF       EQU  H'3FFF'
    _MCLRE_ON        EQU  H'3FFF'
    _CP_OFF          EQU  H'3FFF'
    _CPD_OFF         EQU  H'3FFF'
    _WDTE_OFF        EQU  H'3FF7'
    _BOREN_ON        EQU  H'3FFF'
    _IESO_ON         EQU  H'3FFF'
    _FCMEN_OFF       EQU  H'37FF'
    _LVP_ON          EQU  H'3FFF'
    _BOR4V_BOR40V    EQU  H'3FFF'
    _WRT_OFF         EQU  H'3FFF'
    STATUS	     EQU  H'2003' 
    OSCCON           EQU  H'008F'
    TRISA            EQU  H'0085'
    TRISB            EQU  H'0086'
    TRISC            EQU  H'0087'
    ANSEL            EQU  H'0188'
    ANSELH           EQU  H'0189'
    PORTA            EQU  H'0005'
    PORTB            EQU  H'0006'
    PORTC            EQU  H'0007'
    RP0              EQU  H'0005'
    RP1              EQU  H'0006'
    RC0              EQU  H'0000'
    RC1              EQU  H'0001'
    RC2              EQU  H'0002'
    RC3              EQU  H'0003'
    RC7              EQU  H'0007'
    C                EQU  H'0000'
    Z                EQU  H'0002'

 ; CONFIG1
; __config 0xF7F2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_OFF & _LVP_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
  ;Definicion de variables
 CBLOCK 0x20           ;Inicio de la RAM disponible
 BINARIO:1             ;Variable de un byte
 ACAMBIAR:1
 CONT1:1
 CONTA1:1   
 CONT2:1
 CONTA2:1
 CONT3:1
 UNIDECE:1 
 CENTENAS:0X04
 TIEMPO:1
 TIEMPO2:1
 TEMPORIZADOR:1
    
 ENDC

 ;Comienza Programa
     ORG 0X00             ;Vector de reset
     BSF STATUS,RP0        
     BCF STATUS,RP1       ;ingreso al banco 1
     MOVLW B'01100001'    
     MOVWF OSCCON         ;configuracion del ocilador interno a 4MHz
     ;GOTO START

 START:

     
     BSF STATUS,RP0     ;ACCESO AL BANCO1
     CLRF TRISB         ;DECLARAMOS COMO SALIDA EL PUERTO B
     MOVLW 0XFF        
     MOVWF TRISA        ;SE DECLARA COMO ENTRADA EL PUERTO A
     MOVLW 0X80
     MOVWF TRISC        ;LOS 4 BITS MENOS SIGNIFICATIVOS DEL PUERTO C COMO SALIDA
                        ;LOS 4 BITS MAS SIGNIFICATIVOS DEL PUERTO C COMO ENTRADA 
     BANKSEL ANSEL      ;CAMBIO AL BANCO 3
     CLRF ANSEL         ; DECLARA EL PUERTO A Y C  DIGITALES
     CLRF ANSELH        ; DECLARA EL PUERTO B  DIGITALES
     BANKSEL PORTA      ;CAMBIO AL PBANCO 0
     CLRF PORTB         ;CLAREADO EL  PUERRTO B
     
INIT:
     MOVF  PORTA,W      ;OBTENEMOS LOS DATOS DE LA PRECARGA
     MOVWF BINARIO      ; GUARDAMOS EN EL REGISTRO BINARIO
 INCREMENTO:
     BTFSC PORTC,RC7    ;SALTA SI EL PULSADOR ESTA ACTIVADO
     GOTO INIT          ;RETORNA A TOMAR EL VALOR DE LA PRECARGA
     INCF BINARIO       ;SE INCREMENTA BINARIO 
     MOVF BINARIO,W       
     MOVWF ACAMBIAR     ;MOVEMOS EL VALOR DE BINARIO A ACAMBIAR
     btfss   STATUS,Z   ;SALTA SI OBTENEMOS DESBORDE
     GOTO $+2           ;SALTA DOS POSICIONES
     CALL LUCES         ;LLAMA RUTINA DE LA SECUENCIA DE LUCES
     CALL CONVERSION    ;LLAMA LA RUTINA DE LA CONVERSION DE BINARIO A BCD 
     MOVF UNIDECE,W     
     MOVWF PORTB        ;UNIDADES Y DECENAS MOSTRADAS EN EL PUERTO A
     MOVF CENTENAS,W    
     MOVWF PORTC        ;CENTENAS MOSTRADAS EN EL PUERTO C
     CALL ATRASO        ;LLAMAMOS RUTINA DE RETARDO
     GOTO INCREMENTO
 
 ATRASO:
                         ;AQUI OBTENEMOS UN RETARDO APROXIMDO DE 1 SEGUNDO
            MOVLW .5     ;MOVEMOS EL VALOR DE 5 AL REGISTRO CONT1
	    MOVWF CONT1
	    MOVLW .255   ;MOVEMOS EL VALOR DE 255 AL REGISTRO CONT2
	    MOVWF CONT2
	    MOVLW .255
	    MOVWF CONT3  ;MOVEMOS EL VALOR DE 255 AL REGISTRO CONT3
	    DECFSZ CONT3 ;DECREMENTAMOS CONT3 Y SALTA CUENDO ESTE EN 0
	    GOTO $-1     ;RETORNA UNA POSICION
	    DECFSZ CONT2 ;DISMINUYE CONT2 Y SALTA SI EL REGISTRO CONT2 ES 0
	    GOTO $-5     ;RETORNA 5 POSICIONES
	    DECFSZ CONT1 ;DISMINUYE CONT1 Y SALTA SI EL REGISTRO CONT2 ES 0
	    GOTO $-9     ;RETORNA 5 POSICIONES
	    RETURN       ;TERMINA RUTINA Y DEVUELVE 
	        ;RUTINA DE CONVERSION BINARIO A BCD
CONVERSION:
        CLRF    CENTENAS   ;CLAREA EL REGISTRO CENTENAS
        CLRF    UNIDECE    ;CLAREA EL REGISTRO UNIDECE
BCD_ALTO:
        MOVLW   .100       ;MOVER 100 AL ACUMULADOR W
        SUBWF   ACAMBIAR,f ;RESTA ENTRE EL REGISTRO ACAMBIAR Y 100
        BTFSS   STATUS,C   ;SALTO SI EL CARRY ESTA EN 1
        GOTO    SUMA_CIEN  ;SALTE A LA RUTINA SUMA_CIEN
        INCF    CENTENAS,f ;INCREMENTO DEL VALOR DEL REGISTRO CENTENAS
        GOTO    BCD_ALTO   ;SALTE A LA RUTINA BCD_ALTO
SUMA_CIEN:
        MOVLW   .100       ;MOVER 100 AL ACUMULADOR  W
        ADDWF   ACAMBIAR,f ;SUMA ENTRE EL REGISTRO ACAMBIAR Y 100
        MOVLW   0x0F       ;MOVER F AL ACUMULADOR  W
        MOVWF   UNIDECE    ;GUARDAR W EN EL REGISTRO UNIDECE 
BCD_BAJO:
	MOVLW   .10        ;MOVER 10 AL ACUMULADOR  W
        SUBWF   ACAMBIAR,f ;RESTA ENTRE EL REGISTRO ACAMBIAR Y 100
        BTFSS   STATUS,C   ;SALTO SI EL CARRY ESTA EN 1
        GOTO    SUMA_DIEZ  ;SALTE A LA RUTINA SUMA_DIEZ
        INCF    UNIDECE    ;INCREMENTO DEL VALOR DEL REGISTRO UNIDECE
        MOVLW   0x0F       ;MOVER F AL ACUMULADOR  W
        IORWF   UNIDECE    ;OPERACION OR  ENTRE W Y F
        GOTO    BCD_BAJO   ;SALTE A LA RUTINA BCD_BAJO
SUMA_DIEZ: 
	MOVLW   .10        ;MOVER 10 AL ACUMULADOR  W
        ADDWF   ACAMBIAR,f ;SUMA ENTRE EL REGISTRO ACAMBIAR Y 100
        MOVLW   0xF0       ;MOVER F0 AL ACUMULADOR  W
        ANDWF   UNIDECE,f  ;OPERACION AND ENTRE W Y F
        MOVF    ACAMBIAR,w ;MOVER EL VALOR DE F A W EN EL REGISTRO ACAMBIAR
        IORWF   UNIDECE,f  ;OPERACION OR   ENTRE W Y F
        RETURN             ;RETORNA A LA RUTINA ANTERIOR
                      ;RUTINA DE SECUENCIA DE LUCES
LUCES:
	MOVLW   .30          ;MOVER 30 AL ACUMULADOR  W  
	MOVWF   TEMPORIZADOR ;MOVER W AL REGISTRO TEMPORIZADOR
 REINICIO:
     MOVLW B'00000001'       ;SALIDA DEL PUERTO B Y C EN CADA INSTANTE DE ENCENDIDO
	  MOVWF PORTB
      MOVLW B'1000'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00000010'
	  MOVWF PORTB
      MOVLW B'0100'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00000100'
	  MOVWF PORTB
      MOVLW B'0010'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00001000'
	  MOVWF PORTB
      MOVLW B'0001'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'10010000'
	  MOVWF PORTB
      MOVLW B'0000'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'01100000'
	  MOVWF PORTB
      MOVLW B'0000'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'10010000'
	  MOVWF PORTB
      MOVLW B'0000'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00001000'
	  MOVWF PORTB
      MOVLW B'0001'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00000100'
	  MOVWF PORTB
      MOVLW B'0010'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00000010'
	  MOVWF PORTB
      MOVLW B'0100'
	  MOVWF PORTC
	  CALL RETARDO
	  
      MOVLW B'00000001'
	  MOVWF PORTB
      MOVLW B'1000'
	  MOVWF PORTC
	  CALL RETARDO
	           
	   BTFSC PORTC,RC7   ;REINICIO DEL PROGRAMA CON EL PULSADOR
           GOTO INIT
	   DECFSZ TEMPORIZADOR;DECREMENTO REGISTRO CONTADOR PARA QUE LA SECUENCIA DURE
	   GOTO $+2           ; APROXIMADAMENTE 1MINUTO
	   GOTO INIT
	   GOTO REINICIO
	                   ;RETARDO PARA INTERCAMBIO EFECTO DE LOS LEDS APROXIMADAMENTE 
RETARDO                    ; 200 mS
       MOVLW .255
	    MOVWF CONTA1
	    MOVLW .255
	    MOVWF CONTA2
	    DECFSZ CONT2
	    GOTO $-1;
	    DECFSZ CONT1
	    GOTO $-5
    
 END                     ;Fin del programa


