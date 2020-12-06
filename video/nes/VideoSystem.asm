; VideoSystem.asm
; NES

; Sprite buffer.
SpriteBuffer = ramCounter
!set ramCounter = ramCounter + (NUMBER_OF_HARDWARE_SPRITES * BYTES_PER_HARDWARE_SPRITE)

; Screen Character (background).
ScreenCharacterBuffer = ramCounter
!set ramCounter = ramCounter + $100

ScreenCharacterBufferPointer = zeroPageCounter
ScreenCharacterMessageHeader = zeroPageCounter + 2
ScreenCharacterMessageBody   = zeroPageCounter + 4
ScreenCharacterBufferIndex   = zeroPageCounter + 6
!set zeroPageCounter = zeroPageCounter + 7

; Screen Color (background).
ScreenColorBuffer = ramCounter
!set ramCounter = ramCounter + $100

ScreenColorBufferPointer = zeroPageCounter
ScreenColorTarget        = zeroPageCounter + 2
ScreenColorMessageHeader = zeroPageCounter + 4
ScreenColorMessageBody   = zeroPageCounter + 6
ScreenColorBufferIndex   = zeroPageCounter + 8
ScreenColorBufferTemp    = zeroPageCounter + 9
!set zeroPageCounter = zeroPageCounter + 10

; Palette buffers.
CharacterPaletteBuffer = ramCounter
!set ramCounter = ramCounter + (NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)

CharacterPaletteBufferPointer = zeroPageCounter
!set zeroPageCounter = zeroPageCounter + 2

SpritePaletteBuffer = ramCounter
!set ramCounter = ramCounter + (NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)

SpritePaletteBufferPointer = zeroPageCounter
!set zeroPageCounter = zeroPageCounter + 2

;------------------------------------------------------------------
!zone InitializeVideo
InitializeVideo
  lda #%01000000
  sta $4017                   ; disable APU frame IRQ
  
  lda #0
  sta PPU_CONTROL_REG1        ; disable NMI
  sta PPU_CONTROL_REG2        ; disable rendering
  sta PAPU_DMC_CONTROL_REG    ; disable DMC IRQs

  ; Clear flags to update graphics buffers.
  sta UpdateNameTable
  sta UpdateAttributeTable
  
  sta ScreenCharacterBuffer ; Clear buffer (zeroing first entry).
  sta ScreenCharacterBufferIndex

  sta ScreenColorBuffer ; Clear buffer (zeroing first entry).
  sta ScreenColorBufferIndex
  
  lda #<ScreenCharacterBuffer
  sta ScreenCharacterBufferPointer
  lda #>ScreenCharacterBuffer
  sta ScreenCharacterBufferPointer+1

  lda #<ScreenColorBuffer
  sta ScreenColorBufferPointer
  lda #>ScreenColorBuffer
  sta ScreenColorBufferPointer+1

  ; First wait for vblank to make sure PPU is ready
  jsr WaitForVBlank

  ; Second wait for vblank, PPU is ready after this
  jsr WaitForVBlank
  
  jsr InitializePalettes
  jsr InitializeNameTable
  jsr InitializeSprites
  
  lda #%10001000
  sta PPU_CONTROL_REG1
  lda #%00011110
  sta PPU_CONTROL_REG2
  
  rts

;------------------------------------------------------------------
!zone InitializePalettes
InitializePalettes
  
  lda #<CharacterPaletteBuffer
  sta CharacterPaletteBufferPointer
  lda #>CharacterPaletteBuffer
  sta CharacterPaletteBufferPointer+1

  lda #<SpritePaletteBuffer
  sta SpritePaletteBufferPointer
  lda #>SpritePaletteBuffer
  sta SpritePaletteBufferPointer+1
  
  lda #0
  sta UpdatePaletteTable
  tax
  tay
.loadCharacterPalettesLoop:
  lda PALETTE,x
  sta (CharacterPaletteBufferPointer),y
  inx
  iny
  cpy #(NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)
  bne .loadCharacterPalettesLoop
  
  ldy #0
.loadSpritePalettesLoop:
  lda PALETTE,x
  sta (SpritePaletteBufferPointer),y
  inx
  iny
  cpy #(NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)
  bne .loadSpritePalettesLoop
  
  jsr UpdatePaletteTableRoutine
  
  rts
  
;------------------------------------------------------------------
!zone InitializeNameTable
InitializeNameTable
  lda PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  lda #>PPU_NAME_TABLE_0
  sta VRAM_ADDRESS_REG
  lda #<PPU_NAME_TABLE_0
  sta VRAM_ADDRESS_REG
  
  ldy #$00
  ldx #$04
  
;         lda #<SCREEN
;         sta ZEROPAGE_POINTER_1
;         lda #>SCREEN
;         sta ZEROPAGE_POINTER_1+1
  
  lda #0
.nameTableLoop
;         lda (ZEROPAGE_POINTER_1),y
  sta VRAM_IO_REG
  iny
  bne .nameTableLoop
  inc ZEROPAGE_POINTER_1+1
  dex
  bne .nameTableLoop
  
  rts

;------------------------------------------------------------------
!zone InitializeSprites 
InitializeSprites
  lda #$fe
  ldx #$00
.clearSprites
  sta SpriteBuffer,x
  inx
  bne .clearSprites

  ldy #$04  ; reg y = 4, load sprites 1,2,3,4
.loadSprites
  tya
  asl
  asl
  sta PARAM1

  ldx #$00
.loadSpriteAttributesLoop
  lda SPRITES,x
  sta SpriteBuffer,x
  inx
  cpx PARAM1
  bne .loadSpriteAttributesLoop
  
  rts

;------------------------------------------------------------------
!zone SetBorderColor
SetBorderColor
  rts

;------------------------------------------------------------------
!zone SetBackgroundColor
SetBackgroundColor
  
  tax
  lda COLOR_TABLE,x
  ldy #0
  sta (SpritePaletteBufferPointer),y
  
  lda #1
  sta UpdatePaletteTable
  rts

;------------------------------------------------------------------
!zone SetCharacterColors
SetCharacterColors

  sta PARAM1
  sty PARAM2
  
  ldx PARAM1
  lda COLOR_TABLE,x
  ldy #2
.firstColorLoop
  sta (CharacterPaletteBufferPointer),y
  iny
  iny
  iny
  iny
  cpy #(2+4+4+4)
  bcc .firstColorLoop
  
  ldx PARAM2
  lda COLOR_TABLE,x
  ldy #3
.secondColorLoop
  sta (CharacterPaletteBufferPointer),y
  iny
  iny
  iny
  iny
  cpy #(3+4+4+4)
  bcc .secondColorLoop
  
  lda #1
  sta UpdatePaletteTable
  rts

;------------------------------------------------------------------
!zone WaitForVBlank
WaitForVBlank
  bit PPU_STATUS_REG
  bpl WaitForVBlank
  rts

;------------------------------------------------------------------
!zone UpdateVideo
UpdateVideo
  
  ; Update name table.
  lda UpdateNameTable
  beq .endUpdateNameTable
.updateNameTable
  jsr ProcessCharacterDrawBuffer
.endUpdateNameTable
  
  ; Update palette table.
  lda UpdatePaletteTable
  beq .endUpdatePaletteTable
.updatePaletteTable
  jsr UpdatePaletteTableRoutine
.endUpdatePaletteTable
  
  ;This is the PPU clean up section, so rendering the next frame starts properly.
  lda #%10001000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  sta PPU_CONTROL_REG1
  lda #%00011110   ; enable sprites, enable background, no clipping on left side
  sta PPU_CONTROL_REG2
  
  ; Write scroll.
  lda PPU_STATUS_REG
  
  lda #0        ;tell the ppu there is no background scrolling
  sta BG_SCROLL_REG
  sta BG_SCROLL_REG
  
  rts

;------------------------------------------------------------------
!zone UpdateVideoMMC5
UpdateVideoMMC5
  ; Update attribute table.
  lda UpdateAttributeTable
  beq .endUpdateVideoMMC5

.waitForInFrameLoop
  bit MMC5_IRQ_STATUS
  bvc .waitForInFrameLoop
  
  jsr ProcessColorDrawBuffer
  
.endUpdateVideoMMC5
  rts

;------------------------------------------------------------------
!zone UpdateSprites
UpdateSprites  
  lda #<SpriteBuffer
  sta SPR_RAM_ADDRESS_REG
  lda #>SpriteBuffer                  ; set sprite dma to address $200
  sta SPR_RAM_DMA_REG
  
  rts

;------------------------------------------------------------------
!zone ProcessCharacterDrawBuffer
ProcessCharacterDrawBuffer
  ;lda #0
  ;sta PPU_CONTROL_REG2    ; disable rendering

  ; First wait for vblank to make sure PPU is ready
  ;jsr WaitForVBlank   

  lda PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  
  ldy #0
.processCharacterBufferLoop
  lda (ScreenCharacterBufferPointer),y
  beq .processCharacterBufferEnd

  ; Set the byte number counter.
  tax
  iny
  
  ; Get the target address.
  lda (ScreenCharacterBufferPointer),y
  sta VRAM_ADDRESS_REG
  iny
  lda (ScreenCharacterBufferPointer),y
  sta VRAM_ADDRESS_REG
  iny
  
  ; Copy the 'byte number' many next bytes.
.processByteStringLoop
  lda (ScreenCharacterBufferPointer),y
  sta VRAM_IO_REG
  iny
  beq .processCharacterBufferEnd ; Check for overflow on buffer size.
  dex
  bne .processByteStringLoop
  
  jmp .processCharacterBufferLoop
  
.processCharacterBufferEnd
  lda #0
  sta ScreenCharacterBufferIndex
  sta UpdateNameTable
  
  rts
  
;------------------------------------------------------------------
!zone ProcessColorDrawBuffer
ProcessColorDrawBuffer
  ldy #0
.processColorBufferLoop
  lda (ScreenColorBufferPointer),y
  beq .processColorBufferEnd

  ; Set the byte number counter.
  tax
  iny
  
  ; Get the target address.
  lda (ScreenColorBufferPointer),y
  sta ScreenColorTarget+1
  iny
  lda (ScreenColorBufferPointer),y
  sta ScreenColorTarget
  iny
  
  ; Get the color code.
  lda (ScreenColorBufferPointer),y
  iny
  ;beq .processColorBufferEnd ; Check for overflow on buffer size.
  
  ; Backup buffer index.
  sty ScreenColorBufferTemp
  
  ; Color the 'byte number' many next bytes.        
  ldy #0
.processByteStringLoop
  sta (ScreenColorTarget),y
  iny
  dex
  bne .processByteStringLoop
  
  ; Restore buffer index.
  ldy ScreenColorBufferTemp
  
  jmp .processColorBufferLoop
  
.processColorBufferEnd
  lda #0
  sta ScreenColorBufferIndex
  sta UpdateAttributeTable
  
  rts
  
;------------------------------------------------------------------
!zone UpdatePaletteTableRoutine
UpdatePaletteTableRoutine
  lda PPU_STATUS_REG
  lda #>PPU_IMAGE_PALETTE_1
  sta VRAM_ADDRESS_REG
  lda #<PPU_IMAGE_PALETTE_1
  sta VRAM_ADDRESS_REG
  
  ldy #0
.loadCharacterPalettesLoop:
  lda (CharacterPaletteBufferPointer),y
  sta VRAM_IO_REG
  iny
  cpy #(NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)
  bne .loadCharacterPalettesLoop
  
  ldy #0
.loadSpritePalettesLoop:
  lda (SpritePaletteBufferPointer),y
  sta VRAM_IO_REG
  iny
  cpy #(NUMBER_OF_COLORS_PER_PALETTE_ENTRY * NUMBER_OF_ENTRIES_PER_PALETTE)
  bne .loadSpritePalettesLoop
  
  rts
  
;------------------------------------------------------------------
SCREEN_LINE_OFFSET_TABLE_LO
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT - 1 {
    !byte ( PPU_NAME_TABLE_0 + SCREEN_CHAR_WIDTH + ( SCREEN_CHAR_WIDTH * n )  ) & 0x00ff
    !set n=n+1
  }

SCREEN_LINE_OFFSET_TABLE_HI
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT - 1 {
    !byte ( ( PPU_NAME_TABLE_0 + SCREEN_CHAR_WIDTH + ( SCREEN_CHAR_WIDTH * n ) ) & 0xff00 ) >> 8
    !set n=n+1
  }
  
SCREEN_COLOR_LINE_OFFSET_TABLE_LO
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT - 1 {
    !byte ( MMC5_EXRAM + SCREEN_CHAR_WIDTH + ( SCREEN_CHAR_WIDTH * n )  ) & 0x00ff
    !set n=n+1
  }

SCREEN_COLOR_LINE_OFFSET_TABLE_HI
  !set n=0
  !do while n < SCREEN_CHAR_HEIGHT - 1 {
    !byte ( ( MMC5_EXRAM + SCREEN_CHAR_WIDTH + ( SCREEN_CHAR_WIDTH * n ) ) & 0xff00 ) >> 8
    !set n=n+1
  }

;------------------------------------------------------------------
COLOR_TABLE
  !byte COLOR_BLACK_CODE
  !byte COLOR_WHITE_CODE
  !byte COLOR_RED_CODE
  !byte COLOR_CYAN_CODE
  !byte COLOR_PURPLE_CODE
  !byte COLOR_GREEN_CODE
  !byte COLOR_BLUE_CODE
  !byte COLOR_YELLOW_CODE
  !byte COLOR_ORANGE_CODE
  !byte COLOR_BROWN_CODE
  !byte COLOR_PINK_CODE
  !byte COLOR_DARK_GREY_CODE
  !byte COLOR_GREY_CODE
  !byte COLOR_LIGHT_GREEN_CODE
  !byte COLOR_LIGHT_BLUE_CODE
  !byte COLOR_LIGHT_GREY_CODE

;------------------------------------------------------------------
PALETTE_NUMBER_TO_MMC5_TABLE
  !byte %00000000
  !byte %01000000
  !byte %10000000
  !byte %11000000
