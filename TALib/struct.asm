	struct data
//	coordinates and size in symbols
x		db	//	frame X
y		db	//	frame Y
width		db	//	text area WIDTH
height		db	//	text area HEIGHT  TODO (calculate frame height if this height more)
			//	FIX remove autoHeight and check this height more 22
rndXY		db	//	!0 = use X,Y; 0 = calculate random X,Y
autoHeight	db	//	!0 = use height; 0 = calculate height
//	text wrapping: 0 - no; 1 - words; 2 - 
saveBGAddr	db	//	save and restore background; 0 as not use
wrap		db	//	text wrap: 0 - linearly; 1 - to words; 2 - true is find symbol '-'
drawStyle	db	//	0 = standard;
			//	1 = standard + pause between letters
			//	other used pause
			//	2 = creeping letters
			//	3 = creeping letters invert
			//	4 = draw vertical pixels
			//	5 = shift from left

			//	6 = random from existing
pause		db	//	pause value where 0 or 1 as one halt, other * halt
frameColor	db	//	frame color
areaColor	db	//	text area color
beep		db 	//	0 = sound off; !0 = sound on
frameShadowColor	db	//	frame shadow color; 0 as no shadow
fontAddr	dw	//	font address
textAddr	dw	//	text address

//------------

leftSpace	db 	// 	!0 = true; 0 = false (пробел(ы) начала любой строки удаляется если true)

	ends

