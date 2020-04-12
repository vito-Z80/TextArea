	module text
coordinates 	dw #0000
drawStyle	db 0
;	draw text 
draw 
	
	ld a,(ix+data.beep)
	ld (setBeep+1),a
	ld a,(ix+data.drawStyle)
	ld (drawStyle),a
	ld a,(ix+data.delay)
; 	ld a,1
	ld (delay+1),a
	ld l,(ix+data.fontAddr)
	ld h,(ix+data.fontAddr+1)
	ld (calculate.fontAddr+1),hl
	ld l,(ix+data.x)
	ld h,(ix+data.y)
	inc h
	inc l
	ld (coordinates),hl

	ld ix,calculate.lines

printNextLine
	call calculate.scrAddrDE
	ld a,(ix+2)
	add e
	ld e,a
	ld l,(ix)
	ld a,(ix+1)
	or a
	ret z
	ld h,a
	ld a,(ix+3)
nextChar
	ex af,af
	ld a,(hl)
	cp 32
	jr nc,canDraw
	inc hl
	jr nextChar+1
canDraw:
	push hl
	push de
	push af
	call calculate.letterAddr
	call draw.symbol
	pop af
	call beep
	call delay
	pop de
	inc e
	pop hl
	inc hl
	ex af,af
	dec a
	jr nz,nextChar
	inc ix
	inc ix
	inc ix
	inc ix
	ld hl,(coordinates)
	inc h
	ld (coordinates),hl
	jr printNextLine
; play sound if specified
delay:
	ld b,0	;	(1-128) * halt; (129-255,0) = no halt
	dec b
	ret m
	ei
	halt
	call keyboard.anyKey
	jr z,delay+2
	xor a
	ld (delay+1),a
	ld (setBeep+1),a
	ret
; play sound if specified
beep:
	cp " "		;	'SPACE' char = no beep
	ret z
setBeep:
	ld a,0
	or a		;	if beep not specify = no beep
	ret z
	call sound.setSound
	call sound.soundPlay
	ret
; set area color
areaColor:
	//	A = color
	call calculate.getAttrAddr
	ld bc,33
	add hl,bc
	dec bc
	ld d,(ix+data.height)
colorLine:
	push hl
	ld e,(ix+data.width)
colorSymbol:
	ld (hl),a
	inc l
	dec e
	jr nz,colorSymbol
	pop hl
	add hl,bc
	dec d
	jr nz,colorLine
	ret

	endmodule
