	module calculate
scrAddrDE
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
        //      DE = screen address
	ret
//-------------------
nextLine
        ; next screen line address
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
//-------------------
rnd	dw 23821
rndLimit
	//	A = limit
	ld c,a
	ld hl,(rnd)
	ld a,h
	sbc a,l
	ld l,a
	add hl,hl
	ld (rnd),hl
	and 63
1:
	srl a
	cp c
	jr nc,1B
	//	return A 
	ret
//-------------------
letterAddr
        ; calc address of char in font
        ld l,a
        ld h,0 
        add hl,hl
        add hl,hl
        add hl,hl
fontAddr
        ld bc,0
        add hl,bc       
        ; hl=address in font
        ret
//-------------------
attributesAddr
        ld l,(ix+data.y)
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld b,#58
        ld c,(ix+data.x)
        add hl,bc
        //      HL = attributes address from symbol coordinates
        ret
//-------------------
increaseWidth
        //      ���������� ������ ��������� ������� � 16 ���� �� ���� ������ (data.height==0)
        ld a,(ix+data.width)
        or a
        ret nz
        ld (ix+data.width),16
        ret
//-------------------
        //      FIX      ���������� �������� ���������� ��� increaseWidth ������� ����� ������ ����� ������
increaseHeight
        //      �������� ������ ��������� ������� ���� ���������� ���� ������ ������ ��� �� ���� ������ �����
        ld a,0
        cp (ix+data.height)
        ret c
        ld (ix+data.height),a
        ret
//-------------------
standardFont
        //      ���������� ����������� ����� ���� �� ��� �������������
        ld a,(ix+data.fontAddr+1)
        cp #3c
        ret nc
        ld (ix+data.fontAddr+1),#3c
        ld (ix+data.fontAddr),0
        ret
//-------------------
blackWhiteColor
        //      ���������� ������ ��� + ����� �����, ���� �� ������ + ��� ����� ��-�� �����
        ld c,7
        ld a,(ix+data.frameColor)
        or a
        jr nz,bwTextArea
        ld  (ix+data.frameColor),c
bwTextArea
        ld a,(ix+data.areaColor)
        or a
        ret nz
        ld  (ix+data.areaColor),c
        ret
//-------------------
/*
        �� ����� ���� ����� ���� ��������� �������, ������� �����
*/
lines   block 22*2 // ������ ������ ������ ����������� ������ (�������� 22 ������ ��� ������, ����� == #00 high)
lastLineAddr    dw 0    //      ����� ������������ ������ ����
lastWordAddr    dw 0    //      ������ ���������� ������������ ����� ��� ����� ����������
textAreaWidth   db 0    //      ������ ������ �� ������ ������������� ������
hyphenation
        ld l,(ix+data.textAddr)
        ld h,(ix+data.textAddr+1)

        ld c,(ix+data.width)    //      ������ ��������� �������
        push ix
        ld ix,lines     //      ��������� ������� ����� ������
        xor a                  //      ������� �����
        ex af,af
newLineProcess
        ex af,af
        ld (ix),l               // ��������� ������ ������ ����� ������
        ld (ix+1),h
        inc ix
        inc ix
        inc a                   // ��������� ������� �����
        ex af,af
        ld b,c                  // ������ ������     
        ld (lastLineAddr),hl    // ��������� ����� ������ �� ������ ������� ������
checkNextChar
        ld de,saveLastWord      // �� defineChar �������� �� ������ DE ���� ������ == �����, != �������� �� ��������� split
        jr defineChar
saveLastWord
        ld (lastWordAddr),hl
wordProcess                     // ���� ������������ ����� ��� ����� ������
        inc hl
        dec b
        //------------------------
        jr z,endLine            // ����� ������
        ld de,wordProcess       // �� defineChar �������� �� ������ DE ���� ������ == �����, != �������� �� ��������� split
        jr defineChar
endLine
        ld a,(hl)
        sub 32
        cp 33
        jr c,newLineProcess           
        sub 91-32
        cp 6
        jr c,newLineProcess
        sub 123-91
        cp 5 
        jr c,newLineProcess
        ld hl,(lastWordAddr)
        jr newLineProcess
        //------------------------
;         jr nz,w2                // �� ����� ������ (������)
;         ld hl,(lastWordAddr)
;         jr newLineProcess
; w2
;         ld de,wordProcess       // �� defineChar �������� �� ������ DE ���� ������ == �����, != �������� �� ��������� split
;         jr defineChar


endText
        ld e,0
        ld (ix+1),e     //      ���������� ����� ����� � ��������� ��� '0'
        ld a,b
        cp c
        jr nz,et2
        //      ���� ��������� ������ ������ ��� ��������� �������� ������ �� ��������� ���-�� �����
        inc e
et2
        ex af,af
        sub e
        ld (increaseHeight+1),a   //      ��������� ������ (���-�� ������������ �����)
        pop ix
        ret
split
        //      �������� ����(��������) ������� ����� ���� ��������� �������. ����� �������� � ��������.
        ld (lastWordAddr),hl
        inc hl
        dec b
        jr nz,checkNextChar
        jr newLineProcess
userSymbol
        //      ���������������� ������� ����� ���: ���� � �.�.
        or a
        jr z,endText
        inc hl
        ret
//-------------------
defineChar
        //      ����������: ����� ��� ����� ������
        ld a,(hl)
        or a
        jr z,endText    //      ����� ������
        sub 32
;         or a
;         jr c,userSymbol       //      ���������������� ������� (1-31)
        cp 33
        jr c,split           
        sub 91-32
        cp 6
        jr c,split
        sub 123-91
        cp 5 
        jr c,split
        push de
        ret             //      ��������� �� ������ DE
//-------------------
standard
        ld e,(ix+data.textAddr)
        ld d,(ix+data.textAddr+1)
        ld hl,lines
        ld c,1
s2
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl 
        ld b,(ix+data.width)
s1
        inc de
        ld a,(de)
        or a
        jr z,ending
        djnz s1
        inc c
        jr s2
ending
        inc hl
        ld (hl),0
        ld a,c
        ld (increaseHeight+1),a
        ret
//-------------------
        display "hyphenation: ", /A, hyphenation
	endmodule
