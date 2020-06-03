	module printText
// bit number of first byte each letter convert to reverse digit
init:
	call endShow
	ld b,96
	ld de,8
	ld hl,font
nextTopByte:
	ld a,(hl)
; 	sra a	; увеличит расстояние между буквами
	ld c,0
shiftByte:
	ex af,af
	inc c
	ld a,c
	cp 8
	jr nc,noBits
	ex af,af
	rlca
	cp 1
	jr nz,shiftByte
noBits:
	ld (hl),c
	add hl,de
	djnz nextTopByte
	ret
/*	
	TODO:
	
	настройки текста (присутствующие в самом тексте):
	------------------------------------------------
		конец текста: 1 байт (#FF)
			остановка печати и выход с процедуры.

		конец строки: 1 байт (#FE)
			конец строки в режими опций. Следующий текст печатается с новой строки.

		параграф: 2 байта (settings id, offset X in pixels)
			С текущей позиции переводит текст на новую строку с отступом слева заданным в offset X

		выравнивание: 1 байт
		распознать печатается текст в окне или на экране что бы просчитать выравнивание.
			1) по левоум краю
			2) по правому краю
			3) по центру
			если текст превышает ширину экрана или окна при отсутсвии символа конца строки,
			то выравнивание идет по левому краю.
			если текст прерывает символ параграфа, то далее выравнивание устанавливается на левое.

		спрайт: 6 байт (address, attributes, align ,width,height)
				address - sprite adderss
				attributes - если включено то печать спрайта с атрибутами которые должны находится после спрайта
				align - left or right only
				width & height in symbols
			спрайт печатается с новой строки относительно выравнивания окна или экрана. Текст 
			следующий за спрайтом огибает его по всей высоте спрайта так же учтывая выравнивание текста. 

	Предварительные настройки текста устанавливаемые пользователем перед печатью:
	---------------------------------------------------------------------------------------------
		позиция:
		распознать печатается текст в окне или на экране что бы просчитать позицию.
			1) x
			2) y
			при выравнивании по центру координата X не имеет значения.
		
		? ширина: width
			утанавливается пользователем при печати на экран, при печати в окно
			параметр не имеет значения.


		адрес текста
			адресс текста для печати



		в окне:
			если текст в окне то все просчеты вести относительно окна, иначе относительнно экрана

		опции:


*/
; выход текста за предела экрана по Y
; предатвращает дальнейшую печать и выводит цветовую ошибку на бордюр
; программа не крашится
checkHorizontalOutside:
	ld a,(ix+textSettings.nextY)
	cp 24
	jr c,cho
	ld a,3
	out (254),a
	pop af		; call gag
	jp endShow
cho:
	ld a,(ix+windowSettings.isWindowShow)
	or a
	jr z,noWindow
	ld a,2
noWindow:
	ld (varHeight+1),a
	ld a,(ix+textSettings.nextY)
	sub (ix+textSettings.y)
varHeight:
	add 2
	cp (ix+windowSettings.height)
	ret c
	ld a,2
	out (254),a
	pop af		; call gag
	jr endShow
checkOutisdeScreen:
	ld a,(ix+textSettings.nextY)
	cp 24
	ret c
	ld a,3
	out (254),a
	pop af		; call gag
	jr endShow
; calculate and show text
show:
	ld a,(ix+textSettings.addr+1)
	or a
	ret z
begin:
	xor a
	ld (ix+textSettings.previousChar),a
	ld a,(ix+textSettings.y)
	ld (ix+textSettings.nextY),a
	ld l,(ix+textSettings.addr)
	ld h,(ix+textSettings.addr+1)
pLoop:
	ld a,(hl)
	cp TEXT_END
	jr z,endShow

	call checkWordWrap
	call checkHorizontalOutside

	push hl
	ld a,(hl)
	call getChar
	call createLetter
	call printLetter
	pop hl
	ld a,(hl)
	ld (ix+textSettings.previousChar),a
	call delay
	inc hl
	jr pLoop
delay:
	ld a,(ix+textSettings.delay)
	or a
	ret z
	ld b,a
	ld a,(hl)
	cp " "
	jr z,delayAgain
; 	call sound.touchRune
delayAgain:
; 	ei
	halt
	djnz delayAgain
	ret
endShow:
	xor a
	ret
//---------------------------------------------------------------------------
nextLine:
	ld a,(ix+textSettings.nextY)
	inc a
	ld (ix+textSettings.nextY),a
	xor a
	ld (ix+textSettings.offsetX),a
	ld (ix+textSettings.letterWidth),a
	ld (ix+textSettings.previousChar),a
	ret
; draw separator always from new line
drawSeparator:
	push hl
	ld a,(ix+textSettings.offsetX)
	or a
	call nz,nextLine
	ld a,(ix+textSettings.x)
	srl a
	srl a
	srl a
	ld l,a
	ld h,(ix+textSettings.nextY)
	call print.scrAddrDE
	ld b,(ix+windowSettings.width)
	ld a,(ix+windowSettings.isWindowShow)
	or a
	jr z,nextSeparatorChar
	dec b
	dec b
nextSeparatorChar:
	ld hl,font-256+('*'*8)+1
	inc d
nsc2:
	ld a,(hl)
	ld (de),a
	inc hl
	inc d
	ld a,d
	and 7
	or a
	jr nz,nsc2
	ld a,d
	sub 8
	ld d,a
	inc e
	djnz nextSeparatorChar
	pop hl
	inc hl
	inc (ix+textSettings.nextY)
	ld (ix+textSettings.offsetX),0
	jp recursionUserSymbol
; text align center
textAlignCenter:
	call getStringLength
	inc hl
	ld a,(ix+textSettings.lineWidth)
	rr a
	rr e
	sub e
	ret c ; string width >= linewidth (no align center) 
	ld e,a
	ld a,(ix+textSettings.offsetX)
	or a
	jr z,cus2

	inc (ix+textSettings.nextY)
cus2:
	ld (ix+textSettings.offsetX),e
	xor a
	ld (ix+textSettings.letterWidth),a
	ld (ix+textSettings.previousChar),a
	jp recursionUserSymbol

; 	ld (ix+textSettings.offsetX),e
; 	xor a
; 	ld (ix+textSettings.letterWidth),a
; 	ld (ix+textSettings.previousChar),a
; 	inc hl
; 	jr recursionUserSymbol
; mark string as selectable
markSelectable:
	inc hl
; 	ld a,(ix+textSettings.offsetX)
; 	sub (ix+textSettings.y)
; 	or a
; 	jr nc,ms1
; 	xor a
; 	ld (ix+textSettings.offsetX),a
; 	ld (ix+textSettings.letterWidth),a
; 	ld (ix+textSettings.previousChar),a
; 	inc (ix+textSettings.nextY)
; ms1:

	push hl
	ld a,(ix+textSettings.nextY)
	ld hl,(print.data+textSettings.selectableLineAddr)
	ld (hl),a
	inc hl
	ld (print.data+textSettings.selectableLineAddr),hl
	pop hl
	jr recursionUserSymbol
; set font address
setFont:
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	ld (fontAddr+1),hl
	ex de,hl
	jr recursionUserSymbol
; line color
setLineColor:
	inc hl
	ld e,(hl)
	inc hl
	push hl
	ld l,(ix+textSettings.nextY)
	ld a,(ix+textSettings.x)
	call print.attrAddrHL
	ld b,(ix+windowSettings.width)
	ld a,(ix+windowSettings.isWindowShow)
	jr z,slc1
	dec b
	dec b
slc1:
	ld (hl),e
	inc l
	djnz $-2
	pop hl
	jr recursionUserSymbol
setParagraph:
	ld a,(ix+textSettings.offsetX)
	or a
	jr z,cus3
	ld a,(ix+textSettings.nextY)
	inc a
	ld (ix+textSettings.nextY),a
cus3
	inc hl
	ld a,(hl)
cus:
	ld (ix+textSettings.offsetX),a
	xor a
	ld (ix+textSettings.letterWidth),a
	ld (ix+textSettings.previousChar),a
	inc hl
	jr recursionUserSymbol
setShaded:
	inc hl
	ld (isShaded),a
	jr recursionUserSymbol
//---------------------------------------------------------------------------
checkUserSymbol:
; 	xor a
	ld (isShaded),a

	ld a,(hl)
	cp TEXT_SETTINGS.PARAGRAPH
	jr z,setParagraph
	cp TEXT_SETTINGS.ALIGN_CENTER
	jp z,textAlignCenter
	cp TEXT_SETTINGS.SELECT
	jp z,markSelectable ; mark the string selectable
	cp TEXT_SETTINGS.SEPARATOR
	jp z,drawSeparator
	cp TEXT_SETTINGS.FONT_ADDRESS
	jr z,setFont
	cp TEXT_SETTINGS.LINE_COLOR
	jr z,setLineColor
	cp TEXT_SETTINGS.LINE_SHADED
	jr z,setShaded
	inc hl
; 	ret
recursionUserSymbol:
	; FIX всем пользовательским символам добавить эту проверху с рекурсией после просчета
	ld a,(hl)
	call fullRange
	ret nz
	jr checkUserSymbol
//---------------------------------------------------------------------------
checkSymbolWrap:
	ld a,(hl)
	call fullRange
	or a
	jr z,checkUserSymbol
	push hl
	call getChar
	ld a,(hl)
	pop hl
	or a
	jr nz,symbolWidthNotZero
	ld a,8
symbolWidthNotZero:
	add (ix+textSettings.offsetX)
	add (ix+textSettings.letterWidth)
	dec a
	ret z
	cp (ix+textSettings.lineWidth)


	ret c
	ld a,(ix+textSettings.nextY)
	inc a
	ld (ix+textSettings.nextY),a
	xor a

	ld (ix+textSettings.offsetX),a
	ld (ix+textSettings.letterWidth),a
	ret
//---------------------------------------------------------------------------
checkWordWrap:


; 	ld a,(ix+textSettings.length)
; 	or a
; 	ret z 	; не проверяем перенос слов если неустановлена длинна строки (ширина рамки)
	ld d,#30 ; значение проверки диапазона
/*
	   previous	    current  	      check
	|char		|char		|not check	| 1
	|symbol		|char		|word		| 2
	|char		|symbol		|char		| 4
	|symbol		|symbol		|char		| 8
	|		|		|		|
*/
	ld e,1
	ld a,(hl)
	call range
	cp d
	jr nc,currentNotChar
	rlc e
	rlc e
currentNotChar:
	ld a,(ix+textSettings.previousChar)
	call range
	cp d
	jr nc,previousNotChar
	rlc e
previousNotChar:
	ld a,e
	or a
	srl a
	ret z
	srl a
	jr z,cww
	srl a
	jr z,checkSymbolWrap
	srl a
	jr z,checkSymbolWrap
	ret
cww:
	; начало слова
	; считаем ширину слова в пикселях
	ld e,0  ; word width
	push hl
addNextCharWidth:
	push hl
	ld a,(hl)
	call range
	cp d
	jr c,endCount
	call getChar
	ld a,(hl)	; letter width
	or a
	jr nz,not8Pix
	ld a,8
not8Pix:
	add e
	ld e,a		; word width
	pop hl
	inc hl
	jr addNextCharWidth
endCount:

	ld a,(ix+textSettings.letterWidth)
	add e
; 	dec a
; 	add (ix+textSettings.pad)
; без окна с паддинг = 0 херабора получается
; возможно пересмотреть print.asm
	add (ix+textSettings.offsetX)

; 	add (ix+textSettings.x)
	
; 	add e
; ; 	dec a
; 	add (ix+textSettings.letterWidth)

	// ?
; 	cp 120
; 	jp pe,setNextLine
	//

	jr c,setNextLine
	cp (ix+textSettings.lineWidth)
	jr c,endCheckWordWrap 
	; слово не влезло в строку
; 	ld e,0
; tooMatch:
; 	ld a,e
; 	;  0 - good; !0 - too match (go to next line)
; 	or a
; 	jr z,endCheckWordWrap
	; перенос на следующую строку
setNextLine:
	ld a,(ix+textSettings.nextY)
	inc a
	ld (ix+textSettings.nextY),a
	xor a
	ld (ix+textSettings.offsetX),a
	ld (ix+textSettings.letterWidth),a


endCheckWordWrap:
	pop hl
	pop hl
	ret

; get string text lenght 
getStringLength:
	ld e,0
	push hl

	inc hl
	ld a,(hl)
	call fullRange
	jr z,$-5

nextCharLength:
	ld a,(hl)
	call fullRange
	jr z,endLength
	push hl
	call getChar
	ld a,(hl)
	or a
	jr nz,nclNot8Width
	ld a,8
nclNot8Width:
	add e
	ld e,a
	pop hl
	inc hl
	jr nextCharLength
endLength:
	pop hl
	ret

printLetter:
	; not print top byte
	ld hl,print.letterBuffer+2
	inc d 
	ld b,7
nextByteLetter:
	ld a,(de)
	or (hl)
	ld (de),a
	inc hl
	inc e
	ld a,(de)
	or (hl)
	ld (de),a
	inc hl
	dec e
	inc d
	djnz nextByteLetter
	ret
createLetter:
	//	hl - letter address

	call copyLetterToBuffer

	; прибавили к смещению ширину прошлой буквы
	ld a,(ix+textSettings.offsetX)
	add (ix+textSettings.letterWidth)
	ld (ix+textSettings.offsetX),a

	; x + offsetX
; 	ld a,(ix+textSettings.x)
	add (ix+textSettings.x)
	push af
	and 7
	or a 
	; не делать сдвиг если позиция кратна 8
	call nz,shiftBuffer
	pop af
	srl a
	srl a
	srl a
	ld l,a
	ld h,(ix+textSettings.nextY)
	call print.scrAddrDE
	//	letter width 
	ld a,(print.letterBuffer)
	or a
	jr nz,not8Width
	add 8
not8Width:
	ld (ix+textSettings.letterWidth),a
	ret

; FIX !!!! печатаем букву 7 в высоту. Исправить !!!! копирование и сдвиг только 7 байт !!!!!!!!!

copyLetterToBuffer:
	//	hl letter address
	ld a,(isShaded)
	or a
	jr nz,copyShadedLetterToBuffer
	ld de,print.letterBuffer
	ld bc,#0800 	
cltb:
	ld a,(hl)
	ld (de),a
	inc de
	ld a,c
	ld (de),a
	inc de
	inc hl
	djnz cltb
	ret
isShaded: db 0
copyShadedLetterToBuffer:
	ld de,print.letterBuffer
	ld b,8
	ld c,%10101010
csltb:
	ld a,(hl)
	and c
	ld (de),a
	inc de
	ld a,0
	ld (de),a
	inc de
	inc hl
	rrc c
	djnz csltb
	ret




//	shift letter in buffer
shiftBuffer:
	ld b,a
	ld hl,print.letterBuffer+2 ; не сдвигаем верхние байты, там данные (ширина буквы)
	push bc
	ld b,7
onePass:
	rr (hl)
	inc hl
	rr (hl)
	inc hl
	djnz onePass
	pop bc
	djnz shiftBuffer+1
	ret
getChar:
        ld l,a,h,0      ; a=char
        add hl,hl,hl,hl,hl,hl
fontAddr:
        ld bc,font-256
;         ld bc,15616-256
        add hl,bc       ; hl=address in font
        ret
range:
	CHAR_RANGE_09_AZ_az
fullRange:
	CHAR_RANGE_ALL



//------------MODELS--------------------


	endmodule
