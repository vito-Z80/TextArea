    device zxspectrum48
; Author: Serdjuk
; Assembly: sjasmplus
    	org #6000
    	jp run
scr:
    	incbin "yanga.scr"
	include "TALib/lib/manager.asm"
run:
	ld hl,scr
	ld de,16384
	ld bc,6912
	ldir

; crash AF,AF`,HL,DE,BC,IX. Must save registers.
	; init library
	ld ix,data
	call init
//------------------------
//------------------------
main:
	SET_TEXT_DELAY 0
	inc a
	ld hl,startGame
	ld bc,#0101
	ld de,#1610
	call buildWithChooser
	call selected
	jr main
//------------------------
selected:
	or a
	jr z,simpleWindow
	cp 1
	jr z,coloredWindow
	ret
//------------------------
simpleWindow:
	SET_TEXT_DELAY 1
	ld hl,simpleWindowText
	ld bc,#0307
	ld de,#1018
	call build
	jr waitAnyKey
//------------------------
coloredWindow:
	ld a,INK.YELLOW|PAPER.BLUE|BRIGHTNESS
	ld bc,(INK.RED | PAPER.BLUE|BRIGHTNESS) *256+ (INK.BLUE | PAPER.CYAN)
	call setColor
	SET_TEXT_DELAY 1
	ld hl,coloredWindowText
	ld bc,#0505
	ld de,#0710
	call build
	jr waitAnyKey
//------------------------
	ld a,2
	out (254),a
	jr $
//------------------------

startGame:
keyboard: 	db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "Simple window"
kempston:	db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "Colored window"
sinclair:	db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "Sinclair I"
		db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "Sinclair II"
		db TEXT_SETTINGS.SEPARATOR
		db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "Redefine keys"
historyMenu:	db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "History"	
		db TEXT_SETTINGS.PARAGRAPH,6, TEXT_SETTINGS.SELECT, "About"	
		db TEXT_END
//------------------------

	ret

simpleWindowText:
	db "Simple text window with:"
	db TEXT_SETTINGS.PARAGRAPH, 1, "delay = 1 (SET_TEXT_DELAY 'N' macros)"
	db TEXT_SETTINGS.PARAGRAPH, 11, "paragraph '11'"
	db TEXT_SETTINGS.ALIGN_CENTER, "centered"
	db TEXT_SETTINGS.PARAGRAPH, 1, TEXT_SETTINGS.LINE_COLOR, INK.YELLOW|PAPER.BLUE, "color line"

	db TEXT_SETTINGS.PARAGRAPH, 1, TEXT_SETTINGS.FONT_ADDRESS
	dw ROM_FONT
	db "rom FONT"

	db TEXT_SETTINGS.PARAGRAPH, 1, TEXT_SETTINGS.FONT_ADDRESS
	dw font-256
	db "little FONT"
	db TEXT_SETTINGS.PARAGRAPH,1
	db TEXT_SETTINGS.PARAGRAPH,1
	db "'db TEXT_END' = end window text"
	db TEXT_SETTINGS.PARAGRAPH,1
	db "RED BORDER = text out of window (vertical)"
	db TEXT_END

coloredWindowText:
	db TEXT_SETTINGS.PARAGRAPH, 9
	db "A - area color"
	db TEXT_SETTINGS.PARAGRAPH, 9
	db "B - window edges color"
	db TEXT_SETTINGS.PARAGRAPH, 9
	db "C - window nooks color"
	db TEXT_SETTINGS.PARAGRAPH, 9
	db "CALL setColor"
	db TEXT_END

font:
	incbin "TALib/lib/littleFont.SpecCHR"
	
	savesna "C:\ZX\Addons\ue\qsave1.sna",#6000
	savetap "main.tap",#6000





