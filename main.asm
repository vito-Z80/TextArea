        device zxspectrum48
        org #6000
startCode

        include "TALib/struct.asm"
	call restoreScreen

	ld ix,memory.dataAddr 		//	all values address
rr
; 	SET_AERA_SIZE 22,0

	SET_TEXT_ADDRESS simpleExample
	call draw.execute


	SET_TEXT_ADDRESS message
	SET_FRAME_COLOR INK.PURPLE
	SET_AREA_COLOR INK.BLUE | PAPER.YELLOW
	SET_AERA_SIZE 15,10
	call draw.execute


	SET_AERA_SIZE 0,0
	SET_AREA_COLOR INK.GREEN | PAPER.RED
	SET_FRAME_COLOR INK.GREEN | BRIGHTNESS
	SET_TEXT_ADDRESS beepTest
	BEEP_ON
	SET_DELAY 3
	call draw.execute

	SET_TEXT_ADDRESS initExample
	SET_FRAME_COLOR INK.RED | BRIGHTNESS
	SET_AREA_COLOR INK.YELLOW | PAPER.BLUE | BRIGHTNESS
	SET_AERA_SIZE 20,10
	SET_POSITION 5,2
	SET_DELAY 1
	call draw.execute

	SET_TEXT_ADDRESS colorExample
	SET_FRAME_COLOR INK.RED | BRIGHTNESS
	SET_AREA_COLOR INK.RED | PAPER.YELLOW | BRIGHTNESS
	SET_AERA_SIZE 0,0
	SET_POSITION 0,0
	call draw.execute


	SET_FRAME_COLOR INK.YELLOW
	SET_AREA_COLOR INK.WHITE | PAPER.BLUE | BRIGHTNESS
	SET_AERA_SIZE 20,0
	BEEP_OFF

	jp rr



	call restoreScreen
	SET_AERA_SIZE 20,0
	SET_TEXT_ADDRESS simpleExample
	call draw.execute

	call restoreScreen
       

//	init 

	SET_TEXT_ADDRESS message
	SET_HYPHENATION TRUE
	SET_AREA_COLOR PAPER.BLUE | INK.WHITE
	SET_FRAME_COLOR INK.YELLOW | PAPER.BLACK | BRIGHTNESS
	SET_DRAW_STYLE TYPEWRITER


; 	ld a,HYPHENATION.ON
; 	ld (ix+data.hyphenation),a		//	set wrap
; 	ld a,PAPER.BLUE | INK.WHITE
; 	ld (ix+data.areaColor),a	//	text area color	
; 	ld a,PAPER.BLACK | INK.YELLOW | BRIGHTNESS
; 	ld (ix+data.frameColor),a	//	frame color
; 	ld a,PAPER.BLUE | INK.BLUE
; 	ld (ix+data.frameShadowColor),a	//	frame shadow color
; 	ld a,1
; 	ld (ix+data.drawStyle),a	//	draw style value
; 	ld (ix+data.x),5		//	frame X
; 	ld (ix+data.y),13		//	frame Y
; 	ld (ix+data.width),19		//	text area width
; 	ld (ix+data.height),0		//	text area height
; 	ld hl,0				//	#3c00 standard font
; 	ld (ix+data.fontAddr),l		//	font address low
; 	ld (ix+data.fontAddr+1),h	//	font address high
; 	ld hl,message	
; 	ld (ix+data.textAddr),l		//	text message address low
; 	ld (ix+data.textAddr+1),h	//	text message address  high

repeat
        ei 
        halt
        call draw.execute
        jr repeat
        ret
//-----------------------------------
restoreScreen
	ld hl,testScreen
        ld de,#4000
        ld bc,#1b00
        ldir
	ret
//-----------------------------------
libCode
        include "TALib/draw.asm"
endCode equ $
        
message	
	db "The new Sinclair has arrived at last - a book-sized micro-computer with colour and sound and "
	db "an extended version of ZX Basic. It came through its test well ahead of the competition but,"
	db " as Tim Hartnell found, even Sinclair Research cannot work miracles."
	db TEXT.END	//	text must be ending at '0'
simpleExample
	db "Simple example."
	db TEXT.INDENT,1
	db "LD (IX+data.textAddr),text address"
	db TEXT.INDENT,1
	db "CALL draw.execute"
	db TEXT.END
initExample
	db "delay = 1;"
	db TEXT.INDENT,3
	db "beep ON;"
	db TEXT.END
colorExample
	db "Color test:"
	db TEXT.COLOR, INK.BLUE | PAPER.BLACK
	db TEXT.INDENT,3
	db "ink:BLUE;paper:BLACK"
	db TEXT.RETURN_COLOR
	db ",previous color."
	db TEXT.END
beepTest:
	db "Beep test & delay = 3;"
	db TEXT.INDENT,2
	db "beep, BEEP, beep, BEEP, beep, BEEP, beep, BEEP, beep, BEEP, beep......"
	db TEXT.END

; 	SET_SPRITE 23842,0,0,0,0
testScreen
        incbin "TALib/Sprites/Jarlaxe.scr"

        savetap "main.tap",startCode
//-------------INFO-------------------------------------------------------------
        display "LIBRARY CODE SIZE: ", /A, endCode-libCode
        display "end proc: ", /A, simpleExample
        LABELSLIST "C:\ZX\Addons\ue\user.l" 	//	for labels in UE: "UE path/user.l"
