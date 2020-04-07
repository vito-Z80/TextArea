	struct data
//	coordinates and size in symbols
x		db	//	frame X
y		db	//	frame Y
width		db	//	text area WIDTH
height		db	//	text area HEIGHT
rndXY		db	//	!0 = use X,Y; 0 = calculate random X,Y
autoHeight	db	//	!0 = use height; 0 = calculate height
//	text wrapping: 0 - no; 1 - words; 2 - 
saveBG		db 	//	TODO if true = save and restore background
wrap		db
drawStyle	db	//	0 = standard;
			//	1 = standard + pause between letters
			//	other used pause
			//	2 = creeping letters
			//	3 = creeping letters invert
			//	4 = draw vertical pixels
			//	5 = shift from left
waitLetter	db
frameColor	db	//	frame color
areaColor	db	//	text area color
beep		db 	//	0 = sound off; !0 = sound on
frameShadowColor	db
fontAddr	dw
textAddr	dw

	ends

