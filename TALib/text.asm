	module text
init
	ret
//---------------------------------------------------------
draw 
	ld a,(ix+data.areaColor)
	call areaColor
	ld a,(ix+data.drawStyle)
	cp 2
	jr c,standard
	ret
//---------------------------------------------------------
nextLine 	db 0
scrAddr		dw 0
standard
	xor a
	ld (nextLine),a
	//	save screen address for draw
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	inc l
	inc h
	call calculate.scrAddrDE
	ex de,hl
	ld (scrAddr),hl
	//	set font address
	ld a,(ix+data.fontAddr)
	ld (calculate.fontAddr+1),a
	ld a,(ix+data.fontAddr+1)
	ld (calculate.fontAddr+2),a
	//	get text address HL
	ld l,(ix+data.textAddr)
	ld h,(ix+data.textAddr+1)
	//	get start screen address DE

lineDraw
	ld a,(scrAddr)
	ld e,a
	ld a,(scrAddr+1)
	ld d,a

	ld a,(ix+data.width)
letterDraw
	ex af,af
	ld a,(hl)
	or a
	ret z
	push de
	push hl
	call calculate.letterAddr
	call draw.symbol
	ld a,(ix+data.drawStyle)
	cp 1
	jr nz,noPause
	halt
noPause
	pop hl
	inc hl
	pop de
	inc e
	ex af,af
	dec a
	jr nz,letterDraw

	push hl
	ld l,(ix+data.x)
	inc l
	ld a,(nextLine)
	inc a
	ld (nextLine),a
	inc a
	add (ix+data.y)
	ld h,a
	call calculate.scrAddrDE
	ex de,hl
	ld (scrAddr),hl
	pop hl
	jr lineDraw
//------------------
//---------------------------------------------------------
areaColor
	//	A = color
	call calculate.attributesAddr
	ld bc,33
	add hl,bc
	dec bc
	ld d,(ix+data.height)
colorLine
	push hl
	ld e,(ix+data.width)
colorSymbol
	ld (hl),a
	inc l
	dec e
	jr nz,colorSymbol
	pop hl
	add hl,bc
	dec d
	jr nz,colorLine
	ret
//---------------------------------------------------------
calculateLineBreak



	endmodule
