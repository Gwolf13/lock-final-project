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
				
    WRONG_ATTEMPT_COUNTER EQU 70H
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
    bsf TRISB, 5
    
    movlw 00H
    banksel WRONG_ATTEMPT_COUNTER
    movwf WRONG_ATTEMPT_COUNTER
    
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    ; READ ME!
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; The buttons are organized in such a way that RB0 is the start button
    ; RB1 is what we will refer to as button 1
    ; RB2 is what we will refer to as button 2
    ; RB3 is what we will refer to as button 3
    ; RB5 is what we will refer to as button 4
    
    ; The variable current input is abstracted in such a way that
    ; If CURRENT_INPUT = 0000 0001 then that means the start button was pressed
    ; If CURRENT_INPUT = 0000 0010 then that means that button one was pressed
    ; If CURRENT_INPUT = 0000 0100 then that means that button two was pressed
    ; If CURRENT_INPUT = 0000 1000 then that means that button three was pressed
    ; If CURRENT_INPUT = 0001 0000 then that means that button four was pressed
    
    
    ;passcode is 1132
    
STATE_ZERO:
    ; reset the input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    banksel LATA
    ; turn off all leds
    bcf LATA, 0
    bcf LATA, 1
    bcf LATA, 2
    
LOOP_ZERO:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_ZERO
    
    
    banksel CURRENT_INPUT
    
    ; if start button isn't pressed then stay in STATE_ZERO
    ; if start button is pressed go to state one
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    goto STATE_ZERO 
    
    

STATE_ONE:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    banksel LATA
    ; turn off all leds
    bcf LATA, 0
    bcf LATA, 1
    bcf LATA, 2
    
LOOP_ONE:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_ONE
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; If the right input (which in this case is button 1) was pressed then go to state 2
    btfsc CURRENT_INPUT, 1
    goto STATE_TWO
    
    ; If the wrong input was entered go to state 11. Light up red
    goto STATE_SIX
    
    
    
	
STATE_TWO:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    

LOOP_TWO:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_TWO
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; if button 1 was pressed(correct input, go to state three)
    btfsc CURRENT_INPUT, 1
    goto STATE_THREE
    
    ; wrong button pressed go to state 11
    goto STATE_SEVEN
    
	
STATE_THREE:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    
LOOP_THREE:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_THREE
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; if button 3 the correct input was entered go to state 4
    btfsc CURRENT_INPUT, 3
    goto STATE_FOUR
    
    ; if wrong button was entered go to state 11
    goto STATE_EIGHT

STATE_FOUR:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
LOOP_FOUR:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_FOUR
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; if button 2 was entered go to state five
    btfsc CURRENT_INPUT, 2
    goto STATE_FIVE
    
    ; wrong input go to state 11 light up red led
    goto STATE_NINE
    
STATE_FIVE:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    ;reset wrong attempt counter
    movlw 00H
    banksel WRONG_ATTEMPT_COUNTER ; init to hold 1000 0000
    movwf WRONG_ATTEMPT_COUNTER
    
    
    ; light up RA1(green)
    banksel LATA
    bsf LATA, 1
    
LOOP_FIVE:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_FIVE
    
    
    ; if any button other then start is pressed stay in state 5
    ; if start button is pressed go back to state 1
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    goto STATE_FIVE
    
    
    
STATE_SIX:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
LOOP_SIX:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_SIX
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_one instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; Any input other than start go to state_seven
    goto STATE_SEVEN
    
    
STATE_SEVEN:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
LOOP_SEVEN:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_SEVEN
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_one instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; Any input other than start go to state_eight
    goto STATE_EIGHT
    
    
STATE_EIGHT:
    ; reset input
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
LOOP_EIGHT:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_EIGHT
    
    
    banksel CURRENT_INPUT
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_one instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    ; Any input other than start go to state_nine
    goto STATE_NINE
    
STATE_NINE:
    ; increment WRONG_ATTEMPT_COUNTER 
    movf WRONG_ATTEMPT_COUNTER, w; move WRONG_ATTEMPT_COUNTER to working register
    addlw 1; incremnt 
    movwf WRONG_ATTEMPT_COUNTER
    ; check WRONG_ATTEMPT_COUNTER using overflow
    movlw 253 ; move 255 to working register
    addwf WRONG_ATTEMPT_COUNTER, w; add current input and 255 and store to working register
    ; no overflow
    banksel STATUS
    
    btfss STATUS, 0
    goto STATE_ELEVEN
    ; overflow
    goto STATE_TEN
    
STATE_TEN:
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT 
    
    ; reset wrong attempt counter
    movlw 00H
    banksel WRONG_ATTEMPT_COUNTER ; init to hold 1000 0000
    movwf WRONG_ATTEMPT_COUNTER
    
    ; light up RA0(red) and RA1(green)
    banksel LATA
    bsf LATA, 0
    bsf LATA, 1
    
LOOP_TEN:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_TEN
    
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    goto STATE_TEN
    
    
    
STATE_ELEVEN:
    movlw 00H
    banksel CURRENT_INPUT ; init to hold 1000 0000
    movwf CURRENT_INPUT
    
    ; light up RA0(red)
    banksel LATA
    bsf LATA, 0
    
LOOP_ELEVEN:
    call RECIEVE_INPUT
    
    movlw 255 ; move 255 to working register
    addwf CURRENT_INPUT, w; add current input and 255 and store to working register
    
    banksel STATUS
    
    btfss STATUS, 0
    goto LOOP_ELEVEN
    
    ; If start button was pressed go back to state one
    ; If start button wasn't pressed skip the goto state_zero instruction
    btfsc CURRENT_INPUT, 0
    goto STATE_ONE
    
    goto STATE_ELEVEN
    

    
    
    
    
    
    
  

; this method reads from all possible input ports if not input is read
; Loop back up to read input again if no input was read
RECIEVE_INPUT:
    ; if start is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 0 
    call STABILIZE_START_BUTTON  ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    banksel CURRENT_INPUT
    btfsc CURRENT_INPUT, 0 
    return
    
    ; if button 1 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 1
    call STABILIZE_BUTTON_ONE ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    banksel CURRENT_INPUT
    btfsc CURRENT_INPUT, 1 
    return
    
    ; if button 2 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 2
    call STABILIZE_BUTTON_TWO ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    banksel CURRENT_INPUT
    btfsc CURRENT_INPUT, 2 
    return 
    
    ; if button 3 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 3
    call STABILIZE_BUTTON_THREE ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    banksel CURRENT_INPUT
    btfsc CURRENT_INPUT, 3 
    return
    
    ; if button 4 is pressed then call the stabilize function
    ; other wise skip to the next command
    banksel PORTB ; move to the correct data bank
    btfsc PORTB, 5
    call STABILIZE_BUTTON_FOUR ; TODO MAKE THIS CALL A DIFFERENT BUTTON
    
    banksel CURRENT_INPUT
    btfsc CURRENT_INPUT, 5 
    return
    
    
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
    movlw 00000001B
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
    
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
    movlw 00000010B
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
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
    movlw 00000100B
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
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
    movlw 00001000B
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
    return
    
    
; This subroutine is used as a buffer to wait until the ADC OFF button has fully set after you click it
; NOTE this doesn't actually solve the problem of bouncing with buttons
STABILIZE_BUTTON_FOUR:
    ; if the button is still being pressed loop back to the label of the function
    ; if the button has finally settled and is no longer being pressed
    ; continue with the rest of the subroutine   
    banksel PORTB
    btfsc PORTB, 5
    goto STABILIZE_BUTTON_FOUR
    
    ; update current input to be button 4
    movlw 00010000B
    banksel CURRENT_INPUT
    movwf CURRENT_INPUT
    return

    


