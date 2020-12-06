; GameShell.asm
; NES

  !src "puzl/core/nes/nes.asm"
  
NMIStatus = $01

!set ramCounter = START_OF_RAM

; Move these defines to a VideoSystem.inc file.
UpdateNameTable      = zeroPageCounter
UpdateAttributeTable = zeroPageCounter+1
UpdatePaletteTable   = zeroPageCounter+2
!set zeroPageCounter = zeroPageCounter+3

;==================================================================
*=$fffa
!zone InitVectors
InitVectors
  !word MNIRoutine
  !word Reset
  !word IRQRoutine

;==================================================================
*=(InitVectors-100);TODO: Determine minus value (block size).
!zone Reset
Reset
  sei          ; disable IRQs
  cld          ; disable decimal mode
  
  lda #0
.clearMemory
  sta $00,x     ;7
  sta $0100,x   ;28
  sta $0200,x
  sta $0300,x
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx           ;5
  bne .clearMemory
  
  dex          ; ldx #$ff
  txs          ; Set up stack

  ; Set up MMC5 Rom banks and such.
  lda #$00      ;37
  sta MMC5_PRG_MODE
  sta MMC5_CHR_MODE
  
  lda #$01
  sta MMC5_EXRAM_MODE
  
  lda #%00000000
  sta MMC5_NTABLE_MAP
  
  lda #$01
  sta MMC5_BKGRD_CHR_BANK_3
  
  lda #$01
  sta MMC5_SPR_CHR_BANK_7
  
  lda #$00
  sta MMC5_VERT_SPLIT_MODE
  sta MMC5_IRQ_STATUS

  jmp MainStart

;==================================================================
*=$7ff0
  ; iNES header.
  !raw "NES"                  ;"NES"
  !byte $1a                   ;$1a
  !byte 2                     ;2 x 16KB PRG-ROM
  !byte 1                     ;1 X  8KB CHR-ROM
  !byte $50;((5<<4)|(2))      ;ROM control 1
  !byte 0                     ;ROM control 2
  !byte $00
  !byte $00
  !byte $00
  !byte $00
  !byte $00
  !byte $00
  !byte $00
  !byte $00

;==================================================================
*=$8000
!zone MainStart
MainStart
jsr MainInitialize
  jsr GameInitialize

.mainLoop
  lda #0            ;
  sta NMIStatus     ; Wait for next NMI to end.
.waitNMIEnd
  lda NMIStatus     ;
  beq .waitNMIEnd   ; If nonzero, NMI has ended. Else keep waiting.
  
  jsr UpdateInput
  jsr IncrementFrameCounter
  jsr GameLoop
  
  jsr UpdateVideoMMC5
  
  jmp .mainLoop

;------------------------------------------------------------------
!zone MNIRoutine
MNIRoutine
  php
  pha
  txa
  pha
  tya
  pha
  
  jsr UpdateSprites
  jsr UpdateVideo
  
.NMIFinished
  lda #1
  sta NMIStatus
  
  pla
  tay
  pla
  tax
  pla
  plp
  
  rti
  
;------------------------------------------------------------------
!zone IRQRoutine
IRQRoutine
  rti
