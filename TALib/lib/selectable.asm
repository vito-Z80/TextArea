	module selectable
id:	db 0
count: 	db 0
update:
	ld a,(id)
	cp #ff
	ret z
	ei
	halt
	call move
	ld a,(print.data+textSettings.selectableColor)
	ld (withoutWindow+1),a
	call drawSelector
	ret
move:
	ld a,7
	call keyTimer
	ret nz
	call isAction
	or a
	jr z,noAction
	// заглушки для выхода после call selectable.update
yesAction:
	pop af
	pop af
	ld a,(id)
	ret
noAction:
	ld b,2
	ld a,(key)
	ld hl,moveKeys
na2:
	cp (hl)
	jr z,up
	inc hl
	cp (hl)
	jr z,down
	inc hl
	djnz na2
	ret
up:
	ld a,(id)
	or a
	ret z
	call restoreSelector
	dec a
	ld (id),a
	ret
down:
	ld a,(count)
	dec a
	ld c,a
	ld a,(id)
	cp c
	ret nc
	call restoreSelector
	inc a
	ld (id),a
	ret
restoreSelector:
	push af
	ld a,(print.data+windowSettings.areaColor)
	ld (withoutWindow+1),a
	call drawSelector

; 	call sound.printLetter

	pop af
	ret
drawSelector:
	ld hl,print.selectors
	ld b,0
	ld a,(id)
	ld c,a
	add hl,bc
	ld a,(hl)
	ld l,a
	ld a,(print.data+textSettings.x)
	call print.attrAddrHL
draw:
	ld a,(print.data+windowSettings.isWindowShow)
	or a
	jr z,withoutWindow
	ld a,(print.data+windowSettings.width)
	ld b,a
	dec b
	dec b
withoutWindow:
	ld a,0
nextSymbol:
	ld (hl),a
	inc l
	djnz nextSymbol
	ret
//---------------------------------------------------------
kt:	db 0
keyTimer:
	ld hl,kt
	inc (hl)
	cp (hl)
	ld a,(hl)
	jr c,clearKeyTime
	ex af,af
	ld a,(key)
	cp " "	
	jr c,clearKeyTime
	ex af,af
	or a
	ret
clearKeyTime:
	ld a,#ff
	ld (hl),a
	ret
waitAnyKey:
	ld a,(preKey)
	ld c,a
	ld a,(key)
	cp c
	ret z
	cp " "
	ret nc
	xor a
	ret
preKey:	db 0
key:	db 0
keyListener:
	ld a,(key)
	ld (preKey),a
	xor a
	ld (key),a
	di
	call kl
	ei
	ret
kl:
    call getAKey
    ld a,r
    sub 3
    ret z   ; key not pressed
    sub 4
    rra
div5:
    rrc b
    jr nc,getChar
    sub 3
    jr div5
getChar:
    add a,low rows
    ld l,a
    adc a,high rows
    sub l
    ld h,a
;   ld l,a
;   ld h,0
;   ld bc,rows
;   add hl,bc
    ld a,(hl)   ; received char (key)
    ld (key),a
    // .....
    ret
getAKey:
    ld   bc,#FEFE
    xor a
    ld r,a
nextRow
    in   a,(c)
    cpl
    rrca
    ret c
    rrca
    ret c
    rrca
    ret c
    rrca
    ret c
    rrca
    ret c
    rlc  b
    jr c,nextRow
    ret
rows:  
    db "}ZXCV"
    db "ASDFG"
    db "QWERT"
    db "12345"
    db "09876"
    db "POIUY"
    db "{LKJH"
    db "^`MNB"
//---------------------------------------
isAction:
	; return A = 0 - not press action keys
	ld a,(preKey)
	ld c,a
	ld a,(key)
	cp c
	jr z,notAction
	ld hl,actionKeys	; up to three action keys
	cp (hl)
	ret z
	inc hl
	cp (hl)
	ret z
	inc hl
	cp (hl)
	ret z
notAction:
	xor a
	ret

	display "key: ",/A,key

	endmodule

