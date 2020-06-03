
ROM_FONT	equ  #3C00

		struct TEXT_SETTINGS
NONE			byte
PARAGRAPH		byte	
SEPARATOR		byte	
LINE_COLOR		byte	
LINE_SHADED		byte  	; непосредственно перед тексом
FONT_ADDRESS		byte	
ALIGN_CENTER		byte	
ALIGN_RIGHT		byte	
ALIGN_LEFT		byte	
SELECT			byte	; непосредственно перед тексом
SPRITE			byte
	ends
TEXT_END		equ #FF


; 	macro WAIT_ANY_KEY
; 	call timer.waitAnyKey
; 	jr z,$-3
; 	endm

; 	macro ERROR_CODE color
; 	ld a,(ix+textSettings.nextY)
; 	sub (ix+textSettings.y)
; 	cp (ix+windowSettings.height)
; 	jr c,ec
; 	ld a,color
; 	out (254),a
; 	jr endShow
; ec:
; 	endm



	struct textSettings
//	основные настройки билда: x,y,addr
//	при следующем вызове будут использоваться предыдущие настройки
//	решено сделать что бы не вводить повторяющиеся настройки  каждый вызов, такие как: pad,delay,etc...
		//	public
x:			byte	//	x (pixels)
y:			byte	//	y (symbols)
addr:			dw 	//	text address
delay:			byte 	//	halt * it
pad: 			byte 	// 	left padding
resLeftSpace:		byte	//	reset left "SPACE" for new line
selectableLineAddr:	dw 	// 	address of seletable lines
selectableColor		byte
		//	private
spriteWidth		byte 	// 	in symbols
spriteHeight		byte	//	in symbols
lineWidth		byte	//	width of line
wordWidth:		byte	//      width of word
letterWidth:		byte	//	width of letter (set after calculate letter)
offsetX:		byte 	//	ofsset X from X
nextY:			byte	// 	next Y set for next line
previousChar:		byte	// 	used for check word wrap
	ends
	struct windowSettings, textSettings
x			byte 	//	in symbols
y			byte	//	in symbols
width			byte	//	in symbols
height			byte	//	in symbols
isWindowShow		byte
backgroundAddr:		dw
upKey:			byte
downKey:		byte
selectKey:		byte
resultSelect:		byte    	; have in selectable.asm
areaColor		byte
sidesColor		byte
nooksColor		byte
	ends

	macro SET_TEXT_DELAY delay
	ld a,delay
	ld (print.data+textSettings.delay),a
	endm

	macro SET_TEXT_NO_DELAY
	xor a
	ld (print.data+textSettings.delay),a
	endm

	//----------------CHAR RANGE---------------------
	macro CHAR_RANGE_09_AZ_az
; range [0-9A-Za-z] (english only)
; input: A
; return: if >= #30 == [0-9A-Za-z]
        cp #30
        ret c   
        sub #3A
        cp #07
        ret c 
        sub #21       
        cp #06
        ret c 
        sub #A5
        cp #7B
        ret c
        xor a
        ret
; FIX 
; инвертировать функцию так как для 
; получения результата [0-9A-Za-z]
; она должна пройти до последнего ret c
; В тексте чаще всего встречается [a-z]
; менее [A-Z] и [0-9]
	endm

	macro CHAR_RANGE_ALL
; range [" "- Ⓒ] (all chars of font)
; input: A
; return [" "- Ⓒ] or 0
	cp #20
	jr c,$+5
	cp #80
	ret c
	xor a
	ret
	endm

	//-------------------------------------------------------------
	module INK
BLACK	equ 0
BLUE	equ 1
RED	equ 2
PURPLE	equ 3
GREEN	equ 4
CYAN	equ 5
YELLOW 	equ 6
WHITE	equ 7
	endmodule

	module PAPER
BLACK	equ 0 << 3
BLUE	equ 1 << 3
RED	equ 2 << 3
PURPLE	equ 3 << 3
GREEN	equ 4 << 3
CYAN	equ 5 << 3
YELLOW 	equ 6 << 3
WHITE	equ 7 << 3
	endmodule
BRIGHTNESS 	equ %01000000
FLASH		equ #80
	//-------------------------------------------------------------