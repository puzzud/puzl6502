; InputSystem.asm
; Commodore 64

;------------------------------------------------------------------
!zone UpdateInput
UpdateInput
  ldx #0
  
.joystickLoop
  lda joystickButtons,x
  sta joystickOldButtons,x
  
  lda CIA1_DDRA,x
  sta PARAM1
  
  cli
  
  lda #$00
  sta CIA1_DDRA,x
  
  lda CIA1_PRA,x
  eor #$ff
  and #%00011111
  sta joystickButtons,x
  
  lda PARAM1
  sta CIA1_DDRA,x
  
  sei
  
  lda joystickOldButtons,x
  eor #$ff
  and joystickButtons,x
  sta joystickPressedButtons,x
  
  inx
  cpx #NUMBER_OF_JOYSTICKS
  bne .joystickLoop
  
  rts
