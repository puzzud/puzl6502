; VideoSystem.asm
; Apple

;------------------------------------------------------------------
!zone InitializeVideo
InitializeVideo
  ;jsr $fc58
  
  lda #0
  sta CLRTEXT
  sta CLRMIXED
  sta SETHIRES
  
  ;sta $3fb0
  ;sta $3fa9
  ;sta $3fac
  
  rts

;------------------------------------------------------------------
!zone SetBorderColor
SetBorderColor
SetBackgroundColor
SetCharacterColors
  rts

;------------------------------------------------------------------
!zone UpdateVideo
UpdateVideo

  lda #0
  clc
  asl
  tax
  lda SpriteYPosition,x
  tax
  lda SCREEN_LINE_OFFSET_TABLE_LO,x
  sta ZEROPAGE_POINTER_1
  lda SCREEN_LINE_OFFSET_TABLE_HI,x
  sta ZEROPAGE_POINTER_1+1

  lda #0
  clc
  asl
  tax
  lda SpriteXPosition,x
  tay
  
  lda #$55
  eor (ZEROPAGE_POINTER_1),y
  sta (ZEROPAGE_POINTER_1),y

  rts

;------------------------------------------------------------------
SCREEN_LINE_OFFSET_TABLE_LO
  !set y=0
  !do while y < SCREEN_LINE_HEIGHT {
    !set a=y/64
    !set d=y-(64*a)
    !set b=d/8
    !set c=d-(8*b)
    !byte ( HI_RES_PAGE_1 + ( 1024 * c ) + ( 128 * b ) + ( SCREEN_LINE_WIDTH * a ) ) & 0x00ff
    !set y=y+1
  }

SCREEN_LINE_OFFSET_TABLE_HI
  !set y=0
  !do while y < SCREEN_LINE_HEIGHT {
    !set a=y/64
    !set d=y-(64*a)
    !set b=d/8
    !set c=d-(8*b)
    !byte ( ( HI_RES_PAGE_1 + ( 1024 * c ) + ( 128 * b ) + ( SCREEN_LINE_WIDTH * a ) ) & 0xff00 ) >> 8
    !set y=y+1
  }

;------------------------------------------------------------------
CHARSET_TABLE_LO
  !set n=0
  !do while n < 256 {
    !byte ( CHARSET + ( 8 * n )  ) & 0x00ff
    !set n=n+1
  }

CHARSET_TABLE_HI
  !set n=0
  !do while n < 256 {
    !byte ( ( CHARSET + ( 8 * n ) ) & 0xff00 ) >> 8
    !set n=n+1
  }
