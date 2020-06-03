	module print
start
; text:		include "printText.asm"
; chooser:	include "selectable.asm"
; 		include "window.asm"
; 		include "values.asm"

init:
	call printText.init
	ld a,7
	ld (ix+windowSettings.areaColor),a
	ld (ix+windowSettings.sidesColor),a
	ld (ix+windowSettings.nooksColor),a
	ld a,%00111000
	ld (ix+textSettings.selectableColor),a
	xor a
	ld (ix+windowSettings.backgroundAddr+1),a
	ret
update:
	call selectable.update
	ret
autoUpdate:
	call selectable.update
	jr autoUpdate
setColors:
	; A - area color
	; B - sides color
	; C - nooks xolor
	ld hl,data+windowSettings.areaColor
	ld (hl),a
	inc hl
	ld (hl),b
	inc hl
	ld (hl),c
	ret
//---------------------

saveBackground:
	push af
	push hl
	push de
	push bc

	ld a,(ix+windowSettings.backgroundAddr+1)
	or a
	jr z,notSaveBackground

	// DE - address for save background
	ld d,a
	ld e,(ix+windowSettings.backgroundAddr)
	push de
	ld l,c
	ld h,b
	call scrAddrDE
	pop hl		; HL - address for save background
	push de 	; screen address
	ld b,(ix+windowSettings.height)
	rlc b
	rlc b
	rlc b
; save screen piece
saveNextLine:
	ld c,(ix+windowSettings.width)
	push de
saveNextByte:
	ld a,(de)
	ld (hl),a
	inc hl
	inc e
	dec c
	jr nz,saveNextByte
	pop de
	call down_de
	djnz saveNextLine

; save attribute piece
	pop de
	call scrToAttr
	ex de,hl
	ld a,(ix+windowSettings.height)
saveNextAttr:
	ex af,af
	ld a,#20
	ld c,(ix+windowSettings.width)
	sub c
	ldir
	ld c,a
	add hl,bc
	ex af,af
	dec a
	jr nz,saveNextAttr

notSaveBackground:
	pop bc
	pop de
	pop hl
	pop af

	ret
//---------------------
restoreBackground:

; 	CLEAR_SCREEN
; 	CLEAR_ATTRIBUTES 7


	ld hl,(data+windowSettings.backgroundAddr)
	ld a,h
	or a
	ret z
	push hl
	ld hl,(data+windowSettings.width)
	ld c,l 	;	width
	ld b,h 	;	height
	ld hl,(data+windowSettings.x)
	call scrAddrDE
	pop hl
	push bc
	push de
	rlc b
	rlc b
	rlc b
restoreNextLine
	push bc
	push de
restoreNextByte:
	ld a,(hl)
	ld (de),a
	inc hl
	inc e
	dec c
	jr nz,restoreNextByte
	pop de
	call down_de
	pop bc
	djnz restoreNextLine

	pop de
	call scrToAttr
	pop bc
	ld a,b
	ld b,0
restoreNextAttrLine:
	ex af,af
	ld a,(data+windowSettings.width)
	ld c,a
	ldir
	sub #20
	neg
	ld c,a
	ex de,hl
	add hl,bc
	ex de,hl
	ex af,af
	dec a
	jr nz,restoreNextAttrLine
	ld (data+windowSettings.backgroundAddr+1),a
	ret
//---------------------
build:
	; crash AF,AF`,HL,DE,BC,IX.
	push ix
	ld ix,data
	ld (data+windowSettings.x),bc
	ld (data+windowSettings.width),de
	ld (data+textSettings.addr),hl
	call saveBackground
	ld (data+windowSettings.isWindowShow),a	; show window (0 - false; 1 - true)
	or a
	jr z,notShowWindow
	push de
	push bc
	call window.show
	pop bc
	pop de

	inc b
	inc c
	dec e
	dec e
	dec d
	dec d

notShowWindow:

; cleatArea
	push de
	push bc
	ld l,c
	ld h,b
	ld a,e
	ld (clsLine+1),a
	ld (attrLine+1),a
	ld a,d
	ld b,d ; B - fill attributes height
	rlca
	rlca
	rlca
	ld c,a
	call scrAddrDE
	push de
clsLine:
	ld l,0
	push de
	xor a
clsByte:
	ld (de),a
	inc e
	dec l
	jr nz,clsByte
	pop de
	call down_de
	dec c
	jr nz,clsLine
; fill attributes
	pop de
	call scrToAttr
	ld hl,32
attrLine:
	ld c,0
	push de
	ld a,(data+windowSettings.areaColor)
attrByte:
	ld (de),a
	inc e
	dec c
	jr nz,attrByte
	pop de
	ex de,hl
	add hl,de
	ex de,hl
	djnz attrLine

	pop bc
	pop de

	ld a,e
	rlca
	rlca
	rlca
	jr nc,notCare
	ld a,#FF
notCare 
	sub (ix+textSettings.pad)
	ld (data+textSettings.lineWidth),a 	//	text lineWidth
	ld a,c
	rlca
	rlca
	rlca
	add (ix+textSettings.pad)
	ld c,a	//	text X
	ld (data+textSettings.x),bc

	xor a
	ld (ix+textSettings.offsetX),a
	ld (ix+textSettings.wordWidth),a
	ld (ix+textSettings.previousChar),a
	ld (ix+textSettings.letterWidth),a
; 	ld (ix+textSettings.pad),a
	ld hl,selectors
	ld (data+textSettings.selectableLineAddr),hl
	call printText.show
	ld hl,(data+textSettings.selectableLineAddr)
	ld a,#FF
	ld (hl),a
	ld bc,selectors
	or a
	sbc hl,bc
	ld a,l
	ld (selectable.count),a
	ld (ix+textSettings.pad),0
	pop ix
	ret

scrToAttr:
	//	de - screen address
	ld a,d
        rrca
        rrca
        rrca
        and 3
        add #58
        ld d,a
	//	de - attributes address
	ret
attrAddrHL:
	; l - y
	; a - x
	srl a
	srl a
	srl a
	ld c,a
        ld h,0
        ld b,#58
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,bc
        ;      HL = attributes address from symbol coordinates
        ret
; get screen address in DE
scrAddrDE:
	//	l = x; h = y
	ld a,#40
	add h
        and %11111000
        ld d,a
        ld a,h
        and 7
        rrca
        rrca
        rrca
        add l
        ld e,a
        ret
        ; next screen line address
down_de:
        inc d
        ld  a,d
        and 7
        jr  nz,$+12
        ld  a,e
        add a,32
        ld  e,a
        jr  c,$+6
        ld  a,d
        sub 8
        ld  d,a
        ret
        
data:		block windowSettings
letterBuffer:	block 16,0
selectors:	block 25,0 ; Y of selectors: max 24, #ff ending

	endmodule
