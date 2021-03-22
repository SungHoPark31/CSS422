*-----------------------------------------------------------
* Title      : Input/Branching
* Written by : Sung Ho Park 
* Date       : 1/25/21
* Description: 
*-----------------------------------------------------------
CR      EQU     $0D 
LF      EQU     $0A

START:  ORG     $1000
   
*-------Code for output-------
LOOP    LEA     Message, A1
        MOVE.B  #14, D0
        TRAP    #15
        
*-------Code for input--------
        MOVE.B  #4, D0          *Trap #14 will do the input
        TRAP    #15
        CMP.L   #19978, D1      *Compares the student ID 19978 to the input 
        BEQ     DONE            *Branch to DONE if they are the same
        
        CMP.B   #20, D1         *Compare D1 input created by Trap#4 to 0
        BLT     INVALID         *Branches if less than 20
        CMP.B   #25, D1         *Compare D1 input to 25
        BGT     INVALID         *Branches if greater than 25
        
  
*-------Code for distinct messages-------
        CMP.B   #20, D1         *Compares 20 to D1 first and check
        BNE     TwoOne          *Go to 21 if not equal
        LEA     NUM20, A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP
        
TwoOne  CMP.B   #21, D1         *Compares 21 to D1
        BNE     TwoTwo          *Go to 22 if not equal
        LEA     NUM21, A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP
        
TwoTwo  CMP.B   #22, D1         *Compares 22 to D1
        BNE     TwoThr          *Go to 23 if not equal
        LEA     NUM22,A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP
        
TwoThr  CMP.B   #23, D1         *Compares 23 to D1
        BNE     TwoFou          *Go to 24 if not equal
        LEA     NUM23, A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP

TwoFou  CMP.B   #24, D1         *Compares 24 to D1
        BNE     TwoFiv          *Go to 25 if not equal
        LEA     NUM24, A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP
        
TwoFiv  CMP.B   #20, D1         *Compares 20 to D1
        LEA     NUM20, A1
        MOVE.B  #14, D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP

INVALID LEA     INV, A1
        MOVE.B  #14,D0         *Move #14 to data register
        TRAP    #15
        BRA     LOOP
        
DONE    MOVE.B  #9, D0          *Halt simulator
        TRAP    #15
        
Message DC.B    'Enter a number between 20 and 25 (Enter student ID to exit): ', 0
INV     DC.B    'This is not a number between 20 and 25', CR, LF, 0
NUM20   DC.B    'You have 20 missed calls.', CR, LF, 0
NUM21   DC.B    'You will be 21 this year.', CR, LF, 0
NUM22   DC.B    'Stop what you are doing and watch 22 jump street', CR, LF, 0
NUM23   DC.B    '23 is a random number. I cannot think of anything', CR, LF, 0
NUM24   DC.B    '24 is a funny number', CR, LF, 0
NUM25   DC.B    'But do you know what is funnier than 24? 25!', CR, LF, 0

    END    START       

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
