        device zxspectrum128
        include "TALib/struct.asm"
        org #6000
startCode




        ld hl,testScreen
        ld de,#4000
        ld bc,#1b00
        ldir

//	init 
	ld ix,memory.dataAddr 		//	all values address
	ld a,1
	ld (ix+data.wrap),a
	ld a,%00001111
	ld (ix+data.areaColor),a	//	text area color	
	ld a,6
	ld (ix+data.frameColor),a	//	frame color
	ld a,%00001001
	ld (ix+data.frameShadowColor),a	//	frame shadow color
	ld a,1
	ld (ix+data.drawStyle),a	//	draw style value
; 	ld (ix+data.x),5		//	frame X
; 	ld (ix+data.y),13		//	frame Y
	ld (ix+data.width),15		//	text area width
	ld (ix+data.height),11		//	text area height
	ld hl,15616-256 
	ld (ix+data.fontAddr),l		//	font address low
	ld (ix+data.fontAddr+1),h	//	font address high
	ld hl,message	
	ld (ix+data.textAddr),l		//	text message address low
	ld (ix+data.textAddr+1),h	//	text message address  high

; 	call calculate.hyphenation
; 	jr $
repeat
	call draw.test
        call keyboard.anyKey
        jr z,repeat
        call draw.test
        ei 
        dup 1
        halt
        edup
        call draw.execute
        jr repeat
//-----------------------------------
//-----------------------------------

        //	text must be ending at '0'
message	dm "Hello world, this is a text area library."
	dm " Lorem ipsum dolor sit amet, consectetur adipiscing elit"
	dm "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",0

        include "TALib/draw.asm"
        include "TALib/calculate.asm"
        include "TALib/keyboard.asm"
endCode equ $
        include "TALib/Sprites/topLeftSprite.asm"
        include "TALib/Sprites/leftSprite.asm"
        include "TALib/Sprites/bottomLeftSprite.asm"
        include "TALib/Sprites/bottomRightSprite.asm"
        include "TALib/Sprites/bottomSprite.asm"
        include "TALib/Sprites/topSprite.asm"
        include "TALib/Sprites/topRightSprite.asm"
        include "TALib/Sprites/rightSprite.asm"
        include "TALib/memory.asm"
endProg equ $
testScreen
        incbin "TALib/Sprites/Jarlaxe.scr"

        savetap "main.tap",#6000
//-------------INFO-------------------------------------------------------------
        display "CODE SIZE: ", /A, endCode-startCode
        display "MEMORY USED WITHOUT CODE: ", /A, endProg-endCode
