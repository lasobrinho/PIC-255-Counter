    LIST    P=16F877A,F=INHX8M
#include <p16f877a.inc>
    
    __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    org 0
    
    ; Declaring program variables
    cblock 0x20
    units
    tens
    hundreds
    temp
    endc
    
    ; Moving initial value 0 to counter variables
    MOVLW B'00000000'
    MOVWF units
    MOVLW B'00000000'
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

    ; Main program loop
MainLoop:
    ; Call display functions to refresh each 7-segment display
    CALL DisplayUnits
    CALL DisplayTens
    CALL DisplayHundreds
    
    ; Read input based on the button pressed
    banksel PORTB
    ; If increment button is pressed then increment counter, else check next button
    BTFSC PORTB,0
    GOTO Increment
    ; If decrement button is pressed then decrement counter, else check next button
    BTFSC PORTB,1
    GOTO Decrement
    ; If reset button is pressed then reset the counter, else call main loop again
    BTFSC PORTB,2
    GOTO ResetCounter
    ; If no input is detected, continue looping
    GOTO MainLoop

    ; Function to power on the units 7-segment display
    ; Power is passed through bit 7 of PORTB
DisplayUnits:
    ; Setting ports 6 (tens) and 5 (hundreds) as off
    banksel PORTB
    BCF PORTB,6
    BCF PORTB,5
    ; Moving units value to PORTC to be displayed
    banksel PORTC
    MOVF units,W
    MOVWF PORTC 
    ; Setting PORTB bit 7 as high to power on the display
    banksel PORTB
    BSF PORTB,7    
    RETURN
    
    ; Function to power on the tens 7-segment display
    ; Power is passed through bit 6 of PORTB    
DisplayTens:
    ; Setting ports 7 (units) and 5 (hundreds) as off
    banksel PORTB
    BCF PORTB,7
    BCF PORTB,5
    ; Moving tens value to PORTC to be displayed
    banksel PORTC
    MOVF tens,W
    MOVWF PORTC
    ; Setting PORTB bit 6 as high to power on the display
    banksel PORTB
    BSF PORTB,6
    RETURN

    ; Function to power on the hundreds 7-segment display
    ; Power is passed through bit 5 of PORTB  
DisplayHundreds:
    ; Setting ports 7 (units) and 6 (tens) as off
    banksel PORTB
    BCF PORTB,7
    BCF PORTB,6
    ; Moving hundreds value to PORTC to be displayed
    banksel PORTC
    MOVF hundreds,W
    MOVWF PORTC
    ; Setting PORTB bit 5 as high to power on the display
    banksel PORTB
    BSF PORTB,5
    RETURN
    
    ; Function to increment the counter value
Increment:
    ; Wait until increment button is released
    BTFSC PORTB,0
    GOTO Increment
    ; Increment units
    INCF units,F
    ; Check if units = D'10'
    MOVLW B'00000000'
    ADDWF units,W
    ADDLW -B'00001010'
    MOVWF temp
    MOVF temp,F
    ; If units = D'10' then increment tens variable, else return to main loop
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
    ; Check if tens = D'10'
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
    
Decrement:
    BTFSC PORTB,1
    GOTO Decrement
    DECF units,F
    MOVLW B'00000000'
    ADDWF units,W
    ADDLW B'00000001'
    MOVWF temp
    MOVF temp,F
    BTFSC STATUS,Z
    CALL DecrementTens
    GOTO MainLoop
    
DecrementTens:
    MOVLW B'00001001'
    MOVWF units
    DECF tens,F
    MOVLW B'00000000'
    ADDWF tens,W
    ADDLW B'00000001'
    MOVWF temp
    MOVF temp,F
    BTFSC STATUS,Z
    CALL DecrementHundreds
    RETURN
    
DecrementHundreds:
    MOVLW B'00001001'
    MOVWF tens
    DECF hundreds,F
    RETURN
    
ResetCounter:
    BTFSC PORTB,2
    GOTO ResetCounter
    CALL ResetUnits
    CALL ResetTens
    CALL ResetHundreds
    GOTO MainLoop
    
ResetUnits:
    MOVLW B'00000000'
    MOVWF units
    RETURN

ResetTens:
    MOVLW B'00000000'
    MOVWF tens
    RETURN
    
ResetHundreds:
    MOVLW B'00000000'
    MOVWF hundreds
    RETURN
    
    end