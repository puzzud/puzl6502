!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/video/c64/VideoSystem.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/video/nes/VideoSystem.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/video/apple/VideoSystem.asm"
}

;------------------------------------------------------------------
  !src "puzl/video/VideoPrint.asm"
  !src "puzl/video/VideoBlock.asm"
  !src "puzl/video/VideoSprite.asm"
