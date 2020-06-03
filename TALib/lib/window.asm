; Author: Serdjuk
; Assembly: sjasmplus
	module window

show:
	ld l,(ix+windowSettings.x)
	ld h,(ix+windowSettings.y)
	push hl
	push hl
	inc h
	call print.scrAddrDE
        call vertical		; left
        inc e
        call horizontal		; bottom
	pop hl
	inc l
	call print.scrAddrDE
        call horizontal		; top
        ld a,(ix+windowSettings.width)
        sub 2
        ld c,a
        ld a,e
        add c
        ld e,a
        call vertical		; right
        pop hl
        call print.scrAddrDE
        push de
        call nook		; top-right
        pop de
        inc e
        ld a,(ix+windowSettings.width)
        sub 2
        add e
        ld e,a
        call nook		; top-left	
        ret
nookSprite:
	db 0
	db %01111110
	db %01000010
	db %01001010
	db %01010010
	db %01000010
	db %01111110
	db 0
horSprite:
	db 0,255,0,%01010101,%10101010,0,%01010101,0
horizontal:
	; de - screen address
	push de
	ld a,1
	call attrLines
	ld hl,horSprite
	ld c,8
hor2:
	ld a,(ix+windowSettings.width)	//	width
	sub 2
	ld (hor3+1),a
	ld b,a
	ld a,(hl)
hor1:
	ld (de),a
	inc e
	djnz hor1
	ld a,e
hor3:
	sub 0
	ld e,a
	call print.down_de
	inc hl
	dec c
	jr nz,hor2
	pop hl
	ret

vertical:
	// de - screen address
	ld a,32
	call attrLines
	ld a,(ix+windowSettings.height) 	//	height
	sub 2
	rlca
	rlca
	rlca
	ld b,a
	ld a,%01010010
ver1:
	ld (de),a
	ld c,a
	call print.down_de
	ld a,c
	xor %00011010
	djnz ver1

nook:
	; de - screen address
	push de
	push de
	call print.scrToAttr
	ld a,(ix+windowSettings.nooksColor)
	ld (de),a
	pop de

	ld hl,nookSprite
	ld b,8
nook1:
	ld a,(hl)
	ld (de),a
	inc d
	inc hl
	djnz nook1
	pop de
	ret

attrLines:
	; de - screen address
	; a - 32 or 1
	ld c,a
	push de
	cp 1
	jr nz,al1
	ld a,(ix+windowSettings.width)
	sub 2
	jr al2
al1:
	ld a,(ix+windowSettings.height)
	sub 2
al2:
	ld l,a
	call print.scrToAttr
	ex de,hl
	ld b,0
	ld a,(ix+windowSettings.sidesColor)
al3:
	ld (hl),a
	add hl,bc
	dec e
	jr nz,al3
	pop de
	ret
	endmodule