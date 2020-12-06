; VideoPrint.asm
; Apple

PrintYPosition = zeroPageCounter
!set zeroPageCounter = zeroPageCounter+1

;------------------------------------------------------------------
!zone SetPrintYPosition
SetPrintYPosition
  sty PrintYPosition
  
  ; Set character pointer to beginning of row Y.
;   lda SCREEN_LINE_OFFSET_TABLE_LO,y
;   sta PrintCharacterPointer
;   lda SCREEN_LINE_OFFSET_TABLE_HI,y
;   sta PrintCharacterPointer+1

  rts

;------------------------------------------------------------------
!zone PrintChar
PrintChar
;   pha
;   txa
;   pha
;   
;   sta PARAM2 ; X coordinate.
;   
;   tya
;   pha
;   
;   ldx PARAM1
;   lda CHARSET_TABLE_LO,x
;   sta ZEROPAGE_POINTER_3
;   lda CHARSET_TABLE_HI,x
;   sta ZEROPAGE_POINTER_3+1
;   
;   tya       ; Y coordinate.
;   asl
;   asl
;   asl
;   tax
;   
;   ldy #0
; .printByteSliceLoop
;   
;   lda (ZEROPAGE_POINTER_3),y
;   
;   sty PARAM3
;   ldy PARAM2
;   sta (PrintCharacterPointer),y
;   
;   ldy PARAM3
;   
;   inx
;   iny
;   cpy #8
;   bne .printByteSliceLoop
;   
;   pla
;   tay
;   pla
;   tax
;   pla
  
  rts

;------------------------------------------------------------------
!zone PrintString
PrintString
  pha
  txa
  pha
  tya
  pha
  
  lda PrintYPosition
  asl
  asl
  asl
  sta PARAM4  ; Y coordinate.
  
  ldy #0
.printStringLoop
  lda (ZEROPAGE_POINTER_1),y
  beq .printStringDone
  
  tax
  lda CHARSET_TABLE_LO,x
  sta ZEROPAGE_POINTER_3
  lda CHARSET_TABLE_HI,x
  sta ZEROPAGE_POINTER_3+1

  sty PARAM5

  ldx PARAM4
  ldy #0
.printByteSliceLoop

  lda SCREEN_LINE_OFFSET_TABLE_LO,x
  sta ZEROPAGE_POINTER_2
  lda SCREEN_LINE_OFFSET_TABLE_HI,x
  sta ZEROPAGE_POINTER_2+1
  
  lda (ZEROPAGE_POINTER_3),y
  
  sty PARAM3
  ldy PrintXPosition
  sta (ZEROPAGE_POINTER_2),y
  
  ldy PARAM3
  
  inx
  iny
  cpy #8
  bne .printByteSliceLoop
  
  inc PrintXPosition
  ldy PARAM5
  
  iny
  jmp .printStringLoop

.printStringDone
  
  pla
  tay
  pla
  tax
  pla
  
  rts
  
;------------------------------------------------------------------
!zone FillScreen
FillScreen
  lda #<HI_RES_PAGE_1
  sta ZEROPAGE_POINTER_1
  lda #>HI_RES_PAGE_1
  sta ZEROPAGE_POINTER_1+1
  
  ldy #0
  ldx #>HI_RES_PAGE_SIZE
  
  lda #0
.fillScreenLoop
  sta (ZEROPAGE_POINTER_1),y
  iny
  bne .fillScreenLoop
  inc ZEROPAGE_POINTER_1+1
  dex
  bne .fillScreenLoop
  
  
  rts
