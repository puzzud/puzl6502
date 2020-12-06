; AudioSystem.asm
; Commodore 64

;------------------------------------------------------------------
!zone InitializeAudio
InitializeAudio
  rts

;------------------------------------------------------------------
!zone SoundKillAll
SoundKillAll
  lda #0
  tax
.loop1
  sta SID_S1Lo,x
  inx
  cpx #14
  bne .loop1

  ldx #2
.loop2
  sta SID_FltLo,x
  dex
  bpl .loop2
  
  rts
