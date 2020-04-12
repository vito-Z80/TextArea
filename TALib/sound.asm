;
; Title:	ZX Spectrum 48K Sound Routines
; Author:	Dean Belfield
; Created:	11/08/2011
	module sound
; Call this every time you want to initialise a sound effect
; A = Variable 1
; B = Variable 2
; C = Duration of overall sound effect
; D = Duration of each step of the sound effect
SoundFX_A_Init:		
	LD (SoundFX_A_V2+1),A
	LD A,B
	LD (SoundFX_A_V3+1),A
	LD A,C
	LD (SoundFX_A_Main+1),A
	LD A,D
	LD (SoundFX_A_V1+1),A
	XOR A
	LD (SoundFX_A_V4),A
	RET

; Call this during your main loop
; It will play one step of the sound effect each pass
; until the complete sound effect has finished
;
SoundFX_A_Main:		
	LD A,0
	DEC A
	RET Z
	LD (SoundFX_A_Main+1),A
SoundFX_A_V1:		
	LD B,0
	LD HL,SoundFX_A_V4
SoundFX_A_L1:		
	LD C,B
	LD A,%00010000
	OUT (254),A
	LD A,(HL)
SoundFX_A_V2:		
	XOR 0
	LD B,A
	DJNZ $
	XOR A
	OUT (254),A
	LD A,(HL)
SoundFX_A_V3:		
	XOR 0
	LD B,A
	DJNZ $
	DEC (HL)
	LD B,C
	DJNZ SoundFX_A_L1
	RET
SoundFX_A_V4:		
	DEFB 0
; A = Variable 1
; B = Variable 2
; C = Duration of overall sound effect
; D = Duration of each step of the sound effect
;	FIX - enable the user to set values
setSound:
	ld a,25
	ld b,49
	ld c,2
	ld d,1
	call sound.SoundFX_A_Init
	ret
soundPlay
	ld b,2
step:
	push bc
	call sound.SoundFX_A_Main
	pop bc
	djnz step
	ret

	endmodule
