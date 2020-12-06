; VideoPrint.asm
; NES

;------------------------------------------------------------------
!zone SetPrintYPosition
SetPrintYPosition
  pha
  
  ; Set character pointer to beginning of row Y.
  lda SCREEN_LINE_OFFSET_TABLE_LO,y
  sta PrintCharacterPointer
  lda SCREEN_LINE_OFFSET_TABLE_HI,y
  sta PrintCharacterPointer+1
  
  ; Set color pointer to beginning of row Y.
  lda SCREEN_COLOR_LINE_OFFSET_TABLE_LO,y
  sta PrintColorPointer
  lda SCREEN_COLOR_LINE_OFFSET_TABLE_HI,y
  sta PrintColorPointer+1
  
  pla

  rts

;------------------------------------------------------------------
!zone PrintChar
PrintChar
  sta PARAM2

  pha
  txa
  pha
  tya
  pha
  
  lda SCREEN_LINE_OFFSET_TABLE_LO,y
  sta ZEROPAGE_POINTER_1
  lda SCREEN_LINE_OFFSET_TABLE_HI,y
  sta ZEROPAGE_POINTER_1+1
  
  txa
  clc
  adc ZEROPAGE_POINTER_1
  sta ZEROPAGE_POINTER_1
  lda #0
  adc ZEROPAGE_POINTER_1+1
  sta ZEROPAGE_POINTER_1+1
  
  clc
  lda ZEROPAGE_POINTER_1
  adc #((ScreenColorBuffer-ScreenCharacterBuffer)&0xff)
  sta ZEROPAGE_POINTER_2
  lda ZEROPAGE_POINTER_1+1
  adc #((ScreenColorBuffer-ScreenCharacterBuffer)&0xff00)>>8
  sta ZEROPAGE_POINTER_2+1
  
  ldy #0
  lda PARAM1
  lda PARAM2
  
  ;Declare that the name table and attribute table needs to be updated.
  lda #1
  sta UpdateNameTable
  sta UpdateAttributeTable
  
  pla
  tay
  pla
  tax
  pla
  
  rts

;------------------------------------------------------------------
!zone PrintString
PrintString
  pha
  txa
  pha
  tya
  pha
  
  ; Get address of character draw message header.
  lda ScreenCharacterBufferIndex
  clc
  adc #<ScreenCharacterBuffer
  sta ScreenCharacterMessageHeader
  lda #0
  adc #>ScreenCharacterBuffer
  sta ScreenCharacterMessageHeader+1
  
  ; Get address of character draw message body.
  lda ScreenCharacterBufferIndex
  clc
  adc #3
  sta ScreenCharacterBufferIndex
  clc
  adc #<ScreenCharacterBuffer
  sta ScreenCharacterMessageBody
  lda #0
  adc #>ScreenCharacterBuffer
  sta ScreenCharacterMessageBody+1
  
  ; Make sure a null string hasn't been posted.
  ldy #0
  lda (ZEROPAGE_POINTER_1),y
  bne .writeCharacterMessageHeaderLoop
  ldy ScreenCharacterBufferIndex
  dey
  dey
  dey
  sty ScreenCharacterBufferIndex
  jmp .printStringEnd
  
  ; Write body.
  ldy #0
.writeCharacterMessageHeaderLoop
  lda (ZEROPAGE_POINTER_1),y
  beq .writeCharacterMessageHeaderLoopEnd
  sta (ScreenCharacterMessageBody),y
  iny
  jmp .writeCharacterMessageHeaderLoop
.writeCharacterMessageHeaderLoopEnd
  
  ; End entire message with a 0 (likely the start of next message).
  ;lda #0 ; accumulator should already be 0.
  sta (ScreenCharacterMessageBody),y
  
  ; Store length of message body.
  sty PARAM3
  
  ; Add length of message to index.
  tya
  clc
  adc ScreenCharacterBufferIndex
  sta ScreenCharacterBufferIndex
  
  ; Write header.
  ; TODO: Reverse the order for highest interrupt safety.
  ldy #0
  lda PARAM3
  sta (ScreenCharacterMessageHeader),y
  iny
  iny
  
  lda PrintCharacterPointer
  clc
  adc PrintXPosition
  sta (ScreenCharacterMessageHeader),y
  dey
  
  lda #0
  adc PrintCharacterPointer+1
  sta (ScreenCharacterMessageHeader),y
  
.printStringDone
  ;Declare that the name table needs to be updated.
  lda #1
  sta UpdateNameTable
  
  ; Get address of color draw message header.
  lda ScreenColorBufferIndex
  clc
  adc #<ScreenColorBuffer
  sta ScreenColorMessageHeader
  lda #0
  adc #>ScreenColorBuffer
  sta ScreenColorMessageHeader+1
  
  ; Get address of color draw message body.
  lda ScreenColorBufferIndex
  clc
  adc #3
  sta ScreenColorBufferIndex
  clc
  adc #<ScreenColorBuffer
  sta ScreenColorMessageBody
  lda #0
  adc #>ScreenColorBuffer
  sta ScreenColorMessageBody+1
  
  ; Write body. Translate the color code (palette number) to MMC5 form.
  ldy PrintColor
  lda PALETTE_NUMBER_TO_MMC5_TABLE,y
  ldy #0
  sta (ScreenColorMessageBody),y
  iny
  
  ; End entire message with a 0 (likely the start of next message).
  lda #0
  sta (ScreenColorMessageBody),y
  
  ; Add length of message to index.
  inc ScreenColorBufferIndex
  
  ; Write header.
  ; TODO: Reverse the order for highest interrupt safety.
  ldy #0
  lda PARAM3
  sta (ScreenColorMessageHeader),y
  iny
  iny
  
  lda PrintColorPointer
  clc
  adc PrintXPosition
  sta (ScreenColorMessageHeader),y
  dey
  
  lda #0
  adc PrintColorPointer+1
  sta (ScreenColorMessageHeader),y
  ;;;
  
  ; Declare that the attribute table needs to be updated.
  lda #1
  sta UpdateAttributeTable
  
.printStringEnd
  pla
  tay
  pla
  tax
  pla
  
  rts

;------------------------------------------------------------------
!zone FillScreen
FillScreen
  rts
