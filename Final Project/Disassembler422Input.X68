*-----------------------------------------------------------
* Title      : Disassembler IO
* Written by : Sung Ho Park
* Date       : 2/18/20
* Description: This takes care of the input and the output
*-----------------------------------------------------------
*
*
*Websites used:
*Jmp_Table - https://canvas.uw.edu/courses/1444201/pages/addendum
*TRAP Tasks - http://www.easy68k.com/QuickStart/TrapTasks.htm

stack   EQU     $A000
Min     EQU     $00001000
CR      EQU     $0D     ;carriage return
LF      EQU     $0A     ;line feed
    
START   ORG     $1000    ;first instruction of program
        LEA     stack, SP   ;Load the stack pointer
      *  LEA     jmp_table, A0   ;Load Jump Table


*-----------Starting Prompt--------------
        LEA     Prompt, A1  ;Ask for user for the starting address
        MOVE.B  #14, D0     ;Displays the Message and the rules
        TRAP    #15
        
        LEA     EoO, A1
        MOVE.B  #14, D0
        TRAP    #15
        
*----------Address input---------------
UserInput
        *This is for looping back 
        CLR.L   D1      ;This is for the clear screen. If we loop back, FF00 is still
                        ;in D1 so we have to clear it 
                        
        LEA     EnterStart, A1    ;Ask the user for a starting address
        MOVE.B  #14, D0
        TRAP    #15
        
        LEA     StartString, A1    ;Store the user value to A1
        MOVE.B  #2, D0       ;Read the string value from keyboard and store it in A1
                             ;The length of the user input will be stored in D1
        TRAP    #15          
        
        JSR     InputValidSize ;Check if the input is valid.
        CMP.L   #$FF00, D1       ;This is the code for clearing screen
        BEQ     UserInput    ;Go back to start
        JSR     Convert         ;If it is a valid input, convert it to hex.
        JSR     AfterConvertCheck   ;Check again after it is converted
        CMP.L   #$FF00, D1       ;This is the code for clearing screen
        BEQ     UserInput    ;Go back to start
        MOVEA.L D3, A2          ;Once every check is completed, save the address into
                                ;an address register. We'll use A2 to store the starting
                                
        CLR.L   D3           ;Clear D3 so that we can use it again for the end address
                            
        LEA     EnterEnd, A1    ;Ask the user for a starting address
        MOVE.B  #14, D0
        TRAP    #15
        
        LEA     EndString, A1    ;Store the user value
        MOVE.B  #2, D0       ;Read the string value from keyboard
        TRAP    #15        
        
        JSR     InputValidSize ;Check if the input is valid.
        CMP.L   #$FF00, D1       ;This is the code for clearing screen
        BEQ     UserInput           ;Go back to start
        JSR     Convert         ;If it is a valid input, convert it to hex.   
        JSR     AfterConvertCheck   ;Check again after it is converted
        CMP.L   #$FF00, D1       ;This is the code for clearing screen
        BEQ     UserInput           ;Go back to start
        MOVEA.L D3, A3          ;Once every check is completed, save the address into
                                ;an address register. We'll use A3 to store the ending
                                ;Use MOVEA because the destination is an address register
        
        MOVE.L  A2, StartAddr   ;Make the variable StartAddr the starting address
        MOVE.L  A3, EndAddr     ;Make the variable EndAddr the ending address
        
*------------The Scan Loop-------------------
*Loop that goes through the starting address to the end 
*Scanning opcode is also here but for now, we will not worry about it

        CLR.L   D2              ;We will use D2 as a counter for 20 lines at a time. 
                                ;It has been unused so far, but clear it just in case.
        MOVE.L  StartAddr, D3   ;We will be manipulating this 
        MOVE.L  EndAddr, D4    
        
TheScanLoop
        CMP.L   D3, D4   ;Compare the current and the end address
        BLT     ExitTheLoop         ;If current becomes greater than or equal to the end, stop
       
        CMP.B   #$14, D2         ;Compare D7 to 20 counts (14 should be hex for 20)
        BEQ     TwentyLinesAtATime  ;If it is equal, branch out
        

        MOVE.L  #CurrAddr, A5        ;Load the current address variable
        MOVE.L  D3, D5
        JSR     GetTheCurrent     ;Print the current address
        MOVE.B  #0, (A5)+           ;This is an end delimeter. That way, no other information can append to (A4)
        JSR     Display             ;Display the address
        *****Add opcode section and effective address portion and jump there
        *Assuming we have the opcode and the ea
        *                       ;Take the line
        *                       ;Divide it to characters using some sort of shift
        *                       ;Scan the opcode
        *                       ;Display it 
        *                       ;Scan the effective address 
        *                       ;Display the effective address

        ADD.L   #$2, D3         ;Increment this
        
        MOVE.L  #$2, StartAddr
        ADD.B   #1, D2          ;Increment the amount of lines displayed by 1. Odd addresses are invalid

        BRA     TheScanLoop
        
TwentyLinesAtATime
        CLR.L   D2              ;We'll use D7 as a counter for every 40 lines being displayed
        BRA     NextPrompt      ;Go to nextPrompt
        
*-----------Ending Prompt--------------
Ending
        LEA     Finish, A1  ;Finished Diassembling, ask to restart or stop
        MOVE.B  #14, D0     ;Displays the Message
        TRAP    #15
        
        MOVE.B  #5, D0      ;Read in the character that the user will put in.
        TRAP    #15      

        LEA     Empty, A1     ;Little format
        MOVE.B  #14, D0         
        TRAP    #15   
        
        CMPI.B  #$52, D1    ;Check if the ASCII string is 'R'
        BEQ     Restart

        CMPI.B  #$72, D1    ;Check if the ASCII string is 'r'
        BEQ     Restart
        
        CMPI.B  #$53, D1    ;Check if the ASCII string is 'S'
        BEQ     ExitPro
        
        CMPI.B  #$73, D1    ;Check if the ASCII string is 's'
        BEQ     ExitPro
        
        LEA     RoS, A1     ;Invalid input. Ask for R or S
        MOVE.B  #14, D0     
        TRAP    #15

        BRA     Ending       ;If there is an invalid input
        
Restart
        MOVE.W  #$FF00, D1  ;Task Trap 11 is the clear screen task
        MOVE.B  #11, D0     ;It must have FF00 in D1 for it to work 
        TRAP    #15
        
        CLR.L   D0          ;Clear all Data Registers to reset them
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        
        MOVE.L  #$0, A1      ;Clear all Address Registers to reset them
        MOVE.L  #$0, A2
        MOVE.L  #$0, A3
        MOVE.L  #$0, A4
        MOVE.L  #$0, A5
        MOVE.L  #$0, A6
        
        BRA     Start

        
ExitTheLoop
        BRA     Ending          ;Go to the restarting prompt
ExitPro
        LEA     ExitMsg, A1     ;Print Exit message
        MOVE.B  #14, D0         
        TRAP    #15
        
    SIMHALT             ; halt simulator
                
*-------------Input check valid------------
InputValidSize             ;Check if the input that the user put in is valid
        CMP.L  #0, D1       ;Compare 0 to user input.
                             ;If the user types in nothing, branch to Restart
        BEQ     TypeZero
        
        CMP.L  #8, D1       ;If the user types more than 8 digits
        BGT     MoreThanEight  
        BLT     LessThanEight   ;If the user types less than 8 digits
        
        RTS
        
TypeZero
        LEA     Nothing, A1 ;Prompt that says the user put nothing 
        MOVE.L  #14, D0
        TRAP    #15
        BRA     TryAgainPrompt
        
MoreThanEight
        LEA     MoreEight, A1   ;Prompt saying user put more than eight digits
        MOVE.B  #14, D0     ;Displays the Message
        TRAP    #15
        BRA     TryAgainPrompt  ;Go to try again
        
LessThanEight
        LEA     LessEight, A1   ;Prompt saying the user needs to put in more digits
        MOVE.L  #14, D0
        TRAP    #15
        BRA     TryAgainPrompt  ;Try again
        
TryAgainPrompt
        LEA     TryAgain, A1    ;Try again prompt
        MOVE.B  #14, D0
        TRAP    #15
        
        MOVE.B  #5, D0      ;Read in the character that the user will put in.
        TRAP    #15         
        
        LEA     Empty, A1     ;Little format
        MOVE.B  #14, D0         
        TRAP    #15
        
        CMPI.B  #$59, D1    ;Check if the ASCII string is 'Y'
        BEQ     Restart

        CMPI.B  #$79, D1    ;Check if the ASCII string is 'y'
        BEQ     Restart
        
        CMPI.B  #$4E, D1    ;Check if the ASCII string is 'N'
        BEQ     ExitPro     
      
        CMPI.B  #$6E, D1    ;Check if the ASCII string is 'n'
        BEQ     ExitPro
        BNE     InvalidTryAgain ;If none of these are inputted, try again       
        
InvalidTryAgain
        LEA     YoN, A1     ;Invalid input. Ask for Y or N
        MOVE.B  #14, D0     
        TRAP    #15
        BRA     TryAgainPrompt  ;Go back to the try again prompt
        
*-----------Converting the string to hex-------------
Convert 
        CMP.B   #0, D1      ;Are all the characters of the input converted?
        BEQ     ExitLoop
        
ConvertLoop
        
        CLR.L   D2          ;We are using D2 for storing characters in the input string
        MOVE.B  (A1)+, D2   ;We are using (A1)+ because we are getting individual characters
        CMP.B   #$39, D2    ;Is it a number or alphabet
        BLE.B   DigitConvert  ;If it is less than 39, check if it is a digit
        BGT.B   LetterConvert ;If it's greater than 39, its a letter
        
DigitConvert
        CMP.B   #$30, D2    ;Compare 30 and D2
        BLT     FailToConvert ;If it is below 30, it is invalid
        SUBI.B  #$30, D2    ;If it is in between 30 and 39, subtract to get hex value
        CMPI.B  #1, D1      ;This is the last bit. We will check if it is even or odd. 
        BEQ     EvenOdd     ;Check if it is even or odd. (Odd is invalid)
        BRA     ConvertLoopCounter  ;Go to Loop counter and decrease the count
        
LetterConvert
        CMP.B   #$41, D2    ;Compare 41 (A in Hex) to D2
        BLT     FailToConvert ;Failed to convert if less than captiral A
        CMP.B   #$46, D2    ;Compare 46 (F in Hex) to D2
        BGT     FailToConvert ;Failed to convert if greater than capital F
        SUBI.B  #$37, D2    ;Subtract 37 to get letter hex
        CMPI.B  #1, D1      ;This is the last bit. We will check if it is even or odd. 
        BEQ     EvenOdd     ;Check if it is even or odd. (Odd is invalid)
        BRA     ConvertLoopCounter  ;Go to loop counter and decrease the count
        
FailToConvert
        LEA     ConvertFail, A1 ;Conversion failure prompt
        MOVE.B  #14, D0
        TRAP    #15
        
        BRA     TryAgainPrompt 

ConvertLoopCounter
        SUBI.B  #$1, D1     ;Decrement the size of the string by one so that way
                            ;We keep track of characters being converted
        ADD.B   D2, D3      ;Save this converted hex character to D3 for now
        CMPI.B  #0, D1     ;Are we done with the loop? 
        BEQ     ExitLoop    ;If we are, get out of the conversion loop
        
        ASL.L   #4, D3      ;A single hexadecimal value is 4 bits. So we need to shift 4 bits
                            ;to make room for the next 4 bits
        BRA     ConvertLoop ;Loop back to convert the next character 
        
EvenOdd
        BTST.L  #00, D2     ;Compare the final bit to D2. 
        BNE     Odd        ;If the last bit is 0, then it is even
        BRA     ConvertLoopCounter  ;If it is even then go straight to the loop counter
Odd
        LEA     OddNum, A1     ;Print out the message
        MOVE.B  #14, D0
        TRAP    #15         
        BRA     TryAgainPrompt  ;Try again 
                               
ExitLoop
        RTS
        
        
*-----------------PrintTheCurrent------------------

GetTheCurrent 
        CLR.L   D7          ;Just in case, clear this
        MOVE.B  #0, D7       ;This is for the counter

CurrentLoop
        JSR     HexToASCII  ;Convert the hexadecimal
        ADDI.B  #1, D7      ;Increment count
        CMP.B   #8, D7      ;Compare         
        BLT     CurrentLoop ;If it is less than 8, then loop
        
        MOVE.B  #09, (A5)+
        RTS                 ;If it is 8 then get out of the loop
        
         
HexToASCII
        ROL.L   #4, D5      ;Rotate the first hex value top the left so it wraps around the
                            ;back. The last digit will be the "beginning" one 
        MOVE.L  D5, D6      ;To avoid overriding and saving the contents of D5
        ANDI.L  #$0000000F, D6  ;This will take the last hex digit (or the "first" digit) 

        CMP.B   #$A, D6     ;Compare this character with the contents of D5
        BLT     NumberConvert   ;If it is less than A it is a number
        ADDI.B  #$37, D6    ;Convert to the character in ASCII
        MOVE.B  D6, (A5)+   ;Put this character in the string 
        RTS
        
NumberConvert
        ADDI.B  #$30, D6    ;Add 30 to get the ASCII value of D5
        MOVE.B  D6, (A5)+   ;Put this character in the string 
        RTS
        
*-----------After convert check----------------
AfterConvertCheck       
        CMP.L   #$00001000, D3  ;Compare the starting address
        BLT     LessThanStart   ;If the user inputs something that is less than starting.
        
        CMP.L   #$000FFFFE, D3  ;Compare the ending address
        BGT     GreaterEnd      ;If the user inputs something that is more than end address
 

        RTS                        ;Branch

LessThanStart
        LEA     LessStart, A1   ;Tell the user that they entered something less than start
        MOVE.B  #14, D0
        TRAP    #15
        BRA     TryAgainPrompt
        
GreaterEnd
        LEA     MoreEnd, A1     ;Tell the user that they entered something more than the end
        MOVE.B  #14, D0
        TRAP    #15
        BRA     TryAgainPrompt
        
        RTS
        
        
*--------------Continue------------------
NextPrompt
        LEA     Contin, A1    ;Prompt User to press Enter if they want to continue
        MOVE.B  #14, 0
        TRAP    #15 

        MOVE.B  #5, D0      ;Get the input
        TRAP    #15
        
        LEA     Empty, A1     ;Little format
        MOVE.B  #14, D0         
        TRAP    #15
        
        CMP.B   #$1B, D1    ;This is the escape key in the ASCII table. 
                            ;If the Escape Key is hit then Stop
        BEQ     ExitPro

        CMP.B   #$D, D1     ;This is carriage return in the ASCII table.
                            ;If they press the Enter key to keep going
        BEQ     GoNextPage  ;Go to the next page
        
        LEA     EnE, A1     ;Invalid input. Must put in enter key or esc
        MOVE.B  #14, D0
        TRAP    #15
        BRA     NextPrompt  ;Loop back to next prompt
        
GoNextPage
        MOVE.W  #$FF00, D1  ;Task Trap 11 is the clear screen task
        MOVE.B  #11, D0     ;It must have FF00 in D1 for it to work 
        TRAP    #15
        BRA TheScanLoop     ;go back to the scan loop to continue
        
*-----------Displaying the line----------------
Display
        LEA     CurrAddr, A1        ;Move the current address to A1
        MOVE.B  #14, D0
        TRAP    #15
        
        LEA     Empty, A1        ;Empty to go to the next line
        MOVE.B  #14, D0
        TRAP    #15
        RTS
      
*----------Clearing screen------------
ClearScreen
        MOVE.W  #$FF00, D1  ;Task Trap 11 is the clear screen task
        MOVE.B  #11, D0     ;It must have FF00 in D1 for it to work 
        TRAP    #15
        RTS
        
*--------------JmpTable----------------
*jmp_table      
 *       JMP     code0000
  *      JMP     code0001
   *     JMP     code0010
    *    JMP     code0011
     *   JMP     code0100
 *       JMP     code0101
  *      JMP     code0110
   *     JMP     code0111
    *    JMP     code1000
     *   JMP     code1001
      *  JMP     code1010
*        JMP     code1100
 *       JMP     code1101
  *      JMP     code1110
   *     JMP     code1111
    
*-------------Variables--------------
StartString DS.L    0       ;Initialize the start string
EndString   DS.L    0       ;Initialize an end string
StartAddr   DS.B    20       ;Initialize and declare a starting address
EndAddr     DS.B    20       ;Initialize and declare an end address
PrintCount  DS.L    0       ;This will be used for printing out everthing
TheBuffer   DS.B    1       ;This is a buffer for the output. 
CurrAddr    DS.B    20       ;Initialize and declare the current address
    
*------------Constants------------------
Prompt      DC.B    'Welcome to our Disassembler Program!', CR, LF
            DC.B    'Here are some rules for the program:', CR, LF
            DC.B    '1. Addresses entered must be in Hexadecimal', CR, LF
            DC.B    '2. Starting address must be greater than or less than $00001000', CR, LF
            DC.B    '3. Ending address much be between starting address and $000FFFFE', CR, LF
            DC.B    '4. Must enter an 8 digit Hexadecimal', CR, LF, 0

EoO         DC.B    '5. You must enter an even Hexadecimal', CR, LF, 0
Nothing     DC.B    'You entered 0 digits. Invalid: Restarting', CR, LF, 0
MoreEight   DC.B    'You entered more than eight digits.', CR, LF, 0
LessEight   DC.B    'You entered less than eight digits.', CR, LF, 0
TryAgain    DC.B    'Press Y to try again. N to stop... ', 0
EnterStart  DC.B    'Please enter the starting address: ', 0            
EnterEnd    DC.B    'Please enter the ending address: ', 0
LessStart   DC.B    'You entered a starting address that is less than $00001000. Restarting...', CR, LF, 0 
MoreEnd     DC.B    'You entered a ending address that is more than $000FFFFE. Restarting...', CR, LF, 0
Contin      DC.B    'To continue to the next 20 lines, press ENTER. To Stop, Press ESC...', CR, LF, 0
Finish      DC.B    'We have finished Disassembling! To restart, press R. To stop, press S:', CR, LF, 0
OddNum      DC.B    'You entered an odd hexadecimal, therefore, we cannot disassemble.', CR, LF, 0
Empty       DC.B    ' ',CR, LF, 0
Test        DC.B    '1', CR, LF, 0
EnE         DC.B    'Invalid input. Must be enter or esc...', CR, LF, 0
RoS         DC.B    'Invalid input. Must enter R or S...', CR, LF, 0
YoN         DC.B    'Invalid input. Must enter Y or N...', CR, LF, 0
ConvertFail DC.B    'Failed to convert because user inputted invalid character.', CR, LF, 0
ExitMsg     DC.B    'Thank you for using our disassembler! Exiting...', CR, LF, 0 

    END    START        ; last line of source















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
