	module frame
	//	TODO attributes
draw
	//	check rnadom X,Y
	ld a,(ix+data.rndXY)
	or a
	jr nz,checkHeightLimit
	ld a,32
	ld c,(ix+data.width)
	inc c
	sub c
	call calculate.rndLimit
	ld (ix+data.x),a
	ld a,24
	ld c,(ix+data.height)
	inc c
	sub c
	call calculate.rndLimit
	ld (ix+data.y),a
checkHeightLimit
	ld a,(ix+data.autoHeight)
	or a
	jr z,startDraw
	//	TODO add height calculate

startDraw
	//	topLeftSprite
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	call calculate.scrAddrDE
	ld hl,topLeftSprite
	call draw.symbol
	//	leftSprite
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	inc h
	call calculate.scrAddrDE
	ld hl,leftSprite
	call verticalPath
	//	bottomLeftSprite
	ld l,(ix+data.x)
	ld a,(ix+data.y)
	inc a
	add (ix+data.height)
	ld h,a
	call calculate.scrAddrDE
	ld hl,bottomLeftSprite
	call draw.symbol
	//	topSprite
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	inc l
	call calculate.scrAddrDE
	ld hl,topSprite
	call horizontalPath
	//	topRightSprite
	ld a,(ix+data.x)
	add (ix+data.width)
	inc a
	ld l,a
	ld h,(ix+data.y)
	call calculate.scrAddrDE
	ld hl,topRightSprite
	call draw.symbol
	//	rightSprite
	ld a,(ix+data.x)
	add (ix+data.width)
	inc a
	ld l,a
	ld h,(ix+data.y)
	inc h
	call calculate.scrAddrDE
	ld hl,rightSprite
	call verticalPath
	// 	bottomRightSprite
	ld a,(ix+data.x)
	add (ix+data.width)
	inc a
	ld l,a
	ld a,(ix+data.y)	
	add (ix+data.height)
	inc a
	ld h,a
	call calculate.scrAddrDE
	ld hl,bottomRightSprite
	call draw.symbol
	//	bottomSprite
	ld l,(ix+data.x)
	inc l
	ld a,(ix+data.y)
	add (ix+data.height)
	inc a
	ld h,a
	call calculate.scrAddrDE
	ld hl,bottomSprite
	call horizontalPath
	//	clear area
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	inc l
	inc h
	call calculate.scrAddrDE
	ld a,(ix+data.height)
	add a
	add a
	add a
	ld b,a
	xor a
3:	push bc
	push de
	xor a
	ld b,(ix+data.width)
4:	ld (de),a
	inc e
	djnz 4B
	pop de
	call calculate.nextLine
	pop bc
	djnz 3B
	call frameColor
	ret
//-------------------
verticalPath
	ld b,(ix+data.height)
1:	push bc
	push hl
	call draw.symbol
	pop hl
	dec d
	call calculate.nextLine
	pop bc
	djnz 1B
	ret
horizontalPath
	ld b,(ix+data.width)
2:	push bc
	push de
	push hl
	call draw.symbol
	pop hl
	pop de
	inc e
	pop bc
	djnz 2B
	ret
//---------------------
fColorAddr	dw #0000
frameColor
	ld a,(ix+data.frameColor)
	call calculate.attributesAddr
	//	hl attributes address
	ld (fColorAddr),hl
	ld e,l
	ld d,h
	inc e
	ld b,0
	ld c,(ix+data.width)
	inc c
	ld (hl),a
	//	top side
	ldir
	//	bottom side
	ld l,(ix+data.height)
	inc l
	ld h,b
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ex de,hl
	ld hl,(fColorAddr)
	add hl,de
	ld e,l
	ld d,h
	inc e
	ld c,(ix+data.width)
	inc c
	ld (hl),a
	ldir
	//	left side
	ld hl,(fColorAddr)
	ld c,32
	add hl,bc
	ld a,(ix+data.frameColor)
	ld e,(ix+data.height)
nls
	ld (hl),a
	add hl,bc
	dec e
	jr nz,nls
	//	right side
	ld hl,(fColorAddr)
	ld a,(ix+data.width)
	inc a
	add 32
	ld c,a
	add hl,bc
	ld bc,32
	ld a,(ix+data.frameColor)
	ld e,(ix+data.height)
nrs
	ld (hl),a
	add hl,bc
	dec e
	jr nz,nrs


	ret
//---------------------


	endmodule	
