; VideoSystem.asm
; Commodore 64

;------------------------------------------------------------------
InitializeVideo
  jsr InitializeCharacterGraphics
  jsr InitializeSprites

  rts

;------------------------------------------------------------------
InitializeCharacterGraphics
  ;VIC bank
  lda CIA2_PRA
  and #%11111100  ; bank 3  base vic mem = $c000
  sta CIA2_PRA
  
  ;block interrupts 
  ;since we turn ROMs off this would result in crashes if we didn't
  sei
  
  ;set charset
  lda #%00111100  ; screen mem = $c000 + $0c00 = $cc00
                  ; char mem   = $c000 + $f000 = $f000
  sta VIC_VIDEO_ADR

  ;save old configuration
  lda LORAM
  sta PARAM1

  ;only RAM
  ;to copy under the IO rom
  lda #%00110000
  sta LORAM

  ;take source address from CHARSET
  lda #<CHARSET
  sta ZEROPAGE_POINTER_1
  lda #>CHARSET
  sta ZEROPAGE_POINTER_1+1
  
  ;now copy
  jsr CopyCharacterSet
  
  ;restore ROMs
  lda PARAM1
  sta LORAM

  cli
  
  ;enable multi color charset
  lda VIC_CTRL2
  ora #%00010000
  sta VIC_CTRL2
  
  rts

;------------------------------------------------------------------
InitializeSprites
  ;init sprite registers
  ;no visible sprites
  lda #$0
  sta VIC_SPR_ENA
  
  ; All sprites normal scale.
  sta VIC_SPR_EXP_X
  sta VIC_SPR_EXP_Y
  
  ;take source address from SPRITES
  lda #<SPRITES
  sta ZEROPAGE_POINTER_1
  lda #>SPRITES
  sta ZEROPAGE_POINTER_1+1
  
  sei
  
  ;save old configuration
  lda LORAM
  sta PARAM1

  ;only RAM
  ;to copy under the IO rom
  lda #%00110000
  sta LORAM
  
  jsr CopySprites

  ;restore ROMs
  lda PARAM1
  sta LORAM

  cli

  rts

;------------------------------------------------------------------
!zone CopyCharacterSet
CopyCharacterSet
  ;set target address ($f000)
  lda #<CHARACTER_GRAPHICS_TARGET
  sta ZEROPAGE_POINTER_2
  lda #>CHARACTER_GRAPHICS_TARGET
  sta ZEROPAGE_POINTER_2+1

  ldx #$00
  ldy #$00
  lda #0
  sta PARAM2

.NextLine
  lda (ZEROPAGE_POINTER_1),Y
  sta (ZEROPAGE_POINTER_2),Y
  inx
  iny
  cpx #$08
  bne .NextLine
  cpy #$00
  bne .PageBoundaryNotReached
  
  ;we've reached the next 256 bytes, inc high byte
  inc ZEROPAGE_POINTER_1+1
  inc ZEROPAGE_POINTER_2+1

.PageBoundaryNotReached

  ;only copy 254 chars to keep irq vectors intact
  inc PARAM2
  lda PARAM2
  cmp #254
  beq .CopyCharsetDone
  ldx #$00
  jmp .NextLine

.CopyCharsetDone
  rts

;------------------------------------------------------------------
!zone CopySprites
CopySprites
  ldy #$00
  ldx #$00

  lda #<SPRITE_GRAPHICS_TARGET
  sta ZEROPAGE_POINTER_2
  lda #>SPRITE_GRAPHICS_TARGET
  sta ZEROPAGE_POINTER_2+1
    
  ;4 sprites per loop
.SpriteLoop
  lda (ZEROPAGE_POINTER_1),y
  sta (ZEROPAGE_POINTER_2),y
  iny
  bne .SpriteLoop
  inx
  inc ZEROPAGE_POINTER_1+1
  inc ZEROPAGE_POINTER_2+1
  cpx #NUMBER_OF_SPRITES_DIV_4
  bne .SpriteLoop

  rts
  
;------------------------------------------------------------------
!zone SetBorderColor
SetBorderColor
  sta VIC_BORDERCOLOR
  rts

;------------------------------------------------------------------
!zone SetBackgroundColor
SetBackgroundColor
  sta VIC_BG_COLOR0
  rts

;------------------------------------------------------------------
!zone SetCharacterColors
SetCharacterColors
  sta VIC_BG_COLOR1
  sty VIC_BG_COLOR2
  rts

;------------------------------------------------------------------
SCREEN_LINE_OFFSET_TABLE_LO
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT {
    !byte ( SCREEN_CHAR + ( SCREEN_CHAR_WIDTH * n )  ) & 0x00ff
    !set n=n+1
  }

SCREEN_LINE_OFFSET_TABLE_HI
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT {
    !byte ( ( SCREEN_CHAR + ( SCREEN_CHAR_WIDTH * n ) ) & 0xff00 ) >> 8
    !set n=n+1
  }
  
SCREEN_COLOR_LINE_OFFSET_TABLE_LO
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT {
    !byte ( SCREEN_COLOR + ( SCREEN_CHAR_WIDTH * n )  ) & 0x00ff
    !set n=n+1
  }

SCREEN_COLOR_LINE_OFFSET_TABLE_HI
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT {
    !byte ( ( SCREEN_COLOR + ( SCREEN_CHAR_WIDTH * n ) ) & 0xff00 ) >> 8
    !set n=n+1
  }
      