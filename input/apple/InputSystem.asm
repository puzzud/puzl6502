; InputSystem.asm
; Apple

;------------------------------------------------------------------
!zone UpdateInput
ZERO
  !byte $00
ONE
  !byte $00
UpdateInput

  ldx #$00
  stx ONE
  stx ZERO
  
  ldx #127
  lda PDLTRIG
.loop
  lda PADDLE0
  and #%10000000
  asl
  rol
  adc ZERO
  sta ZERO
  
  lda PADDLE1
  and #%10000000
  asl
  rol
  adc ONE
  sta ONE
  
  dex
  bne .loop
  
.checkAxes
  stx joystickButtons ; x should be 0.

.checkXAxis
  lda #127
  sec
  sbc ZERO
  ;sta ZERO

  ;cmp #92
  ;beq .doneCheckingXAxis
  cmp #92+9
  bcs .pressingLeft
.pressingRight
  cmp #92-10
  bcs .doneCheckingXAxis
  lda joystickButtons
  ora #%00001000
  sta joystickButtons
  jmp .doneCheckingXAxis
.pressingLeft
  lda joystickButtons
  ora #%00000100
  sta joystickButtons
.doneCheckingXAxis

.checkYAxis
  lda #127
  sec
  sbc ONE
  ;sta ONE
  
  ;cmp #93
  ;beq .doneCheckingYAxis
  cmp #93+9
  bcs .pressingUp
.pressingDown
  cmp #93-10
  bcs .doneCheckingYAxis
  bcs .pressingUp
  lda joystickButtons
  ora #%00000010
  sta joystickButtons
  jmp .doneCheckingYAxis
.pressingUp
  lda joystickButtons
  ora #%00000001
  sta joystickButtons
.doneCheckingYAxis

  ; button3,button2,button1,button0,right,left,down,up
  
  rts
