!if SYSTEM = SYSTEM_COMMODORE_64 {
  !src "puzl/audio/c64/AudioSystem.asm"
}
!if SYSTEM = SYSTEM_NES {
  !src "puzl/audio/nes/AudioSystem.asm"
}
!if SYSTEM = SYSTEM_APPLE_II {
  !src "puzl/audio/apple/AudioSystem.asm"
}

  !src "puzl/audio/AudioMusic.asm"
