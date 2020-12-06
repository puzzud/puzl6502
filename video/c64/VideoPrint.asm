; VideoPrint.asm
; Commodore 64

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
  pha
  sty PARAM2
  
  ldy PrintXPosition
  sta (PrintCharacterPointer),y
  lda PrintColor
  sta (PrintColorPointer),y
  
  ldy PARAM2
  pla
  
  rts

;------------------------------------------------------------------
!zone PrintString
PrintString
  pha
  tya
  pha
  
  ldy #0
.printStringLoop
  ; Load character byte from input string.
  lda (ZEROPAGE_POINTER_1),y
  
  ; End on null terminator.
  cmp #0
  beq .printStringDone
  
  sty PARAM1
  
  ldy PrintXPosition
  sta (PrintCharacterPointer),y
  lda PrintColor
  sta (PrintColorPointer),y
  inc PrintXPosition
  
  ldy PARAM1
  iny
    
  jmp .printStringLoop

.printStringDone
  
  pla
  tay
  pla
  
  rts

;------------------------------------------------------------------
!zone FillScreen
FillScreen
  sta PARAM1
  
  txa
  pha
  tya
  pha

  ; Fill character memory.
  ; Algorithm assumes even pages, thus -1 to high byte and zeroing of low byte of address.
  lda #>SCREEN_CHAR+SCREEN_CHAR_SIZE-1
  sta ZEROPAGE_POINTER_1+1
  tax ; Set up X to be part of loop as a secondary decrementer.
  ldy #0 ; Also, setting Y's starting value in loop.
  sty ZEROPAGE_POINTER_1
  
  lda PARAM1
.fillScreenCharacterLoop
  dey
  sta (ZEROPAGE_POINTER_1),y
  bne .fillScreenCharacterLoop
  dex
  cpx #>SCREEN_CHAR-1
  beq .endFillScreenCharacter
  stx ZEROPAGE_POINTER_1+1
  bne .fillScreenCharacterLoop
.endFillScreenCharacter

  ; Fill color memory.
  lda #>SCREEN_COLOR+SCREEN_CHAR_SIZE-1
  sta ZEROPAGE_POINTER_1+1
  tax
  
  lda #0
  sta ZEROPAGE_POINTER_1
  tay
  
  lda PrintColor
.fillScreenColorLoop
  dey
  sta (ZEROPAGE_POINTER_1),y
  bne .fillScreenColorLoop
  dex
  cpx #>SCREEN_COLOR-1
  beq .endFillScreenColor
  stx ZEROPAGE_POINTER_1+1
  bne .fillScreenColorLoop
.endFillScreenColor

  pla
  tay
  pla
  tax
  
  lda PARAM1
  
;   lda #<SCREEN_COLOR
;   sta ZEROPAGE_POINTER_2
;   lda #>SCREEN_COLOR
;   sta ZEROPAGE_POINTER_2+1

;   ldx #0
; .FillRow
;   ldy #0
; .FillRowColumn
;   lda PARAM1
;   sta (ZEROPAGE_POINTER_1),y
;   
;   lda PARAM2
;   sta (ZEROPAGE_POINTER_2),y
;   
;   iny
;   cpy #SCREEN_CHAR_WIDTH
;   bcs .AdvanceToNextRow
;   jmp .FillRowColumn
; .AdvanceToNextRow
;   inx
;   cpx #SCREEN_CHAR_HEIGHT
;   bcs .FillScreenDone
;   
;   clc
;   lda ZEROPAGE_POINTER_1
;   adc #SCREEN_CHAR_WIDTH
;   sta ZEROPAGE_POINTER_1
;   lda #0
;   adc ZEROPAGE_POINTER_1+1
;   sta ZEROPAGE_POINTER_1+1
;   
;   clc
;   lda ZEROPAGE_POINTER_2
;   adc #SCREEN_CHAR_WIDTH
;   sta ZEROPAGE_POINTER_2
;   lda #0
;   adc ZEROPAGE_POINTER_2+1
;   sta ZEROPAGE_POINTER_2+1
;   
;   jmp .FillRow
;  
; .FillScreenDone
  rts
