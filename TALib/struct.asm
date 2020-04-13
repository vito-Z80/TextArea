/*
	Байты в тексте:
		0 - конец строки
		1 - отступ	(1,4) второй байт = offset left
		2 - цвет	(2,4) второй символ = цвет
		3 - разделитель	(3) разделитель во всю следующую строку
		4 - спрайт	(4, width, height, align, attributes) 
				attributes or attrAddr ?
				если attributes включен - то атрибуты должны следовать сразу за спрайтом, иначе без атрибутов
				если attrAddr установлен - берем атрибуты с адреса, иначе без атрибутов.




	Коллекция адресов и коориднат спрайтов
		Адрес спрайта, width, height, align

	Коллекция обработанных строк для печати строк:
		Адрес текста, офсет Х, длина


	...	Расчет:
		взяли символ
		определили значение
		произвели расчеты относительно полученого значения
		сохранили данные в коллекцию
		повторили пока не наткнулись на конец текста
	...	Печать:
		отпечатали спрайты если имеются (мгновенно)
		узнали стиль печати текста
		отпечатали текст
		ожидаем нажатие любой клавиши
		выход
	...	Дополнительно:
		во время ожидания нажатия клавиши пускать блик атрибутов по диагонали, если задано, через определенное время.


	... 
		приняли байт с текущего адреса текста

		== символ поддержки:
			0 - завершение всего, ожидаем нажатие клавиши для выхода из процедуры печати
			1 - определили следующую строку, офсет, длину. сохранили: адресс текста, офсет, длину
			2 - установили текщему цвет. Дальше все атрибуты красятся в текущий цвет пока не будет изменено.
			3 - определили следующую строку, сохранили в коллекцию



	...
		печать текста:
			берутся заранее подготовленные адреса с коллекции где указан адрес текста текущей строки и ее длинна. 0 = конец печати
				типы печати:
					Мгновенно - сразу печатается.
					Печатная машинка - по одной букве через промежуток времени
					Принтер - по линии сверху вниз
					Принтер инверт - по линии снизу вверх
					Выползание снизу - буквы выползают из нижней части своей строки 
					Выползание сверху - буквы выползают из верхней части своей строки 
					Выползание слева - буквы выползают слева своего символа
					Жалюзи слева - буквы выползают с левого столбца слева направо.
					Рандом - буквы появляются каждая на своем месте но в случайном порядке через определенный промежуток времени.

				...	атрибутные (изначально закрашивается вся текстовая область одним цветом бумаги и чернил)
					Друг на друга по горизонтали - четные линии атрибутов движутся на встречу нечетных начиная 
						с краев текстовой области и заканчивая ими-же с противоположной стороны.
					Друг на бруга по вертикали - что и выше но по горизонтали.
					Диагональ одноцветная - диагональная линия пробегая открывает текст.
					Давгональ радужная - диагонвльная радужная линия открывает текст.


*/	

//--------------MACROS------------------------
	include "TALib/macros.asm"
	;	
	macro SET_HYPHENATION hyphenation
	ld (ix+data.hyphenation),hyphenation
	endm
	;	draw style
	macro SET_DRAW_STYLE style
	ld (ix+data.drawStyle),style
	endm
	;	frame position in symbols
	macro SET_POSITION x,y
	ld (ix+data.x),x
	ld (ix+data.y),y
	endm
	;	width/height text area in symbols
	macro SET_AERA_SIZE width,height
	ld (ix+data.width),width
	ld (ix+data.height),height
	endm
	;	font address
	macro SET_FONT_ADDRESS address
	ld (ix+data.fontAddr),low address
	ld (ix+data.fontAddr+1),high address
	endm
	;	text start address
	macro SET_TEXT_ADDRESS address
	ld (ix+data.textAddr),low address
	ld (ix+data.textAddr+1),high address
	endm
	;	text area color
	macro SET_AREA_COLOR color
	ld (ix+data.areaColor),color
	endm
	;	frame color
	macro SET_FRAME_COLOR color
	ld (ix+data.frameColor),color
	endm
	;	beep
	macro BEEP_ON
	ld (ix+data.beep),1
	endm
	macro BEEP_OFF
	ld (ix+data.beep),0
	endm
	;	delay
	macro SET_DELAY delay
	ld (ix+data.delay),delay
	endm
//---------------------------------------------

//-------------CONSTANTS---------------------
STANDARD 	equ 0
TYPEWRITER 	equ 1

TRUE 		equ 0
FALSE		equ 1
//---------------------------------------------

	struct data
//	coordinates and size in symbols
x		db	//	frame X
y		db	//	frame Y
width		db	//	text area WIDTH
height		db	//	text area HEIGHT  TODO (calculate frame height if this height more)
rndXY		db	//	!0 = use X,Y; 0 = calculate random X,Y
//	text wrapping: 0 - no; 1 - words; 2 - 
saveBGAddr	db	//	save and restore background; 0 as not use
hyphenation	db	//	0 - true; !0 = false;
drawStyle	db	//	0 = standard;
			//	1 = standard + pause between letters
			//	other used pause
			//	2 = creeping letters
			//	3 = creeping letters invert
			//	4 = draw vertical pixels
			//	5 = shift from left

			//	6 = random from existing
delay		db	//	pause value where 0 or 1 as one halt, other * halt
frameColor	db	//	frame color
areaColor	db	//	text area color
beep		db 	//	0 = sound off; !0 = sound on
frameShadowColor	db	//	frame shadow color; 0 as no shadow
fontAddr	dw	//	font address
textAddr	dw	//	text address

//------------

leftSpace	db 	// 	!0 = true; 0 = false (пробел(ы) начала любой строки удаляется если true)

	ends

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


	module HYPHENATION
ON	equ 0
OFF 	equ 1
	endmodule


BRIGHTNESS equ %01000000


	module TEXT
END	equ 0
INDENT	equ 1
COLOR	equ 2
RETURN_COLOR	equ 3

; 	MACRO SET_SPRITE spriteAddress,width,height,align,attributes
; 	dw	spriteAddress
; 	db	width, height, align, attributes
; 	ENDM

	endmodule