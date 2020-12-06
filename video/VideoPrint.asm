; Reserve variables for general printing.
PrintCharacterPointer = zeroPageCounter
!set zeroPageCounter = zeroPageCounter+2

PrintColorPointer = zeroPageCounter
!set zeroPageCounter = zeroPageCounter+2

PrintXPosition = zeroPageCounter
!set zeroPageCounter = zeroPageCounter+1

PrintColor = zeroPageCounter
!set zeroPageCounter = zeroPageCounter+1

;------------------------------------------------------------------
!zone ClearScreen
ClearScreen
  pha
  
  lda #' '
  jsr FillScreen
  
  pla
  rts
  
;------------------------------------------------------------------
!zone PrintInteger
PrintInteger
  pha
  tya
  pha
  txa
  pha
  
  jsr IntegerToString
  
  pla
  tax
  pla
  tay
  pla
  
  jsr PrintString
  
  rts

;------------------------------------------------------------------
!zone PrintByte
PrintByteString = ramCounter
!set ramCounter = ramCounter+9
PrintByte
  sta PARAM1

  txa
  pha
  tya
  pha

  ldx #0
  ldy #8
  
  ; Store string terminator.
  lda #0
  sta PrintByteString,y
  
  dey
.printByteLoop
  lda PARAM1
  and BitTable,x
  beq +
  lda #'1'
  sta PrintByteString,y
  jmp .nextBit
+
  lda #'0'
  sta PrintByteString,y

.nextBit
  inx
  dey
  cpx #8
  bne .printByteLoop
  
  pla
  tay
  pla
  tax
  
  lda #<PrintByteString
  sta ZEROPAGE_POINTER_1
  lda #>PrintByteString
  sta ZEROPAGE_POINTER_1+1
  lda PARAM1
  jsr PrintString
  
  rts

;------------------------------------------------------------------
!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/video/c64/VideoPrint.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/video/nes/VideoPrint.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/video/apple/VideoPrint.asm"
}
