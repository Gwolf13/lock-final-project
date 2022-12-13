;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Title: Combination lock final project
; Team Members: Emmanuel Bastidas, Gwendolyn Wolf, Zahra Ziaee
;
; Desc: Enter start button then enter a 4 pin combination if at any time the start button is entered
;       reset the pin and try again. If the right combination is entered then light up green
;	If the wrong combination is entered then light up red, if it has been entered 3 times wrong in a row
;       brighten yellow led then flash
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
#include <xc.inc>
#include "pic16f18875.inc" 

; CONFIG1 
; __config 0xFFFF 
 CONFIG FEXTOSC=ECH
 CONFIG RSTOSC=EXT1X
 CONFIG CLKOUTEN=OFF
 CONFIG CSWEN=ON
 CONFIG FCMEN=ON 
 CONFIG MCLRE=ON
 CONFIG PWRTE=OFF
 CONFIG LPBOREN=OFF
 CONFIG BOREN=ON
 CONFIG BORV=LO
 CONFIG ZCD=OFF
 CONFIG PPS1WAY=ON
 CONFIG STVREN=ON 
 CONFIG WDTCPS=31
 CONFIG WDTE=OFF
 CONFIG WDTCWS=7
 CONFIG WDTCCS=SC 
 CONFIG WRT=OFF
 CONFIG SCANE=available
 CONFIG LVP=ON 
 CONFIG CP=OFF
 CONFIG CPD=OFF 
  
 PSECT res_vect, class=CODE, delta=2
res_vect:
 ;org 0x0000 
 goto Start
 
 ;RB0 start button
 ;RB1 is far left button(button 1)
 ;RB2 is next button(button 2)
 ;RB3 is next button(button 3)
 
 ;RA0 red
 ;RA1 green
 ;RA2 blue

Start:
    banksel 	OSCFRQ		; Select clock bank
    movlw	00000000B	; 1 Mhz clock move from l to w(working register)
    movwf  	OSCFRQ      	; Load new clock, move from working register to f
				; with f being OSCFRQ
				
    INPUT_COUNTER EQU 70H
    WRONG_ATTEMPT_COUNTER EQU 71H
    CURRENT_INPUT EQU 72H
 
    ; prep for leds
    ; make the pins digital
    banksel ANSELA
    clrf    ANSELA
    ; turn leds off
    banksel LATA  
    clrf    LATA

    ; turn leds off
    banksel PORTA
    clrf    PORTA
    
    ; make the pins output
    banksel TRISA
    clrf    TRISA
    
    ; prep for buttons
    ; make pins digital
    banksel ANSELB
    clrf ANSELB
    
    banksel LATB
    clrf LATB
    
    banksel PORTB
    clrf    PORTB
    
    banksel TRISB
    clrf TRISB
    
    ;set pins for button inputs
    bsf TRISB, 0 ; start button
    bsf TRISB, 1
    bsf TRISB, 2
    bsf TRISB, 3
    bsf TRISB, 4
    
    movlw 00H
    banksel INPUT_COUNTER
    movwf INPUT_COUNTER
    
    movlw 00H
    banksel WRONG_ATTEMPT_COUNTER
    movwf WRONG_ATTEMPT_COUNTER
    
    movlw 00H
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
    
    
    
    
Mainloop:
    
    
    
    
    
    
    
    
    
    
    
RECIEVE_INPUT:
    ; if start is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 0 
    call STABILIZE_START_BUTTON  ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    ; if button 1 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 1
    call STABILIZE_BUTTON_ONE ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    ; if button 2 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 2
    call STABILIZE_BUTTON_TWO ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    ; if button 3 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 3
    call STABILIZE_BUTTON_THREE ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    ; if button 4 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 4
    call STABILIZE_BUTTON_FOUR ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    return

    
; This subroutine is used as a buffer to wait until the ADC ON button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_START_BUTTON:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine
    banksel PORTB
    btfsc PORTB, 0
    goto STABILIZE_START_BUTTON
    
    ; add a goto to go to another state?
    
    return
    

; This subroutine is used as a buffer to wait until the ADC OFF button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_BUTTON_ONE:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine   
    banksel PORTB
    btfsc PORTB, 1
    goto STABILIZE_BUTTON_ONE
    
    ; add go to another state?
    return
    
    
; This subroutine is used as a buffer to wait until the ADC OFF button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_BUTTON_TWO:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine   
    banksel PORTB
    btfsc PORTB, 2
    goto STABILIZE_BUTTON_TWO
    
    ; add go to another state?
    return
    

; This subroutine is used as a buffer to wait until the ADC OFF button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_BUTTON_THREE:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine   
    banksel PORTB
    btfsc PORTB, 3
    goto STABILIZE_BUTTON_THREE
    
    ; add go to another state?
    return
    
    
; This subroutine is used as a buffer to wait until the ADC OFF button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_BUTTON_FOUR:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine   
    banksel PORTB
    btfsc PORTB, 4
    goto STABILIZE_BUTTON_FOUR
    
    ; add go to another state?
    return

