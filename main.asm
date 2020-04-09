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
	ld (ix+data.wrap),a		//	set wrap
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
	ld (ix+data.width),19		//	text area width
	ld (ix+data.height),0		//	text area height
	ld hl,0				//	#3c00 standard font
	ld (ix+data.fontAddr),l		//	font address low
	ld (ix+data.fontAddr+1),h	//	font address high
	ld hl,message	
	ld (ix+data.textAddr),l		//	text message address low
	ld (ix+data.textAddr+1),h	//	text message address  high

repeat
;         call keyboard.anyKey
;         jr z,repeat
        ei 
        halt
        call draw.execute
        jr repeat
//-----------------------------------
//-----------------------------------


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
        
message	
	dm "The new Sinclair has arrived at last - a book-sized micro-computer with colour and sound and "
	dm "an extended version of ZX Basic. It came through its test well ahead of the competition but,"
	dm " as Tim Hartnell found, even Sinclair Research cannot work miracles."
	db 0	//	text must be ending at '0'
endProg equ $
testScreen
        incbin "TALib/Sprites/Jarlaxe.scr"

        savetap "main.tap",#6000
//-------------INFO-------------------------------------------------------------
        display "CODE SIZE: ", /A, endCode-startCode
        display "MEMORY USED WITHOUT CODE: ", /A, endProg-endCode
