;------------------------------------------------------------------
!zone DrawBlock
DrawBlock
  lda #BLOCK_STANDARD_NW
  sta PARAM1
  lda #(COLOR_LIGHT_GREEN | $f0)
  jsr PrintChar
  
  lda #BLOCK_STANDARD_NE
  sta PARAM1
  lda #(COLOR_LIGHT_GREEN | $f0)
  inx
  jsr PrintChar
  
  lda #BLOCK_STANDARD_SE
  sta PARAM1
  lda #(COLOR_LIGHT_GREEN | $f0)
  iny
  jsr PrintChar
  
  lda #BLOCK_STANDARD_SW
  sta PARAM1
  lda #(COLOR_LIGHT_GREEN | $f0)
  dex
  jsr PrintChar
  
  dey

  rts
