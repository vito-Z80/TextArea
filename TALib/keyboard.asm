	module keyboard

lastKey		db 0
//--------------------------------
anyKey
        ld hl,lastKey
        xor a
        in a,(#fe)
        cpl
        and #1f
        jr z,unpressed 	
	ld a,(23556)
	cp (hl)
unpressed
	ld (hl),a
        ret
//--------------------------------

	endmodule
