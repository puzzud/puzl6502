; Joystick expected bit flag format
; button3,button2,button1,button0,right,left,down,up

;------------------------------------------------------------------
!zone InitializeInput
InitializeInput
  lda #0
  ldx #NUMBER_OF_JOYSTICKS
.clearJoystickDataLoop
  dex
  sta joystickButtons,x
  sta joystickOldButtons,x
  sta joystickPressedButtons,x
  bne .clearJoystickDataLoop
  rts

!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/input/c64/InputSystem.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/input/nes/InputSystem.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/input/apple/InputSystem.asm"
}
