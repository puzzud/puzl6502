!set zeroPageCounter = $02
PARAM1 = zeroPageCounter
PARAM2 = zeroPageCounter+1
PARAM3 = zeroPageCounter+2
PARAM4 = zeroPageCounter+3
PARAM5 = zeroPageCounter+4
!set zeroPageCounter = zeroPageCounter+5

;placeholder for zero page pointers
ZEROPAGE_POINTER_1 = zeroPageCounter
ZEROPAGE_POINTER_2 = zeroPageCounter+2
ZEROPAGE_POINTER_3 = zeroPageCounter+4
ZEROPAGE_POINTER_4 = zeroPageCounter+6
!set zeroPageCounter = zeroPageCounter+8

FrameCounter                = zeroPageCounter
FrameCounterMod8            = zeroPageCounter+1
FrameCounterMod8CounterMod3 = zeroPageCounter+2
!set zeroPageCounter = zeroPageCounter+3

COLOR_BLACK                  = 0
COLOR_WHITE                  = 1
COLOR_RED                    = 2
COLOR_CYAN                   = 3
COLOR_PURPLE                 = 4
COLOR_GREEN                  = 5
COLOR_BLUE                   = 6
COLOR_YELLOW                 = 7
COLOR_ORANGE                 = 8
COLOR_BROWN                  = 9
COLOR_PINK                   = 10
COLOR_DARK_GREY              = 11
COLOR_GREY                   = 12
COLOR_LIGHT_GREEN            = 13
COLOR_LIGHT_BLUE             = 14
COLOR_LIGHT_GREY             = 15

NUMBER_OF_JOYSTICKS        = 2
JOYSTICK_DATA_BASE_ADDRESS = zeroPageCounter
joystickButtons            = JOYSTICK_DATA_BASE_ADDRESS
joystickOldButtons         = joystickButtons        + (1*NUMBER_OF_JOYSTICKS)
joystickPressedButtons     = joystickOldButtons     + (1*NUMBER_OF_JOYSTICKS)
JOSTICK_DATA_END_ADDRESS   = joystickPressedButtons + (1*NUMBER_OF_JOYSTICKS)
!set zeroPageCounter = zeroPageCounter+(NUMBER_OF_JOYSTICKS*3)

SPRITE_TYPE_JOYSTICK = 0
SPRITE_TYPE_KEYBOARD = 1
SPRITE_TYPE_MOUSE    = 2
SPRITE_TYPE_NETWORK  = 3
SPRITE_TYPE_COMPUTER = $ff

NUMBER_OF_SPRITES        = 8;NUMBER_OF_HARDWARE_SPRITES
SpriteDataBaseAddress = zeroPageCounter
SpriteType                = SpriteDataBaseAddress
SpriteControllerId        = SpriteType                + (1*NUMBER_OF_SPRITES)
SpriteXPosition           = SpriteControllerId        + (1*NUMBER_OF_SPRITES)
SpriteYPosition           = SpriteXPosition           + (2*NUMBER_OF_SPRITES)
SpriteXVelocity           = SpriteYPosition           + (2*NUMBER_OF_SPRITES)
SpriteYVelocity           = SpriteXVelocity           + (1*NUMBER_OF_SPRITES)
SpriteXAcceleration       = SpriteYVelocity           + (1*NUMBER_OF_SPRITES)
SpriteYAcceleration       = SpriteXAcceleration       + (1*NUMBER_OF_SPRITES)
SpriteTileXPosition       = SpriteYAcceleration       + (1*NUMBER_OF_SPRITES)
SpriteTileYPosition       = SpriteTileXPosition       + (1*NUMBER_OF_SPRITES)
SpriteState               = SpriteTileYPosition       + (1*NUMBER_OF_SPRITES)
SpriteFrameIndex          = SpriteState               + (1*NUMBER_OF_SPRITES)
SpriteAnimationCounter    = SpriteFrameIndex          + (1*NUMBER_OF_SPRITES)
SpriteAnimationDelay      = SpriteAnimationCounter    + (1*NUMBER_OF_SPRITES)
SpriteAnimationFrameIndex = SpriteAnimationDelay      + (1*NUMBER_OF_SPRITES)
SpriteAnimation           = SpriteAnimationFrameIndex + (1*NUMBER_OF_SPRITES)
SpriteAnimationPointer    = SpriteAnimation           + (1*NUMBER_OF_SPRITES)
SpriteDataEndAddress      = SpriteAnimationPointer    + (2*NUMBER_OF_SPRITES) - 1
!set zeroPageCounter = zeroPageCounter+(NUMBER_OF_SPRITES*20);+1+1

; NOTE: It is necessary for each system based GameShell to set this counter's base.
; $200 is just conveniently past the zero page and the stack.
!set ramCounter = $200

!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/core/c64/GameShell.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/core/nes/GameShell.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/core/apple/GameShell.asm"
}

;------------------------------------------------------------------
!zone IncrementFrameCounter
IncrementFrameCounter
  inc FrameCounter
  inc FrameCounterMod8
  lda FrameCounterMod8
  cmp #8
  bne .endFrameCounterIncrement
  lda #0
  sta FrameCounterMod8
  inc FrameCounterMod8CounterMod3
  lda FrameCounterMod8CounterMod3
  cmp #3
  bne .endFrameCounterIncrement
  lda #0
  sta FrameCounterMod8CounterMod3
.endFrameCounterIncrement
  rts

;------------------------------------------------------------------
!zone MainInitialize
MainInitialize
  jsr InitializeInput
  jsr InitializeVideo
  jsr InitializeAudio
  
  rts

;------------------------------------------------------------------
  !src "puzl/input/InputSystem.asm"
  !src "puzl/video/VideoSystem.asm"
  !src "puzl/audio/AudioSystem.asm"

;------------------------------------------------------------------
  !src "puzl/utility/Float.asm"
  !src "puzl/utility/String.asm"
  !src "puzl/utility/IO.asm"
  !src "puzl/utility/Math.asm"

;------------------------------------------------------------------
BitTable
  !byte %00000001
  !byte %00000010
  !byte %00000100
  !byte %00001000
  !byte %00010000
  !byte %00100000
  !byte %01000000
  !byte %10000000

InverseBitTable
  !byte %11111110
  !byte %11111101
  !byte %11111011
  !byte %11110111
  !byte %11101111
  !byte %11011111
  !byte %10111111
  !byte %01111111
