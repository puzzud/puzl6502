;
; C64 generic definitions. Stolen from Elite128
;


; ---------------------------------------------------------------------------
; Zero page, Commodore stuff

ST              = $90   ; IEC status byte

TIME            = $A0          ; 60 HZ clock
FNAM_LEN        = $B7   ; Length of filename
SECADR          = $B9   ; Secondary address
DEVNUM          = $BA   ; Device number
FNAM            = $BB          ; Pointer to filename
KEY_COUNT       = $C6   ; Number of keys in input buffer
RVS             = $C7          ; Reverse flag
CURS_FLAG       = $CC   ; 1 = cursor off
CURS_BLINK      = $CD   ; Blink counter
CURS_CHAR       = $CE   ; Character under the cursor
CURS_STATE      = $CF   ; Cursor blink state
SCREEN_PTR      = $D1   ; Pointer to current char in text screen
CURS_X          = $D3   ; Cursor column
CURS_Y          = $D6   ; Cursor row
CRAM_PTR        = $F3   ; Pointer to current char in color RAM

BASIC_BUF       = $200    ; Location of command-line
BASIC_BUF_LEN = 89    ; Maximum length of command-line

CHARCOLOR       = $286
CURS_COLOR      = $287    ; Color under the cursor
PALFLAG         = $2A6    ; $01 = PAL, $00 = NTSC


; ---------------------------------------------------------------------------
; Kernal routines

; Direct entries
CLRSCR          = $E544
KBDREAD         = $E5B4
NMIEXIT         = $FEBC

; ---------------------------------------------------------------------------
; Vector and other locations

IRQVec          = $0314
BRKVec          = $0316
NMIVec          = $0318

; ---------------------------------------------------------------------------
; Screen size

XSIZE           = 40
YSIZE           = 25

; ---------------------------------------------------------------------------
; I/O: VIC

VIC             = $D000
VIC_SPR0_X      = $D000
VIC_SPR0_Y      = $D001
VIC_SPR1_X      = $D002
VIC_SPR1_Y      = $D003
VIC_SPR2_X      = $D004
VIC_SPR2_Y      = $D005
VIC_SPR3_X      = $D006
VIC_SPR3_Y      = $D007
VIC_SPR4_X      = $D008
VIC_SPR4_Y      = $D009
VIC_SPR5_X      = $D00A
VIC_SPR5_Y      = $D00B
VIC_SPR6_X      = $D00C
VIC_SPR6_Y      = $D00D
VIC_SPR7_X      = $D00E
VIC_SPR7_Y      = $D00F
VIC_SPR_HI_X    = $D010
VIC_SPR_ENA     = $D015
VIC_SPR_EXP_Y   = $D017
VIC_SPR_EXP_X   = $D01D
VIC_SPR_MCOLOR  = $D01C
VIC_SPR_BG_PRIO = $D01B

VIC_SPR_SP_COL  = $D01E
VIC_SPR_BG_COL  = $D01F

VIC_SPR_MCOLOR0 = $D025
VIC_SPR_MCOLOR1 = $D026

VIC_SPR0_COLOR  = $D027
VIC_SPR1_COLOR  = $D028
VIC_SPR2_COLOR  = $D029
VIC_SPR3_COLOR  = $D02A
VIC_SPR4_COLOR  = $D02B
VIC_SPR5_COLOR  = $D02C
VIC_SPR6_COLOR  = $D02D
VIC_SPR7_COLOR  = $D02E

SPR_X_SCREEN_LEFT = 24
SPR_Y_SCREEN_TOP  = 50

VIC_CTRL1       = $D011
VIC_CTRL2       = $D016

VIC_HLINE       = $D012

VIC_VIDEO_ADR   = $D018

VIC_IRR         = $D019        ; Interrupt request register
VIC_IMR         = $D01A ; Interrupt mask register

VIC_BORDERCOLOR = $D020
VIC_BG_COLOR0   = $D021
VIC_BG_COLOR1   = $D022
VIC_BG_COLOR2   = $D023
VIC_BG_COLOR3   = $D024

; 128 stuff:
VIC_KBD_128     = $D02F        ; Extended kbd bits (visible in 64 mode)
VIC_CLK_128     = $D030 ; Clock rate register (visible in 64 mode)


; ---------------------------------------------------------------------------
; I/O: SID

SID             = $D400
SID_S1Lo        = $D400
SID_S1Hi        = $D401
SID_PB1Lo       = $D402
SID_PB1Hi       = $D403
SID_Ctl1        = $D404
SID_AD1         = $D405
SID_SUR1        = $D406

SID_S2Lo        = $D407
SID_S2Hi        = $D408
SID_PB2Lo       = $D409
SID_PB2Hi       = $D40A
SID_Ctl2        = $D40B
SID_AD2         = $D40C
SID_SUR2        = $D40D

SID_S3Lo        = $D40E
SID_S3Hi        = $D40F
SID_PB3Lo       = $D410
SID_PB3Hi       = $D411
SID_Ctl3        = $D412
SID_AD3         = $D413
SID_SUR3        = $D414

SID_FltLo       = $D415
SID_FltHi       = $D416
SID_FltCtl      = $D417
SID_Amp         = $D418
SID_ADConv1     = $D419
SID_ADConv2     = $D41A
SID_Noise       = $D41B
SID_Read3       = $D41C

; ---------------------------------------------------------------------------
; I/O: VDC (128 only)

VDC_INDEX       = $D600
VDC_DATA        = $D601

; ---------------------------------------------------------------------------
; I/O: CIAs

CIA1            = $DC00
CIA1_PRA        = $DC00
CIA1_PRB        = $DC01
CIA1_DDRA       = $DC02
CIA1_DDRB       = $DC03
CIA1_TOD10      = $DC08
CIA1_TODSEC     = $DC09
CIA1_TODMIN     = $DC0A
CIA1_TODHR      = $DC0B
CIA1_ICR        = $DC0D
CIA1_CRA        = $DC0E
CIA1_CRB        = $DC0F

CIA2            = $DD00
CIA2_PRA        = $DD00
CIA2_PRB        = $DD01
CIA2_DDRA       = $DD02
CIA2_DDRB       = $DD03
CIA2_TOD10      = $DD08
CIA2_TODSEC     = $DD09
CIA2_TODMIN     = $DD0A
CIA2_TODHR      = $DD0B
CIA2_ICR        = $DD0D
CIA2_CRA        = $DD0E
CIA2_CRB        = $DD0F

; ---------------------------------------------------------------------------
; Super CPU

SCPU_VIC_Bank1  = $D075
SCPU_Slow       = $D07A
SCPU_Fast       = $D07B
SCPU_EnableRegs = $D07E
SCPU_DisableRegs= $D07F
SCPU_Detect     = $D0BC


; ---------------------------------------------------------------------------
; Processor Port at $01

LORAM   = $01     ; Enable the basic rom
HIRAM   = $02     ; Enable the kernal rom
IOEN    = $04     ; Enable I/O
CASSDATA  = $08     ; Cassette data
CASSPLAY  = $10     ; Cassette: Play
CASSMOT   = $20     ; Cassette motor on
TP_FAST   = $80     ; Switch Rossmoeller TurboProcess to fast mode

RAMONLY   = $F8     ; (~(LORAM | HIRAM | IOEN)) & $FF


; -----------
; Color codes

!set COLOR_BLACK                  = 0
!set COLOR_WHITE                  = 1
!set COLOR_RED                    = 2
!set COLOR_CYAN                   = 3
!set COLOR_PURPLE                 = 4
!set COLOR_GREEN                  = 5
!set COLOR_BLUE                   = 6
!set COLOR_YELLOW                 = 7
!set COLOR_ORANGE                 = 8
!set COLOR_BROWN                  = 9
!set COLOR_PINK                   = 10
!set COLOR_DARK_GREY              = 11
!set COLOR_GREY                   = 12
!set COLOR_LIGHT_GREEN            = 13
!set COLOR_LIGHT_BLUE             = 14
!set COLOR_LIGHT_GREY             = 15

; ---------------------------------------------------------------------------
; Additional defines (not stolen from Elite128).

;address of the screen buffer
SCREEN_CHAR                  = $cc00
SCREEN_CHAR_SIZE             = $400

;address of color ram
SCREEN_COLOR                 = $d800

SPRITE_GRAPHICS_TARGET       = $d000
CHARACTER_GRAPHICS_TARGET    = $f000
  
NUMBER_OF_HARDWARE_SPRITES   = 8

;address of sprite pointers
SPRITE_POINTER_BASE          = SCREEN_CHAR + SCREEN_CHAR_SIZE - NUMBER_OF_HARDWARE_SPRITES

SCREEN_CHAR_WIDTH            = 40
SCREEN_CHAR_HEIGHT           = 25

SCREEN_BORDER_THICKNESS_X    = 24
SCREEN_BORDER_THICKNESS_Y    = 50

;sprite number constants
SPRITE_BASE                  = 64