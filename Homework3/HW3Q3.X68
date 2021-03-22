*-----------------------------------------------------------
* Title      : Homework 3 Question 3
* Written by : Sung Ho Park
* Date       : 2/3/21
* Description: Pattern Finding and Cumulative Program
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

START:  ORG     $1000       *Program should start at $1000

*------Code for getting user input-----
USERIN  LEA     MESS1, A1   *Displays the prompt
        MOVE.B  #14, D0     *Trap 14 displays the message
        TRAP    #15
        
        JSR     Input       *Get the first digit
        JSR     ToHex       *Convert this digit
        LSL.B   #4, D6      *Use a Logical Shift left to shift the first digit
        MOVE.B  D6, D2      *Save the first digit 
        JSR     Input       *Get the second digit 
        JSR     ToHex       *Convert this didgit 
        ADD.B   D6, D2      *Add D6 to D2 to get the byte value
        MOVE.B  D2, $A000   *Save the value at address $A000
        
        CLR.L   D2
        CLR.L   D6          *Clear the registers 
        LEA     BLANK, A1   *New Line
        MOVE.B  #14, D0
        TRAP    #15
        
*-----Looping through the memory-----
        MOVEA.L #$6000, A3  *Starting location
        MOVEA.L #$8000, A4  *Ending location
        MOVE.L  #$6000, (Addr1)   *Initialize Addr1 to #$6000
        MOVE.L  #$0, (CarryBit)   *Initialize carry bit
        MOVE.L  #$0, (AddSum)     *Initialize AddSum
        MOVE.B  #$3E, $6240 *Test number
        
        *Read each byte data stored in memory from $6000 to $8000 
        *and compare it to $A000
Loop    CMPA.L  A3, A4      *Start looping and if they are the same, break
        BEQ     StartSum    *Branch out if starting and ending is the same
        MOVE.B  (A3),D2     *Move the contents of the memory location to D2
        CMP.B   ($A000),D2  *Compare it to address $A000
        BEQ     SetAddr1    *If they are equal (or found), the longword
                            *address of the data memory is saved into Addr1
        BRA     Continue
        
SetAddr1    
        MOVE.L  A3, Addr1

Continue    
        MOVE.B  (A3)+, D2   *Increment A3
        BRA     Loop        *Loop back to Loop

*-----Summation-----
StartSum    
        CLR.L   D2
        CLR.L   D3          *Clear used data registers
        MOVE.L  (Addr1),D4  *Move the contents of the memory location to 
        MOVEA.L D4, A4      *Move to Address register 4
        ADDI.L  #512, D4    *Add a 512 to D4 to get the destination
        MOVEA.L D4, A5      *This is the destination
        MOVE.B  (A4)+, D2   *Initialize a value so that this register will hold values
        MOVE.B  (A4)+, D3   *Initialize a value, The sum destination
        
LoopSum
        CMPA.L  A4, A5      *Compare the address registers (This should loop 512 times)
        BEQ     Push        *If A4 and A5 are the same, branch to push
        ADD.W   D2, D3      *Add for summation
        BCS     SetCarry    *Branch there is a carry set
        BRA     ContinueSum *Branch past carry
        
SetCarry
        MOVE.B  #$01, (CarryBit)    *There could be a chance that the sum exceeds
                                    *$FFFF, this is for the overflow
        
ContinueSum
        MOVE.B  (A4)+,D2    *Increment A4 and move it to D2 to continue loop
        BRA     LoopSum     *Branch to Loop
        
Push    MOVE.W  D3, AddSum  *If end of the loop, save sum value to AddSum
        BRA     Print       *Print out everything
        
*-----Print out-----
Print   LEA     ADDR1_, A1  *Print out the Address prompt 
        MOVE.B  #14, D0 
        TRAP    #15
        
        MOVE.L  (Addr1),D2  *Move the contents in memory to D2 
        JSR     PrintWord   *Jump to PrintWord to Print Address
        
        LEA     Blank, A1   *Make a Blank line
        MOVE.B  #14, D0 
        TRAP    #15
        
        LEA     SUM_, A1    *Print out the Addsum 
        MOVE.B  #14, D0 
        TRAP    #15
        
        CLR.L   D2
        MOVE.W  (AddSum),D2
        JSR     PrintWord
        
        LEA     Blank, A1     *Make a Blank line
        MOVE.B  #14, D0 
        TRAP    #15
        
        LEA     CARRY_, A1    *Print out the Carry
        MOVE.B  #14, D0 
        TRAP    #15
        
        CLR.L   D2
        MOVE.W  (CarryBit),D2
        JSR     Printbyte
        
        SIMHALT             *Halt the simulator
        
*-----Code for input-----
Input   MOVE.B  #5, D0      *Read a character from keyboard
        TRAP    #15
        MOVE.B  D1, D6      *Store the character in D6 to avoid override
        RTS
        
*-----ASCII to HEX (Ignoring the errors)-----
ToHex   MOVE.B  #0, D0      *Flag for non-hex character
        CMPI.B  #$39, D6    *Is it a number or alphabet
        BGT.B   ALPHAB      *If it's greater than 39, its a letter
        SUBI.B  #$30, D6    *Subtract to get the hexadecimal value
        RTS
        
ALPHAB  SUBI.B  #$37, D6    *Subtract to get the hexadecimal value
        RTS   
        
*----printing subroutine----

        *This is for printing purposes only. We will take these 
        *hexadecimal and convert it back to ASCII to print out 
        *strings.
Char    MOVE.B  #6, D0      *Trap task 6 displays a single character
        MOVE.B  D6, D1
        TRAP    #15
        RTS
    
ToAscii    
        CMPI.B  #9, D6      *Compare it to 0-9 in hex
        BGT     ToAlpha        *If greater than 9, it's a letter. Branch toAlpha

Num     ADDI.B  #$30, D6    *Add 30 to get the ASCII of numbers
        RTS
        
ToAlpha
        ADDI.B  #$37, D6    *Add 37 to get the ASCII of letters
        RTS  
        
PrintWord
        MOVE.W  D2, D6      *Move D2 to D6 to manipulate data 
        LSR.W   #8, D6      *Shift right to eliminate first 3 digits
        LSR.B   #4, D6
        JSR     ToAscii     *Convert
        MOVE.B  D6, D1      *Move D6 ASCII to D1
        JSR     Char        *Print out the character
        MOVE.W  D2, D6      *Max shift is one Byte
        LSL.L   #8, D6      *Shift left to delete first digit
        LSL.L   #8, D6
        LSL.L   #4, D6
        LSR.L   #8, D6      *Shift right to move desired digit to first 4 bits
        LSR.L   #8, D6
        LSR.L   #8, D6
        LSR.B   #4, D6
        JSR     ToAscii     *Convert again because we put D2 in D6
        MOVE.B  D6, D1      *Move it to D1 
        JSR     Char        *Print out the character
        JSR     Printbyte    
        RTS

Printbyte 
        MOVE.B  D2, D6      *Move D2 to D6 to manipulate data
        LSR.B   #4, D6      *Shift right to eliminate the first byte
        JSR     ToAscii     *Convert
        MOVE.B  D6, D1      *Move D6 ASCII to D1
        JSR     Char        *Print out the character 
        MOVE.B  D2, D6      
        LSL.B   #4, D6
        LSR.B   #4, D6
        JSR     ToAscii     *Convert again 
        MOVE.B  D6, D1      *Move D6 ASCII to D1
        JSR     Char        *Print out the character
        RTS

*-----Variables and constants-----
Addr1   DS.L    1   *Declare a LONGWORD Addr1 variable
AddSum  DS.W    1   *Declare a WORD AddSum variable
CarryBit DS.B    1   *Declare a carry bit variable
MESS1   DC.B    'Type in a Hex Byte Value: ', CR, LF, 0
ADDR1_  DC.B    'Addr1 was set to: ', 0, CR, LF
SUM_    DC.B    'AddSum was set to: ', 0, CR, LF
CARRY_  DC.B    'Carry Bit is: ', 0, CR, LF
BLANK   DC.B    ' ', CR, LF, 0
ERR     DC.B    'There is an Error.', CR, LF, 0 
    
        END    START        * last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
