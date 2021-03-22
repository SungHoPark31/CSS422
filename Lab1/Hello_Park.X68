*-----------------------------------------------------------
* Title      : Hello_Park
* Written by : Sung Ho Park
* Date       : 1/24/21
* Description: Lab 1
*-----------------------------------------------------------
    ORG    $1000
START:               
*-------Code for output---------   
        LEA     MESSAGE, A1     *Loads the constant message into address register, A1
        MOVE.B  #14, D0         *Moves the number 14 to data register 0
        TRAP    #15             *Displays the message
    
        MOVE.B  #9, D0          *Move the number 9 to D0
        TRAP    #15             *Displays the message
        
CR      EQU     $0D             *ASCII code for carriage return
LF      EQU     $0A             *ASCII code for line feed
    
MESSAGE DC.B    'Hello, My name is Sung Ho Park', CR, LF
        DC.B    'This Program took me 5 minutes to finish, and I hope you enjoy the 68k programming', CR, LF, CR, LF
        DC.B    'Thank you for listening.', 0

        END     START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
