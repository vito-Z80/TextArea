        module calculate
;       всё кроме букв может быть разорвано строкой, включая цифры
;       one record is 4 bytes (text line address, offsetX, length)
lines:          block 22*4      
;       start last text line address 
lastLineAddr:   dw 0           
;       start last word address
lastWordAddr:   dw 0         
; start attribute address for text area
attributeAddr:  dw #0000 
currentColor:   db 0
previousColor:  db 0
mainProcess:
        call createMissing
        call getAttrAddr
        ld (attributeAddr),hl
        call textFormatting
        call controlTuning
        ret
controlTuning
        //      position VS size

        ret
//      format text 
textFormatting:
        ld l,(ix+data.textAddr)
        ld h,(ix+data.textAddr+1)
        ld (lastLineAddr),hl
        ld a,(ix+data.width)    ;      ширина ранее заданной текстовой области
        ld c,a
        inc c
        ld e,0
        push ix
        ld ix,lines   //      коллекция адресов линий текста
        xor a                   //      line count
        ex af,af
newLine:
        //      сохраним начало строки (оно может быть изменено далее)
        ld (ix),l
        ld (ix+1),h
        //      смещение и длина строки пока не известны
        ld (ix+2),0     
        ld (ix+3),0
        ld b,c
nextChar:
        ld a,(hl)       //      получили текущий символ
        cp 32
        jr c,userSymbols//      пользовательские символы (1-31)
        sub 32
        cp 33
        jr c,break      //      символ не является буквой и может быть перенесен на другую строку      
        sub 91-32
        cp 6
        jr c,break      //      символ не является буквой и может быть перенесен на другую строку
        sub 123-91
        cp 5 
        jr c,break      //      символ не является буквой и может быть перенесен на другую строку
//      word
        inc hl
        inc e
        dec b
        jr nz,nextChar
        ld hl,(lastWordAddr)
        ld (lastLineAddr),hl
        ld a,c
        sub e
        sub (ix+2)
        ld (ix+3),a     //      line length  
        ld e,0
        ex af,af
        inc a           //      add lines counter
        ex af,af
        jr b2
//------
userSymbols:
        or a
        jr z,endProc
        cp TEXT.INDENT
        jr z,newLineWithOffsetX
        cp TEXT.COLOR
        jr z,setColor
        cp TEXT.RETURN_COLOR
        jr z,returnColor

        ; if unregistered symbol
        jr endProc
//------
break:
        ld e,0
        inc hl
        ld (lastWordAddr),hl
        dec b
        jr nz,nextChar
        ex af,af
        inc a           //      add lines counter
        ex af,af
        dec hl
        ld a,c
        dec a
        ld (ix+3),a     //      line length  
b2:
        inc ix   
        inc ix   
        inc ix   
        inc ix   
        jr newLine
//------
newLineWithOffsetX:
        ex af,af
        inc a           //      add lines counter
        ex af,af
        inc hl
        ld a,c
        sub b
        ld (ix+3),a
        inc ix
        inc ix
        inc ix
        inc ix
        ld a,(hl)
        ld (ix+2),a     //      set offsetX
        inc hl
        ld (ix),l
        ld (ix+1),h
        ld (lastWordAddr),hl
        ld (lastLineAddr),hl

        ld b,c
        sub a
;         dec a
        ld (ix+3),a     //      length
        ld e,0

        jp nextChar
//------
endProc:
        ld a,c
        sub b
        jr z,ep1
        ld (ix+3),a     //      line length  
        ld (ix+5),0     //      end text lines collection
        jr ep2
ep1:
        ld (ix+1),0
ep2:
        ex af,af
        inc a           ;      line counter result
        pop ix
        ld c,(ix+data.height)
        ret c
        ld (ix+data.height),a
        ret
//-------------------
setColor
        ld a,(currentColor)
        ld (previousColor),a
        inc hl
        ld a,(hl)
sc
        ld (currentColor),a
        inc hl
        jp nextChar
; set previous color
returnColor
        ld a,(previousColor)
        jr sc
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
	endmodule
