; Author: Serdjuk
; Assembly: sjasmplus

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
1:
	xor a
	ret
	endm