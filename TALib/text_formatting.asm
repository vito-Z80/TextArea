	module textFormat
dataAddr	block data,0  	//	data size
; one record is 4 bytes (text line address, offsetX, length)
collect:          block 22*4      
; start last text line address 
lineAddr:   dw 0           
; start last word address
wordAddr:   dw 0         
; line counter
lineCount:  db 0

currentColor:   db 0
previousColor:  db 0
	struct line
textAddr dw
offsetX  db
length	 db
	ends
	; когда определен конец строки и встречаем офсет, похоже происходит
	; еще раз переход строки
run:
	; clear data
	ld hl,collect
	ld de,collect+1
	ld bc,run-collect-1
	ld (hl),0
	ldir
	; start text address save value
	ld l,(ix+data.textAddr)
	ld h,(ix+data.textAddr+1)
	ld (wordAddr),hl
	ld (lineAddr),hl
	; max width (line length)
	ld c,(ix+data.width)
	; d - offset X
	; e - word length
	ld de,0
	; text area color save value
	ld a,(ix+data.areaColor)
	ld (currentColor),a
	ld (previousColor),a
	push ix
	ld ix,collect
process:
	; text line length
	ld a,c
	sub (ix+line.offsetX)
	ld b,a
nextChar:
	; get char
	ld a,(hl)
	or a
	jp nz,checkUserSymbols
	; exit process
	call nextLine
	ld (ix+line.textAddr+1),0
	pop ix
	ld b,(ix+data.height)
	ld a,(lineCount)
	cp b
	ret c
	ld (ix+data.height),a
	ret
checkUserSymbols:
	cp #20
	jr nc,notUserSymbol
	cp TEXT.INDENT
	jp z,setOffset
	cp TEXT.COLOR
	jr nz,oneInc
	inc hl
oneInc
	inc hl
	jr nextChar
;not user symbols
notUserSymbol:
	call calculate.charRange09AZaz
	cp #30
	jr nc,rangeChars
	; other symbols
	; reset word length
	ld e,0 
	inc (ix+line.length)
	inc hl
	ld (wordAddr),hl
	dec b
	jr nz,nextChar
	call nextLine
	jr process

rangeChars:
        ; used text characters
        inc hl
        inc (ix+line.length)
	; inc word length
        inc e 
        dec b
        jr nz,nextChar
; если следующий символ после конца строки
; тексотвый, то переносим последнее слово
; на новую строку
	ld a,(hl)
	call calculate.charRange09AZaz
	cp #30
	jr nc,transferWord
	ld (wordAddr),hl
	call nextLine
	jr process
transferWord:
	ld a,(ix+line.length)
	sub e
	ld (ix+line.length),a
	call  nextLine
        jr process
; save values and start next line procss
nextLine:
	ld hl,(lineAddr)
	ld (ix+line.textAddr),l
	ld (ix+line.textAddr+1),h
	inc ix
	inc ix
	inc ix
	inc ix
	ld hl,(wordAddr)
	ld (lineAddr),hl
	ld (ix+line.textAddr),l
	ld (ix+line.textAddr+1),h
	ld (ix+line.offsetX),0
	ld (ix+line.length),0
	ld a,(lineCount)
	inc a
	ld (lineCount),a
	ld de,0
	ret
setOffset:
	inc hl
	ld a,(hl)
	inc hl
	push af
	ld (wordAddr),hl
	ld a,c
	sub b
	or a
	jr z,newLineIsSet
	call nextLine
newLineIsSet:
	pop af
	ld (ix+line.offsetX),a
	xor a
	sub d
	ld (ix+line.length),a
	jp process
; set colors to text area

	endmodule
