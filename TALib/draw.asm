	module draw
execute
	ld a,r
	ld (calculate.rnd),a
	//	save screen place
	call calculate.mainProcess
; 	call dotScreen
; 	ld a,2
; 	call screenAttributes


	call frame.draw
	ld a,(ix+data.areaColor)
	call text.areaColor

	push ix
	call text.draw
	pop ix
	call keyboard.anyKey
        jr z,$-3

	ret

//----------------------------------------------------------
test
	ld a,(23556)
	call calculate.letterAddr
	ld de,16384
	call symbol
	ret
//----------------------------------------------------------

empty

	ret
//-------------------
symbol
	ld b,8
	ld a,(hl)
	ld (de),a
	inc d
	inc hl
	djnz symbol+2
	ret
//-------------------
dotScreen
	ld c,%01010101
	ld de,#4000
	ld b,192
dotLine
	push bc
	push de
	ld b,32
dotSymbol
	ld a,(de)
	and c
	ld (de),a
	inc e
	djnz dotSymbol

	pop de
	call calculate.nextLine
	pop bc
	ld a,c
	cpl
	ld c,a
	djnz dotLine
	ret
//-------------------
screenAttributes
	//	A = color
	ld hl,#5800
	ld de,#5801
	ld bc,#02ff
	ld (hl),a
	ldir
	ret
	endmodule
	//	code
	include "TALib/keyboard.asm"
	include "TALib/calculate.asm"
	include "TALib/text_formatting.asm"
        include "TALib/frame.asm"
        include "TALib/text.asm"
        include "TALib/sound.asm"
        //	frame Sprites
        include "TALib/Sprites/topLeftSprite.asm"
        include "TALib/Sprites/leftSprite.asm"
        include "TALib/Sprites/bottomLeftSprite.asm"
        include "TALib/Sprites/bottomRightSprite.asm"
        include "TALib/Sprites/bottomSprite.asm"
        include "TALib/Sprites/topSprite.asm"
        include "TALib/Sprites/topRightSprite.asm"
        include "TALib/Sprites/rightSprite.asm"
