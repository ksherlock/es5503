*
* AM test/demo
*
*
* North American busy signal - 480 + 620 hz.  .5 seconds on, .5 seconds off. 
* 8 oscillators - 2 for 480 + AM, 2 for 620 + AM, 4 unused.
* (mono :/ )
* 480 hz = res 6, freq = 44995
* 620 hz = res 5, freq = 29059
* am/timer:
* 1 second = res 7, freq 187

o1_res	equ 7
o2_res	equ 6
o3_res	equ 7
o4_res	equ 5

o1_freq	equ 187
o2_freq	equ 44995
o3_freq	equ 187
o4_freq	equ 29059

o1_vol	equ 0
o2_vol	equ $40
o3_vol	equ 0
o4_vol	equ $40

o1_page	equ 1
o2_page	equ 0
o3_page	equ 1
o4_page	equ 0

* 0000_0_10_0
o1_cr	equ %0000_0_10_0 ; channel 0, int off, sync/am mode, running
o2_cr	equ %0000_0_00_0 ; channel 0, int off, free-run, running
o3_cr	equ %0000_0_10_0 ; channel 0, int off, sync/am mode, running
o4_cr	equ %0000_0_00_0 ; channel 0, int off, free-run, running




	org $2000
	mx %11

GLU_CTRL	equ $c03c
GLU_DATA	equ $c03d
GLU_ADDR	equ $c03e ; and c03f

ESQ_FRQ_LO	equ	$00
ESQ_FRQ_HI	equ	$20
ESQ_VOL		equ $40
ESQ_DATA	equ $60
ESQ_WTP		equ $80
ESQ_CTRL	equ $a0
ESQ_WSZ		equ $c0

* write to doc memory, enable auto-incremement
	lda GLU_CTRL
	ora #%0_1_1_0_0000
	sta GLU_CTRL

	stz GLU_ADDR
	stz GLU_ADDR+1

	ldx #0
]loop	lda sin,x
	sta GLU_DATA
	inx
	bne ]loop

]loop	lda vol,x
	sta GLU_DATA
	inx
	bne ]loop



* write to registers, auto-increment on
	lda GLU_CTRL
	and #%1_0_1_1_1111
	sta GLU_CTRL
	stz GLU_ADDR
	stz GLU_ADDR+1



	lda #$e1 ; osc. enable register
	sta GLU_ADDR
	lda #{8-1}*2  ; osc to enable - 1 * 2
	sta GLU_DATA


	lda #$a0 ; control register.
	sta GLU_ADDR
	lda #%0000_0_00_1 ; channel 0, int off, free-run, halted
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA



	lda #$01 ; #1 freq low
	sta GLU_ADDR
	lda #o1_freq
	sta GLU_DATA
	lda #o2_freq
	sta GLU_DATA
	lda #o3_freq
	sta GLU_DATA
	lda #o4_freq
	sta GLU_DATA


	lda #$21 ; #1 freq high
	sta GLU_ADDR
	lda #>o1_freq
	sta GLU_DATA
	lda #>o2_freq
	sta GLU_DATA
	lda #>o3_freq
	sta GLU_DATA
	lda #>o4_freq
	sta GLU_DATA

	lda #$41 ; volume register
	sta GLU_ADDR
	lda #o1_vol
	sta GLU_DATA
	lda #o2_vol
	sta GLU_DATA
	lda #o3_vol
	sta GLU_DATA
	lda #o4_vol
	sta GLU_DATA

	lda #$81 ; wave table ptr
	sta GLU_ADDR
	lda #o1_page
	sta GLU_DATA
	lda #o2_page
	sta GLU_DATA
	lda #o3_page
	sta GLU_DATA
	lda #o4_page
	sta GLU_DATA


	lda #$c1 ; wave table size
	sta GLU_ADDR
	lda #o1_res
	sta GLU_DATA
	lda #o2_res
	sta GLU_DATA
	lda #o3_res
	sta GLU_DATA
	lda #o4_res
	sta GLU_DATA


*	lda #$a1 ; control register.
*	sta GLU_ADDR
*	lda #%0000_0_10_0 ; channel 0, int off, sync/am mode, running
*	sta GLU_DATA

	lda #$a1
	sta GLU_ADDR
	lda #o1_cr
	sta GLU_DATA
	lda #o2_cr
	sta GLU_DATA
	lda #o3_cr
	sta GLU_DATA
	lda #o4_cr
	sta GLU_DATA


keyloop
]loop
	lda $c000
	bpl ]loop
*	bpl :idle
	sta $c010
	and #%01011111 ; remove high bit, upper-case it
	cmp #'Q'
	beq bye
	cmp #$11 ; '1'
	beq one
	cmp #$12 ; '2'
	beq two
	bra ]loop

	do 0
:idle
* print osc 1/2 data registers to screen
	lda #ESQ_DATA+1
	sta GLU_ADDR
	lda GLU_DATA ; dummy read
	lda GLU_DATA
	tay ; save
	and #$f0
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex,x
	sta $0400 ; screen
	tya
	and #$0f
	tax
	lda hex,x
	sta $0401	

	lda GLU_DATA
	tay ; save
	and #$f0
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex,x
	sta $0404 ; screen
	tya
	and #$0f
	tax
	lda hex,x
	sta $0405	

* print osc 3 volume register 
	lda #ESQ_VOL+2 ; volume register
	sta GLU_ADDR
	lda GLU_DATA ; dummy read
	lda GLU_DATA
	tay ; save
	and #$f0
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex,x
	sta $0408 ; screen
	tya
	and #$0f
	tax
	lda hex,x
	sta $0409

	;


	bra keyloop
	fin

one ; turn on/off osc #2

	lda :t
	eor #1
	sta :t
	lda #$a2
	sta GLU_ADDR
	lda #0
	ora :t
	sta GLU_DATA

	brl keyloop
:t	dw 1

two ; turn on/off osc #4

	lda :t
	eor #1
	sta :t
	lda #$a4
	sta GLU_ADDR
	lda #0
	ora :t
	sta GLU_DATA

	brl keyloop
:t	dw 1


bye

* turn osc. off
	lda #$a0 ; control register.
	sta GLU_ADDR
	lda #%0000_0_00_1 ; channel 0, int off, free-run, halted
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA


exit
	inc $03f4  ; invalidate power-up byte
	jsr $bf00
	db $65
	dw quitrec
	brk $00

quitrec
	db 4
	db 0
	dw 0
	db 0
	dw 0


t	dw 0

hex	asc "0123456789abcdef"

sin
*	hex 808386898c909396999c9fa2a5a8abae
*	hex b1b3b6b9bcbfc1c4c7c9ccced1d3d5d8
*	hex dadcdee0e2e4e6e8eaebedeff0f1f3f4
*	hex f5f6f8f9fafafbfcfdfdfefefeffffff
*	hex fffffffffefefefdfdfcfbfafaf9f8f6
*	hex f5f4f3f1f0efedebeae8e6e4e2e0dedc
*	hex dad8d5d3d1ceccc9c7c4c1bfbcb9b6b3
*	hex b1aeaba8a5a29f9c999693908c898683
*	hex 807d7a7774706d6a6764615e5b585552
*	hex 4f4d4a4744413f3c393734322f2d2b28
*	hex 262422201e1c1a1816151311100f0d0c
*	hex 0b0a0807060605040303020202010101
*	hex 0101010102020203030405060607080a
*	hex 0b0c0d0f1011131516181a1c1e202224
*	hex 26282b2d2f323437393c3f4144474a4d
*	hex 4f5255585b5e6164676a6d7074777a7d

	hex 808283858688898b8c8e909193949697
	hex 989a9b9d9ea0a1a2a4a5a6a7a9aaabac
	hex adaeafb0b1b2b3b4b5b6b7b8b8b9babb
	hex bbbcbcbdbdbebebebfbfbfc0c0c0c0c0
	hex c0c0c0c0c0c0bfbfbfbebebebdbdbcbc
	hex bbbbbab9b8b8b7b6b5b4b3b2b1b0afae
	hex adacabaaa9a7a6a5a4a2a1a09e9d9b9a
	hex 989796949391908e8c8b898886858382
	hex 807e7d7b7a7877757472706f6d6c6a69
	hex 6866656362605f5e5c5b5a5957565554
	hex 535251504f4e4d4c4b4a494848474645
	hex 45444443434242424141414040404040
	hex 40404040404041414142424243434444
	hex 454546474848494a4b4c4d4e4f505152
	hex 5354555657595a5b5c5e5f6062636566
	hex 68696a6c6d6f7072747577787a7b7d7e

* on / off with a slight ramp
vol
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 01010101010101010101010101010101
	hex 0105090d1115191d2125292d3135393d
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 40404040404040404040404040404040
	hex 3d3935312d2925211d1915110d090501



	typ sys
	sav busy.am.sys
