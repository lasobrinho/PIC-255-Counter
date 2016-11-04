    LIST    P=16F877A,F=INHX8M
#include <p16f877a.inc>
    
    __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    CONSTANT BASE_VAR=0CH
    
W_SAVE         EQU BASE_VAR+3
STATUS_SAVE    EQU BASE_VAR+4
    
    ; Declaring program variables
    cblock 0x20
    units
    tens
    hundreds
    ; temp variable is used with assembly-style if statements to store the 
    ; subtraction result
    temp
    endc
    
    org 000H
    GOTO MAIN
    
    org 004H
    GOTO INT_SERV
       
    
MAIN:
    ; Moving initial value 0 to counter variables
    MOVLW B'00001000'
    MOVWF units
    MOVLW B'00001001'
    MOVWF tens
    MOVLW B'00000000'
    MOVWF hundreds
    ; Configuring PORTB I/O
    banksel TRISB
    MOVLW B'00000111'
    MOVWF TRISB
    ; Configuring PORTC I/O
    banksel TRISC
    MOVLW B'00000000'
    MOVWF TRISC
    ; Configuring INTCON register
    banksel INTCON
    BSF INTCON,GIE
    BSF INTCON,RBIE
    ; Configuring OPTION_REG to detect only falling edge changes
    BCF OPTION_REG, INTEDG
       

    ; Main program loop
MainLoop:
    ; Call display functions to refresh each 7-segment display
    CALL DisplayUnits
    CALL DisplayTens
    CALL DisplayHundreds
    
    ; Read input based on the button pressed
    ;banksel PORTB
    ; If increment button is pressed then increment counter, else check 
    ; next button
    ;BTFSC PORTB,0
    ;GOTO Increment
    ; If decrement button is pressed then decrement counter, else check 
    ; next button
    ;BTFSC PORTB,1
    ;GOTO Decrement
    ; If reset button is pressed then reset the counter, else call 
    ; main loop again
    ;BTFSC PORTB,2
    ;GOTO ResetCounter
    ; If no input is detected, continue looping
    GOTO MainLoop

    
    ; Function to power on the units 7-segment display
    ; Power is passed through bit 7 of PORTB
DisplayUnits:
    ; Setting ports 6 (tens) and 5 (hundreds) as off
    banksel PORTC
    BCF PORTC,6
    BCF PORTC,5
    ; Moving units value to PORTC to be displayed
    ;banksel PORTC
    MOVF units,W
    MOVWF PORTC 
    ; Setting PORTB bit 7 as high to power on the display
    ;banksel PORTB
    BSF PORTC,7    
    RETURN
    
    
    ; Function to power on the tens 7-segment display
    ; Power is passed through bit 6 of PORTB    
DisplayTens:
    ; Setting ports 7 (units) and 5 (hundreds) as off
    banksel PORTC
    BCF PORTC,7
    BCF PORTC,5
    ; Moving tens value to PORTC to be displayed
    ;banksel PORTC
    MOVF tens,W
    MOVWF PORTC
    ; Setting PORTB bit 6 as high to power on the display
    ;banksel PORTB
    BSF PORTC,6
    RETURN

    
    ; Function to power on the hundreds 7-segment display
    ; Power is passed through bit 5 of PORTB  
DisplayHundreds:
    ; Setting ports 7 (units) and 6 (tens) as off
    banksel PORTC
    BCF PORTC,7
    BCF PORTC,6
    ; Moving hundreds value to PORTC to be displayed
    ;banksel PORTC
    MOVF hundreds,W
    MOVWF PORTC
    ; Setting PORTB bit 5 as high to power on the display
    ;banksel PORTB
    BSF PORTC,5
    RETURN
    
    
    ; Function to increment the counter value
Increment:
    ; Wait until increment button is released
    BTFSC PORTB,0
    GOTO Increment
    ; Increment units
    INCF units,F
    ; Checks if units = D'10'
    MOVLW B'00000000'
    ADDWF units,W
    ADDLW -B'00001010'
    MOVWF temp
    MOVF temp,F
    ; If units = D'10' then increment tens variable, else return 
    ; to main loop
    BTFSC STATUS,Z
    CALL IncrementTens
    GOTO MainLoop
    
    
    ; Function to increment tens variable/counter
IncrementTens:
    ; If this function was called, it means that units variable needs to 
    ; be reset to 0, so we call ResetUnits function
    CALL ResetUnits
    ; Increment tens variable
    INCF tens,F
    ; Checks if tens = D'10'
    MOVLW B'00000000'
    ADDWF tens,W
    ADDLW -B'00001010'
    MOVWF temp
    MOVF temp,F
    ; If tens = D'10' then increment hundreds variable, else just return
    BTFSC STATUS,Z
    CALL IncrementHundreds
    RETURN
    
    
    ; Function to increment hundreds variable/counter
IncrementHundreds:
    ; If this function was called, it means that tens variable needs to 
    ; be reset to 0, so we call ResetTens function
    CALL ResetTens
    ; Increment hundreds variable
    INCF hundreds,F
    RETURN
    
    
    ; Function to decrement counter
Decrement:
    ; Wait until decrement button is released
    BTFSC PORTB,1
    GOTO Decrement
    ; Decrement units variable
    DECF units,F
    ; Checks if units = D'255' (representing -1 in this case)
    MOVLW B'00000000'
    ADDWF units,W
    ADDLW B'00000001'
    MOVWF temp
    MOVF temp,F
    ; If units = D'255' then decrement tens variable. Otherwise go to 
    ; main loop
    BTFSC STATUS,Z
    CALL DecrementTens
    GOTO MainLoop
    
    
    ; Function to decrement tens variable/counter
DecrementTens:
    ; Move number 9 to units variable
    MOVLW B'00001001'
    MOVWF units
    ; Decrement tens variable
    DECF tens,F
    ; Checks if tens = D'255' (representing -1 in this case)
    MOVLW B'00000000'
    ADDWF tens,W
    ADDLW B'00000001'
    MOVWF temp
    MOVF temp,F
    ; If tens = D'255' then decrement hundreds variable. Otherwise go to 
    ; main loop
    BTFSC STATUS,Z
    CALL DecrementHundreds
    RETURN
    
    
    ; Function to decrement hundreds variable/counter
DecrementHundreds:
    ; Move number 9 to tens variable
    MOVLW B'00001001'
    MOVWF tens
    ; Decrement hundreds variable and return
    DECF hundreds,F
    RETURN
    
    
    ; Auxiliar function to reset the counter displays and variables
ResetCounter:
    ; Wait until Reset button is released
    BTFSC PORTB,2
    GOTO ResetCounter
    ; Call to functions to reset every display and variables
    CALL ResetUnits
    CALL ResetTens
    CALL ResetHundreds
    GOTO MainLoop
    
    
    ; Reset units function
ResetUnits:
    ; Moves D'0' to units variable
    MOVLW B'00000000'
    MOVWF units
    RETURN

    
    ; Reset tens function
ResetTens:
    ; Moves D'0' to tens variable
    MOVLW B'00000000'
    MOVWF tens
    RETURN
    
    
    ; Reset hundreds function
ResetHundreds:
    ; Moves D'0' to hundreds variable
    MOVLW B'00000000'
    MOVWF hundreds
    RETURN
    
    
INT_SERV:
    
    MOVWF W_SAVE        ; save W
    SWAPF STATUS, W     ; save STATUS 
    MOVWF STATUS_SAVE
     
    ; If increment button is pressed then increment counter, else check 
    ; next button
    BTFSC PORTB,5
    GOTO Increment
    ; If decrement button is pressed then decrement counter, else check 
    ; next button
    BTFSC PORTB,6
    GOTO Decrement
    ; If reset button is pressed then reset the counter, else call 
    ; main loop again
    BTFSC PORTB,7
    GOTO ResetCounter
    ; Clear RBIF flag
    BCF INTCON,RBIF
    
    SWAPF STATUS_SAVE, W
    MOVWF STATUS	; restore W and STATUS
    SWAPF W_SAVE, F
    SWAPF W_SAVE, W   
    
    RETFIE
    
    
    ; Program end
    end