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
        MOVE.B  #14, D0
        TRAP    #15
        
        LEA     StartString, A1    ;Store the user value
        
        MOVE.B  #2, D0       ;Read the string value from keyboard
        TRAP    #15        
        
        CMPI.L  #0, D1       ;If the user types in nothing, branch to Restart
        BEQ     Restart
        
        CMPI.L  #8, D1       ;If the user types more than 8 digits
        BGT     Restart  
        
        MOVE.B  D1, D4      ;D4 is where we will manipulate data. To avoid override
                            ;store the contents of D1 to D4. This is also the 
                            ;starting location
                            
        LEA     Address2, A1    ;Ask the user for a starting address
        MOVE.B  #14, D0
        TRAP    #15
        
        LEA     EndString, A1    ;Store the user value
        
        MOVE.B  #2, D0       ;Read the string value from keyboard
        TRAP    #15        
        
        CMPI.L  #0, D1       ;If the user types in nothing, branch to Restart
        BEQ     Restart
        
        CMPI.L  #8, D1       ;If the user types more than 8 digits
        BGT     Restart  

        MOVE.B  D4, D5      ;Use D5 as a for loop counter
        LEA     StartString, A3 ;Use A3 pointer to keep track of the ASCII so we convert it to Hex later  
        LEA     StartAddr, A4   ;Use A4 pointer to keep track of where to store the conversion results 
        CLR.L   StartAddr
        JSR     Convert

          
        MOVE.B  D1, D5      ;D5 is where we will manipulate data. To avoid override
                            ;store the contents of D1 to D5.
                            ;end location
        LEA     EndString, A3
        LEA     EndAddr, A4
        CLR.L   EndAddr
        JSR     Convert    

*-----------Converting the string to hex-------------
Convert
        MOVE.B  (A3)+, D4   ;In this context, use D4 to keep track of the current ASCII code
        MOVE.L  (A4),D6     
        LSL.L   #4, D6      ;Shift the address by 4 bits to the left
        MOVE.L  D6, (A4)    ;Make space for the digit we are about to add
        CMPI.L  #$40, D4    ;Compare ASCII Code to 40. If greater than 40, it's a letter
        BGE     ConvertAlpha

        CMPI.L  #$30, D4    ;Check one more time to check if it is a digit between 0-9
        BLT     Restart     ;Characters less than 0 is invalid. Restart
        SUB.L   #$30, D4    ;Convert this ASCII to Hex
        ADD.L   D4, (A4)
        BRA     AfterConvert

ConvertAlpha
        CMPI.L  #$46, D4    ;Still make sure it is a letter and if it is less than F
        BGT     Restart     ;Greater than 46, means greater than F. Invalid
        SUB.L   #$37, D4    
        ADD.L   D4, (A4)

AfterConvert
        SUB.L   #1, D5
        CMPI.L  #0, D5
        BNE     Convert
        RTS

NextPrompt
        LEA     NextPage, A1    ;Prompt User to press Enter if they want to continue
        MOVE.B  #14, 0
        TRAP    #15 

        MOVE.B  #5, D0
        TRAP    #15

        CMP.B   #$D, D1     ;This is if they press the Enter key to keep going
        BEQ     GoNextPage  ;Go to the next page
        
        CMP.B   #$1B, D1    ;If the Escape Key is hit then Stop
        BEQ     ExitPro
        
        BNE     NextPrompt  ;If the user doesn't press any of the keys, ask again

GoNextPage
        CLR.L   D5          ;Clear the counter
        BRA     ProcessInstructions    

*-----------Process----------------
* Start reading both the addresses 

ProcessInstructions
        NOP
        JSR     PrintTheAddress     ;Print the address of the next instruction
        

PrintTheAddress
        NOP
        MOVEM.L D0/D3/D5/D6/A1, -(SP)   ;Preserve these registers into the stack
        LEA     CurrentAddress, A1      ;Point A1 at this variable
        MOVE.L  A1, D5                  ;D5 points to start of current address
        ADD.L   #9, A1                  ;A1 points to the end of current address
        MOVE.B  #0, -(A1)               ;Load null character at the current address
        MOVE.L  A6, D6                  ;Copy address into D6
   
PrintAddressLoop
        NOP
        MOVE.L  D6, D3      ;Copy the remaining address into D3
        LSR.L   #4, D6      ;Shift the last 4 bits which is one hex digit
        AND.L   #$0F, D3    ;Get last 4 bits
        JSR     

*----------------IO-------------------


*-------------------------------------
*Print the string pointed to by A1
PrintTask13
        MOVEM.L D0, -(SP)   ;Load it to the stack
        MOVE.L  #13, D0     ;Print A1 with task 13
        TRAP    #15

        MOVEM.L (SP)+, D0   ;Pop this from the stack
        RTS            
        
PrintTask13
        MOVEM.L D0, -(SP)   ;Load it to the stack
        MOVE.L  #14, D0     ;Print A1 with Task 14
        TRAP    #15

        MOVEM.L (SP)+, D0   ;Pop this from the stack
        RTS 
        
*-----------Converting------------------
DigitHexConvert    NOP                         ; converts hex digit in D3 into its ASCII equivalent
                AND.L   #$0F, D3            ; get last 4 bits
                CMP.B   #10, D3              ; is the hex digit a number or a letter?
                BLT     DigitHexNum          ; handle numbers
                ADD.B   #$7, D3             ; add $7 (will add $30 later, for full $37, diff between letter digit and ascii digit)                        

DigitHexNum     NOP
                ADD.B   #$30, D3            ; add #$30, diff between number and ascii number 
                RTS                         ; return
        
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
        
Restart:
        LEA     Clear, A1   ;Load the newline to the address
        JSR     PrintTask13 ;Print the new line
        
        CLR.L   D0          ;Clear all Data Registers to reset them
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        
        MOVE.L  D1, A1      ;Clear all Address Registers to reset them
        MOVE.L  D2, A2
        MOVE.L  D3, A3
        MOVE.L  D4, A4
        MOVE.L  D5, A5
        MOVE.L  D6, A6
        
        JMP     START   
        
ExitPro
    SIMHALT             ; halt simulator
    
*-------------Variables--------------
StartString DS.L    0       ;Initialize the start string
EndString   DS.L    0       ;Initialize an end string
StartAddr   DS.L    1000    ;Initialize and declare a starting address
EndAddr     DS.L    1000    ;Initialize and declare an end address
    
*------------Prompt------------------
Prompt      DC.B    'Welcome to our Disassembler Program!', CR, LF
            DC.B    'Here are some rules for the program:', CR, LF
            DC.B    '1. Addresses entered must be in Hexadecimal', CR, LF
            DC.B    '2. Starting address must be more tham $00001000', CR, LF
            DC.B    '3. Ending address much be greater than starting address or less than $FFFFFFFF', CR, LF

Address1    DC.B    'Please enter the starting address: ', 0            
Address2    DC.B    'Please enter the ending address: ', 0
Contin      DC.B    'To continue to the next 20 lines, press ENTER', CR, LF
Finish      DC.B    'We have finished Disassembling! To restart, press R. To stop, press S:', CR, LF
Clear       DC.B    '', 0
NextPage    DC.B    'To Continue, Press ENTER. To Stop, Press ESC', CR, LF

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
