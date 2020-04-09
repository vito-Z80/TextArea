	module text
init
	ret
//---------------------------------------------------------
draw 
	ld a,(ix+data.drawStyle)
	ld (pause),a
	ld a,(ix+data.areaColor)
	call areaColor
	call drawHyphenation
	ret
//---------------------------------------------------------
pause 		db 0
nextLine 	db 0
//------------------
draw8Letter
	ret
//------------------
nextLineY	db 0  	// Y ������� ������
staticX		db 0	// X ���������� ����
endLineDraw	db 0
drawHyphenation
	ld a,(ix+data.x)
	inc a
	ld (staticX),a
	ld a,(ix+data.y)
	inc a
	ld (nextLineY),a

	//	set font address
	ld a,(ix+data.fontAddr)
	ld (calculate.fontAddr+1),a
	ld a,(ix+data.fontAddr+1)
	ld (calculate.fontAddr+2),a

	//	text line addresses
	ld hl,calculate.lines

	

nextLineDraw
	push hl
	ld e,(hl)
	inc hl
	ld a,(hl)
	or a
	jr nz,continueDraw
	pop hl
	ret
continueDraw
	ld d,a
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	//	BC = �������� ����� ������ ��� ��������� ������
	ex de,hl
	//	HL = �������� ����� ������ ��� ������ ������
	push hl
	push hl
	push bc
	pop hl
	pop bc
	or a
	sbc hl,bc
	ld b,l
	//	B = �������� ������ ������

	ld a,(staticX)
	ld l,a
	ld a,(nextLineY)
	ld h,a
	call calculate.scrAddrDE
	//	DE = �������� ����� ������ ��� ������
	pop hl
; 	ld b,(ix+data.width)
nextLetterDraw
	push bc
	push hl
	ld a,(hl)
	or a
	jr nz,nld
	pop af
	pop af
	pop af
	ret



nld
	call calculate.letterAddr
	push de
	call draw.symbol
	ld a,(pause)
	cp 1
	jr nz,noPause
	call keyboard.anyKey
	jr z,noPause-2
	xor a
	ld (pause),a
	ei
	halt
noPause
	pop de
	inc e
	pop hl
	inc hl
	pop bc
	djnz nextLetterDraw
	ld a,(nextLineY)
	inc a
	ld (nextLineY),a
	pop hl
	inc hl
	inc hl
	jr nextLineDraw
//---------------------------------------------------------
/*
	������ �������� ������ �� ������:

	��������: ������ ������

		������� ������ �����, �������� �� ������ ������
		�������� ������
			���� ������ � ������ ������ = �� �������� ��� (TODO ��� ������ ������ ������)
		���� ������ ������ > 0 ���������� ������� else ��������� �� ����� ������ � ����� ��������� ���������� �����


*/
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
