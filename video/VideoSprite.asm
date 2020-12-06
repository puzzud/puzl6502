;------------------------------------------------------------------
!zone SetXVelocity
SetXVelocity
  sta SpriteXVelocity,x        
  rts

;------------------------------------------------------------------
!zone SetYVelocity
SetYVelocity
  sta SpriteYVelocity,x        
  rts

;------------------------------------------------------------------
!zone GetDeltaFromVelocity
GetDeltaFromVelocity
  pha
  and #%01111000
  lsr
  lsr
  lsr
  sta PARAM2

  pla
  and #%00000111
  asl
  asl
  clc
  adc FrameCounterMod8CounterMod3
  tax
  lda FloatTable,x
  ldx FrameCounterMod8
  and BitTable,x
  beq +
  inc PARAM2
+
  rts

;------------------------------------------------------------------
!zone SetXAcceleration
SetXAcceleration
  sta SpriteXAcceleration,x        
  rts

;------------------------------------------------------------------
!zone SetYAcceleration
SetYAcceleration
  sta SpriteYAcceleration,x        
  rts

;------------------------------------------------------------------
!zone SetAnimation
SetAnimation
  pha
  
  sty SpriteAnimation,x

  tya
  pha
  clc
  asl
  tay
  
  txa
  pha
  clc
  asl
  tax
  
  lda #<ANIMATION_TABLE
  sta ZEROPAGE_POINTER_1
  lda #>ANIMATION_TABLE
  sta ZEROPAGE_POINTER_1+1
  
  lda (ZEROPAGE_POINTER_1),y
  sta SpriteAnimationPointer,x
  iny
  lda (ZEROPAGE_POINTER_1),y
  sta SpriteAnimationPointer+1,x
  
  pla
  tax
  
  lda SpriteAnimationDelay,x     ;reset counter.
  sta SpriteAnimationCounter,x
  ldy #0                      ;reset animation frame index
  jsr SetAnimationFrame
  
  pla
  tay
  
  pla
  rts

!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/video/c64/VideoSprite.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/video/nes/VideoSprite.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/video/apple/VideoSprite.asm"
}
