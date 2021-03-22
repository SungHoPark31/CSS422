*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Sung Ho Park
* Date       : 2/18/20
* Description: Input
*-----------------------------------------------------------
stack   EQU     $A000
CR      EQU     $0D     ;carriage return
LF      EQU     $0A     ;line feed
    
START   ORG     $1000    ;first instruction of program

*-----------Starting Prompt--------------
Initial     
        LEA     Prompt, A1  ;Ask for user for the starting address
        MOVE.B  #14, D0     ;Displays the Message
        TRAP    #15

*----------Address input---------------
UserInput
        LEA     Address1, A1    ;Ask the user for a starting address
        MOVE.B #14, D0
        TRAP   #15
        
        LEA     StartAdr, A1    ;Store the user value
        
        MOVE.B #2, D0       ;Read the string value from keyboard
        TRAP   #15        
        
        CMPI.L #0, D1       ;If the user types in nothing, branch to Restart
        BEQ    Restart
        
        CMPI.L #8, D1       ;If the user types more than 8 digits
        BGT    Restart  
        
        MOVE.B  D1, D4      ;D4 is where we will manipulate data. To avoid override
                            ;store the contents of D1 to D4
                            
        LEA     Address2, A1    ;Ask the user for a starting address
        MOVE.B #14, D0
        TRAP   #15
        
        LEA     EndAdr, A1    ;Store the user value
        
        MOVE.B #2, D0       ;Read the string value from keyboard
        TRAP   #15        
        
        CMPI.L #0, D1       ;If the user types in nothing, branch to Restart
        BEQ    Restart
        
        CMPI.L #8, D1       ;If the user types more than 8 digits
        BGT    Restart  
        
        MOVE.B  D1, D4      ;D4 is where we will manipulate data. To avoid override
                            ;store the contents of D1 to D4
                            
        
        
        
        
*-----------Ending Prompt--------------
End
        CLR.L   D0
        LEA     Finish, A1  ;Finished Diassembling, ask to restart or stop
        MOVE.B  #14, D0     ;Displays the Message
        TRAP    #15
        
        MOVE.B  #5, D0      ;Read in the character that the user will put in.
        TRAP    #15         
        
        CMPI.B  #$52, D1    ;Check if the ASCII string is 'R'
        BEQ     Restart

        CMPI.B  #$72, D1    ;Check if the ASCII string is 'r'
        BEQ     Restart
        
        CMPI.B  #$53, D1    ;Check if the ASCII string is 'S'
        BEQ     ExitPro
        
        CMPI.B  #$53, D1    ;Check if the ASCII string is 's'
        BEQ     ExitPro

        BRA     End         ;If there is an invalid input
Restart
        *LEA     Clear, A1   ;Load the newline to the address
        CLR.L   D0          ;Clear all Data Registers to reset them
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        
        MOVE.L  D0, A1      ;Clear all Address Registers to reset them
        MOVE.L  D0, A2
        MOVE.L  D0, A3
        MOVE.L  D0, A4
        MOVE.L  D0, A5
        MOVE.L  D0, A6
        
        JMP     START   
        
ExitPro
    SIMHALT             ; halt simulator
    
*-------------Variables--------------
StartAdr    DS.L    1000    ;Initialize and declare a starting address
EndAdr      DS.L    1000    ;Initialize and declare an end address
    
*------------Prompt------------------
Prompt      DC.B    'Welcome to our Disassembler Program!', CR, LF
            DC.B    'Here are some rules for the program:', CR, LF
            DC.B    '1. Addresses entered must be in Hexadecimal', CR, LF
            DC.B    '2. Starting address must be more tham $00001000', CR, LF
            DC.B    '3. Ending address much be greater than starting address or less than $FFFFFFFF', CR, LF

Address1    DC.B    'Please enter the starting address: ', 0            
Address2    DC.B    'Please enter the ending address: ', 0
Contin      DC.B    'To continue to the next 20 lines, press ENTER', CR,LF
Finish      DC.B    'We have finished Disassembling! To restart, press R. To stop, press S:', CR, LF
Clear       DC.B    '', 0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
