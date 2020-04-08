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
	//	return A = coordinate
	ret
//-------------------
letterAddr
        ; calc address of char in font
        ld l,a,h,0      ; a=char
        add hl,hl,hl,hl,hl,hl
fontAddr
        ld bc,0
        add hl,bc       ; hl=address in font
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
/*
        всё кроме букв может быть разорвано строкой, включая цифры
*/
lines   block 22*2 // адреса текста каждой вычисленной строки (максимум 22 строки для печати, конец == #00 high)
lastLineAddr    dw 0    //      адрес неразрываной строки слов
lastWordAddr    dw 0    //      адресс последнего проверяемого слова или знака препинания
textAreaWidth   db 0    //      ширина текста из раннее установленных данных
hyphenation
        ld l,(ix+data.textAddr)
        ld h,(ix+data.textAddr+1)
        ld (lastLineAddr),hl
        //     сохранили адресс начала текста для дальнейшего использования
        ld a,(ix+data.width)
        ld (textAreaWidth),a
        ld c,a
        //      сохранили ширину текстовой площади для дальнейшего использования

        push ix
        ld ix,lines     //      коллекция адресов линий текста

aga
        ld (ix),l
        ld (ix+1),h
        inc ix
        inc ix
        //      сохранили начало текста в первую ячейку коллекции адресов линий текста

        //      HELLO 

newLineProcess
        ld a,(ix+data.width)
        ld b,a                  // ширина строки     
        ld (lastLineAddr),hl    // сохраняем адрес начала слова на случай если слово не войдет в строку
checkNextChar

        


        //      определяем БуКвА в HL или нечто другое
        ld a,(hl)
        or a
        jr z,endText
        sub 32
;         or a
;         jr z,userSymbol
        cp 33
        jr c,split           
        sub 91-32
        cp 6
        jr c,split
        sub 123-91
        cp 5 
        jr c,split


;         inc hl
;         dec b
;         jr nz,checkNextChar
;         jr split
        ld (lastWordAddr),hl
word

        //----------------------twink
        inc hl
        dec b
        jr nz,w2
        ld a,(lastWordAddr)
        ld l,a
        ld a,(lastWordAddr+1)
        ld h,a
        jr aga
w2
        ld a,(hl)
        or a
        jr z,endText
        sub 32
;         or a
;         jr z,userSymbol
        cp 33
        jr c,split           
        sub 91-32
        cp 6
        jr c,split
        sub 123-91
        cp 5 
        jr c,split

        //----------------------

        jr word


endText
        ld (ix+1),0
        pop ix
        ret

split
        ld (lastWordAddr),hl
        inc hl
        dec b
        jr nz,checkNextChar
        ld (lastLineAddr),hl
        jr newLineProcess
userSymbol
        or a
        jr z,endText
        inc hl
        //      пользовательские символы такие как: цвет и т.д.
        ret
//------------------------------

hLoop   
        ld a,(hl)
        cp " "
        jr nz,countWordLength   //      если не пробел значит слово 
        inc hl
        dec c
        jp m,endLine    //      пробел выходит за передлы строки
        jr hLoop

countWordLength         //      считаем длинну слова и отнимаем ее от оставшейся ширина
        ld b,0
        ld (lastLineAddr),hl // сохраняем адрес начала слова на случай если слово не войдет в строку
cwlLoop
        inc b
        ld a,(hl)
        inc hl
        cp 0                    //      конец всего текста
        jr nz,cwl2
        //     установить точку выхода - старший байт конечного адреса текстовой линии в НОЛЬ
        inc ix
        ld (ix),a
        pop ix
        ret
cwl2
;         cp "."
;         jr z,cwl3
        cp " "                  //      конец слова
        jr nz,cwlLoop
cwl3
        ld a,c
        sub b
        ld c,a
        jp p,hLoop  //      слово вошло в строку - выходим, продолжаем
        //              слово не вошло в строку:
        //                      сохраняем адрес данного слова для новой строки
endLine
        ld a,(lastLineAddr)
        ld (ix),a
        ld a,(lastLineAddr+1)
        inc ix
        ld (ix),a
        inc ix
        //      восстанавливаем ширину строки
        ld a,(textAreaWidth)
        ld c,a
        jr hLoop
//-------------------
standard
        ld e,(ix+data.textAddr)
        ld d,(ix+data.textAddr+1)
        ld hl,lines
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
        jr s2
ending
        inc hl
        ld (hl),0
        ret
//-------------------
        display "hyphenation: ", /A, hyphenation
	endmodule
