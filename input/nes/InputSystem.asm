; InputSystem.asm
; NES

;------------------------------------------------------------------
!zone UpdateInput
UpdateInput
  lda joystickButtons
  sta joystickOldButtons
  
  ldx #$01
  stx JOYPAD1_REG
  dex
  stx JOYPAD1_REG
.JoystickLoop
  lda JOYPAD1_REG
  lsr
  ror joystickButtons
  inx
  cpx #8
  bne .JoystickLoop
  
  lda joystickButtons
  cmp #%10000000
  rol
  cmp #%10000000
  rol
  cmp #%10000000
  rol
  cmp #%10000000
  rol  
  sta joystickButtons
  
  eor #$ff
  and joystickButtons
  sta joystickPressedButtons
  
  rts
