        module calculate
mainProcess:
        ld a,(ix+data.width)
        cp 14
        jr nc,noRndWidth
        ld a,14
        call rndLimit
        add 16
        ld (ix+data.width),a
noRndWidth:
        call createMissing

        call textFormat.run
        call controlTuning
        ret
controlTuning
        //      position VS size

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
        //      DE = screen address
	ret
//-------------------
nextLine:
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
rnd:	dw 23821
rndLimit:
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
letterAddr:
        ; calc address of char in font
        ld l,a
        ld h,0 
        add hl,hl
        add hl,hl
        add hl,hl
fontAddr:
        ld bc,0
        add hl,bc       
        ; hl=address in font
        ret
//-------------------
getAttrAddr:
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
        ;      HL = attributes address from symbol coordinates
        ret
//-------------------
createMissing:
        ;       установить ширину текстовой области в 30 символов если не было задано
        ;       так-же установить координаты  X=0;Y=0;
        ld a,(ix+data.width)
        or a
        jr nz,standardFont
        ld (ix+data.x),a
        ld (ix+data.y),a
        ld (ix+data.width),30
standardFont:
        ;      установить стандартный шрифт если не был установленных
        ld a,(ix+data.fontAddr+1)
        cp #3c
        jr nc,blackWhiteColor
        ld (ix+data.fontAddr+1),#3c
        ld (ix+data.fontAddr),0
blackWhiteColor:
        ;      установить черный фон + белые буквы, если не задано + для рамки то-же самое
        ld c,7
        ld a,(ix+data.frameColor)
        or a
        jr nz,bwTextArea
        ld  (ix+data.frameColor),c
bwTextArea:
        ld a,(ix+data.areaColor)
        or a
        ret nz
        ld  (ix+data.areaColor),c
        ret
charRange09AZaz:
        CHAR_RANGE_09_AZ_az
	endmodule
