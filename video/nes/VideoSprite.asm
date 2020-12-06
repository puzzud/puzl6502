; VideoSprite.asm
; NES

;------------------------------------------------------------------
!zone EnableSprite
EnableSprite
  rts

;------------------------------------------------------------------
!zone DisableSprite
DisableSprite
  rts
  
;------------------------------------------------------------------
!zone SetSpriteMultiColor
SetSpriteMultiColor
  rts

;------------------------------------------------------------------
!zone SetSpriteColors
SetSpriteColors
  rts
  
;------------------------------------------------------------------
!zone SetXPosition
SetXPosition
  sta PARAM1
  sty PARAM2
  
  txa
  pha
  clc
  asl
  tay
  
  lda PARAM1
  sta SpriteXPosition,y
  
  sta (SpriteBuffer+3)+4*0
  sta (SpriteBuffer+3)+4*2
  clc
  adc #8
  sta (SpriteBuffer+3)+4*1
  sta (SpriteBuffer+3)+4*3
  
  lda PARAM2
  sta SpriteXPosition+1,y
  
  pla
  tax
  
  lda PARAM1
  ldy PARAM2
  
  rts

;------------------------------------------------------------------
!zone SetYPosition
SetYPosition
  sta PARAM1
  sty PARAM2
  
  txa
  pha
  clc
  asl
  tay
  
  lda PARAM1
  sta SpriteYPosition,y
  
  sta (SpriteBuffer+0)+4*0
  sta (SpriteBuffer+0)+4*1
  clc
  adc #8
  sta (SpriteBuffer+0)+4*2
  sta (SpriteBuffer+0)+4*3
  
  lda PARAM2
  sta SpriteYPosition+1,y

  pla
  tax
  
  lda PARAM1
  ldy PARAM2
  
  rts

;------------------------------------------------------------------
!zone SetAnimationFrame
SetNextAnimationFrame
SetAnimationFrame
  rts
