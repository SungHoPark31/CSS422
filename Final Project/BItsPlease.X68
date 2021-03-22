*-----------------------------------------------------------
* Title      : Disassembler IO
* Written by : Sung Ho Park, Nathan Wong, Olivia McFarland,Kenneth Ven
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
        MOVEA.L D3,A2
        MOVE.W  (A2),D5
        JSR     opFind
        *****Add opcode section and effective address portion and jump there
        *Assuming we have the opcode and the ea
        *                       ;Take the line
        *                       ;Divide it to characters using some sort of shift
        *                       ;Scan the opcode
        *                       ;Display it 
        *                       ;Scan the effective address 
        *                       ;Display the effective address
        LEA Empty,A1
        MOVE.B  #14,D0
        TRAP    #15

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
        
        *LEA     Empty, A1        ;Empty to go to the next line
        *MOVE.B  #14, D0
        *TRAP    #15
        RTS
      
*----------Clearing screen------------
ClearScreen
        MOVE.W  #$FF00, D1  ;Task Trap 11 is the clear screen task
        MOVE.B  #11, D0     ;It must have FF00 in D1 for it to work 
        TRAP    #15
        RTS
*-----------OPCODE Section------------
opFind    
    MOVEM.L A1-A6/D0-D2/D4/D6-D7,-(SP)
    JSR     CLRREGS
    JSR     OpCodeBits 
opReturn    
    MOVEM.L (SP)+,A1-A6/D0-D2/D4/D6-D7
    RTS

OpCodeBits
    LEA     TheBuffer,A3
    MOVE.W  D5,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    LEA     tableJumpOp,A2
    MULU    #6,D6   *Convert to the size of elements
    JSR     (A2,D6.W)
    *MOVE.B  #0,(A3)+
    *LEA     $1,A1
    *MOVE.B  #14,D0
    *TRAP    #15
    RTS
*Table to jump towards
tableJumpOp
    JMP     hex0 
    JMP     hex1 *MOVE.B    
    JMP     hex2 *MOVE.L, MOVEA.L
    JMP     hex3 *MOVE.W, MOVEA.W
    JMP     hex4 *NOT, MOVEM, NOP,LEA,JSR,RTS
    JMP     hex5 *ADDQ
    JMP     hex6 *BCC(BGT,BLE,BEQ),BRA,
    JMP     hex7 *MOVEQ
    JMP     hex8 *OR
    JMP     hex9 *SUB
    JMP     hexA
    JMP     hexB
    JMP     hexC *AND
    JMP     hexD *ADD/ADDA
    JMP     hexE *LSL,ASL,ASR,LSR,ROR,ROL
    JMP     hexF
hex0
    JSR PRINTINVALID
    
    RTS
hex1
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    MOVE.B #'.',(A3)+
    JSR    PRINTB
    JSR    PRINTOP
    *Get EA
    JSR PRINTMOVEEA
    
    RTS 
hex2    
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    JSR    ISADDRESS
    MOVE.B #'.',(A3)+
    MOVE.B #'L',(A3)+
    MOVE.B #%0001,D4
    MOVE.B   D4,ImmediateDataSize
    JSR     PRINTOP
    *GETEA
    CMP.B   #$1,D6
    BEQ     PRINTMOVEAEA
    
    JSR PRINTMOVEEA
    
    RTS
hex3
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    JSR    ISADDRESS
    MOVE.B #'.',(A3)+
    MOVE.B #'W',(A3)+
    MOVE.B #%0010,D4
    MOVE.B   D4,ImmediateDataSize
    JSR     PRINTOP
    *GETEA
    CMP.B   #$1,D6
    BEQ     PRINTMOVEAEA

    JSR PRINTMOVEEA
    
    RTS
    
*NOT, MOVEM, NOP, LEA, JSR, RTS command 
hex4
    *Move where we currently are on the address back to d5
    *MOVE.W  (A1),D5
    MOVE.W  D5,D6
    LSR.W   #8,D6 *Test the eigth bit to see if its LEA
    LSL.B   #7,D6
    LSR.B   #7,D6
    CMP.B   #1,D6
    BNE     getSecondPart
    MOVE.B  #'L',(A3)+
    MOVE.B  #'E',(A3)+
    MOVE.B  #'A',(A3)+
    JSR     PRINTOP
    *
    *Print LEA    
    
    JSR     PRINTLEAEA
    RTS
*Needs to get  bits 8,9,10 make sure it is eual to 0, 1 or 2
hex5
    MOVE.W  D5,D6
    LSL.W   #7,D6
    LSR.W   #8,D6
    LSR.W   #5,D6
    CMP.B   #$2,D6
    BLE     CODEADDQ
    *INVALID COMMAND
    JSR PRINTINVALID
    RTS
*BCC/BRA
hex6
    MOVE.W  D5,D6
    LSR.W   #8,D6
    LSL.B   #4,D6
    LSR.B   #4,D6
    LEA     tableJumpBCC,A2
    MULU    #6,D6
    JSR     (A2,D6.W)
    RTS
hex7
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    MOVE.B #'Q',(A3)+
    JSR     PRINTOP

    JSR PRINTMOVEQEA
    RTS
hex8
    *Not sure how to decipher SBCD vs OR, Best guess has to do with it being data register
    *MOVE.W  D5,D6
    *LSL.B   #2,D6
    *LSR.B   #5,D6
   * CMP.B   #$1,D6
    JSR     TESTOR
    *BAD Command
    RTS
hex9
    JSR     TESTSUB
    RTS
hexA
    JSR PRINTINVALID
    RTS
hexB
    JSR PRINTINVALID
    RTS
*AND
hexC
    JSR     TESTAND
    RTS
hexD
    MOVE.W  D5,D6
    MOVE.B  #'A',(A3)+
    MOVE.B  #'D',(A3)+
    MOVE.B  #'D',(A3)+
    JSR     ISOLATE9_10BITS
    CMP.B   #$2,D6
    BGT     ADDRESS
    MOVE.B  #'.',(A3)+
    CMP.B   #$0,D6
    BEQ     ADDSIZEB
    CMP.B   #$1,D6
    BEQ     ADDSIZEW
    CMP.B   #$2,D6
    BEQ     ADDSIZEL
    JSR PRINTINVALID
    
GETADD
    JSR     PRINTOP
    JSR     PRINTADDEA   
    RTS
    
ADDSIZEB
    JSR     PRINTB
    BRA     GETADD
ADDSIZEW
    JSR     PRINTW
    BRA     GETADD
ADDSIZEL
    JSR     PRINTL
    BRA     GETADD
    
hexE
    MOVE.W  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$3,D6
    BEQ     MEMSHIFT
    MOVE.W  D5,D6
    LSL.B   #3,D6
    LSR.B   #6,D6 *Isolate the bits should be 000000xx
    CMP.B   #$0,D6
    BEQ     ASD
    CMP.B   #$1,D6
    BEQ     LSD
    CMP.B   #$3,D6
    BEQ     ROD
    JSR PRINTINVALID
    *Bad input
    RTS
ASD 
    MOVE.B  #'A',(A3)+
    MOVE.B  #'S',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.B  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$0,D6
    BEQ     SHIFTPRINTB
    CMP.B   #$1,D6
    BEQ     SHIFTPRINTW
    CMP.B   #$2,D6
    BEQ     SHIFTPRINTL
    RTS
LSD 
    MOVE.B  #'L',(A3)+
    MOVE.B  #'S',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.B  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$0,D6
    BEQ     SHIFTPRINTB
    CMP.B   #$1,D6
    BEQ     SHIFTPRINTW
    CMP.B   #$2,D6
    BEQ     SHIFTPRINTL
    RTS
ROD 
    MOVE.B  #'R',(A3)+
    MOVE.B  #'O',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.W  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$0,D6
    BEQ     SHIFTPRINTB
    CMP.B   #$1,D6
    BEQ     SHIFTPRINTW
    CMP.B   #$2,D6
    BEQ     SHIFTPRINTL
    RTS
SHIFTPRINTB
    JSR PRINTB 
    BRA SHIFTEA 
SHIFTPRINTW
    JSR PRINTW  
    BRA SHIFTEA
SHIFTPRINTL
    JSR PRINTL
    BRA SHIFTEA
SHIFTEA
    JSR PRINTOP
    MOVE.W  D5,D6
    LSL.W   #8,D6
    LSL.W   #2,D6
    LSR.W   #8,D6
    LSR.W   #7,D6
    CMP.B   #$0,D6
    BEQ     ISIMMEDIATE
    BRA     ISREGISTER
    
    RTS
ISREGISTER
    LEA TheBuffer,A3
    MOVE.B  #'D',(A3)+
    JSR PRINTREST
    RTS
ISIMMEDIATE
    LEA TheBuffer,A3
    LEA PoundSign,A1
    MOVE.B  #14,D0
    TRAP    #15
PRINTREST
    MOVE.W  D5,D6
    LSR.W   #8,D6
    LSR.W   #1,D6
    LSL.B   #4,D6
    LSR.B   #4,D6
    JSR     NumberConvert2
    MOVE.B  #',',(A3)+
    MOVE.B  #'D',(A3)+
    MOVE.W  D5,D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSL.B   #5,D6
    LSR.B   #5,D6
    JSR     NumberConvert2
    MOVE.B  #0,(A3)+
    LEA     TheBuffer,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    
    RTS
    
MEMSHIFT
    MOVE.W  D5,D6
    LSR.W   #8,D6
    LSL.B   #4,D6
    LSR.B   #5,D6 *Should be xxxx567
    CMP.B   #$0,D6
    BEQ     ASM
    CMP.B   #$1,D6
    BEQ     LSM
    CMP.B   #$3,D6
    BEQ     ROM
    JSR PRINTINVALID
    *BAD Input
    RTS
ASM
    MOVE.B  #'A',(A3)+
    MOVE.B  #'S',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.B  #'W',(A3)+
    JSR     PRINTOP
    JSR     MEMSHIFTEA
    *ea
    RTS
LSM
    MOVE.B  #'L',(A3)+
    MOVE.B  #'S',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.B  #'W',(A3)+
    JSR     PRINTOP
    JSR     MEMSHIFTEA
    *ea
    RTS
ROM
    MOVE.B  #'R',(A3)+
    MOVE.B  #'O',(A3)+
    JSR     GETDIRECTION
    MOVE.B  #'.',(A3)+
    MOVE.B  #'W',(A3)+
    JSR     PRINTOP
    JSR     MEMSHIFTEA
    *ea
    RTS
MEMSHIFTEA
    MOVE.W  D5,D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.B   #3,D6
    LSL.B   #5,D6
    LSR.B   #5,D6
    CMP.B   #$7,D6
    BEQ     ISABSOLUTE
    MOVE.B  D6,D1
    MOVE.B  D5,D6
    LSL.W   #8,D6
    LSL.W   #5,D6
    LSR.W   #8,D6
    LSR.W   #5,D6
    MOVE.B  D6,D7
    JSR     EAMODETABLE
    RTS
ISABSOLUTE
    MOVE.B  D6,D1
    MOVE.B  D5,D4
    LSL.W   #8,D4
    LSL.W   #5,D4
    LSR.W   #5,D4
    LSR.W   #8,D4
    JSR EAMODETABLE
    RTS
hexF
    JSR PRINTINVALID
    RTS
tableJumpBCC
    JMP BCC0
    JMP BCC1
    JMP BCC2
    JMP BCC3
    JMP BCC4
    JMP BCC5
    JMP BCC6
    JMP BCC7
    JMP BCC8
    JMP BCC9
    JMP BCCA
    JMP BCCB
    JMP BCCC
    JMP BCCD
    JMP BCCE
    JMP BCCF
    
BCC0 *BRA
    MOVE.B #'B',(A3)+
    MOVE.B #'R',(A3)+
    MOVE.B #'A',(A3)+
    JSR PRINTOP
    JSR PRINTBRANCHEA
    RTS
BCC1 *BSR
    JSR PRINTINVALID
    RTS
BCC2 *HI
    JSR PRINTINVALID
    RTS
BCC3 *LOWER/SAME
    JSR PRINTINVALID
    RTS
BCC4 *CARRYCLEAR
    MOVE.B #'B',(A3)+
    MOVE.B #'C',(A3)+
    MOVE.B #'C',(A3)+
    *MOVE.B #'.',(A3)+
    JSR PRINTOP
    JSR PRINTBRANCHEA
    RTS
BCC5 *CARRYSET
    JSR PRINTINVALID
    RTS
BCC6 *NOTEQUAL
    JSR PRINTINVALID
    RTS
BCC7 *EQ
    MOVE.B #'B',(A3)+
    MOVE.B #'E',(A3)+
    MOVE.B #'Q',(A3)+
    *MOVE.B #'.',(A3)+
    JSR PRINTOP
    JSR PRINTBRANCHEA
    RTS
BCC8 *OVERFLOWCLEAR
    JSR PRINTINVALID
    RTS
BCC9 *OVERFLOWSET
    JSR PRINTINVALID
    RTS
BCCA *PLUS
    JSR PRINTINVALID
    RTS
BCCB *MINUS
    JSR PRINTINVALID
    RTS
BCCC *GREATER OR EQUAL
    JSR PRINTINVALID
    RTS
BCCD *LESS THAN
    JSR PRINTINVALID
    RTS
BCCE *GREATER THAN
    MOVE.B #'B',(A3)+
    MOVE.B #'G',(A3)+
    MOVE.B #'T',(A3)+
   * MOVE.B #'.',(A3)+
    JSR PRINTOP
    JSR PRINTBRANCHEA
    RTS
BCCF *LESS OR EQUAL
    MOVE.B #'B',(A3)+
    MOVE.B #'L',(A3)+
    MOVE.B #'E',(A3)+
  *  MOVE.B #'.',(A3)+
    JSR PRINTOP
    JSR PRINTBRANCHEA
    
    RTS

getSecondPart
    *Moves value held in D5 back to D6
    MOVE.W  D5,D6
    *Get rid of the last eight bits
    LSR.W   #8,D6
    LSL.B   #4,D6 *Should be in xxxx 0000
    LSR.B   #4,D6 *Should go back to 0000 xxxx
    LEA tableJumpTwo,A2
    MULU    #6,D6
    JSR     (A2,D6.W)
    RTS
*NOT,MoveM,NOPE,JSR,RTS
tableJumpTwo
    JMP hex40
    JMP hex41
    JMP hex42
    JMP hex43
    JMP hex44
    JMP hex45
    JMP hex46
    JMP hex47
    JMP hex48
    JMP hex49
    JMP hex4A
    JMP hex4B
    JMP hex4C
    JMP hex4D
    JMP hex4E
    JMP hex4F

hex40
    JSR PRINTINVALID
    RTS
hex41
    JSR PRINTINVALID
    RTS   
hex42
    JSR PRINTINVALID
    RTS
hex43
    JSR PRINTINVALID
    RTS
hex44
    JSR PRINTINVALID
    RTS
hex45
    JSR PRINTINVALID
    RTS
*Has to be not
hex46
    MOVE.B #'N',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'T',(A3)+
    MOVE.B #'.',(A3)+
    JSR     CALCSIZE
    JSR     PRINTOP
    *Needs EA
    JSR     PRINTNOTEA
    RTS
hex47
    JSR PRINTINVALID
    RTS
*MOVEM with register to memory
hex48
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    MOVE.B #'M',(A3)+
    MOVE.B #'.',(A3)+
    JSR     CALCMOVEMSIZE
    JSR     PRINTOP
    *EA
    JSR     PRINTMOVEMEA
    RTS
hex49
    JSR PRINTINVALID
    RTS
hex4A
    JSR PRINTINVALID
    RTS
hex4B
    JSR PRINTINVALID
    RTS
*MOVEM with memory to Register
hex4C
    MOVE.B #'M',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'V',(A3)+
    MOVE.B #'E',(A3)+
    MOVE.B #'M',(A3)+
    MOVE.B #'.',(A3)+
    JSR     CALCMOVEMSIZE
    JSR     PRINTOP
    *EA
    JSR     PRINTMOVEMEA
    RTS
hex4D
    JSR PRINTINVALID
    RTS
*Can be RTS,JSR, or NOP
hex4E
    MOVE.W  D5,D6
    CMP.W   #$4E71,D6
    BEQ     CODENOP
    CMP.W   #$4E75,D6
    BEQ     CODERTS
    LSL.W  #7,D6
    LSR.W  #7,D6
    LSR.W  #6,D6
    CMP.B  #$2,D6
    BEQ    CODEJSR
    JSR PRINTINVALID
    *Bad command
     
    
    
    RTS
hex4F
    JSR PRINTINVALID
    RTS
GETDIRECTION
    MOVE.W  D5,D6
    LSR.W   #8,D6
    LSL.B   #7,D6
    LSR.B   #7,D6
    CMP.B   #$1,D6
    BEQ     JUSTL
    CMP.B   #$0,D6
    BEQ     JUSTR
    *invalid
    RTS
JUSTL
    MOVE.B  #'L',(A3)+
    RTS
JUSTR
    MOVE.B  #'R',(A3)+
    RTS
TESTOR
    MOVE.W  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$2,D6
    BLE     CODEOR
    JSR PRINTINVALID
    RTS
TESTAND
    MOVE.W  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$2,D6
    BLE     CODEAND
    JSR PRINTINVALID
    RTS
TESTSUB  
    *Sub vs SUBX?   
    MOVE.W  D5,D6
    JSR     ISOLATE9_10BITS
    CMP.B   #$2,D6
    BLE     CODESUB
    JSR PRINTINVALID
    *Invalid
    RTS
* Put program code here
CODEAND
    MOVE.B  #'A',(A3)+
    MOVE.B  #'N',(A3)+
    MOVE.B  #'D',(A3)+
    MOVE.B  #'.',(A3)+
    CMP.B  #$0,D6
    BEQ    ANDSIZEB
    CMP.B  #$1,D6
    BEQ    ANDSIZEW
    CMP.B  #$2,D6
    BEQ    ANDSIZEL

GETAND
    JSR     PRINTOP
    JSR     PRINTANDOREA  
    RTS
    
ANDSIZEB
    JSR     PRINTB
    BRA     GETAND
ANDSIZEW
    JSR     PRINTW
    BRA     GETAND
ANDSIZEL
    JSR     PRINTL
    BRA     GETAND

CODESUB
    MOVE.B  #'S',(A3)+
    MOVE.B  #'U',(A3)+
    MOVE.B  #'B',(A3)+
    MOVE.B  #'.',(A3)+
    CMP.B  #$0,D6
    BEQ    SUBSIZEB
    CMP.B  #$1,D6
    BEQ    SUBSIZEW
    CMP.B  #$2,D6
    BEQ    SUBSIZEL
    
GETSUB
    JSR     PRINTOP
    JSR     PRINTADDEA  
    RTS
    
SUBSIZEB
    JSR     PRINTB
    BRA     GETSUB
SUBSIZEW
    JSR     PRINTW
    BRA     GETSUB
SUBSIZEL
    JSR     PRINTL
    BRA     GETSUB

CODEOR 
    MOVE.B #'O',(A3)+
    MOVE.B #'R',(A3)+
    MOVE.B #'.',(A3)+
    CMP.B  #$0,D6
    BEQ    ORSIZEB
    CMP.B  #$1,D6
    BEQ    ORSIZEW
    CMP.B  #$2,D6
    BEQ    ORSIZEL
    
GETOR
    JSR     PRINTOP
    JSR     PRINTANDOREA  
    RTS
    
ORSIZEB
    JSR     PRINTB
    BRA     GETOR
ORSIZEW
    JSR     PRINTW
    BRA     GETOR
ORSIZEL
    JSR     PRINTL
    BRA     GETOR

CODENOP
    MOVE.B #'N',(A3)+
    MOVE.B #'O',(A3)+
    MOVE.B #'P',(A3)+
    JSR     PRINTOP
    RTS
CODERTS
    MOVE.B #'R',(A3)+
    MOVE.B #'T',(A3)+
    MOVE.B #'S',(A3)+  
   JSR     PRINTOP
    RTS
CODEJSR
    MOVE.B #'J',(A3)+
    MOVE.B #'S',(A3)+
    MOVE.B #'R',(A3)+
    JSR     PRINTOP
    JSR     PRINTJSREA
    RTS
CODEADDQ
    MOVE.B  #'A',(A3)+
    MOVE.B  #'D',(A3)+
    MOVE.B  #'D',(A3)+
    MOVE.B  #'Q',(A3)+
    MOVE.B  #'.',(A3)+
    CMP.B   #$0,D6
    BEQ     ADDQSIZEB
    CMP.B   #$1,D6
    BEQ     ADDQSIZEW
    CMP.B   #$2,D6
    BEQ     ADDQSIZEL
GETADDQ
    JSR     PRINTOP
    JSR     PRINTADDQEA  
    RTS
    
ADDQSIZEB
    JSR     PRINTB
    BRA     GETADDQ
ADDQSIZEW
    JSR     PRINTW
    BRA     GETADDQ
ADDQSIZEL
    JSR     PRINTL
    BRA     GETADDQ

ISOLATE9_10BITS
    *Assumming value is already in D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #6,D6
    RTS
    
ADDRESS
    MOVE.W  D5,D6
    MOVE.B  #'A',(A3)+
    MOVE.B  #'.',(A3)+
    LSR.W   #8,D6
    LSL.B   #7,D6
    LSR.B   #7,D6
    CMP.B   #$1,D6
    BEQ     ADDASIZEL
    CMP.B   #$0,D6
    BEQ     ADDASIZEW
GETADDA
    JSR     PRINTOP
    JSR     PRINTADDAEA   
    RTS
ADDASIZEW
    JSR     PRINTW
    BRA     GETADDA
ADDASIZEL
    JSR     PRINTL
    BRA     GETADDA
  
ISADDRESS
    MOVE.W  D5,D6
    LSL.W   #7,D6
    LSR.W   #7,D6
    LSR.W   #6,D6
    CMP.B   #$1,D6
    BEQ     PRINTA
    RTS
CALCSIZE
    MOVE.W D5,D6
    JSR    ISOLATE9_10BITS
    CMP.B  #$0,D6
    BEQ    PRINTB
    CMP.B  #$01,D6
    BEQ    PRINTW
    CMP.B  #$02,D6
    BEQ    PRINTL
    RTS
CALCMOVEMSIZE
    MOVE.W  D5,D6
    LSL.W   #8,D6
    LSL.W   #1,D6
    LSR.W   #8,D6
    LSR.W   #7,D6
    CMP.B   #$0,D6
    BEQ     PRINTW
    JSR     PRINTL
    RTS
    
PRINTA
    MOVE.B #'A',(A3)+
    RTS
PRINTB
    MOVE.B #'B',(A3)+
    MOVE.B #%0000,D4
    MOVE.B   D4,ImmediateDataSize
    RTS
PRINTW
    MOVE.B #'W',(A3)+
    MOVE.B #%0010,D4
    MOVE.B   D4,ImmediateDataSize
    RTS
PRINTL
    MOVE.B #'L',(A3)+
    MOVE.B #%0001,D4
    MOVE.B   D4,ImmediateDataSize
    RTS
PRINTR
    MOVE.B #'R',(A3)+
    RTS
CLRREGS
    CLR.L   D0                  
    CLR.L   D1
    CLR.L   D2
    CLR.L   D4
    CLR.L   D6
    CLR.L   D7
    RTS
PRINTOP
    MOVE.B  #9,(A3)+
    MOVE.B  #0,(A3)+
    LEA     TheBuffer,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRINTINVALID
    LEA     DollarSign,A1
    MOVE.B  #14,D0
    TRAP    #15
    LEA     TheBuffer,A3
    JSR     REVERSE
    MOVE.W  D5,D6
    JSR     HEXTOASCII2
    JSR     HEXTOASCII2
    JSR     HEXTOASCII2
    JSR     HEXTOASCII2
    MOVE.L  NEWLINE,(A3)+
    LEA     TheBuffer,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
HEXTOASCII2
 
   MOVE.B   D5,D6
   LSL.B    #4,D6
   LSR.B    #4,D6
   LSR.W    #4,D5
   CMP.B   #$A, D6     ;Compare this character with the contents of D5
   BLT     NumberConvert2   ;If it is less than A it is a number
   ADDI.B  #$37, D6    ;Convert to the character in ASCII
   MOVE.B  D6, (A3)+   ;Put this character in the string 
   RTS
NumberConvert2
   ADDI.B  #$30, D6    ;Add 30 to get the ASCII value of D5
   MOVE.B  D6, (A3)+   ;Put this character in the string 
   RTS
REVERSE
   ROR.W    #4,D5
   ROR.W    #4,D5
   ROR.W    #4,D5
   ROR.W    #4,D5
   RTS
    
*-----------EA Section------------
EAMODETABLE     
            CMP.B    #%0000,D1       *Data Register Direct
            BEQ      DNMODEPRINT
     
            CMP.B    #%0001,D1      *Address Register Direct
            BEQ      ANMODEPRINT  
         
            CMP.B    #%0010,D1      *Address Register Indirect
            BEQ      INDIRECTMODEPRINT
 
            CMP.B    #%0011,D1      *Register Indirect Address Post Inc
            BEQ      INDIRECTPOSTINCPRINT
           
            CMP.B    #%0100,D1        *Register Indirect Address Pre Dec
            BEQ      INDIRECTPREDECPRINT
           
            CMP.B    #%0000,D4         *Absolute Data Short
            BEQ      ABSOLUTESPRINT
            
            CMP.B    #%0001,D4         *Absolute Data Long
            BEQ      ABSOLUTELPRINT
            
            CMP.B   #%0100,D4          *Immediate Data
            BEQ     IMMEDIATEPRINT
           
            BRA      EAINVALIDPRINT
*MOVE
PRINTMOVEEA
*first part of ea
            JSR     CLEARDREGS
            
            JSR     SHIFTBITS0THROUGH2 *shift to figure out reg
            MOVE.B  D2,D4   
            MOVE.B  D2,D7   *stored into d7 for resgister
            
            CLR     D2
            JSR     SHIFTBITS3THROUGH5   *shift to figure out ea
            MOVE.B  D2,D1
                        
            JSR     EAMODETABLE    *print depending on values stored from shift
           
*secont part of ea          
            JSR     PRINTCOMMA  *print comma to seperate
           
            *clear for new values 
            CLR     D2
            CLR     D6
            CLR     D7
          
            JSR     SHIFTBITS6THROUGH8  *shift to figure destination
            MOVE.B  D2,D1   *ea to decode
            
            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *shift to figure out reg
            MOVE.B  D2,D4   
            MOVE.B  D2,D7   *store reg number in d7
            
            CMP.B  #%0001,D1    *invalid if an
            BEQ    EAINVALIDPRINT
            
            CMPI.B     #%0111,D1    *invlaid if immediate data
            BEQ        ADDITIONALCHECK
            
            JSR     EAMODETABLE     *if not invalid, then figure out what to print
            
            RTS 
*MOVEQ            
PRINTMOVEQEA
            JSR     CLEARDREGS

            JSR     SHIFTBITS8THROUGH15  *shift to figure out destination
            MOVE.W  D2,D1
            
            JSR     IMMEDIATEDATAPRINT   *first will be immediate data  
                        
            JSR     PRINTCOMMA
            
            JSR     SHIFTBITS9THROUGH11  *shift for reg value
            MOVE.B  D2,D7       *reg value stored at d7
                
            JSR DNMODEPRINT     *print dn          
            RTS
*MOVEA            
PRINTMOVEAEA
            JSR     CLEARDREGS 
            JSR     SHIFTBITS0THROUGH2
            MOVE.B  D2,D4   *store for comparison later
            MOVE.B  D2,D7   *store for  reg number
            
            CLR     D2
            JSR     SHIFTBITS3THROUGH5 
            MOVE.W  D2,D1  *store source to print
            
            JSR     EAMODETABLE   *figure out what source is
           
            JSR     PRINTCOMMA     
            
            CLR     D2
            CLR     D6
            CLR     D7
            JSR     SHIFTBITS6THROUGH8  *shift to figure out destination
            MOVE.B  D2,D1     *store it in d1
            
            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *shift to figure out reg number for dest
            MOVE.B  D2,D7   *store in d7
            
            CMP.B  #%0001,D1     *destination must be an
            BNE    EAINVALIDPRINT
            
            JSR     ANMODEPRINT     *print an        
            RTS
*ADD            
PRINTADDEA
            JSR     CLEARDREGS
            
            JSR     SHIFTBIT8
            
            *figure out if add to or add from
            CMPI.B  #%0000,D2   
            BEQ     GETADDTO

            CMPI.B  #%0001,D2
            BEQ     GETADDFROM

GETADDTO
            CLR D2
            JSR     SHIFTBITS0THROUGH2  *shift to figure out source
            MOVE.B  D2,D4   
            MOVE.B  D2,D7  *store source
            
            CLR     D2
            JSR     SHIFTBITS3THROUGH5 *shift to figure out reg number of source
            MOVE.W  D2,D1   *store in d1

            JSR     EAMODETABLE      *go to ea table to figure out what to print for source        
            
            JSR     PRINTCOMMA  
            
            JSR     SHIFTBITS9THROUGH11 *figure out dest number
            MOVE.B  D2,D7   
            
            JSR     DNMODEPRINT      *print dn      
            RTS    
 
GETADDFROM
            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *figure out reg number of destination
            MOVE.B  D2,D7  *store in d7
            
            JSR     DNMODEPRINT *print dn
            
            JSR     PRINTCOMMA
            
            CLR     D2
            JSR     SHIFTBITS0THROUGH2  *figure out source 
            MOVE.B  D2,D4   
            MOVE.B  D2,D7
                    
            CLR     D2
            JSR     SHIFTBITS3THROUGH5 *shift to figure out reg number of source
            MOVE.W  D2,D1

            CMP.B   #%0001,D1   *an invalid
            BEQ     EAINVALIDPRINT
            
            CMPI.B     #%0100,D4     *pre invalid
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE     *print depending on what the source is     
            
            RTS   
*ADDA
PRINTADDAEA
            JSR     CLEARDREGS
            JSR     SHIFTBITS0THROUGH2  * get source
            MOVE.B  D2,D4   
            MOVE.B  D2,D7   
            
            CLR     D2
            JSR     SHIFTBITS3THROUGH5  *shift for reg number of source
            MOVE.B  D2,D1   *store it in d1
            
            JSR     EAMODETABLE    *jump to ea mode table sub routine
           
            JSR     PRINTCOMMA        

            *clear for new values
            CLR     D2      
            CLR     D6
            CLR     D7
            JSR     SHIFTBITS9THROUGH11 *shift for dest number
            MOVE.B  D2,D7   *destination
            
            JSR     ANMODEPRINT *print an
            RTS 
*ADDQ
PRINTADDQEA
            JSR     SHIFTBITS9THROUGH11 *figure out source
            MOVE.B  D2,D1   
                      
            LEA     PoundSign,A1  *pound
            MOVE.B  #14,D0
            TRAP    #15
                              
            JSR     TRAPPRINT     *print values
      
            JSR     PRINTCOMMA
            
            JSR     SHIFTBITS3THROUGH5  *shift to figure out destination
            MOVE.B  D2,D1   
            
            CLR     D2
            JSR     SHIFTBITS0THROUGH2  *shift to figure out reg number of dest
            MOVE.B  D2,D4   
            MOVE.B  D2,D7  
            
            CMPI.B     #%0100,D4    *pre invalid
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE    *jump to ea table to figure out what to print   
            RTS                                       
*LEA            
PRINTLEAEA
            JSR     CLEARDREGS
            JSR     SHIFTBITS0THROUGH2
            MOVE.B  D2,D4
            MOVE.B  D2,D7

            CLR     D2 
            JSR     SHIFTBITS3THROUGH5
            MOVE.B  D2,D1 

            CMP.B   #%0000,D1
            BEQ     EAINVALIDPRINT

            CMP.B   #%0001,D1
            BEQ     EAINVALIDPRINT

            CMP.B   #%0011,D1
            BEQ     EAINVALIDPRINT

            CMP.B   #%0100,D1
            BEQ     EAINVALIDPRINT

            CMP.B   #%0111,D1
            BEQ     ADDITIONALCHECK

            JSR     EAMODETABLE

            JSR     PRINTCOMMA

            CLR     D2
            JSR     SHIFTBITS9THROUGH11
            MOVE.B  D2,D7

            JSR    ANMODEPRINT
            RTS   *if not absolute value, then invalid     

LEAABSOLUTESPRINT
*first part of ea
            LEA     DollarSign,A1   *dollar sign
            MOVE.B  #14,D0
            TRAP    #15   

            ADD.W   #2, D3      *abs word, add to current address counter
            MOVEA.L  D3, A2
            MOVE.W  (A2),D1     *get value to print
            
            JSR     TRAPPRINT   *print
            CLR     D1

*second part of ea
            JSR     PRINTCOMMA 

            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *figure out destination 
            MOVE.B  D2,D7   *stores an value
            
            JSR     ANMODEPRINT  *print a#
            
            RTS     

LEAABSOLUTELPRINT
*first part of ea
            LEA     DollarSign,A1   *print dollar sign
            MOVE.B  #14,D0
            TRAP    #15   

            ADD.W   #2, D3      *store long, increase address counter
            MOVEA.L  D3, A2
            MOVE.L  (A2),D1     *get value 
            
            JSR     TRAPPRINT   *print value
            CLR.L     D1

*second part of ea
            JSR     PRINTCOMMA 

            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *get destination reg number
            MOVE.B  D2,D7   *stores an value
            
            JSR     ANMODEPRINT  *print a#
            
            RTS
*AND/OR
PRINTANDOREA
            JSR     CLEARDREGS
            JSR     SHIFTBIT8 *shift to figour out what is source and dest
            
            *figur out if from or to
            CMPI.B  #%0000,D2
            BEQ     GETANDORTO

            CMPI.B  #%0001,D2   *an invalid
            BEQ     GETANDORFROM

GETANDORTO
            CLR D2
            JSR     SHIFTBITS0THROUGH2  *shift to figure out source number
            MOVE.B  D2,D4   
            MOVE.B  D2,D7   
            
            CLR     D2
            JSR     SHIFTBITS3THROUGH5  *figure out what source is
            MOVE.B  D2,D1   
            
            CMP.B   #%0001,D1     *an invalid
            BEQ     ANDORFAIL

            JSR     EAMODETABLE     *print depending on d1 source
            
            JSR     PRINTCOMMA
            
            JSR     SHIFTBITS9THROUGH11
            MOVE.B  D2,D7   *reg of destination 
    
            JSR     DNMODEPRINT   *print dn      
            RTS    
            
ANDORFAIL
            *print invalid and contiune
            JSR     EAINVALIDPRINT
            BRA      ANDORCONTINUE 
            
ANDORCONTINUE            
            JSR     PRINTCOMMA
            
            JSR     SHIFTBITS9THROUGH11 *shift to figoure out dest num
            MOVE.B  D2,D7   *reg of destination 
            JSR     DNMODEPRINT    *print dn  
            RTS     
                         
GETANDORFROM
            CLR     D2
            JSR     SHIFTBITS9THROUGH11 *get dest number
            MOVE.B  D2,D7   *store dest number
            
            JSR     DNMODEPRINT     *print dn
            
            JSR     PRINTCOMMA
            
            CLR D2
            JSR     SHIFTBITS0THROUGH2  *shift to figure out source number
            MOVE.B  D2,D4   
            MOVE.B  D2,D7   

            CLR     D2
            JSR     SHIFTBITS3THROUGH5  *figure out source
            MOVE.B  D2,D1   

            CMP.B   #%0001,D1     *an invaild
            BEQ     EAINVALIDPRINT
            
            CMPI.B     #%0100,D4      *pre invalid
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE    *jump to ea table to print         
            
            RTS
*NOT            
PRINTNOTEA
            JSR     CLEARDREGS    
            JSR     SHIFTBITS0THROUGH2  *shift to figure out source reg number
            MOVE.B  D2,D4   
            MOVE.B  D2,D7 
                       
            CLR     D2
            JSR     SHIFTBITS3THROUGH5  *shift to figure out source
            MOVE.B  D2,D1   *store in d1
            
            CMP.B   #%0001,D1   *an invalid
            BEQ     EAINVALIDPRINT
            
            CMPI.B     #%0100,D4    *pre invalid
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE  *jump to ea table and print depending on d1 value
            RTS     
*MOVEM            
PRINTMOVEMEA
            MOVE.B  #%0000,SLASHCOUNTER
            JSR     CLEARDREGS

            JSR     SHIFTBITS3THROUGH5
            MOVE.B  D2,D1   *store Destination Mode into D3
            *ADD.W   #$2,D3
            
            CLR     D2
            JSR     SHIFTBIT10
                      
            CMPI.B  #%0000,D2
            BEQ     MovemRegFirst
            *otherwise we print the registers second
            
            CLR     D2
            JSR     SHIFTBITS0THROUGH2
            MOVE.B  D2,D4   *store Destination source into D4
            MOVE.B  D2,D7
            
            MOVE.W  (A2)+,REGISTERS     
          
            CMP.B   #%0000,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0001,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0100,D1
            BEQ     EAINVALIDPRINT
            
            CMPI.B     #%0100,D4
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE        *Print the source ea
            
            BRA     MovemRegSecondHalfTwo
            
MovemRegSecondHalfTwo        
            JSR     PRINTCOMMA
            
            JSR     LOOPSETUP
MovemRegMaskLoop
            MOVE.W  REGISTERS,D2
            JSR     SHIFTBIT15 
            
            CMPI.B  #0000,D2
            BEQ     NextIteration
            
            CMPI.B  #7,D4   
            BGT     MovemDnOUTPUT
            
            *check that we have already printed data. if we havent then we branch to set flag to 0001
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     AddressOUTPUTFlagSet
            
            JSR     PRINTSLASH
            
AddressOUTPUTFlagReturn            
            MOVE.B  NUMADDRESS,D7
            JSR     ANMODEPRINT
            
NextIteration
            ADDI.B  #1,D4           
            SUBI.B  #1,NUMADDRESS
            
            CMPI.B  #15,D4
            BLE     MovemRegMaskLoop    *Go back to the start of the loop
            
            RTS                       
MovemDnOUTPUT
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     MovemDnOUTPUTFlagSet
            
            *Print the slash
            JSR     PRINTSLASH
            
DnOUTPUTFlagReturn
            MOVE.B  ANDNCOUNTER,D7
            JSR     DNMODEPRINT    
            
            SUBI.B  #1,ANDNCOUNTER
            BRA     NextIteration        
             
MovemRegFirst
            MOVE.W  (A2)+,REGISTERS
            ADD.W   #$2,D3
            
            CMP.B   #%0011,D1
            BNE     PreDecrementMoveM
            
            BRA     PostIncrementMoveM            
MovemRegFirstSecondHalf
            JSR     PRINTCOMMA
            
            CLR     D2
            CLR.L   D4
            JSR     SHIFTBITS0THROUGH2
            MOVE.B  D2,D7   *store Destination source into D4
            
            CMP.B   #$7,D1
            BEQ     MOVEMIMMEDIATE
            CMP.B   #%0000,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0001,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0100,D1
            BEQ     EAINVALIDPRINT
            
            CMPI.B     #%0011,D4
            BEQ        EAINVALIDPRINT
            
            JSR     EAMODETABLE    
            RTS                 
MOVEMIMMEDIATE
    MOVE.B  D2,D4
    JSR EAMODETABLE
    RTS
PostIncrementMoveM            
            JSR     LOOPSETUP
            
PostMovemRegMaskLoop
            MOVE.W  REGISTERS,D2
            JSR     SHIFTBIT15 
            
            CMPI.B  #0000,D2
            BEQ     PostNextIteration
            
            CMPI.B  #7,D4   *check that we don't need to do data registers yet
            BGT     PostMovemDnOUTPUT
            
            *Check the slash flag
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     PostMovemAnOUTPUTFlagSet
            
            *Print the slash
            JSR     PRINTSLASH
            
PostAnOUTPUTFlagReturn
            MOVE.B  NUMADDRESS,D7
            JSR     ANMODEPRINT
            
PostNextIteration
            ADDI.B  #1,D4
            SUBI.B  #1,NUMADDRESS
            
            CMPI.B  #15,D4
            BLE     PostMovemRegMaskLoop    *Go back to the start of the loop
            
            BRA     MovemRegFirstSecondHalf *Go and print the second half
                    
PostMovemDnOUTPUT
            *Check the slash flag
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     PostMovemDnOUTPUTFlagSet
            
            *Print the slash
            JSR     PRINTSLASH
            
PostDnOUTPUTFlagReturn
            MOVE.B  ANDNCOUNTER,D7
            JSR     DNMODEPRINT
            SUBI.B  #1,ANDNCOUNTER
            BRA     PostNextIteration  
      
PreDecrementMoveM       
*counters     
            MOVE.B  #0,D4 
            MOVE.B  #0,ANDNCOUNTER
            
PreMovemRegMaskLoop
            MOVE.W  REGISTERS,D2
            JSR     SHIFTBIT15 
            
            CMPI.B  #7,D4   *check that we don't need to do data registers yet
            BGT     PreMovemAnOUTPUT
            
            CMPI.B  #0000,D2
            BEQ     PreNextIteration
            
            *Check the slash flag
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     PreMovemDnOUTPUTFlagSet
            
            *Print the slash
            JSR     PRINTSLASH
            
PreDnOUTPUTFlagReturn
            MOVE.B  D4,D7
            JSR     DNMODEPRINT
            
PreNextIteration
            ADDI.B  #1,D4          
            CMPI.B  #15,D4
            BLE     PreMovemRegMaskLoop    *Go back to the start of the loop
            
            BRA     MovemRegFirstSecondHalf     *Once greater than we need to print the second half of the EA
                    
PreMovemAnOUTPUT
            *If we can't print anything we need to increment address register
            CMPI.B  #0000,D2
            BEQ     IncrementAddressRegister
            
             *Check the slash flag
            CMPI.B  #%0000,SLASHCOUNTER
            BEQ     PreMovemAnOUTPUTFlagSet
            
            *Print the slash
            JSR     PRINTSLASH
            
PreAnOUTPUTFlagReturn
            MOVE.B  ANDNCOUNTER,D7
            JSR     ANMODEPRINT
            ADDI.B  #1,ANDNCOUNTER
            BRA     PreNextIteration  
      
IncrementAddressRegister
            ADDI.B  #1,ANDNCOUNTER
            BRA     PreNextIteration  
*Beneath are flag sets for SLASH
AddressOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     AddressOUTPUTFlagReturn
MovemDnOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     DnOUTPUTFlagReturn
PostMovemAnOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     PostAnOUTPUTFlagReturn            
PostMovemDnOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     PostDnOUTPUTFlagReturn    
PreMovemDnOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     PreDnOUTPUTFlagReturn 
PreMovemAnOUTPUTFlagSet
            MOVE.B  #%0001,SLASHCOUNTER
            BRA     PreAnOUTPUTFlagReturn   
*BRA
PRINTBRANCHEA
            JSR     CLEARDREGS

            JSR     SHIFTBITS8THROUGH15 *shift to figure out what to do
            MOVE.W  D2,D1
            
            JSR     OTHERBRANCHCHECK    *check for different branch
            
            *extend data register -> word/long
            EXT.W   D1      
            EXT.L   D1
            ADD.L   D3,D1
            
            JSR     PRINTDOLLAR            
            JSR     TRAPPRINT
  
            CLR.L   D1
            RTS                 
OTHERBRANCHCHECK
            CMPI.W  #$0000,D1
            BEQ     BRANCHCONTINUELONG
            
            CMPI.W  #$00FF,D1
            BEQ     BRANCHCONTINUEWORD
BRANCHCONTINUELONG
            ADDA.L   #2,A2
            MOVE.L   (A2)+,D1    *read the next long
           
            ADD.L    A5,D1
            JSR     PRINTDOLLAR
            JSR     TRAPPRINT
            
            CLR.L   D1
            RTS                
BRANCHCONTINUEWORD          
            
            *Now we need to read absolute address (Word)
            MOVE.W  (A2)+,D1     *STORE ABSOLUTE ADDRESS for printing
            
            EXT.L   D1  *extend data reg to long
            ADD.L  A5,D1
            ADDI.B  #2,D1   *2 bytes for the instruction
            
            JSR     PRINTDOLLAR
            JSR     TRAPPRINT

            CLR.L   D1
            RTS
*JSR
PRINTJSREA
            JSR     CLEARDREGS
            JSR     SHIFTBITS0THROUGH2  *shift to get source
            MOVE.B  D2,D4   
            MOVE.B  D2,D7
                      
            CLR     D2                     
            JSR     SHIFTBITS3THROUGH5
            MOVE.B  D2,D1   *destination to d1
            
            CMP.B   #%0000,D1
            BEQ     EAINVALIDPRINT  *not dn
            
            CMP.B   #%0001,D1
            BEQ     EAINVALIDPRINT  *not dn
            
            CMP.B   #%0011,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0100,D1
            BEQ     EAINVALIDPRINT
            
            CMP.B   #%0111,D1
            BEQ     ADDITIONALCHECK *check for immediate
            
            JSR     EAMODETABLE
            RTS
                               
      
*-------------SUB ROUTINES FOR SHIFTING EA--------------
SHIFTBITS0THROUGH2
            MOVE.W  D5,D2
            MOVE.B  #13,D6  *prepare shift 13 bits
            LSL.W   D6,D2   *shift left
            LSR.W   D6,D2   *shift right to the front 
            
            RTS
            
SHIFTBITS3THROUGH5
            MOVE.W   D5,D2
            MOVE.B  #10,D0  *prepare shit 10 bits 
            LSL.W   D0,D2   *left shift
            MOVE.B  #13,D0  *prepare shift 13 bits
            LSR.W   D0,D2   *shift right to front
            
            RTS
SHIFTBITS6THROUGH8
            MOVE.W  D5,D2  
            LSL.W   #7,D2   *shift 7 bits
            MOVE.B  #13,D0  *prepare 13 bits shift
            LSR.W   D0,D2   *shift it right 13 bits
            
            RTS
            
SHIFTBITS9THROUGH11
            MOVE.W  D5,D2
            LSL.W   #4,D2   *shift left 4 bits
            MOVE.B  #13,D0  *prepare 13 bits shift
            LSR.W   D0,D2   *shift right
            
            RTS
            
SHIFTBITS8THROUGH15
            MOVE.W  D5,D2           
            MOVE.B  #8,D0   *prepare 8 bits shift
            LSL.W   D0,D2   *shift left 8
            LSR.W   D0,D2   *shift right 8
            
            RTS
SHIFTBIT8    
            MOVE.W  D5,D2
            LSL.W   #7,D2   *7 bit shift left
            MOVE.B  #15,D0  *prepare 15 bit shift
            LSR.W   D0,D2   *shift right

            RTS
SHIFTBIT10             
            MOVE.W  D5,D2   
            LSL.W   #5,D2   *5 bit shift left
            MOVE.B  #15,D0  *prepare 15 bits shift
            LSR.W   D0,D2   *shift right

            RTS 
SHIFTBIT15
            LSL.W   D4,D2   *shhift left of D4
            MOVE.B  #15,D0  *prepare 15bits shift
            LSR.W   D0,D2   *shift right
                  
            RTS   
CLEARDREGS
*clear up for ea decode 
            CLR     D2
            CLR     D4
            CLR     D6
            CLR     D7
            
            RTS
*-------------SUB ROUTINES FOR PRINTING EA--------------
DNMODEPRINT
            LEA     DMode,A1  *print D for Dn mode
            MOVE.B  #14,D0
            TRAP    #15
            
            JSR     GETREG
            
            RTS
            
ANMODEPRINT
            LEA     AMode,A1  *print A for An mode
            MOVE.B  #14,D0
            TRAP    #15
            
            JSR     GETREG      *then get register
                    
            RTS
            
INDIRECTMODEPRINT
            LEA     OpenParSign,A1  *open parentheses
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     AMode,A1  *print A for An mode
            MOVE.B  #14,D0
            TRAP    #15
            
            JSR     GETREG      *then get register
            
            LEA     ClosedParSign,A1  *close parentheses
            MOVE.B  #14,D0
            TRAP    #15
                    
            RTS
            
INDIRECTPOSTINCPRINT
            LEA     OpenParSign,A1  *open parentheses
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     AMode,A1  *print A for An mode
            MOVE.B  #14,D0
            TRAP    #15

            JSR     GETREG
            
            LEA     ClosedParSign,A1  *close parentheses
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     PlusSign,A1  *plus sign for inc
            MOVE.B  #14,D0
            TRAP    #15

            RTS
            
INDIRECTPREDECPRINT
            LEA     MinusSign,A1  *minus sign for dec
            MOVE.B  #14,D0
            TRAP    #15

            LEA     OpenParSign,A1  *open parentheses
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     AMode,A1  *print A for An mode
            MOVE.B  #14,D0
            TRAP    #15

            JSR     GETREG
            
            LEA     ClosedParSign,A1  *close parentheses
            MOVE.B  #14,D0
            TRAP    #15

            RTS
            
IMMEDIATEPRINT
            LEA     PoundSign,A1  *print pound
            MOVE.B  #14,D0
            TRAP    #15
            
            CMP.B   #%0010,ImmediateDataSize    *branch to immediate word depending on stored size
            BEQ     IMMEDIATEWORD
            
            BRA     IMMEDIATELONG   *if not word it is a long
            
IMMEDIATEWORD
            ADD.W   #$2,D3
            MOVEA.L D3,A2
            MOVE.W  (A2),D1     *word to print
            
            JSR     PRINTIMMEDIATE        *print
            CLR.L   D1
            RTS
            
IMMEDIATELONG
            ADD.W   #$2,D3
            MOVEA.L D3,A2
            MOVE.L  (A2),D1     *word to print
            
            JSR     PRINTIMMEDIATE   
            ADD.W   #$2,D3 
            CLR.L    D1
            RTS
 
PRINTIMMEDIATE
            LEA     DollarSign,A1  *dollar
            MOVE.B  #14,D0
            TRAP    #15
            MOVEQ   #15,D0
            MOVEQ  #16,D2
            TRAP    #15
            RTS           
IMMEDIATEDATAPRINT
            LEA     PoundSign,A1  *pound
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     DollarSign,A1  *dollar
            MOVE.B  #14,D0
            TRAP    #15
                                
            JSR TRAPPRINT   *print  stored word
            RTS
            
ABSOLUTESPRINT
*first part of ea
            LEA     DollarSign,A1   *dollar sign to print
            MOVE.B  #14,D0
            TRAP    #15   

            ADD.W   #2, D3      *abs word
            MOVEA.L  D3, A2
            MOVE.W  (A2),D1     
            
            JSR     TRAPPRINT   *print value
            CLR     D1
            
            RTS     

ABSOLUTELPRINT
*first part of ea
            LEA     DollarSign,A1   *dollar sign to print
            MOVE.B  #14,D0
            TRAP    #15   

            ADD.W   #2, D3      *store long
            MOVEA.L  D3, A2     
            MOVE.L  (A2),D1     
            ADD.W   #2, D3      *for current address

            JSR     TRAPPRINT   *print value
            CLR.L     D1
            
            RTS   
            
ADDITIONALCHECK
            CMPI.B     #%0100,D4
            BEQ        EAINVALIDPRINT
            BRA        EAMODETABLE 
            RTS
            
GETREG
            MOVE.B  #15,D0
            MOVE.B  D7,D1   *move register value to d1 to print
            MOVE.B  #16,D2
            TRAP    #15     *print
            
            RTS
            
EAINVALIDPRINT
            LEA     InvalidEAPrint,A1  *print invalid 
            MOVE.B  #14,D0
            TRAP    #15     *print
            
            RTS
            
PRINTCOMMA
            LEA     Comma,A1  *print commma
            MOVE.B  #14,D0
            TRAP    #15 
            
            RTS
PRINTSLASH
            LEA     SlashSign,A1  *slash to print
            MOVE.B  #14,D0
            TRAP    #15     *print
                
            RTS      
PRINTDOLLAR
            LEA     DollarSign,A1  *print dollar
            MOVE.B  #14,D0
            TRAP    #15 

            RTS      
LOOPSETUP
            CLR     D4  
            CLR     D7
            MOVE.B  #0,D4 *loop counter
            MOVE.B  #7,ANDNCOUNTER *an dn counter
            MOVE.B  #7,NUMADDRESS *an
            
            RTS
CHECKLOOP
            CMPI.B  #%0000,D2
            BEQ     NextIteration
            
            CMPI.B  #7,D4   
            BGT     MovemDnOUTPUT 
            
            RTS
TRAPPRINT
*first trap print
            MOVEQ   #15,D0
            MOVEQ  #16,D2
            TRAP    #15
            
            RTS
            
TRAPPRINTTWO
*second trap print
            MOVEQ   #15,D0
            MOVEQ  #10,D2
            TRAP    #15
            
            RTS
*-------------EA Variables--------------
DMode          DC.B    'D',0
AMode           DC.B    'A',0
PlusSign       DC.B    '+',0
MinusSign      DC.B    '-',0
OpenParSign     DC.B    '(',0
ClosedParSign     DC.B    ')',0
SlashSign      DC.B    '/',0
SLASHCOUNTER       DS.B    1 
PoundSign       DC.B    '#',0
DollarSign     DC.B    '$',0
Comma      DC.B    ',',0
Space      DC.B    ' ',0
ImmediateDataSize     DC.B    %0000
InvalidEAPrint  DC.B    'INVALID EA',0
REGISTERS       DS.W    1
ANDNCOUNTER   DS.W    1
NUMADDRESS   DS.W    1
   

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
ConvertFail DC.B    'Failed to convert because user inputted invalid character. Restarting...', CR, LF, 0
ExitMsg     DC.B    'Thank you for using our disassembler! Exiting...', CR, LF, 0 
NEWLINE     DC.L    CR,LF,0


    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
