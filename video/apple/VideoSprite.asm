; VideoSprite.asm
; Apple

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
