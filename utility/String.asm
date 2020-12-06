;------------------------------------------------------------------                                             
!zone IntegerToString
INTEGER_TO_STRING_MAX_LENGTH = 5
IntegerToStringBuffer = ramCounter
!set ramCounter = ramCounter+INTEGER_TO_STRING_MAX_LENGTH+1
IntegerToStringOutput = ramCounter
!set ramCounter = ramCounter+INTEGER_TO_STRING_MAX_LENGTH+1
IntegerToString
  ;set up pointer to output string.
  lda #<IntegerToStringOutput
  sta ZEROPAGE_POINTER_1
  lda #>IntegerToStringOutput
  sta ZEROPAGE_POINTER_1+1

  ;set up pointer to buffer string.
  lda #<IntegerToStringBuffer
  sta ZEROPAGE_POINTER_2
  lda #>IntegerToStringBuffer
  sta ZEROPAGE_POINTER_2+1
  
  lda PARAM1
  ldy PARAM2
  
  ;set up index variable.
  ldx #0
  stx ZEROPAGE_POINTER_3
.buildBufferLoop
  ldx #10
  jsr div16Bits
  
  ldy ZEROPAGE_POINTER_3
  lda PARAM4
  sta (ZEROPAGE_POINTER_2),y
  
  inc ZEROPAGE_POINTER_3
  
  ;if( resullt == 0 )
  lda PARAM2
  ora PARAM3
  beq .buildBufferLoopEnd
  
  lda PARAM2
  ldy PARAM3
  
  jmp .buildBufferLoop
.buildBufferLoopEnd

  ldy ZEROPAGE_POINTER_3
  lda #0
  sta (ZEROPAGE_POINTER_1),y
  
  ; Reverse buffer to make correct output
  cpy #0
  beq .endIntegerToString
  
  dey
  tya
  tax
  ldy #0
.reverseIntegerStringLoop
  lda IntegerToStringBuffer,x
  clc
  adc #'0'
  sta (ZEROPAGE_POINTER_1),y
  iny
  dex
  bpl .reverseIntegerStringLoop

.endIntegerToString
  rts
