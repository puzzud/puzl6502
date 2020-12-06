; AudioSystem.asm
; NES

;------------------------------------------------------------------
!zone InitializeAudio
InitializeAudio
  lda #%00000001
  sta $4015
  rts

;------------------------------------------------------------------
!zone PlayBeep
PlayBeep
  lda #$86
  sta $4000
  lda #$b9
  sta $4002
  lda #$00
  sta $4003
  rts
