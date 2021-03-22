*-----------------------------------------------------------
* Title      : Homework 3 Q4
* Written by : Sung Ho Park
* Date       : 2/4/21
* Description: Decode a Floating-point number
*-----------------------------------------------------------
UserIn     DC.L    1       *This will be a variable that we will store
                            *the Hexadecimal input

START:  ORG    $4000         *first instruction of program
        LEA     Message, A1 *Trap task 14 displays
        MOVE.B  #14, D0
        TRAP    #15
    
*-----User input-----
        JSR     Input       *Read the first input
        JSR     ToHex       *Convert to hexadecimal
        MOVE.B  D6,D2
        LSL.L   #4,D2       *Shift D2 to the left to make room for next digit

        MOVE.B  #0, D4      *Loop Start
        MOVE.B  #6, D5      *Loop Stop  
    
LoopInput
        JSR     Input       *This will loop 7 more times to get the IEEE
        JSR     ToHex       *Convert each char number to Hex        
        ADD.B   D6,D2       *Add the next digit to D2 to get numbers
    
        CMP.B   D4,D5       *Compare the start and stop
        BEQ     Read        *If they are the same, then you can stop the loop
        ADDI.B  #1,D4       *Increment D4 
        LSL.L   #4,D2       *Shift D2 to left to make more room for next digit    
        BRA     LoopInput   *Keep Looping

Read    MOVE.L  D2,(UserIn) *Move user number to variable, leave number in D2
        JSR     Blank

*-----Checking the Sign-----
        BTST    #$1F,D2         *Check the sign with BTST at location 1F (Leftmost)
        BEQ     Position        *If the Z flag is set, jump to position
        LEA     Negative,A1     *Or else, print the negative
        MOVE.B  #14, D0
        TRAP    #15
        BRA     ExponentPr
    
Position
        LEA     Positive,A1     *Print out the positive sign
        MOVE.B  #14, D0
        TRAP    #15 
 
*-----Print the exponent-----
ExponentPr
        LSR.L   #$8, D2         *Shift Right by 23
        LSR.L   #$8, D2
        LSR.L   #$7, D2         *This total is 23
    
        LEA     Exponent, A1    *Print out the exponent
        MOVE.B  #14, D1
        TRAP    #15
    
        MOVE.B  D2, D1          *Display the signed number in decimal
        MOVE.B  #3, D0          *in smallest field
        TRAP    #15
        JSR     Blank
    
*-----Mantissa Print-----
        MOVE.L  (UserIn),D2     *Move user's hexadecimal back to d2 to get hex
        LSL.L   #$1, D2         *Eliminate sign bit
        LSL.L   #$8, D2         *Eliminate exponant
        LSR.L   #$8, D2         *Move back to beggining
        LSR.L   #$1, D2     
    
ShiftRight
        BTST.L  #$0,D2          *Loop through the Mantissa
        BNE     DoneShifting    *Go to Done Shifting once we are done shifting
        LSR.L   #$1,D2          *Increment to shift right
        BRA     ShiftRight      *Keep going

DoneShifting   
        LEA     Mantissa,A1     *Print out the mantissa
        MOVE.B  #14, D1
        TRAP    #15
        
        MOVE.L  D2, D1
        MOVE.B  #3, D0
        TRAP    #15
    
    SIMHALT             ; halt simulator

*-----Subroutines-----
  
Input   MOVE.B  #5, D0      *Input a character
        TRAP    #15
        MOVE.B  D1, D6      *Store char in D6
        RTS
    
ToHex
        MOVE.B  #0, D7      *Flag for non-hex character
        CMP.B   #$39, D6    *Is it greater than 39?     
        BGT.B   Alphab      *It is an alphabet if it's greater than 39
        SUBI.B  #$30, D6    *Subtract 30 to get the hexadecimal    
        RTS
    
Alphab  SUBI.B  #$37, D6    *Subtract 37 to get hexadecimal    
        RTS

Blank   LEA     Blank_,A1    *Move print to new line
        MOVE.B  #14, D0
        TRAP    #15  
        RTS 

*-----Defining constants-----
CR      EQU     $0D
LF      EQU     $0A

Message     DC.B    'Please enter IEEE 32-bit floating point number in Hexadecimal Format',CR,LF,0
Positive    DC.B    'Sign bit: +',CR,LF,0
Negative    DC.B    'Sign bit: -',CR,LF,0
Exponent    DC.B    'Exponant: ',0
Mantissa    DC.B    'Mantissa: ',0
Blank_      DC.B    '',CR,LF,0

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
