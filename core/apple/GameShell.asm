; GameShell.asm
; Apple

  !src "puzl/core/apple/apple.asm"
  
!set ramCounter = START_OF_RAM

;==================================================================
;*=$0bfc
*=$3ffc
  ; Apple II program executable header.
  !word MainStart
  !word (AfterProgramAndData-MainStart)

;==================================================================
;*=$0c00
*=$4000
!zone MainStart
MainStart
  jsr MainInitialize
  jsr GameInitialize

.mainLoop
  jsr UpdateInput
  jsr IncrementFrameCounter
  jsr GameLoop
  jsr WaitFrame
  jsr UpdateVideo
  jmp .mainLoop
  
;------------------------------------------------------------------
!zone WaitFrame
WaitFrame
  lda RDVBLBAR
  bmi WaitFrame
  rts
