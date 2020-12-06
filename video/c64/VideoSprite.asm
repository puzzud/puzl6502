; VideoSprite.asm
; Commodore 64

;------------------------------------------------------------------
!zone EnableSprite
EnableSprite
  lda VIC_SPR_ENA
  ora BitTable,x
  sta VIC_SPR_ENA
  rts

;------------------------------------------------------------------
!zone DisableSprite
DisableSprite
  lda VIC_SPR_ENA
  and InverseBitTable,x
  sta VIC_SPR_ENA
  rts

;------------------------------------------------------------------
!zone SetSpriteMultiColor
SetSpriteMultiColor
  pha
  
  cmp #1
  beq .multiColor
  cmp #2
  beq .extendedMultiColor

.notMultiColor
  lda VIC_SPR_MCOLOR
  and InverseBitTable,x
  sta VIC_SPR_MCOLOR
  jmp .endSetSpriteMultiColor

.multiColor
  lda VIC_SPR_MCOLOR
  ora BitTable,x
  sta VIC_SPR_MCOLOR
  jmp .endSetSpriteMultiColor

.extendedMultiColor
  cpx #7
  beq .endSetSpriteMultiColor
  lda VIC_SPR_MCOLOR
  and InverseBitTable,x
  inx
  ora BitTable,x
  dex
  sta VIC_SPR_MCOLOR
  
.endSetSpriteMultiColor
  pla
  
  rts

;------------------------------------------------------------------
!zone SetSpriteColors
SetSpriteColors
  pha
  
  ; TODO: fix this so multicolor modes are taken in account.
  sta VIC_SPR0_COLOR+1,x
  tya
  sta VIC_SPR0_COLOR,x
  
  lda PARAM1
  sta VIC_SPR_MCOLOR0
  lda PARAM2
  sta VIC_SPR_MCOLOR1
  
  pla
  
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
  sta VIC_SPR0_X,y
  sta VIC_SPR0_X+2,y
  
  sta SpriteXPosition,y
  
  lda PARAM2
  sta SpriteXPosition+1,y
  and #1
  beq +
  
  lda VIC_SPR_HI_X
  ora BitTable,x
  inx
  ora BitTable,x
  dex
  sta VIC_SPR_HI_X
  jmp ++
+
  lda VIC_SPR_HI_X
  and InverseBitTable,x
  inx
  and InverseBitTable,x
  dex
  sta VIC_SPR_HI_X
++
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
  sta VIC_SPR0_Y,y
  sta VIC_SPR0_Y+2,y
  
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
  inc SpriteAnimationFrameIndex,x
  ldy SpriteAnimationFrameIndex,x
  jmp .checkAnimationEnd
  
SetAnimationFrame
  sty SpriteAnimationFrameIndex,x
  
.checkAnimationEnd
  lda (SpriteAnimationPointer),y
  bpl .setNewAnimationFrame
  ldy #0                    ;reset animation to 0th frame.
  sty SpriteAnimationFrameIndex,x
  lda (SpriteAnimationPointer),y
  
.setNewAnimationFrame
  sta SPRITE_POINTER_BASE+1,x
  tay
  iny
  tya
  inx
  sta SPRITE_POINTER_BASE-1,x
  rts
