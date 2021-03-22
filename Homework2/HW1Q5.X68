*-----------------------------------------------------------
* Title      : Homework2
* Written by : Sung Ho Park 
* Date       : 1/26/21
* Description: Add two numbers
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

START:  ORG     $1000    

*-----Code for output 1--------
        LEA     MESS1, A1       *Display the first number prompt
        MOVE.L  #14, D0         *Trap 14 displays
        TRAP    #15
        
*-----Code for input 1---------        
        MOVE.L  #4, D0          *Task 4 gets the input and puts it in D1
        TRAP    #15             *Display
        MOVE.L  D1, D2          *Move it D1 to D2 to prevent override
        
*-----Code for output 2--------
        LEA     MESS2, A1       *Display the second number input prompt
        MOVE.L  #14, D0
        TRAP    #15
        
*-----Code for input 2---------   
        MOVE.L  #4, D0          *Get the Second Number and will be stored
        TRAP    #15             *in D1
        
        ADD.L   D2, D1          *Add both D1 and D2
        BVS.S   ERROR           *Print error message if overflow on 
        MOVE.L  D1, $6000       *Store it in address $6000
               
*-----Code for Result---------  
RESULT  LEA     RES, A1         *Display the result 
        MOVE.L  #14, D0
        TRAP    #15
        
        MOVE.L  #3, D0          *Display the answer in decimal
        TRAP    #15
        
        LEA     NXTL, A1        *Next Line, mainly here for formatting
        MOVE.L  #14, D0
        TRAP    #15
        
        MOVE.L  #9, D0          *Stop the program
        TRAP    #15
        
ERROR   LEA     FlagV, A1       *Get the line that shows the error
        MOVE.B  #14, D0
        TRAP    #15
        JMP     RESULT          *Jump to result
        
* Put variables and constants here
MESS1 DC.B    'We are going to add two numbers! Enter the first number: ', CR, LF, 0
MESS2 DC.B    'Enter the second number: ', CR, LF, 0
RES   DC.B    'Result: ', CR, LF, 0
NXTL  DC.B    ' ', CR, LF, 0  
FlagV DC.B    'Error: Overflow', CR, LF, 0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
