	module draw
execute
	ld a,r
	ld (calculate.rnd),a
	//	calculate 
	//	save screen place
	call dotScreen
	ld a,2
	call screenAttributes
	call frame.draw
	call text.draw
	//	draw text

	ret

//----------------------------------------------------------
calculate
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


        include "TALib/frame.asm"
        include "TALib/text.asm"
	
	endmodule

