FLOAT_0   = 0
FLOAT_1_8 = 1
FLOAT_1_4 = 2
FLOAT_3_8 = 3
FLOAT_1_2 = 4
FLOAT_5_8 = 5
FLOAT_3_4 = 6
FLOAT_7_8 = 7
FLOAT_1   = 8

;------------------------------------------------------------------
!zone AddFloat
AddFloat
  sta PARAM1
  and #%10000000
  beq .positive

.negative
  tya
  pha
  sta PARAM2
  bpl .addNegativeToPositiveFloat
  jmp .addNegativeToNegativeFloat

.positive
  tya
  pha
  sta PARAM2
  bpl .addPositiveToPositiveFloat

.addPositiveToNegativeFloat
  ; A + -B = A - B
  and #%01111111
  sta PARAM2
  cmp PARAM1
  beq .p2nEqual
  bcc .p2nLess
.p2nGreater
  lda PARAM2
  sec
  sbc PARAM1
  ora #%10000000
  jmp .endAddFloat
.p2nLess
  lda PARAM1
  sec
  sbc PARAM2
  jmp .endAddFloat
.p2nEqual        
  lda #%00000000
  jmp .endAddFloat
  
.addPositiveToPositiveFloat
  ; A + B = A + B
  lda PARAM1
  clc
  adc PARAM2
  bpl .endAddFloat
  lda #%01111111
  jmp .endAddFloat
  
.addNegativeToPositiveFloat
  ; -A + B = B - A
  lda PARAM1
  and #%01111111
  sta PARAM1
  cmp PARAM2
  beq .n2pEqual
  bcc .n2pLess
.n2pGreater
  lda PARAM1
  sec
  sbc PARAM2
  ora #%10000000
  jmp .endAddFloat
.n2pLess
  lda PARAM2
  sec
  sbc PARAM1
  jmp .endAddFloat
.n2pEqual        
  lda #%10000000
  jmp .endAddFloat
  
.addNegativeToNegativeFloat
  ; -A + -B = -(A + B)
  and #%01111111
  sta PARAM2
  lda PARAM1
  and #%01111111
  clc
  adc PARAM2
  eor #%10000000
  bmi .endAddFloat
  lda #%11111111
  ;jmp .endAddFloat
  
.endAddFloat
  sta PARAM1
  pla
  tay
  lda PARAM1
  
  rts

;------------------------------------------------------------------
!zone SubstractFloat
SubstractFloat
  pha
  tya
  
  eor #%10000000
  tay
  pla
  jsr AddFloat
  
  pha
  tya
  
  eor #%10000000
  tay
  pla
  
  rts

;------------------------------------------------------------------
!zone FloatTable
FloatTable
  !byte %00000000, %00000000, %00000000, %00000000
  !byte %00000001, %00000001, %00000001, %00000000
  !byte %00010001, %00010001, %00010001, %00000000
  !byte %01001001, %01001001, %01001001, %00000000
  !byte %01010101, %01010101, %01010101, %00000000
  !byte %01011011, %01011011, %01011011, %00000000
  !byte %01110111, %01110111, %01110111, %00000000
  !byte %01111111, %01111111, %01111111, %00000000
  !byte %11111111, %11111111, %11111111, %00000000
