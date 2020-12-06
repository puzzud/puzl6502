; GameShell.asm
; Commodore 64

  !src "puzl/core/c64/c64.asm"

!set ramCounter = AfterProgramAndData

;==================================================================
*=$0801
!zone MainStart
  ;this creates a basic start
  ;SYS 2064
  !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00,$00,$00   
;==================================================================
MainStart
  jsr MainInitialize

  sei

  lda #%01111111
  sta CIA1_ICR
  sta CIA2_ICR

  lda CIA1_ICR
  lda CIA2_ICR

  lda VIC_IMR
  ora #%00000001
  sta VIC_IMR

  lda #248
  sta VIC_HLINE

  lda VIC_CTRL1
  ;ora #%10000000
  and #%01111111
  sta VIC_CTRL1

  lda #<DefaultInterrupt  ;this is how we set up
  sta $fffe  ;the address of our interrupt code
  lda #>DefaultInterrupt
  sta $ffff

  lda #%00110101
  sta LORAM

  cli

  jsr GameInitialize
.mainLoop
  jsr UpdateInput
  jsr IncrementFrameCounter
  jsr GameLoop
  
  ;wait for the raster to reach line $f8 (248)
  ;this is keeping our timing stable
  
  ;are we on line $F8 already? if so, wait for the next full screen
  ;prevents mistimings if called too fast
; .waitFrame
;   lda VIC_HLINE
;   cmp #248
;   beq .waitFrame
; 
;   ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
; .waitStep2
;   lda VIC_HLINE
;   cmp #248
;   bne .waitStep2
  
  jmp .mainLoop

;==================================================================

;------------------------------------------------------------------
!zone DefaultInterrupt
DefaultInterrupt
  pha
  txa
  pha
  tya
  pha

  lda #$ff
  sta VIC_IRR
  
  jsr ProcessMusic
            
  pla
  tay
  pla
  tax
  pla

EmptyInterrupt
  rti
