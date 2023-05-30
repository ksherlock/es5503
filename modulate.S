*
* test if AM mode does anything
*
*

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

* both osc 1 and 2 use the same sin wav for data
* but at vastly different frequencies.

	ldx #0
]loop	lda sin,x
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
	lda #{4-1}*2  ; osc to enable - 1 * 2
	sta GLU_DATA


	lda #$a0 ; control register.
	sta GLU_ADDR
	lda #%0000_0_00_1 ; channel 0, int off, free-run, halted
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA
	sta GLU_DATA


* am = freq 7, resolution 4 (2.01s)
* c4 = frq 14715, resolution 6
	lda #$01 ; #1 freq low
	sta GLU_ADDR
	lda #7
	sta GLU_DATA
	lda #14715
	sta GLU_DATA

	lda #$21 ; #1 freq high
	sta GLU_ADDR
	lda #>7
	sta GLU_DATA
	lda #>14715
	sta GLU_DATA

	lda #$41 ; volume register
	sta GLU_ADDR
	lda #$00
	sta GLU_DATA
*	stz GLU_DATA
	lda #$40
	sta GLU_DATA

	lda #$81 ; wave table ptr
	sta GLU_ADDR
	lda #0 ; page 0
	sta GLU_DATA
*	inc ; page 1
	sta GLU_DATA



	lda #$c1 ; wave table size
	sta GLU_ADDR
	lda #%00_000_000!4 ; 256 bytes, resolution = 4
	sta GLU_DATA
	lda #%00_000_000!6 ; 256 bytes, resolution = 6
	sta GLU_DATA


*	lda #$a1 ; control register.
*	sta GLU_ADDR
*	lda #%0000_0_10_0 ; channel 0, int off, sync/am mode, running
*	sta GLU_DATA

	lda #$a2
	sta GLU_ADDR
	lda #%0000_0_00_0 ; channel 0, int off, free-run, running
	sta GLU_DATA


keyloop
]loop
	lda $c000
	bpl :idle
	sta $c010
	and #$07
	asl
	tax
	jmp (table,x)
*	and #%01011111 ; remove high bit, upper-case it
*	cmp #'Q'
*	beq bye
*	cmp #'M'
*	beq toggle
*	bra ]loop

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

table
	dw keyloop	; @HPX
	dw bye		; AIQY
	dw keyloop 	; BJRZ
	dw keyloop	; CKS
	dw keyloop	; DLT
	dw toggle	; EMU
	dw keyloop	; FNV
	dw keyloop	; GOW


toggle



	lda #$a1 ; control register.
	sta GLU_ADDR
	lda #%0000_0_10_0 ; channel 0, int off, sync/am mode, running
	ora t
	sta GLU_DATA

*	lda t
	eor #1
	sta t

	brl keyloop

bye

* turn osc. off
	lda #$a0 ; control register.
	sta GLU_ADDR
	lda #%0000_0_00_1 ; channel 0, int off, free-run, halted
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
	hex 808386898c909396999c9fa2a5a8abae
	hex b1b3b6b9bcbfc1c4c7c9ccced1d3d5d8
	hex dadcdee0e2e4e6e8eaebedeff0f1f3f4
	hex f5f6f8f9fafafbfcfdfdfefefeffffff
	hex fffffffffefefefdfdfcfbfafaf9f8f6
	hex f5f4f3f1f0efedebeae8e6e4e2e0dedc
	hex dad8d5d3d1ceccc9c7c4c1bfbcb9b6b3
	hex b1aeaba8a5a29f9c999693908c898683
	hex 807d7a7774706d6a6764615e5b585552
	hex 4f4d4a4744413f3c393734322f2d2b28
	hex 262422201e1c1a1816151311100f0d0c
	hex 0b0a0807060605040303020202010101
	hex 0101010102020203030405060607080a
	hex 0b0c0d0f1011131516181a1c1e202224
	hex 26282b2d2f323437393c3f4144474a4d
	hex 4f5255585b5e6164676a6d7074777a7d


	typ sys
	sav modulate.sys
