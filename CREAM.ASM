;              ***** CREAM-MUSIC-SCREEN was assembled with *****        
;                  **** SNES Cross Assembler V 1.05 ****
;                        **** a very old one.. ****
        
        org     $8000
        nam     CREAM-DEMO

start:
        clc                     ; Into native mode
        xce                     ; NO 6502 Emulation !
        sei                     ; disable irq's
        rep     #$10            ; set X+Y to 16 bit
        sep     #$20            ; and set accum to 8 bit
        ply                     ; return address
        ldx.v   #$01ff          ; and set up the stack
        txs                     ; to top of lo-ram
        phy                     ; back on stack
        lda     #$00            ; clear the top byte of the accum
        xba                     ; by swapping it up...just to be sure
        lda     #$00
        pha
        plb                     ; set the data bank register to 0
        lda     #$00            ; set direct register to zero
        tcd

        jsr     init_vic
        jsr     set_hdma
        jsr     set_mode1
        jsr     music_init

        sep     #$30            ;all registers to 8 bit        
        rep     #$10            ;x + y reg. back to 16 bit (acc.stays 8)
        lda.b   #$32            ;choose opening tune
        jsr     select_music    ;            ..
        sep     #$30
        stz     $200            ;scrollcounter
        stz     $201            ;textcounter
        stz     $202            ;     ..
        stz     $203            ;bounce counter
        stz     $204            ;bounce2 x counter
        stz     $205            ;bounce2 x counter2
        stz     $206            ;bounce3 y counter
        lda.b   #$20            ;loads opening value (music)
        sta     $20a            ;music counter
        stz     $20b            ;parameteradress
        stz     $20c            ;button still pressed?-indicator
        stz     $20d            ;turnoffmusic indicator
        lda     #$0f
        sta     $2100           ;turn on screen, full brightness
        lda     #$81
        sta     $4200           ;enable interrupt and joypadread
        cli                     ;clear interrupt-flag    

label:
        sep     #$30
        lda     $20d            ;is y-button being pressed?
        bne     label2          ;yes? then go to label2    
        lda     $20b            ;is b-button being pressed?
        beq     label           ;no? then jump label
        stz     $20b            ;set it to zero
        ldx     $20a            ;which music is to be played ?
        lda     music_tab,x     ;get the right tune out of music_tab
        rep     #$10
        jsr     select_music    ;and play it
        jmp     label

label2:
        sep     #$30
        stz     $20d            ;set it to zero
        rep     #$10            
        lda     #$30            ;$30 makes the music silent
        jsr     select_music
        jmp     label
loop:   
        rep     #$10            ;x+y reg. 16 bit
        ldx.v   #$130b          ;music-number appears here
        stx     $2116
        sep     #$30            ;all reg. 8 bit
        lda     $20a            ;which music is to be displayed ?
        asl                     ;multiply with 2
        tax
        lda     music_tab2,x    ;get it out of music_tab2
        sta     $2118           ;and display first digit
        stz     $2119
        inx
        lda     music_tab2,x
        sta     $2118           ;now the second digit
        stz     $2119
        rts

joy_read:
        sep     #$30          
        lda     $4212           ;is joypad ready to be read ?
        and     #$01
        bne     joy_read        ;no? then go back  
        lda     $4219
        cmp     $20c            ;button still pressed?
        beq     no_up           ;well, then exit immediatly
        stz     $20c            ;clear buttonstillpressed
nopr:        
        lda     $4212           ;joypad ready to be read ?
        and     #$01
        bne     nopr
        lda     $4219           ;read joypad
        and     #$40            ;leave only "y"-bit
        beq     no_y            ;if result is zero then branch
        sta     $20c            ;store result to test later
        inc     $20d            ;shows other routine that there`s work to do
        rts
no_y:        
        lda     $4212           
        and     #$01
        bne     no_y
        lda     $4219
        and     #$80            ;leave only "b"-bit
        beq     no_b            ;not pressed? well, branch !
        sta     $20c            ;store result
        inc     $20b            ;shows other routine that there`s work to do
        rts
no_b:        
        lda     $4212   
        and     #$01
        bne     no_b
        lda     $4219
        and     #$04            ;leave "down"-bit
        beq     no_down         
        sta     $20c     
        lda     $20a            ;load music-indicator
        beq     no_up           ;already zero? then, do nothing !
        dec     $20a            ;count music-indicator one down
        rts

no_down:
        lda     $4212   
        and     #$01
        bne     no_down
        lda     $4219
        and     #$08            ;up?
        beq     no_up
        sta     $20c     
        lda     $20a            ;get value of music-indicator
        cmp     #$2a            ;did it exeed HEX 2a?
        beq     no_up           ;yes? then do nothing at all
        inc     $20a            ;increment music-indicator by one
no_up:  rts

music_init:
        sep     #$30
        rep     #$10
        lda.b   #$00
        ldy.v   #$00f9          ;i'm not sure about that parameter...
        jsr     init            ;maybe it shows to play tune in foreground
        lda.b   #$01
        ldy.v   #$00f9
        jsr     init
        lda.b   #$02
        ldy.v   #$00f9
        jsr     init
        rts
init:        
        dcb $08,$84,$02,$C2,$30,$29,$FF
        dcb $00,$C9,$10,$00,$90,$01,$1A,$85,$00,$0A,$65,$00,$AA,$BF,$00,$80
        dcb $01,$29,$FF,$7F,$A8,$A9,$00,$80,$85,$10,$E2,$20,$BF,$02,$80,$01
       ;     ^^                                                          ^^
        dcb $EA,$EA,$85,$12,$8A,$F0,$0E,$AF,$FB,$FF,$7E,$CD,$42,$21,$D0,$FB
        dcb $A5,$02,$8D,$40,$21,$C2,$20,$A9,$AA,$BB,$CD,$40,$21,$D0,$FB,$E2
        dcb $20,$A9,$CC,$80,$34,$B7,$10,$C8,$10,$05,$A0,$00,$00,$E6,$12,$EB
        dcb $A9,$00,$80,$12,$EB,$B7,$10,$C8,$10,$05,$A0,$00,$00,$E6,$12,$EB
        dcb $CD,$40,$21,$D0,$FB,$1A,$C2,$20,$8D,$40,$21,$E2,$20,$CA,$D0,$E4
        dcb $CD,$40,$21,$D0,$FB,$69,$03,$F0,$FC,$48,$B7,$10,$EB,$C8,$10,$05
        dcb $A0,$00,$00,$E6,$12,$B7,$10,$EB,$AA,$C8,$10,$05,$A0,$00,$00,$E6
        dcb $12,$B7,$10,$EB,$C8,$10,$05,$A0,$00,$00,$E6,$12,$B7,$10,$8D,$43
        dcb $21,$C8,$10,$05,$A0,$00,$00,$E6,$12,$EB,$8D,$42,$21,$E0,$01,$00
        dcb $A9,$00,$2A,$8D,$41,$21,$69,$7F,$68,$8D,$40,$21,$CD,$40,$21,$D0
        dcb $FB,$70,$82,$E2,$30,$A9,$01,$8F,$FB,$FF,$7E,$A2,$3F,$9E,$C0,$03
        dcb $CA,$10,$FA,$9C,$B6,$00,$9C,$B5,$00,$28,$60
select_music:
        dcb $EB,$AF,$FD,$FF,$7E
        dcb $8F,$FE,$FF,$7E,$EB,$8F,$FD,$FF,$7E,$A0,$FA,$00
        jsr     init
        rts             ;i cutted the sfx part out of that routine


set_mode1:
        sep     #$30
        lda     #$00
        sta     $210b ;charset of playfield 0/1 to vram $0000
        lda     #$00
        sta     $210c ;charset of playfield 2/3 to vram $0000
        lda     #$10
        sta     $2107 ;playfield 1 (0) to $1000 into vram
        lda     #$20
        sta     $2108 ;playfield 2 (1) to $2000 into vram
        lda     #$30
        sta     $2109 ;          3 (2)    $3000
        lda     #$40
        sta     $210a ;          4 (3) ....because it's so easy to handle
        
        lda     #$00  
        sta     $2105 ; mode 0
        lda     #$0f  
        sta     $212c ;enable playfield 1-4 (0-3)
        
        rep     #$30 ; X and Y to 16 bit
        sep     #$20
        ldx.v   #$0000          ;assign VRAM location to $0000
        stx     $2116
        ldx.v   #$0000
copy:   
        lda     font,x          ;copy font to vram $0000 
        sta     $2118
        stz     $2119
        inx
        cpx.v   #$0320
        bne     copy

        ldx.v    #$1000
        stx     $2116
        
        ldx.v   #$0000
        lda     #$20
fill:
        sta     $2118       ; fill unused area with spaces !
        stz     $2119
        inx
        cpx     #$0400
        bne     fill
        
        ldx.v    #$2000
        stx     $2116
        
        ldx.v   #$0000
        lda     #$20
fill2:
        sta     $2118
        stz     $2119
        inx
        cpx     #$0400
        bne     fill2
        
        ldx.v   #$3000
        stx     $2116
        
        ldx.v   #$0000
        lda     #$20
fill3:
        sta     $2118
        stz     $2119
        inx
        cpx     #$0400
        bne     fill3

        ldx.v    #$4000
        stx     $2116
       
        ldx.v   #$0000
set_logo:
        lda     logo,x          ;copy cream logo to vram $4000
        sta     $2118
        stz     $2119
        inx
        cpx.v   #224
        bne     set_logo

        ldx.v   #$0000
        lda     #$20            ; fill rest with spaces
hoppla:
        sta     $2118
        stz     $2119
        inx
        cpx.v   #$320
        bne     hoppla

        ldx.v   #$1304      ;copy "music #" to screen on playfield 2 (1)
        stx     $2116
        sep     #$30
        ldy     #$00
sele:
        lda     soundtext,y
        sta     $2118
        stz     $2119
        iny
        cpy     #$07
        bne     sele
        rep     #$10
        lda     #$01
        ldx.v   #$0038
be:        
        ldy.v   minus1,x        ;creates a vertical black line to hide
        sty     $2116           ;scrolline error
        sta     $2118
        stz     $2119
        dex
        dex
        bpl     be
        
        sep     #$30
        lda     #$20
        ldx     #$21
        sta     $2121      ;color register
        stz     $2122      ;color value 
        stz     $2122
        stx     $2121
        stz     $2122
        stz     $2122
        rts ;-------------------------------------------------

set_hdma:
        sep     #$30
        rep     #$10

        stz     $420c   ;turn off dmas
        
        stz     $4310   ;channel 1 to 1 byte modus
        lda     #$02
        sta     $4320   ;channel 2 to 2 byte modus
        
        lda     #$21    ;channel 1 data goes in $2121
        sta     $4311
        lda     #$22
        sta     $4321   ;channel 2 data in $2122 
        
        ldx.v   #da1
        stx     $4312   ;channel 1 data is to be read from label da1
        ldx.v   #da2
        stx     $4322   ;channel 2 data from label da2
        stz     $4314   ;channel 1 data bankregister to 0
        stz     $4324   ;channel 2 data bankregister to 0
        lda     #$06
        sta     $420c   ;turn on channel 1 and 2 
        rts
;*****************************************************************

        
bounce_logo:
        sep     #$30
        inc     $205
        lda     $205            
        cmp     #$02            ;x-movement of logo every 2nd irq
        bne     no_reset
        stz     $205
        inc     $204            
        ldx     $204
        lda     sinus,x         ;get current sinus-value out of sinus table
        clc
        adc     #$80            ;add #$80 to position
        sta     $2113           ;write to planyfield 4 (3) x-position
        stz     $2113
no_reset:
        
        inc     $206
        ldx     $206
        lda     sinus,x         ;y-movement of logo
        clc
        adc     #$80            ;add #$80 to position
        sta     $2114           ;write to planyfield 4 (3) x-position
        stz     $2114
        rts
;*****************************************************************
scroll:
        sep     #$20    ;acc. to 8 bit
        rep     #$10    ;xy to 16 bit
        
        lda     $200    ;scroll 1bit left
        sta     $2111
        stz     $2111


        inc     $200
        lda     $200
        cmp     #$08    ;reached 8 bit?
        bne     no_copy
        
        
        lda     #$00
        sta     $200
no_copy:        
        lda     $200
        cmp     #$01
        bne     no_copy2        ;this is because of a slow raster
        
        ldx.v   #$31c0          
        stx     $2116
        ldy.v   $201
        ldx.v   #$0000
scr:        

        lda     text,y

        sta     $2118           ;move entire scrolline left by 1 chr.
        stz     $2119           ;and puts next letter on screen 
        inx
        iny
        cpx.v   #$0020     
        bne     scr
        
        ldx.v   $201
        inx
        cpx     #$05c8         ;already the end of scrolltext?
        beq     tpzero
        stx.v   $201

no_copy2:
        
again:        
        sep     #$30
        ldy     $203
        lda     bounce,y
        sta     $2112
        stz     $2112
        inc     $203
        cmp.b   #$ff
        bne     hallo
        lda     #$01
        sta     $203
        jmp     again
hallo:        
        rts

tpzero:
        ldx.v   #$0000
        stx.v   $201
        rts


minus1:
        dcw     $201f,$203f,$205f,$207f,$209f,$20bf,$20df,$20ff
        dcw     $211f,$213f,$215f,$217f,$219f,$21bf,$21df,$21ff
        dcw     $221f,$223f,$225f,$227f,$229f,$22bf,$22df,$22ff
        dcw     $231f,$233f,$235f,$237f,$239f

music_tab2:
        dcw     "01","02","03","04","05","06","07","08","09","10"
        dcw     "11","12","13","14","15","16","17","18","19","20"
        dcw     "21","22","23","24","25","26","27","28","29","30"
        dcw     "31","32","33","34","35","36","37","38","39","40"
        dcw     "41","42","43"

music_tab:
        dcb     $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
        dcb     $21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
        dcb     $31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C

soundtext:
        dcb   "MUSIC #"

text:
        dcb    "                                "
        dcb    "HACKER HARRY FOR CREAM PRESENTS "
        dcb    "THE MUSIC FROM SQUARESOFTS      BREATH OF FIRE              "
        dcb    "PRESS UP/DOWN TO CHANGE MUSIC NUMBER, B-BUTTON TO PLAY, Y-BU"
        dcb    "TTON TO STOP MUSIC. YOU CAN REWIND/FAST FORWARD MUSIC NUMBER"
        dcb    " BY PRESSING DOWN/LEFT OR UP/LEFT.                          "
        dcb    "THE MUSIC WAS RIPPED AND ALTERED TO SLOWROM BY HACKER HARRY." 
        dcb    " MAIN PROGRAMMING DONE BY CANDYMAN. COLOR CALCULATIONS BY TA"
        dcb    "O. PROGRAM SUPPORT BY RED ONE.                              "
        dcb    "THE MUSIC SIZE IS ONLY 128 KILOBYTES AND IT TOOK A WHILE TO "
        dcb    "RIP IT. OF COURSE, IF YOU COMPARE THIS DEMO SCREEN WITH OTHE"
        dcb    "RS, YOU MAY SAY THAT THIS IS A LOUSY ONE. WELL, IT IS !!    "
        dcb    "BUT THAT IS NOT IMPORTANT,BECAUSE IT WAS A LOT OF FUN TO WRI"
        dcb    "TE THIS SCREEN AND TO WORK ON SNES-MUSIC. SINCE I OWE JUST A"  
        dcb    " 8086 XT, IT WAS A BIT HARDER TO FIND SOFTWARE, THAT HELPS U"
        dcb    "S IN DEVELOPING SNES SOFTWARE...YES...YOU MAY LAUGH NOW !   "
        dcb    "                                "
        dcb    "WHAT HAPPEND IN THE NEARER PAST ?    I AM SERCHING NEW WORK "
        dcb    "BECAUSE THE LAST JOB WAS NOT MUCH PROFITABLE...THE WORK ITSE"
        dcb    "LF WAS SUPERB...BUT NO ONE WANTS TO KNOW THAT...HEHE        "
        dcb    "OK. LETS STOP THIS SCROLLTEXT NOW WITH A FEW GREETINGS.     "
        dcb    "REGARDS GO TO ALL MUSICANS, SNES PROGRAMMERS, TO MY MOTHER, "
        dcb    "RED ONE, MY GIRLFRIEND STEFFI, STAR TREK FANS OUT THERE, TAO"
        dcb    ", ZOMB (WITH HIS NICE MUSICBOX), CANDYMAN, AGENT T, ABYSS.  "
        dcb    "                    SO LONG...TILL THE NEXT CREAM PRODUCT.  "
        dcb    "                                "
        dcb    "                                "
        dcb    "                                "
        dcb    "                                "


sintab:

logo:                 
  dcb 0,3,1,1,1,0,1,1,1,2,0,3,1,1,1,0,3,1,1,2,0,1,1,1,1,2,0,0,0,0,0,0
  dcb 0,1,7,0,0,0,1,0,8,1,0,1,7,0,0,0,1,7,8,1,0,1,0,0,8,1,0,0,0,0,0,0
  dcb 0,1,0,0,0,0,1,0,10,1,0,1,0,0,0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0
  dcb 0,1,0,0,0,0,1,1,1,6,0,1,1,1,0,0,1,1,1,1,0,1,0,1,0,1,0,0,0,0,0,0
  dcb 0,1,0,0,0,0,1,0,8,1,0,1,0,0,0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0
  dcb 0,1,9,0,0,0,1,0,0,1,0,1,9,0,0,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0
  dcb 0,4,1,1,1,0,1,0,0,1,0,4,1,1,1,0,1,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0

font:        
  dcb 0,0,0,0,0,0,0,0

  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111

  dcb %11110000
  dcb %11111100
  dcb %11111110
  dcb %11111110
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111

  dcb %00001111
  dcb %00111111
  dcb %01111111
  dcb %01111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111

  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %01111111
  dcb %01111111
  dcb %00111111
  dcb %00001111
              
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111110
  dcb %11111110
  dcb %11111100
  dcb %11110000

  dcb %11111110
  dcb %11111110
  dcb %11111100
  dcb %11110000
  dcb %11110000
  dcb %11111100
  dcb %11111110
  dcb %11111110

  dcb %10000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000

  dcb %00000001
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000

  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %10000000

  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000001

  dcb %10000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %10000000

  dcb %00000001
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000000
  dcb %00000001

  dcb %00011000
  dcb %00111100
  dcb %01111110
  dcb %01111110
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111

  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %11111111
  dcb %01111110
  dcb %01111110
  dcb %00111100
  dcb %00011000

  
  dcb %00011000
  dcb %00111100
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %00111100
  dcb %00011000
  
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb %01111110
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  dcb 0,0,0,0,0,0,0,0     
  
       dcb    $00,$00,$00,$00,$00,$00,$00,$00 ;' '
       dcb    $00,$18,$18,$18,$00,$00,$18,$00 ;'!'
       dcb    $00,$66,$66,$00,$00,$00,$00,$00 ;'"'
       dcb    $00,$66,$ff,$66,$ff,$66,$00,$00 ;'#'
       dcb    $00,$08,$1c,$28,$28,$1c,$08,$00 ;'$'
       dcb    $00,$64,$6c,$18,$30,$6c,$4c,$00 ;'%'
       dcb    $00,$00,$18,$18,$7e,$18,$18,$00 ;'&'
       dcb    $00,$0c,$18,$00,$00,$00,$00,$00 ;'''
       dcb    $00,$18,$30,$30,$30,$18,$0c,$00 ;'('
       dcb    $00,$18,$0c,$0c,$0c,$18,$30,$00 ;')'
       dcb    $00,$66,$3c,$ff,$3c,$66,$00,$00 ;'*'
       dcb    $00,$18,$18,$7e,$18,$18,$00,$00 ;'+'
       dcb    $00,$00,$00,$00,$00,$18,$18,$30 ;','
       dcb    $00,$00,$00,$fe,$00,$00,$00,$00 ;'-'
       dcb    $00,$00,$00,$00,$00,$18,$18,$00 ;'.'
       dcb    $03,$06,$0c,$18,$30,$60,$c0,$00 ;'/'
       dcb    $00,$3c,$66,$6e,$76,$66,$3c,$00 ;'0'
       dcb    $00,$18,$38,$18,$18,$18,$7e,$00 ;'1'
       dcb    $00,$7c,$06,$0c,$30,$60,$7e,$00 ;'2'
       dcb    $00,$7e,$06,$1c,$06,$66,$3c,$00 ;'3'
       dcb    $00,$0e,$1e,$36,$7f,$06,$06,$00 ;'4'
       dcb    $00,$7e,$60,$7c,$06,$66,$3c,$00 ;'5'
       dcb    $00,$3e,$60,$7c,$66,$66,$3c,$00 ;'6'
       dcb    $00,$7e,$06,$0c,$0c,$0c,$0c,$00 ;'7'
       dcb    $00,$3c,$66,$3c,$66,$66,$3c,$00 ;'8'
       dcb    $00,$3c,$66,$3e,$06,$66,$3c,$00 ;'9'
       dcb    $00,$00,$18,$00,$00,$18,$00,$00 ;':'
       dcb    $00,$00,$18,$00,$00,$18,$18,$30 ;';'
       dcb    $18,$18,$18,$18,$18,$18,$18,$00 ;'<'
       dcb    $00,$00,$7e,$00,$7e,$00,$00,$00 ;'='
       dcb    $18,$18,$0c,$0c,$0c,$0c,$18,$18 ;'>'
       dcb    $00,$7c,$06,$0c,$18,$00,$18,$00 ;'?'
       dcb    $55,$aa,$55,$aa,$55,$aa,$55,$aa ;'@'
        dcb     $18,$24,$66,$66,$7e,$66,$66,$00 ;A
        dcb     $7c,$66,$66,$7c,$66,$66,$7c,$00 ;B
        dcb     $3c,$66,$60,$60,$60,$66,$3c,$00 ;C
        dcb     $7c,$66,$66,$66,$66,$66,$7c,$00 ;D
        dcb     $7e,$60,$60,$7c,$60,$60,$7e,$00 ;E
        dcb     $7e,$60,$60,$7c,$60,$60,$60,$00 ;F
        dcb     $3c,$66,$60,$6e,$66,$66,$3a,$00 ;G
        dcb     $66,$66,$66,$7e,$66,$66,$66,$00 ;H
        dcb     $3c,$18,$18,$18,$18,$18,$3c,$00 ;I
        dcb     $1e,$0c,$0c,$0c,$0c,$6c,$38,$00 ;J
        dcb     $66,$6c,$78,$70,$78,$6c,$66,$00 ;K
        dcb     $60,$60,$60,$60,$60,$60,$7e,$00 ;L
        dcb     $46,$6e,$7e,$7e,$56,$46,$46,$00 ;M
        dcb     $62,$72,$7a,$5e,$4e,$46,$42,$00 ;N
        dcb     $3c,$66,$66,$66,$66,$66,$3c,$00 ;O
        dcb     $7c,$66,$66,$66,$7c,$60,$60,$00 ;P
        dcb     $3c,$66,$66,$66,$76,$6c,$3a,$00 ;Q
        dcb     $7c,$66,$66,$7c,$78,$6c,$66,$00 ;R
        dcb     $3c,$66,$60,$3c,$06,$66,$3c,$00 ;S
        dcb     $7e,$18,$18,$18,$18,$18,$18,$00 ;T
        dcb     $66,$66,$66,$66,$66,$66,$3c,$00 ;U
        dcb     $66,$66,$66,$66,$24,$3c,$18,$00 ;V
        dcb     $46,$56,$56,$56,$7e,$2c,$2c,$00 ;W
        dcb     $66,$66,$3c,$18,$3c,$66,$66,$00 ;X
        dcb     $66,$66,$66,$3c,$18,$18,$18,$00 ;Y
        dcb     $7e,$06,$0c,$18,$30,$60,$7e,$00 ;Z
       dcb    $00,$3c,$30,$30,$30,$30,$3c,$00 ;'['
       dcb    $c0,$60,$30,$18,$0c,$06,$03,$00 ;'|'
       dcb    $00,$3c,$0c,$0c,$0c,$0c,$3c,$00 ;']'
       dcb    $10,$38,$6c,$c6,$00,$00,$00,$00 ;'^'
       dcb    $00,$00,$00,$00,$00,$00,$00,$fe ;'_'

bounce:
        dcb  30,30,30,29,29,28,27,26,25,24,22,20,18,16,13,10,7
        dcb  4,7,10,13,16,18,20,22,24,25,26,27,28,29,29
        
        dcb     $ff

da1:    dcb $FF
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61
        dcb $E5
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$61,$61,$61
        dcb $61,$61,$61,$61,$61,$61,$61,$41,$01,$00
        dcb $40

da2:
   dcb $FF
   dcw 25703,26760,27817,28874,29931,30988,32045
   dcw 31054,30063,29072,28081,27090,26099,25108,24117
   dcw 23126,22135,21144,20153,19162,18171,17180,16189
   dcw 15198,14207,13214,12221,11228,10235,9178,8121
   dcw 7064,6007,4950,3893,2836,1779,722,689
   dcw 656,1647,2638,3629,4620,5611,6602,7593
   dcw 8584,9575,10566,11557,12548,13539,14530,15521
   dcw 16512,17504,18496,19489,20482,21507,22532,23589
   dcw 24646,25703,26760,27817,28874,29931,30988,32045
   dcw 31054,30063,29072,28081,27090,26099,25108,24117
   dcw 23126,22135,21144,20153,19162,18171,17180,16189
   dcw 15198,14207,13214,12221,11228,10235,9178,8121
   dcw 7064,6007,4950,3893,2836,1779,722,689
   dcw 656,1647,2638,3629,4620,5611,6602,7593
   dcw 8584,9575,10566,11557,12548,13539,14530,15521
   dcw 16512,17504,18496,19489,20482,21507,22532,23589
   dcb $E5
   dcw 24646,25703,26760,27817,28874,29931,30988,32045
   dcw 31054,30063,29072,28081,27090,26099,25108,24117
   dcw 23126,22135,21144,20153,19162,18171,17180,16189
   dcw 15198,14207,13214,12221,11228,10235,9178,8121
   dcw 7064,6007,4950,3893,2836,1779,722,689
   dcw 656,1647,2638,3629,4620,5611,6602,7593
   dcw 8584,9575,10566,11557,12548,13539,14530,15521
   dcw 16512,17504,18496,19488,20481,21506,22531,23588
   dcw 24645,25702,26759,27816,28873,29930,30987,32044
   dcw 31053,30062,29071,28080,27089,26098,25107,24116
   dcw 23125,22134,21143,20152,19161,18170,17179,16188
   dcw 15197,14206,13215,12222,11229,10236,9179,8122
   dcw 7065,$7fff,$7fff,$0,$0

sinus:        
        dcb  0 , 3 , 6 , 9 , 12 , 15 , 18 , 21 
        dcb  24 , 28 , 31 , 34 , 37 , 40 , 43 , 46 
        dcb  48 , 51 , 54 , 57 , 60 , 63 , 65 , 68 
        dcb  71 , 73 , 76 , 78 , 81 , 83 , 85 , 88 
        dcb  90 , 92 , 94 , 96 , 98 , 100 , 102 , 104 
        dcb  106 , 108 , 109 , 111 , 112 , 114 , 115 , 117 
        dcb  118 , 119 , 120 , 121 , 122 , 123 , 124 , 124 
        dcb  125 , 126 , 126 , 127 , 127 , 127 , 127 , 127 
        dcb  127 , 127 , 127 , 127 , 127 , 127 , 126 , 126 
        dcb  125 , 124 , 124 , 123 , 122 , 121 , 120 , 119 
        dcb  118 , 117 , 115 , 114 , 112 , 111 , 109 , 108 
        dcb  106 , 104 , 102 , 100 , 98 , 96 , 94 , 92 
        dcb  90 , 88 , 85 , 83 , 81 , 78 , 76 , 73 
        dcb  71 , 68 , 65 , 63 , 60 , 57 , 54 , 51 
        dcb  48 , 46 , 43 , 40 , 37 , 34 , 31 , 28 
        dcb  24 , 21 , 18 , 15 , 12 , 9 , 6 , 3 
        dcb -1 ,-4 ,-7 ,-10 ,-13 ,-16 ,-19 ,-22 
        dcb -25 ,-29 ,-32 ,-35 ,-38 ,-41 ,-44 ,-47 
        dcb -49 ,-52 ,-55 ,-58 ,-61 ,-64 ,-66 ,-69 
        dcb -72 ,-74 ,-77 ,-79 ,-82 ,-84 ,-86 ,-89 
        dcb -91 ,-93 ,-95 ,-97 ,-99 ,-101 ,-103 ,-105 
        dcb -107 ,-109 ,-110 ,-112 ,-113 ,-115 ,-116 ,-118 
        dcb -119 ,-120 ,-121 ,-122 ,-123 ,-124 ,-125 ,-125 
        dcb -126 ,-127 ,-127 ,-128 ,-128 ,-128 ,-128 ,-128 
        dcb -128 ,-128 ,-128 ,-128 ,-128 ,-128 ,-127 ,-127 
        dcb -126 ,-125 ,-125 ,-124 ,-123 ,-122 ,-121 ,-120 
        dcb -119 ,-118 ,-116 ,-115 ,-113 ,-112 ,-110 ,-109 
        dcb -107 ,-105 ,-103 ,-101 ,-99 ,-97 ,-95 ,-93 
        dcb -91 ,-89 ,-86 ,-84 ,-82 ,-79 ,-77 ,-74 
        dcb -72 ,-69 ,-66 ,-64 ,-61 ,-58 ,-55 ,-52 
        dcb -49 ,-47 ,-44 ,-41 ,-38 ,-35 ,-32 ,-29 
        dcb -25 ,-22 ,-19 ,-16 ,-13 ,-10 ,-7 ,-4 

irq:
        pha
        phx
        phy
        php

        jsr     scroll
        jsr     joy_read
        jsr     loop
        jsr     bounce_logo

        plp
        ply
        plx
        pla
        rti

init_vic:
        sep #$30        ; make X, Y, A all 8-bits
        lda #$80        ; screen off, no brightness
        sta $2100       ; brightness & screen enable register
        lda #$00
        sta $2101       ; sprite register (size & address in VRAM)
        sta $2102       ; sprite registers (address of sprite memory [OAM])
        sta $2103       ; sprite registers (address of sprite memory [OAM])
        sta $2105       ; graphic mode register
        sta $2106       ; mosaic register
        sta $2107       ; plane 0 map VRAM location
        sta $2108       ; plane 1 map VRAM location
        sta $2109       ; plane 2 map VRAM location
        sta $210A       ; plane 3 map VRAM location
        sta $210B       ; plane 0 & 1 Tile data location
        sta $210C       ; plane 2 & 3 Tile data location
        sta $210D       ; plane 0 scroll x (first 8 bits)
        sta $210D       ; plane 0 scroll x (last 3 bits)
        sta $210E       ; plane 0 scroll y (first 8 bits)
        sta $210E       ; plane 0 scroll y (last 3 bits)
        sta $210F       ; plane 1 scroll x (first 8 bits)
        sta $210F       ; plane 1 scroll x (last 3 bits)
        sta $2110       ; plane 1 scroll y (first 8 bits)
        sta $2110       ; plane 1 scroll y (last 3 bits)
        sta $2111       ; plane 2 scroll x (first 8 bits)
        sta $2111       ; plane 2 scroll x (last 3 bits)
        sta $2112       ; plane 2 scroll y (first 8 bits)
        sta $2112       ; plane 2 scroll y (last 3 bits)
        sta $2113       ; plane 3 scroll x (first 8 bits)
        sta $2113       ; plane 3 scroll x (last 3 bits)
        sta $2114       ; plane 3 scroll y (first 8 bits)
        sta $2114       ; plane 3 scroll y (last 3 bits)
        lda #$80        ; increase VRAM address after writing to $2119
        sta $2115       ; VRAM address increment register
        lda #$00
        sta $2116       ; VRAM address low
        sta $2117       ; VRAM address high
        sta $211A       ; initial mode 7 setting register
        sta $211B       ; mode 7 matrix parameter A register (low)
        lda #$01
        sta $211B       ; mode 7 matrix parameter A register (high)
        lda #$00
        sta $211C       ; mode 7 matrix parameter B register (low)
        sta $211C       ; mode 7 matrix parameter B register (high)
        sta $211D       ; mode 7 matrix parameter C register (low)
        sta $211D       ; mode 7 matrix parameter C register (high)
        sta $211E       ; mode 7 matrix parameter D register (low)
        lda #$01
        sta $211E       ; mode 7 matrix parameter D register (high)
        lda #$00
        sta $211F       ; mode 7 center position X register (low)
        sta $211F       ; mode 7 center position X register (high)
        sta $2120       ; mode 7 center position Y register (low)
        sta $2120       ; mode 7 center position Y register (high)
        sta $2121       ; color number register ($00-$ff)
        sta $2123       ; bg1 & bg2 window mask setting register
        sta $2124       ; bg3 & bg4 window mask setting register
        sta $2125       ; obj & color window mask setting register
        sta $2126       ; window 1 left position register
        sta $2127       ; window 2 left position register
        sta $2128       ; window 3 left position register
        sta $2129       ; window 4 left position register
        sta $212A       ; bg1, bg2, bg3, bg4 window logic register
        sta $212B       ; obj, color window logic register (or, and, xor, xnor)
        lda #$01
        sta $212C       ; main screen designation (planes, sprites enable)
        lda #$00
        sta $212D       ; sub screen designation
        sta $212E       ; window mask for main screen
        sta $212F       ; window mask for sub screen
        lda #$30
        sta $2130       ; color addition & screen addition init setting
        lda #$00
        sta $2131       ; add/sub sub designation for screen, sprite, color
        lda #$E0
        sta $2132       ; color data for addition/subtraction
        lda #$00
        sta $2133       ; screen setting (interlace x,y/enable SFX data)
        sta $4200       ; enable v-blank, interrupt, joypad register
        lda #$FF
        sta $4201       ; programmable I/O port
        lda #$00
        sta $4202       ; multiplicand A
        sta $4203       ; multiplier B
        sta $4204       ; multiplier C
        sta $4205       ; multiplicand C
        sta $4206       ; divisor B
        sta $4207       ; horizontal count timer
        sta $4208       ; horizontal count timer MSB
        sta $4209       ; vertical count timer
        sta $420A       ; vertical count timer MSB
        sta $420B       ; general DMA enable (bits 0-7)
        sta $420C       ; horizontal DMA (HDMA) enable (bits 0-7)
        sta $420D       ; access cycle designation (slow/fast rom)
        rts



;---------------- set irq adress
        pad $ffea
        dcw irq

        pad $fffc       ;set start vector
        dcw start
        pad 
        bin mus1.bin    ;put first 32 kb of music to $018000
        pad             
        bin mus2.bin    
        pad 
        bin mus3.bin
        pad 
        bin mus4.bin
